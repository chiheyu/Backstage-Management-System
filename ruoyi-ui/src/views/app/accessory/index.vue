<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="80px">
      <el-form-item label="配件名称" prop="accessoryName">
        <el-input v-model="queryParams.accessoryName" placeholder="请输入配件名称" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="分类" prop="categoryName">
        <el-input v-model="queryParams.categoryName" placeholder="请输入分类" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择状态" clearable>
          <el-option label="上架" value="0" />
          <el-option label="下架" value="1" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="el-icon-plus" size="mini" @click="handleAdd" v-hasPermi="['app:accessory:add']">新增</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="accessoryList">
      <el-table-column label="配件编号" align="center" prop="accessoryId" width="90" />
      <el-table-column label="封面图" align="center" width="100">
        <template slot-scope="scope">
          <image-preview :src="scope.row.coverImage" :width="50" :height="50" />
        </template>
      </el-table-column>
      <el-table-column label="配件名称" align="center" prop="accessoryName" :show-overflow-tooltip="true" />
      <el-table-column label="分类" align="center" prop="categoryName" />
      <el-table-column label="价格" align="center" prop="price" width="100" />
      <el-table-column label="库存" align="center" prop="stock" width="80" />
      <el-table-column label="销量" align="center" prop="salesCount" width="80" />
      <el-table-column label="状态" align="center" prop="status" width="100">
        <template slot-scope="scope">
          <el-tag :type="scope.row.status === '0' ? 'success' : 'info'">{{ scope.row.status === '0' ? '上架' : '下架' }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="260" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button size="mini" type="text" icon="el-icon-view" @click="handleDetail(scope.row)" v-hasPermi="['app:accessory:query']">详情</el-button>
          <el-button size="mini" type="text" icon="el-icon-edit" @click="handleUpdate(scope.row)" v-hasPermi="['app:accessory:edit']">编辑</el-button>
          <el-button size="mini" type="text" icon="el-icon-delete" @click="handleDelete(scope.row)" v-hasPermi="['app:accessory:remove']">删除</el-button>
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

    <el-dialog :title="title" :visible.sync="open" width="760px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="90px">
        <el-row>
          <el-col :span="12">
            <el-form-item label="配件名称" prop="accessoryName">
              <el-input v-model="form.accessoryName" placeholder="请输入配件名称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="分类" prop="categoryName">
              <el-input v-model="form.categoryName" placeholder="请输入配件分类" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="价格" prop="price">
              <el-input-number v-model="form.price" :min="0" :precision="2" :step="1" controls-position="right" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="库存" prop="stock">
              <el-input-number v-model="form.stock" :min="0" :step="1" controls-position="right" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="状态" prop="status">
              <el-radio-group v-model="form.status">
                <el-radio label="0">上架</el-radio>
                <el-radio label="1">下架</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="封面图" prop="coverImage">
              <image-upload v-model="form.coverImage" :limit="1" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="配件描述" prop="accessoryDesc">
              <el-input v-model="form.accessoryDesc" type="textarea" :rows="4" placeholder="请输入配件描述" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { addAccessory, delAccessory, getAccessory, listAccessory, updateAccessory } from '@/api/app/accessory'

export default {
  name: 'AppAccessory',
  data() {
    return {
      loading: false,
      showSearch: true,
      total: 0,
      open: false,
      title: '',
      accessoryList: [],
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        accessoryName: undefined,
        categoryName: undefined,
        status: undefined
      },
      form: {},
      rules: {
        accessoryName: [{ required: true, message: '配件名称不能为空', trigger: 'blur' }],
        categoryName: [{ required: true, message: '分类不能为空', trigger: 'blur' }],
        price: [{ required: true, message: '价格不能为空', trigger: 'blur' }],
        stock: [{ required: true, message: '库存不能为空', trigger: 'blur' }]
      }
    }
  },
  created() {
    this.getList()
  },
  methods: {
    // 查询配件列表。
    getList() {
      this.loading = true
      listAccessory(this.queryParams).then(response => {
        this.accessoryList = response.rows
        this.total = response.total
        this.loading = false
      }).catch(() => {
        this.loading = false
      })
    },
    // 表单重置。
    reset() {
      this.form = {
        accessoryId: undefined,
        categoryName: undefined,
        accessoryName: undefined,
        accessoryDesc: undefined,
        coverImage: undefined,
        price: 0,
        stock: 0,
        salesCount: 0,
        status: '0'
      }
      this.resetForm('form')
    },
    // 搜索。
    handleQuery() {
      this.queryParams.pageNum = 1
      this.getList()
    },
    // 重置搜索。
    resetQuery() {
      this.resetForm('queryForm')
      this.handleQuery()
    },
    // 打开新增弹窗。
    handleAdd() {
      this.reset()
      this.title = '新增配件'
      this.open = true
    },
    // 打开详情。
    handleDetail(row) {
      this.reset()
      getAccessory(row.accessoryId).then(response => {
        this.form = response.data
        this.title = '配件详情'
        this.open = true
      })
    },
    // 打开编辑。
    handleUpdate(row) {
      this.reset()
      getAccessory(row.accessoryId).then(response => {
        this.form = response.data
        this.title = '编辑配件'
        this.open = true
      })
    },
    // 取消。
    cancel() {
      this.open = false
      this.reset()
    },
    // 提交表单。
    submitForm() {
      this.$refs.form.validate(valid => {
        if (!valid) {
          return
        }
        const request = this.form.accessoryId ? updateAccessory : addAccessory
        request(this.form).then(() => {
          this.$modal.msgSuccess(this.form.accessoryId ? '修改成功' : '新增成功')
          this.open = false
          this.getList()
        })
      })
    },
    // 删除配件。
    handleDelete(row) {
      this.$modal.confirm('是否确认删除配件“' + row.accessoryName + '”？').then(() => {
        return delAccessory(row.accessoryId)
      }).then(() => {
        this.$modal.msgSuccess('删除成功')
        this.getList()
      })
    }
  }
}
</script>
