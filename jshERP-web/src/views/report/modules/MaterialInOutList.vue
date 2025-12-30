<template>
  <div ref="container">
    <a-modal
      :title="title"
      :width="1400"
      :visible="visible"
      :getContainer="() => $refs.container"
      :maskStyle="{ top: '93px', left: '154px' }"
      :wrapClassName="wrapClassNameInfo()"
      :mask="isDesktop()"
      :maskClosable="false"
      @cancel="handleCancel"
      cancelText="Fermer"
      style="top: 20px; height: 95%"
    >
      <template slot="footer">
        <a-button key="back" @click="handleCancel">Annuler</a-button>
      </template>
      <!-- Zone de recherche -->
      <div class="table-page-search-wrapper">
        <!-- Zone de recherche -->
        <a-form layout="inline" @keyup.enter.native="searchQuery">
          <a-row :gutter="24">
            <a-col :md="8" :sm="24">
              <a-form-item label="Numéro de document" :labelCol="labelCol" :wrapperCol="wrapperCol">
                <a-input placeholder="Veuillez saisir le numéro de document" v-model="queryParam.number"></a-input>
              </a-form-item>
            </a-col>
            <a-col :md="8" :sm="24">
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
            <a-col :md="8" :sm="24">
              <a-button type="primary" @click="searchQuery">Rechercher</a-button>
              <a-button style="margin-left: 8px" @click="searchReset">Réinitialiser</a-button>
              <a-button style="margin-left: 8px" @click="exportExcel" icon="download">Exporter</a-button>
            </a-col>
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
        :components="handleDrag(columns)"
        :pagination="ipagination"
        :loading="loading"
        @change="handleTableChange"
      >
        <span slot="numberCustomRender" slot-scope="text, record">
          <a @click="myHandleDetail(record)">{{ record.number }}</a>
        </span>
      </a-table>
      <!-- Zone du tableau - fin -->
      <!-- Zone du formulaire -->
      <bill-detail ref="billDetail"></bill-detail>
    </a-modal>
  </div>
</template>
<script>
import BillDetail from '../../bill/dialog/BillDetail'
import { JeecgListMixin } from '@/mixins/JeecgListMixin'
import JEllipsis from '@/components/jeecg/JEllipsis'
import { findBillDetailByNumber } from '@/api/api'
import { mixinDevice } from '@/utils/mixin'

export default {
  name: 'MaterialInOutList',
  mixins: [JeecgListMixin, mixinDevice],
  components: {
    BillDetail,
    JEllipsis,
  },
  data() {
    return {
      title: 'Opération',
      visible: false,
      disableMixinCreated: false,
      toFromType: '',
      currentMaterialId: '',
      // Conditions de recherche
      queryParam: {
        depotIds: '',
        materialId: '',
        number: '',
        beginTime: '',
        endTime: '',
      },
      ipagination: {
        pageSizeOptions: ['10', '20', '30', '100', '200'],
      },
      tabKey: '1',
      // En-têtes de colonnes
      columns: [
        {
          title: '#',
          dataIndex: '',
          key: 'rowIndex',
          width: 40,
          align: 'center',
          customRender: function (t, r, index) {
            return parseInt(index) + 1
          },
        },
        {
          title: 'Numéro de document',
          dataIndex: 'number',
          width: 120,
          scopedSlots: { customRender: 'numberCustomRender' },
        },
        { title: 'Type', dataIndex: 'type', width: 80 },
        { title: 'Code-barres', dataIndex: 'barCode', width: 100 },
        { title: 'Nom', dataIndex: 'materialName', width: 200 },
        { title: "Nom de l'entrepôt", dataIndex: 'depotName', width: 80 },
        { title: 'Quantité', dataIndex: 'basicNumber', width: 70 },
        { title: 'Prix unitaire', dataIndex: 'unitPrice', width: 70 },
        { title: 'Montant', dataIndex: 'allPrice', width: 70 },
        { title: 'Date', dataIndex: 'operTime', width: 110 },
      ],
      labelCol: {
        xs: { span: 1 },
        sm: { span: 2 },
      },
      wrapperCol: {
        xs: { span: 10 },
        sm: { span: 16 },
      },
      url: {
        list: '/depotItem/findDetailByDepotIdsAndMaterialId',
      },
    }
  },
  created() {},
  methods: {
    getQueryParams() {
      let param = Object.assign({}, this.queryParam, this.isorter)
      param.field = this.getQueryField()
      param.materialId = this.currentMaterialId
      param.currentPage = this.ipagination.current
      param.pageSize = this.ipagination.pageSize
      return param
    },
    show(record, depotIds) {
      this.model = Object.assign({}, record)
      this.currentMaterialId = record.id
      this.visible = true
      this.queryParam.depotIds = depotIds
      this.queryParam.materialId = record.id
      this.loadData(1)
    },
    close() {
      this.$emit('close')
      this.visible = false
    },
    handleCancel() {
      this.close()
    },
    onDateChange: function (value, dateString) {
      this.queryParam.beginTime = dateString[0]
      this.queryParam.endTime = dateString[1]
    },
    onDateOk(value) {
      console.log(value)
    },
    myHandleDetail(record) {
      let that = this
      this.toFromType = record.fromType
      findBillDetailByNumber({ number: record.number }).then((res) => {
        if (res && res.code === 200) {
          this.$refs.billDetail.isCanBackCheck = false
          that.$refs.billDetail.show(res.data, record.type)
          that.$refs.billDetail.title = 'Détails'
        }
      })
    },
    exportExcel() {
      let list = []
      let head = "Numéro de document,Type,Code-barres,Nom,Nom de l'entrepôt,Quantité,Prix unitaire,Montant,Date"
      for (let i = 0; i < this.dataSource.length; i++) {
        let item = []
        let ds = this.dataSource[i]
        item.push(
          ds.number,
          ds.type,
          ds.barCode,
          ds.materialName,
          ds.depotName,
          ds.basicNumber,
          ds.unitPrice,
          ds.allPrice,
          ds.operTime
        )
        list.push(item)
      }
      let tip = 'Recherche de mouvements de stock de produit'
      this.handleExportXlsPost('Mouvements de stock de produit', 'Mouvements de stock de produit', head, tip, list)
    },
  },
}
</script>
<style scoped>
@import '~@assets/less/common.less';
</style>
