<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import EmptyState from '@/components/EmptyState.vue'
import MerchantReceiptPanel from '@/components/MerchantReceiptPanel.vue'
import { commonApi, userApi } from '@/lib/api'
import { getRoleState } from '@/lib/domain'
import { consumeAfterSalePrefill, formatAddress, getDefaultAddress, loadAddressList } from '@/lib/localData'
import { pushNotice } from '@/lib/notice'
import { session } from '@/lib/session'

const router = useRouter()

const productHints = ['手机', '平板', '笔记本电脑', '显示器', '路由器', '电池配件']
const saving = ref(false)
const uploading = ref(false)
const addressList = ref([])
const selectedAddressId = ref('')
const imageInput = ref(null)
const imageList = ref([])

const form = reactive({
  productName: '',
  productModel: '',
  faultDesc: '',
  contactName: '',
  contactPhone: '',
  address: ''
})

const roleState = computed(() => getRoleState(session.roleType))

function syncAddressList() {
  addressList.value = loadAddressList()
}

function applyAddress(address) {
  if (!address) {
    return
  }
  selectedAddressId.value = address.id
  form.contactName = address.name || form.contactName
  form.contactPhone = address.phone || form.contactPhone
  form.address = formatAddress(address) || form.address
}

function applyDefaultAddress() {
  const defaultAddress = getDefaultAddress()
  if (defaultAddress) {
    applyAddress(defaultAddress)
  }
}

function consumePrefill() {
  const prefill = consumeAfterSalePrefill()
  if (!prefill) {
    return
  }

  form.productName = prefill.productName || form.productName
  form.productModel = prefill.productModel || form.productModel
  form.contactName = prefill.name || form.contactName
  form.contactPhone = prefill.phone || form.contactPhone
  form.address = prefill.receiverAddress || form.address
}

function fillHint(name) {
  form.productName = name
}

function openImagePicker() {
  imageInput.value?.click()
}

function handleImageChange(event) {
  const files = Array.from(event.target.files || [])
  if (!files.length) {
    return
  }

  const remainCount = 3 - imageList.value.length
  const selectedFiles = files.slice(0, remainCount).map(file => ({
    id: `${Date.now()}_${Math.random().toString(16).slice(2, 8)}`,
    file,
    preview: URL.createObjectURL(file)
  }))
  imageList.value = imageList.value.concat(selectedFiles).slice(0, 3)
  event.target.value = ''
}

function removeImage(id) {
  const target = imageList.value.find(item => item.id === id)
  if (target?.preview) {
    URL.revokeObjectURL(target.preview)
  }
  imageList.value = imageList.value.filter(item => item.id !== id)
}

async function uploadImages() {
  if (!imageList.value.length) {
    return []
  }

  uploading.value = true
  try {
    const uploadResults = await Promise.all(imageList.value.map(item => commonApi.uploadFile(item.file)))
    return uploadResults
      .map(item => item?.url)
      .filter(url => typeof url === 'string' && url.trim())
  } finally {
    uploading.value = false
  }
}

function validateForm() {
  if (!session.token) {
    pushNotice('请先登录普通用户账号', 'danger')
    return false
  }
  if (!roleState.value.isUser || roleState.value.isMerchant) {
    pushNotice('当前账号不能提交售后申请', 'danger')
    return false
  }
  if (!form.productName.trim()) {
    pushNotice('请填写产品名称', 'danger')
    return false
  }
  if (!form.productModel.trim()) {
    pushNotice('请填写产品型号', 'danger')
    return false
  }
  if (!form.faultDesc.trim()) {
    pushNotice('请描述故障现象', 'danger')
    return false
  }
  if (!form.contactName.trim()) {
    pushNotice('请填写联系人', 'danger')
    return false
  }
  if (!/^1\d{10}$/.test(form.contactPhone)) {
    pushNotice('请输入正确的联系电话', 'danger')
    return false
  }
  if (!form.address.trim()) {
    pushNotice('请填写服务地址', 'danger')
    return false
  }
  return true
}

async function submitForm() {
  if (!validateForm()) {
    return
  }

  saving.value = true
  try {
    const imageUrls = await uploadImages()
    await userApi.createAfterSalesOrder({
      productType: `${form.productName.trim()} / ${form.productModel.trim()}`,
      faultDesc: form.faultDesc.trim(),
      faultImages: imageUrls.join(','),
      contactName: form.contactName.trim(),
      contactPhone: form.contactPhone.trim(),
      address: form.address.trim()
    })
    pushNotice('售后申请已提交，等待商家接单', 'success')
    router.push({ name: 'after-sales-orders' })
  } catch (error) {
    pushNotice(error.message || '售后申请提交失败', 'danger')
  } finally {
    saving.value = false
  }
}

onMounted(() => {
  syncAddressList()
  form.contactName = session.appUser?.nickName || ''
  form.contactPhone = session.appUser?.phone || ''
  applyDefaultAddress()
  consumePrefill()
})
</script>

<template>
  <section class="page-shell after-sale-apply-page">
    <EmptyState
      v-if="!session.token"
      title="提交售后前需要登录"
      description="售后申请会绑定当前登录账号，请先登录后继续。"
      action-label="前往登录"
      @action="router.push({ name: 'auth' })"
    />

    <MerchantReceiptPanel v-else-if="roleState.isMerchant" />

    <template v-else>
      <section class="glass-card apply-hero">
        <div>
          <span class="eyebrow">售后申请</span>
          <h1>提交设备报修与售后需求</h1>
          <p>补充产品、故障、地址和图片信息后，商家可更快判断处理方式并更新进度。</p>
        </div>

        <div class="surface-card apply-side-card">
          <strong>处理流程</strong>
          <span>待接单</span>
          <span>已接单</span>
          <span>维修中</span>
          <span>已完成 / 已取消</span>
        </div>
      </section>

      <section class="apply-grid">
        <section class="surface-card section-card">
          <div class="section-head">
            <div>
              <span class="eyebrow">填写信息</span>
              <h2>售后申请表</h2>
              <p>与小程序一致，产品名称与型号分开填写，最终会自动合并成后端所需字段。</p>
            </div>
          </div>

          <form class="apply-form" @submit.prevent="submitForm">
            <div class="field-row">
              <label>
                <span>产品名称</span>
                <input v-model.trim="form.productName" class="field" placeholder="例如 手机、显示器、路由器" />
              </label>
              <label>
                <span>产品型号</span>
                <input v-model.trim="form.productModel" class="field" placeholder="例如 Mate 60、ThinkPad X1" />
              </label>
            </div>

            <div class="chip-row">
              <button v-for="item in productHints" :key="item" type="button" class="chip" @click="fillHint(item)">
                {{ item }}
              </button>
            </div>

            <label>
              <span>故障描述</span>
              <textarea
                v-model.trim="form.faultDesc"
                class="textarea"
                placeholder="尽量描述故障表现、出现时间、是否进水/摔落、是否已自行拆机等"
              ></textarea>
            </label>

            <label>
              <span>故障图片</span>
              <div class="image-panel">
                <article v-for="item in imageList" :key="item.id" class="image-card">
                  <img :src="item.preview" alt="故障图片" />
                  <button type="button" class="image-card__remove" @click="removeImage(item.id)">删除</button>
                </article>
                <button v-if="imageList.length < 3" type="button" class="image-picker" @click="openImagePicker">
                  上传图片
                </button>
              </div>
              <input ref="imageInput" class="file-input" type="file" accept="image/*" multiple @change="handleImageChange" />
            </label>

            <div class="field-row">
              <label>
                <span>联系人</span>
                <input v-model.trim="form.contactName" class="field" placeholder="服务联系人" />
              </label>
              <label>
                <span>联系电话</span>
                <input v-model.trim="form.contactPhone" class="field" placeholder="11 位手机号" />
              </label>
            </div>

            <label>
              <span>已保存地址</span>
              <div class="field-row">
                <select class="field" :value="selectedAddressId" @change="applyAddress(addressList.find(item => item.id === $event.target.value))">
                  <option value="">请选择地址</option>
                  <option v-for="item in addressList" :key="item.id" :value="item.id">
                    {{ item.name }} / {{ item.phone }} / {{ item.region }} {{ item.detail }}
                  </option>
                </select>
                <RouterLink class="btn btn--ghost btn--small" :to="{ name: 'addresses' }">管理地址</RouterLink>
              </div>
            </label>

            <label>
              <span>服务地址</span>
              <input v-model.trim="form.address" class="field" placeholder="上门地址或设备送修地址" />
            </label>

            <div class="between-row apply-form__footer">
              <p>提交后可在“售后工单”页跟踪接单、维修与回执状态。</p>
              <button class="btn btn--primary" :disabled="saving || uploading">
                {{ saving ? '提交中...' : uploading ? '上传图片中...' : '提交售后申请' }}
              </button>
            </div>
          </form>
        </section>

        <section class="surface-card section-card">
          <div class="section-head">
            <div>
              <span class="eyebrow">常用入口</span>
              <h2>相关入口</h2>
              <p>申请前后常用的几个操作集中在这里。</p>
            </div>
          </div>

          <div class="apply-side-links">
            <RouterLink class="apply-link-card" :to="{ name: 'after-sales-orders' }">
              <strong>查看我的售后单</strong>
              <span>提交后在这里跟踪接单、维修和完成状态。</span>
            </RouterLink>
            <RouterLink class="apply-link-card" :to="{ name: 'merchants' }">
              <strong>浏览服务商家</strong>
              <span>先查看门店服务范围，再决定是否发起申请。</span>
            </RouterLink>
            <RouterLink class="apply-link-card" :to="{ name: 'mall' }">
              <strong>进入配件商城</strong>
              <span>如果只是更换配件，也可以先购买商品再申请售后。</span>
            </RouterLink>
          </div>
        </section>
      </section>
    </template>
  </section>
</template>

<style scoped>
.after-sale-apply-page {
  display: grid;
  gap: 24px;
}

.apply-hero {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 260px;
  gap: 22px;
  padding: 28px;
}

.apply-hero h1 {
  margin: 16px 0 10px;
  font-size: clamp(32px, 4.2vw, 52px);
  line-height: 1.08;
}

.apply-side-card {
  display: grid;
  gap: 12px;
  padding: 22px;
  align-content: start;
}

.apply-side-card strong {
  font-size: 18px;
  color: var(--primary-deep);
}

.apply-side-card span {
  display: inline-flex;
  align-items: center;
  min-height: 44px;
  padding: 0 16px;
  border-radius: 999px;
  background: rgba(14, 116, 144, 0.08);
  color: var(--primary-deep);
  font-weight: 700;
}

.apply-grid {
  display: grid;
  grid-template-columns: minmax(0, 1.15fr) minmax(300px, 0.85fr);
  gap: 24px;
}

.apply-form {
  display: grid;
  gap: 16px;
}

.apply-form label {
  display: grid;
  gap: 8px;
  min-width: 0;
}

.apply-form span {
  font-size: 14px;
  font-weight: 700;
  color: var(--primary-deep);
}

.image-panel {
  display: flex;
  flex-wrap: wrap;
  gap: 14px;
}

.image-card,
.image-picker {
  width: 124px;
  height: 124px;
  border-radius: 20px;
}

.image-card {
  position: relative;
  overflow: hidden;
}

.image-card img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.image-card__remove {
  position: absolute;
  right: 8px;
  bottom: 8px;
  min-height: 34px;
  padding: 0 10px;
  border-radius: 999px;
  background: rgba(17, 61, 77, 0.78);
  color: #fff;
}

.image-picker {
  border: 1px dashed rgba(24, 48, 43, 0.18);
  background: rgba(255, 255, 255, 0.78);
  color: var(--muted);
  font-weight: 700;
}

.file-input {
  display: none;
}

.apply-form__footer p {
  max-width: 520px;
}

.apply-side-links {
  display: grid;
  gap: 14px;
}

.apply-link-card {
  display: block;
  padding: 18px;
  border-radius: 22px;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.94), rgba(248, 244, 236, 0.94));
  border: 1px solid rgba(17, 61, 77, 0.08);
}

.apply-link-card strong {
  display: block;
  margin-bottom: 8px;
}

@media (max-width: 980px) {
  .apply-hero,
  .apply-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 720px) {
  .apply-hero,
  .field-row,
  .apply-form__footer {
    display: grid;
  }

  .apply-hero {
    padding: 18px;
  }
}
</style>
