<template>
  <div ref="container">
    <a-modal
      :title="title"
      :width="1200"
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
            <a-col :md="6" :sm="24">
              <a-form-item label="Numéro de document" :labelCol="{ span: 5 }" :wrapperCol="{ span: 18, offset: 1 }">
                <a-input
                  placeholder="Veuillez saisir le numéro de document pour la recherche"
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
            <span style="float: left; overflow: hidden" class="table-page-search-submitButtons">
              <a-col :md="12" :sm="24">
                <a-button type="primary" @click="searchQuery">Rechercher</a-button>
                <a-button style="margin-left: 8px" v-print="'#debtAccountPrint'" icon="printer">Imprimer</a-button>
                <a-button style="margin-left: 8px" @click="handleExportXls('Détails de la dette')" icon="download"
                  >Exporter</a-button
                >
                <a-button style="margin-left: 8px" @click="handleHistoryFinancial" icon="history">{{
                  historyText
                }}</a-button>
              </a-col>
            </span>
          </a-row>
        </a-form>
      </div>
      <!-- Zone du tableau - début -->
      <section ref="debtPrint" id="debtAccountPrint">
        <a-table
          bordered
          ref="table"
          size="middle"
          rowKey="id"
          :columns="columns"
          :dataSource="dataSource"
          :pagination="false"
          :loading="loading"
          @change="handleTableChange"
        >
          <span slot="numberCustomRender" slot-scope="text, record">
            <a @click="myHandleDetail(record)">{{ record.number }}</a>
          </span>
        </a-table>
      </section>
      <!-- Zone du tableau - fin -->
      <!-- Zone du formulaire -->
      <bill-detail ref="modalDetail"></bill-detail>
      <history-financial-list ref="historyFinancial"></history-financial-list>
    </a-modal>
  </div>
</template>

<script>
import BillDetail from '../../bill/dialog/BillDetail'
import HistoryFinancialList from './HistoryFinancialList'
import { JeecgListMixin } from '@/mixins/JeecgListMixin'
import { getMpListShort } from '@/utils/util'
import { mixinDevice } from '@/utils/mixin'
import { findBillDetailByNumber } from '@/api/api'
import Vue from 'vue'
export default {
  name: 'DebtAccountList',
  mixins: [JeecgListMixin, mixinDevice],
  components: {
    BillDetail,
    HistoryFinancialList,
  },
  data() {
    return {
      title: 'Opération',
      visible: false,
      disableMixinCreated: true,
      queryParam: {
        organId: '',
        materialParam: '',
        number: '',
        type: '',
        subType: '',
        status: '',
        mpList: getMpListShort(Vue.ls.get('materialPropertyList')), // Attributs étendus
      },
      historyText: '',
      financialType: '',
      ipagination: {
        pageSize: 10001,
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
        {
          title: '#',
          dataIndex: 'rowIndex',
          width: 40,
          align: 'center',
          customRender: function (t, r, index) {
            return t !== 'Total' ? parseInt(index) + 1 : t
          },
        },
        {
          title: 'Numéro de document',
          dataIndex: 'number',
          width: 120,
          scopedSlots: { customRender: 'numberCustomRender' },
        },
        { title: '', dataIndex: 'organName', width: 120 },
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
        { title: 'Opérateur', dataIndex: 'userName', width: 60, ellipsis: true },
        { title: 'Dette de ce document', dataIndex: 'needDebt', width: 70 },
        { title: 'Dette reçue', dataIndex: 'finishDebt', width: 70 },
        { title: 'Dette en attente', dataIndex: 'debt', width: 70 },
      ],
      url: {
        list: '/depotHead/debtList',
        exportXlsUrl: '/depotHead/debtExport',
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
    show(organId, type, subType, organType, status, beginTime, endTime) {
      this.queryParam.organId = organId
      this.queryParam.type = type
      this.queryParam.subType = subType
      this.queryParam.status = status
      this.queryParam.beginTime = beginTime
      this.queryParam.endTime = endTime
      this.columns[2].title = organType
      if (type === '入库') {
        this.columns[7].title = 'Dette payée'
        this.columns[8].title = 'Dette en attente de paiement'
        this.historyText = 'Historique des paiements'
        this.financialType = '付款'
      } else if (type === '出库') {
        this.columns[7].title = 'Dette reçue'
        this.columns[8].title = 'Dette en attente'
        this.historyText = 'Historique des recouvrements'
        this.financialType = '收款'
      }
      this.model = Object.assign({}, {})
      this.visible = true
      this.loadData(1)
    },
    myHandleDetail(record) {
      findBillDetailByNumber({ number: record.number }).then((res) => {
        if (res && res.code === 200) {
          let type = res.data.depotHeadType
          type = type.replace('其它', '')
          this.$refs.modalDetail.isCanBackCheck = false
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
    onDateOk(value) {
      console.log(value)
    },
    handleHistoryFinancial() {
      this.$refs.historyFinancial.visible = true
      this.$refs.historyFinancial.title = this.historyText
      this.$refs.historyFinancial.queryParam.organId = this.queryParam.organId
      this.$refs.historyFinancial.queryParam.beginTime = this.queryParam.beginTime
      this.$refs.historyFinancial.queryParam.endTime = this.queryParam.endTime
      this.$refs.historyFinancial.queryParam.type = this.financialType
      this.$refs.historyFinancial.show()
    },
  },
}
</script>

<style scoped></style>
