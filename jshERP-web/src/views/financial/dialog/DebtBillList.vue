<template>
  <div ref="container">
    <a-modal
      :title="title"
      :width="1300"
      :visible="visible"
      :getContainer="() => $refs.container"
      :maskStyle="{ top: '93px', left: '154px' }"
      :wrapClassName="wrapClassNameInfo()"
      :mask="isDesktop()"
      :maskClosable="false"
      @ok="handleOk"
      @cancel="handleCancel"
      cancelText="Fermer"
      style="top: 20px; height: 95%"
    >
      <!-- Zone de recherche -->
      <div class="table-page-search-wrapper">
        <!-- Zone de recherche -->
        <a-form layout="inline" @keyup.enter.native="searchQuery">
          <a-row :gutter="24">
            <a-col :md="6" :sm="24">
              <a-form-item label="Numéro de document" :labelCol="{ span: 5 }" :wrapperCol="{ span: 18, offset: 1 }">
                <a-input
                  placeholder="Veuillez saisir le numéro de document pour rechercher"
                  v-model="queryParam.number"
                ></a-input>
              </a-form-item>
            </a-col>
            <a-col :md="6" :sm="24">
              <a-form-item
                label="Informations sur le produit"
                :labelCol="{ span: 5 }"
                :wrapperCol="{ span: 18, offset: 1 }"
              >
                <a-input
                  placeholder="Veuillez saisir le nom, les spécifications, le modèle"
                  v-model="queryParam.materialParam"
                ></a-input>
              </a-form-item>
            </a-col>
            <a-col :md="6" :sm="24">
              <a-form-item label="Date du document" :labelCol="labelCol" :wrapperCol="wrapperCol">
                <a-range-picker
                  style="width: 100%"
                  v-model="queryParam.createTimeRange"
                  format="YYYY-MM-DD"
                  :placeholder="['Heure de début', 'Heure de fin']"
                  @change="onDateChange"
                  @ok="onDateOk"
                />
              </a-form-item>
            </a-col>
            <span style="float: left; overflow: hidden" class="table-page-search-submitButtons">
              <a-col :md="6" :sm="24">
                <a-button type="primary" @click="searchQuery">Rechercher</a-button>
                <a-button style="margin-left: 8px" @click="searchReset">Réinitialiser</a-button>
              </a-col>
            </span>
          </a-row>
        </a-form>
      </div>
      <!-- Zone du tableau - début -->
      <a-table
        bordered
        ref="table"
        size="middle"
        rowKey="id"
        :columns="columns"
        :dataSource="dataSource"
        :pagination="ipagination"
        :loading="loading"
        :rowSelection="{ selectedRowKeys: selectedRowKeys, onChange: onSelectChange, type: getType }"
        :customRow="rowAction"
        @change="handleTableChange"
      >
        <span slot="numberCustomRender" slot-scope="text, record">
          <a @click="myHandleDetail(record)">{{ record.number }}</a>
        </span>
      </a-table>
      <!-- Zone du tableau - fin -->
      <!-- Zone du formulaire -->
      <bill-detail ref="modalDetail"></bill-detail>
    </a-modal>
  </div>
</template>

<script>
import BillDetail from '../../bill/dialog/BillDetail'
import { JeecgListMixin } from '@/mixins/JeecgListMixin'
import { mixinDevice } from '@/utils/mixin'
import { findBillDetailByNumber } from '@/api/api'
import Vue from 'vue'
export default {
  name: 'DebtBillList',
  mixins: [JeecgListMixin, mixinDevice],
  components: {
    BillDetail,
  },
  data() {
    return {
      title: 'Opération',
      visible: false,
      disableMixinCreated: true,
      selectedRowKeys: [],
      selectionRows: [],
      selectBillRows: [],
      selectBillIds: '',
      queryParam: {
        organId: '',
        materialParam: '',
        number: '',
        type: '',
        subType: '',
        status: '',
      },
      labelCol: {
        xs: { span: 24 },
        sm: { span: 8 },
      },
      wrapperCol: {
        xs: { span: 24 },
        sm: { span: 16 },
      },
      // En-têtes de colonnes
      columns: [
        { title: '', dataIndex: 'organName', width: 120, ellipsis: true },
        {
          title: 'Numéro de document',
          dataIndex: 'number',
          width: 120,
          scopedSlots: { customRender: 'numberCustomRender' },
        },
        {
          title: 'Informations sur le produit',
          dataIndex: 'materialsList',
          width: 200,
          ellipsis: true,
          customRender: function (text, record, index) {
            if (text) {
              return text.replace(',', '，')
            }
          },
        },
        { title: 'Date du document', dataIndex: 'operTimeStr', width: 130 },
        { title: 'Opérateur', dataIndex: 'userName', width: 70, ellipsis: true },
        { title: 'Dette de ce document', dataIndex: 'needDebt', width: 70 },
        { title: 'Dette recouvrée', dataIndex: 'finishDebt', width: 70 },
        { title: 'Dette en attente de recouvrement', dataIndex: 'debt', width: 70 },
      ],
      url: {
        list: '/depotHead/debtList',
      },
    }
  },
  computed: {
    getType: function () {
      return 'checkbox'
    },
  },
  created() {},
  methods: {
    show(organId, type, subType, organType, status) {
      this.queryParam.organId = organId
      this.queryParam.type = type
      this.queryParam.subType = subType
      this.queryParam.status = status
      this.columns[0].title = organType
      if (type === '入库') {
        this.columns[6].title = 'Dette payée'
        this.columns[7].title = 'Dette en attente de paiement'
      } else if (type === '出库') {
        this.columns[6].title = 'Dette recouvrée'
        this.columns[7].title = 'Dette en attente de recouvrement'
      }
      this.model = Object.assign({}, {})
      this.visible = true
      this.ipagination.pageSize = 100
      this.ipagination.pageSizeOptions = ['100', '200', '300']
      this.loadData(1)
    },
    myHandleDetail(record) {
      findBillDetailByNumber({ number: record.number }).then((res) => {
        if (res && res.code === 200) {
          let type = res.data.depotHeadType
          type = type.replace('其它', '')
          this.handleDetail(res.data, type)
        }
      })
    },
    close() {
      this.$emit('close')
      this.visible = false
    },
    handleCancel() {
      this.close()
    },
    onSelectChange(selectedRowKeys, selectionRows) {
      this.selectedRowKeys = selectedRowKeys
      this.selectionRows = selectionRows
    },
    handleOk() {
      this.getSelectBillRows()
      this.$emit('ok', this.selectBillRows)
      this.selectedRowKeys = []
      this.selectBillRows = []
      this.close()
    },
    onDateChange: function (value, dateString) {
      this.queryParam.beginTime = dateString[0]
      this.queryParam.endTime = dateString[1]
    },
    onDateOk(value) {
      console.log(value)
    },
    searchReset() {
      this.queryParam = {
        type: this.queryParam.type,
        subType: this.queryParam.subType,
      }
      this.loadData(1)
    },
    getSelectBillRows() {
      let dataSource = this.dataSource
      let billIds = ''
      this.selectBillRows = []
      for (let i = 0, len = dataSource.length; i < len; i++) {
        if (this.selectedRowKeys.includes(dataSource[i].id)) {
          this.selectBillRows.push(dataSource[i])
          billIds = billIds + ',' + dataSource[i].id
        }
      }
      this.selectBillIds = billIds.substring(1)
    },
    rowAction(record, index) {
      return {
        on: {
          click: () => {
            let arr = []
            arr.push(record.id)
            this.selectedRowKeys = arr
          },
          dblclick: () => {
            let arr = []
            arr.push(record.id)
            this.selectedRowKeys = arr
            this.handleOk()
          },
        },
      }
    },
  },
}
</script>

<style scoped></style>
