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
      <template slot="footer">
        <a-button @click="handleCancel">Fermer (ESC)</a-button>
        <a-button @click="handleBackBill" v-if="selectType === 'detail'">Retour à la liste des documents</a-button>
        <a-button type="primary" @click="handleOk">Confirmer</a-button>
      </template>
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
          <template v-if="!queryParam.purchaseStatus">
            <a-tag v-if="record.status === '0'" color="red">Non audité</a-tag>
            <a-tag v-if="record.status === '1'" color="green">Audité</a-tag>
            <a-tag v-if="record.status === '2' && queryParam.subType === '请购单'" color="cyan">Achat terminé</a-tag>
            <a-tag v-if="record.status === '2' && queryParam.subType === '采购订单'" color="cyan">Achat terminé</a-tag>
            <a-tag v-if="record.status === '2' && queryParam.subType === '销售订单'" color="cyan">Vente terminée</a-tag>
            <a-tag v-if="record.status === '3' && queryParam.subType === '请购单'" color="blue">Achat partiel</a-tag>
            <a-tag v-if="record.status === '3' && queryParam.subType === '采购订单'" color="blue">Achat partiel</a-tag>
            <a-tag v-if="record.status === '3' && queryParam.subType === '销售订单'" color="blue"
              >Vente partielle</a-tag
            >
            <a-tag
              v-if="record.status === '2' && (queryParam.subType === '采购' || queryParam.subType === '销售')"
              color="green"
              >Audité</a-tag
            >
            <a-tag
              v-if="record.status === '3' && (queryParam.subType === '采购' || queryParam.subType === '销售')"
              color="green"
              >Audité</a-tag
            >
          </template>
          <template v-if="queryParam.purchaseStatus">
            <a-tag v-if="record.purchaseStatus === '0'" color="red">Non acheté</a-tag>
            <a-tag v-if="record.purchaseStatus === '2' && queryParam.subType === '销售订单'" color="cyan"
              >Achat terminé</a-tag
            >
            <a-tag v-if="record.purchaseStatus === '3' && queryParam.subType === '销售订单'" color="blue"
              >Achat partiel</a-tag
            >
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
import Vue from 'vue'
export default {
  name: 'LinkBillList',
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
      oldTitle: '',
      linkNumber: '',
      organId: '',
      accountId: '',
      salesMan: '',
      discountMoney: '',
      deposit: '',
      remark: '',
      defaultDepotId: '',
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
        { title: 'Montant total', dataIndex: 'totalPrice', width: 70 },
        {
          title: 'Total TTC',
          dataIndex: 'totalTaxLastMoney',
          width: 70,
          customRender: function (text, record, index) {
            if (record.discountLastMoney) {
              return (record.discountMoney + record.discountLastMoney).toFixed(2)
            } else {
              return record.totalPrice
            }
          },
        },
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
        { title: 'Nom', dataIndex: 'name', width: 150, ellipsis: true },
        { title: 'Spécification', dataIndex: 'standard', width: 100, ellipsis: true },
        { title: 'Modèle', dataIndex: 'model', width: 100, ellipsis: true },
        { title: 'Unité', dataIndex: 'unit', width: 50 },
        { title: 'Quantité', dataIndex: 'operNumber', width: 80 },
        { title: 'Prix unitaire', dataIndex: 'unitPrice', width: 80 },
        { title: 'Montant', dataIndex: 'allPrice', width: 80 },
        { title: 'Taux de taxe (%)', dataIndex: 'taxRate', width: 80 },
        { title: 'Montant de la taxe', dataIndex: 'taxMoney', width: 80 },
        { title: 'Total TTC', dataIndex: 'taxLastMoney', width: 80 },
        { title: 'Remarque', dataIndex: 'remark', width: 100, ellipsis: true },
      ],
      dataSource: [],
      dataSourceDetail: [],
      url: {
        list: '/depotHead/list',
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
    show(type, subType, organType, status) {
      this.selectType = 'list'
      this.showType = 'basic'
      this.queryParam.type = type
      this.queryParam.subType = subType
      this.queryParam.status = status
      this.model = Object.assign({}, {})
      this.visible = true
      this.selectedDetailRowKeys = []
      this.initColumns(subType, organType)
      this.loadData(1)
    },
    purchaseShow(type, subType, organType, status, purchaseStatus) {
      this.selectType = 'list'
      this.showType = 'purchase'
      this.queryParam.type = type
      this.queryParam.subType = subType
      this.queryParam.status = status
      this.queryParam.purchaseStatus = purchaseStatus
      this.model = Object.assign({}, {})
      this.visible = true
      this.selectedDetailRowKeys = []
      this.initColumns(subType, organType)
      this.loadData(1)
    },
    initColumns(subType, organType) {
      for (let i = 0; i < this.columns.length; i++) {
        if (this.columns[i].dataIndex === 'organName') {
          this.columns[i].title = organType
        }
      }
      if (subType === '请购单') {
        for (let i = 0; i < this.columns.length; i++) {
          if (this.columns[i].dataIndex === 'organName') {
            this.columns.splice(i, 1)
          }
          if (this.columns[i].dataIndex === 'totalPrice') {
            this.columns.splice(i, 1)
          }
          if (this.columns[i].dataIndex === 'totalTaxLastMoney') {
            this.columns.splice(i, 1)
          }
        }
      }
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
    handleBackBill() {
      this.selectType = 'list'
      this.title = this.oldTitle
      this.selectedDetailRowKeys = []
    },
    handleOk() {
      if (this.selectType === 'list') {
        this.getDepotByCurrentUser()
        this.getSelectBillRows()
        if (this.selectBillRows && this.selectBillRows.length > 0) {
          this.selectType = 'detail'
          this.oldTitle = this.title
          this.title = 'Veuillez sélectionner les détails du document'
          let record = this.selectBillRows[0]
          this.linkNumber = record.number
          this.organId = record.organId
          this.accountId = record.accountId
          this.salesMan = record.salesMan
          this.discountMoney = record.discountMoney
          this.deposit = record.changeAmount - record.finishDeposit
          this.remark = record.remark
          this.initListColumns()
          this.loadDetailData(1)
        } else {
          this.$message.warning('Désolé, veuillez sélectionner un document !')
        }
      } else {
        if (this.selectedDetailRowKeys.length) {
          this.getSelectBillDetailRows()
          this.$emit(
            'ok',
            this.selectBillDetailRows,
            this.linkNumber,
            this.organId,
            this.discountMoney,
            this.deposit,
            this.remark,
            this.defaultDepotId,
            this.accountId,
            this.salesMan
          )
          this.close()
        } else {
          this.$message.warning('Désolé, veuillez sélectionner les détails du document !')
        }
      }
    },
    initListColumns() {
      if (this.queryParam.subType === '请购单') {
        for (let i = 0; i < this.columnsDetail.length; i++) {
          if (this.columnsDetail[i].dataIndex === 'unitPrice') {
            this.columnsDetail.splice(i, 1)
          }
          if (this.columnsDetail[i].dataIndex === 'allPrice') {
            this.columnsDetail.splice(i, 1)
          }
          if (this.columnsDetail[i].dataIndex === 'taxRate') {
            this.columnsDetail.splice(i, 1)
          }
          if (this.columnsDetail[i].dataIndex === 'taxMoney') {
            this.columnsDetail.splice(i, 1)
          }
          if (this.columnsDetail[i].dataIndex === 'taxLastMoney') {
            this.columnsDetail.splice(i, 1)
          }
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
              if (info.finishNumber < info.preNumber) {
                // Supprimer les détails déjà entièrement convertis, ne charger que les détails non convertis
                listEx.push(info)
              } else {
                if (
                  this.queryParam.subType === '采购' ||
                  this.queryParam.subType === '销售' ||
                  this.queryParam.subType === '零售'
                ) {
                  // Pour les documents de retour, ne pas filtrer les détails
                  listEx.push(info)
                }
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
    // Charger l'ID de l'entrepôt par défaut
    getDepotByCurrentUser() {
      getAction('/depot/findDepotByCurrentUser').then((res) => {
        if (res.code === 200) {
          if (res.data.length === 1) {
            this.defaultDepotId = res.data[0].id + ''
          } else {
            for (let i = 0; i < res.data.length; i++) {
              if (res.data[i].isDefault) {
                this.defaultDepotId = res.data[i].id + ''
              }
            }
          }
        }
      })
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
