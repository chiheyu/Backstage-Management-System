<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="80px">
      <el-form-item label="商家名称" prop="merchantName">
        <el-input v-model="queryParams.merchantName" placeholder="请输入商家名称" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="联系电话" prop="contactPhone">
        <el-input v-model="queryParams.contactPhone" placeholder="请输入联系电话" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="审核状态" prop="auditStatus">
        <el-select v-model="queryParams.auditStatus" placeholder="请选择审核状态" clearable>
          <el-option v-for="item in auditStatusOptions" :key="item.value" :label="item.label" :value="item.value" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="merchantList">
      <el-table-column label="商家编号" align="center" prop="merchantId" width="100" />
      <el-table-column label="商家名称" align="center" prop="merchantName" :show-overflow-tooltip="true" />
      <el-table-column label="登录账号" align="center" prop="userName" />
      <el-table-column label="联系人" align="center" prop="contactName" />
      <el-table-column label="联系电话" align="center" prop="contactPhone" width="120" />
      <el-table-column label="服务范围" align="center" prop="serviceScope" :show-overflow-tooltip="true" />
      <el-table-column label="地址" align="center" prop="address" :show-overflow-tooltip="true" />
      <el-table-column label="审核状态" align="center" prop="auditStatus" width="120">
        <template slot-scope="scope">
          <el-tag :type="auditStatusType(scope.row.auditStatus)">{{ auditStatusLabel(scope.row.auditStatus) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="260" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button size="mini" type="text" icon="el-icon-view" @click="handleDetail(scope.row)" v-hasPermi="['app:merchant:query']">详情</el-button>
          <el-button size="mini" type="text" icon="el-icon-edit" @click="handleUpdate(scope.row)" v-hasPermi="['app:merchant:edit']">编辑</el-button>
          <el-button size="mini" type="text" icon="el-icon-circle-check" @click="openAudit(scope.row)" v-hasPermi="['app:merchant:audit']">审核</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination
      v-show="total > 0"
      :total="total"
      :page.sync="queryParams.pageNum"
      :limit.sync="queryParams.pageSize"
      @pagination="getList"
    />

    <el-dialog :title="title" :visible.sync="open" width="720px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="100px">
        <el-row>
          <el-col :span="12">
            <el-form-item label="商家名称" prop="merchantName">
              <el-input v-model="form.merchantName" placeholder="请输入商家名称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="联系人" prop="contactName">
              <el-input v-model="form.contactName" placeholder="请输入联系人" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="联系电话" prop="contactPhone">
              <el-input v-model="form.contactPhone" placeholder="请输入联系电话" maxlength="11" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="所在城市" prop="cityName">
              <el-input v-model="form.cityName" placeholder="请输入所在城市" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="商家地址" prop="address">
              <el-input v-model="form.address" placeholder="请输入商家地址" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="服务范围" prop="serviceScope">
              <el-input v-model="form.serviceScope" type="textarea" :rows="2" placeholder="请输入服务范围" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="商家简介" prop="merchantDesc">
              <el-input v-model="form.merchantDesc" type="textarea" :rows="3" placeholder="请输入商家简介" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>

    <el-dialog title="审核商家" :visible.sync="auditOpen" width="520px" append-to-body>
      <el-form ref="auditForm" :model="auditForm" label-width="90px">
        <el-form-item label="商家名称">
          <el-input v-model="auditForm.merchantName" disabled />
        </el-form-item>
        <el-form-item label="审核状态">
          <el-radio-group v-model="auditForm.auditStatus">
            <el-radio label="1">审核通过</el-radio>
            <el-radio label="0">待审核</el-radio>
            <el-radio label="2">禁用商家</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="审核备注">
          <el-input v-model="auditForm.auditRemark" type="textarea" :rows="3" placeholder="请输入审核备注" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitAudit">确 定</el-button>
        <el-button @click="auditOpen = false">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { auditMerchant, getMerchant, listMerchant, updateMerchant } from '@/api/app/merchant'

export default {
  name: 'AppMerchant',
  data() {
    return {
      loading: false,
      showSearch: true,
      total: 0,
      merchantList: [],
      open: false,
      auditOpen: false,
      title: '',
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        merchantName: undefined,
        contactPhone: undefined,
        auditStatus: undefined
      },
      form: {},
      auditForm: {
        merchantId: undefined,
        merchantName: undefined,
        auditStatus: '1',
        auditRemark: undefined
      },
      auditStatusOptions: [
        { label: '待审核', value: '0' },
        { label: '正常', value: '1' },
        { label: '禁用', value: '2' }
      ],
      rules: {
        merchantName: [{ required: true, message: '商家名称不能为空', trigger: 'blur' }],
        contactName: [{ required: true, message: '联系人不能为空', trigger: 'blur' }],
        contactPhone: [{ required: true, message: '联系电话不能为空', trigger: 'blur' }]
      }
    }
  },
  created() {
    this.getList()
  },
  methods: {
    // 查询商家列表。
    getList() {
      this.loading = true
      listMerchant(this.queryParams).then(response => {
        this.merchantList = response.rows
        this.total = response.total
        this.loading = false
      }).catch(() => {
        this.loading = false
      })
    },
    // 审核状态文案。
    auditStatusLabel(status) {
      return (this.auditStatusOptions.find(item => item.value === status) || {}).label || '未知'
    },
    // 审核状态标签类型。
    auditStatusType(status) {
      if (status === '1') {
        return 'success'
      }
      if (status === '2') {
        return 'danger'
      }
      return 'warning'
    },
    // 表单重置。
    reset() {
      this.form = {
        merchantId: undefined,
        merchantName: undefined,
        contactName: undefined,
        contactPhone: undefined,
        address: undefined,
        serviceScope: undefined,
        merchantDesc: undefined,
        cityName: '汉中市'
      }
      this.resetForm('form')
    },
    // 查询重置。
    resetQuery() {
      this.resetForm('queryForm')
      this.handleQuery()
    },
    // 搜索。
    handleQuery() {
      this.queryParams.pageNum = 1
      this.getList()
    },
    // 查看详情。
    handleDetail(row) {
      this.reset()
      getMerchant(row.merchantId).then(response => {
        this.form = response.data
        this.title = '商家详情'
        this.open = true
      })
    },
    // 打开编辑。
    handleUpdate(row) {
      this.reset()
      getMerchant(row.merchantId).then(response => {
        this.form = response.data
        this.title = '编辑商家'
        this.open = true
      })
    },
    // 打开审核弹窗。
    openAudit(row) {
      this.auditForm = {
        merchantId: row.merchantId,
        merchantName: row.merchantName,
        auditStatus: row.auditStatus,
        auditRemark: ''
      }
      this.auditOpen = true
    },
    // 取消编辑。
    cancel() {
      this.open = false
      this.reset()
    },
    // 提交编辑。
    submitForm() {
      this.$refs.form.validate(valid => {
        if (!valid) {
          return
        }
        updateMerchant(this.form).then(() => {
          this.$modal.msgSuccess('修改成功')
          this.open = false
          this.getList()
        })
      })
    },
    // 提交审核。
    submitAudit() {
      auditMerchant({
        merchantId: this.auditForm.merchantId,
        auditStatus: this.auditForm.auditStatus,
        auditRemark: this.auditForm.auditRemark
      }).then(() => {
        this.$modal.msgSuccess('审核完成')
        this.auditOpen = false
        this.getList()
      })
    }
  }
}
</script>
