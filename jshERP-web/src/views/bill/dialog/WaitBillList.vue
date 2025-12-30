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
      <div class="table-page-search-wrapper" v-if="selectType === 'list'">
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
              <a-form-item label="Informations produit" :labelCol="{ span: 5 }" :wrapperCol="{ span: 18, offset: 1 }">
                <a-input
                  placeholder="Code-barres|Nom|Spécification|Modèle"
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
        v-if="selectType === 'list'"
        bordered
        ref="table"
        size="middle"
        rowKey="id"
        :columns="columns"
        :dataSource="dataSource"
        :components="handleDrag(columns)"
        :pagination="ipagination"
        :loading="loading"
        :rowSelection="{ selectedRowKeys: selectedRowKeys, onChange: onSelectChange, type: getType }"
        :customRow="rowAction"
        @change="handleTableChange"
      >
        <span slot="numberCustomRender" slot-scope="text, record">
          <a v-if="!queryParam.purchaseStatus" @click="myHandleDetail(record)">{{ record.number }}</a>
          <span v-if="queryParam.purchaseStatus">{{ record.number }}</span>
        </span>
        <template slot="customRenderStatus" slot-scope="text, record">
          <template>
            <a-tag v-if="record.status === '1'" color="green">Audité</a-tag>
            <a-tag v-if="record.status === '3' && queryParam.type === '入库'" color="blue">Entrée partielle</a-tag>
            <a-tag v-if="record.status === '3' && queryParam.type === '出库'" color="blue">Sortie partielle</a-tag>
          </template>
        </template>
      </a-table>
      <a-table
        v-if="selectType === 'detail'"
        bordered
        ref="table"
        size="middle"
        rowKey="id"
        :pagination="false"
        :columns="columnsDetail"
        :dataSource="dataSourceDetail"
        :components="handleDrag(columnsDetail)"
        :loading="loading"
        :rowSelection="{ selectedRowKeys: selectedDetailRowKeys, onChange: onSelectDetailChange, type: 'checkbox' }"
        @change="handleTableChange"
      >
      </a-table>
      <!-- Zone du tableau - fin -->
      <!-- Zone du formulaire -->
      <bill-detail ref="billDetail"></bill-detail>
    </a-modal>
  </div>
</template>

<script>
import BillDetail from './BillDetail'
import { JeecgListMixin } from '@/mixins/JeecgListMixin'
import { mixinDevice } from '@/utils/mixin'
import { findBillDetailByNumber } from '@/api/api'
import { getAction } from '@/api/manage'
export default {
  name: 'WaitBillList',
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
      selectedDetailRowKeys: [],
      selectBillRows: [],
      selectBillDetailRows: [],
      showType: 'basic',
      selectType: 'list',
      linkNumber: '',
      organId: '',
      discountMoney: '',
      deposit: '',
      remark: '',
      queryParam: {
        number: '',
        materialParam: '',
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
          width: 130,
          scopedSlots: { customRender: 'numberCustomRender' },
        },
        {
          title: 'Informations produit',
          dataIndex: 'materialsList',
          width: 280,
          ellipsis: true,
          customRender: function (text, record, index) {
            if (text) {
              return text.replace(',', '，')
            }
          },
        },
        { title: 'Date du document', dataIndex: 'operTimeStr', width: 145 },
        { title: 'Opérateur', dataIndex: 'userName', width: 70 },
        { title: 'Quantité', dataIndex: 'materialCount', width: 60 },
        {
          title: 'État',
          dataIndex: 'status',
          width: 70,
          align: 'center',
          scopedSlots: { customRender: 'customRenderStatus' },
        },
      ],
      columnsDetail: [
        { title: 'Code-barres', dataIndex: 'barCode', width: 120 },
        { title: 'Nom', dataIndex: 'name', width: 100, ellipsis: true },
        { title: 'Spécification', dataIndex: 'standard', width: 120, ellipsis: true },
        { title: 'Modèle', dataIndex: 'model', width: 120, ellipsis: true },
        { title: 'Unité', dataIndex: 'unit', width: 50 },
        { title: 'Quantité', dataIndex: 'operNumber', width: 50 },
        { title: 'Remarque', dataIndex: 'remark', width: 100, ellipsis: true },
      ],
      dataSource: [],
      dataSourceDetail: [],
      url: {
        list: '/depotHead/waitBillList',
      },
    }
  },
  computed: {
    getType: function () {
      return 'radio'
    },
  },
  created() {},
  methods: {
    show(type, subType, status) {
      this.selectType = 'list'
      this.showType = 'other'
      this.queryParam.type = type
      this.queryParam.subType = subType
      this.queryParam.status = status
      this.columns[0].title = 'Fournisseur ou client'
      this.model = Object.assign({}, {})
      this.visible = true
      this.loadData(1)
    },
    myHandleDetail(record) {
      findBillDetailByNumber({ number: record.number }).then((res) => {
        if (res && res.code === 200) {
          let type = res.data.depotHeadType
          type = type.replace('其它', '')
          this.$refs.billDetail.show(res.data, type)
          this.$refs.billDetail.title = type + '- Détails'
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
    onSelectChange(selectedRowKeys) {
      this.selectedRowKeys = selectedRowKeys
    },
    onSelectDetailChange(selectedRowKeys) {
      this.selectedDetailRowKeys = selectedRowKeys
    },
    handleOk() {
      if (this.selectType === 'list') {
        this.getSelectBillRows()
        this.selectType = 'detail'
        this.title = 'Veuillez sélectionner les détails du document'
        if (this.selectBillRows && this.selectBillRows.length > 0) {
          let record = this.selectBillRows[0]
          this.linkNumber = record.number
          this.organId = record.organId
          this.remark = record.remark
          this.loadDetailData(1)
        }
      } else {
        if (this.selectedDetailRowKeys.length) {
          this.getSelectBillDetailRows()
          this.$emit('ok', this.selectBillDetailRows, this.linkNumber, this.remark)
          this.close()
        } else {
          this.$message.warning('Désolé, veuillez sélectionner les détails du document !')
        }
      }
    },
    // Interroger la liste des détails
    loadDetailData(arg) {
      // Charger les données - si le paramètre 1 est passé, charger le contenu de la première page
      if (arg === 1) {
        this.ipagination.current = 1
      }
      if (this.selectBillRows && this.selectBillRows.length > 0) {
        let record = this.selectBillRows[0]
        let param = {
          headerId: record.id,
          mpList: '',
          linkType: this.showType,
        }
        this.loading = true
        getAction('/depotItem/getDetailList', param).then((res) => {
          if (res.code === 200) {
            let list = res.data.rows
            let listEx = []
            for (let j = 0; j < list.length; j++) {
              let info = list[j]
              if (info.preNumber !== info.finishNumber) {
                // Supprimer les détails déjà entièrement convertis
                listEx.push(info)
              }
            }
            this.dataSourceDetail = listEx
            this.ipagination.total = res.data.total
          }
          if (res.code === 510) {
            this.$message.warning(res.data)
          }
          this.loading = false
        })
      }
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
        status: '1,3',
      }
      this.loadData(1)
    },
    getSelectBillRows() {
      let dataSource = this.dataSource
      this.selectBillRows = []
      for (let i = 0, len = dataSource.length; i < len; i++) {
        if (this.selectedRowKeys.includes(dataSource[i].id)) {
          this.selectBillRows.push(dataSource[i])
        }
      }
    },
    getSelectBillDetailRows() {
      let dataSource = this.dataSourceDetail
      this.selectBillDetailRows = []
      for (let i = 0, len = dataSource.length; i < len; i++) {
        if (this.selectedDetailRowKeys.includes(dataSource[i].id)) {
          this.selectBillDetailRows.push(dataSource[i])
        }
      }
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
