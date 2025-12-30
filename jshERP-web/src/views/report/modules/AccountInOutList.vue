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
        <span slot="customTitle">
          <a-popover trigger="click" placement="right">
            <template slot="content">
              <a-checkbox-group @change="onColChange" v-model="settingDataIndex" :defaultValue="settingDataIndex">
                <a-row style="width: 600px">
                  <template v-for="(item, index) in defColumns">
                    <template>
                      <a-col :span="6">
                        <a-checkbox :value="item.dataIndex" v-if="item.dataIndex === 'rowIndex'" disabled></a-checkbox>
                        <a-checkbox :value="item.dataIndex" v-if="item.dataIndex !== 'rowIndex'">
                          <j-ellipsis :value="item.title" :length="10"></j-ellipsis>
                        </a-checkbox>
                      </a-col>
                    </template>
                  </template>
                </a-row>
                <a-row style="padding-top: 10px">
                  <a-col>
                    Restaurer la configuration de colonnes par défaut :
                    <a-button @click="handleRestDefault" type="link" size="small">Restaurer par défaut</a-button>
                  </a-col>
                </a-row>
              </a-checkbox-group>
            </template>
            <a-icon type="setting" />
          </a-popover>
        </span>
      </a-table>
      <!-- Zone du tableau - fin -->
      <!-- Zone du formulaire -->
      <bill-detail ref="billDetail"></bill-detail>
      <financial-detail ref="financialDetail"></financial-detail>
    </a-modal>
  </div>
</template>
<script>
import BillDetail from '../../bill/dialog/BillDetail'
import FinancialDetail from '../../financial/dialog/FinancialDetail'
import { JeecgListMixin } from '@/mixins/JeecgListMixin'
import { mixinDevice } from '@/utils/mixin'
import JEllipsis from '@/components/jeecg/JEllipsis'
import { findBillDetailByNumber, findFinancialDetailByNumber } from '@/api/api'
export default {
  name: 'AccountInOutList',
  mixins: [JeecgListMixin, mixinDevice],
  components: {
    BillDetail,
    FinancialDetail,
    JEllipsis,
  },
  data() {
    return {
      title: 'Opération',
      visible: false,
      disableMixinCreated: true,
      toFromType: '',
      currentAccountId: '',
      currentInitialAmount: '',
      // Conditions de recherche
      queryParam: {
        accountId: '',
        initialAmount: '',
        number: '',
        beginTime: '',
        endTime: '',
      },
      tabKey: '1',
      pageName: 'accountInOutList',
      // Index par défaut
      defDataIndex: ['rowIndex', 'number', 'type', 'supplierName', 'changeAmount', 'balance', 'operTime'],
      // Colonnes par défaut
      defColumns: [
        {
          dataIndex: 'rowIndex',
          width: 40,
          align: 'center',
          slots: { title: 'customTitle' },
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
        { title: 'Type', dataIndex: 'type', width: 100 },
        { title: "Informations sur l'unité", dataIndex: 'supplierName', width: 180, ellipsis: true },
        {
          title: 'Montant',
          dataIndex: 'changeAmount',
          width: 100,
          ellipsis: true,
          customRender: function (t, r, index) {
            if (r.aList && r.amList) {
              let aListArr = r.aList.toString().split(',')
              let amListArr = r.amList.toString().split(',')
              let res = 0
              for (let i = 0; i < aListArr.length; i++) {
                if (aListArr[i] == r.accountId) {
                  res = amListArr[i]
                }
              }
              if (res > 0) {
                res = '+' + res
              }
              return res + '[Multi-comptes]'
            } else {
              if (r.changeAmount > 0) {
                return '+' + r.changeAmount
              } else {
                return r.changeAmount
              }
            }
          },
        },
        { title: 'Solde', dataIndex: 'balance', width: 80 },
        { title: 'Date du document', dataIndex: 'operTime', width: 120 },
        { title: 'Remarque', dataIndex: 'remark', width: 150 },
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
        list: '/account/findAccountInOutList',
      },
    }
  },
  created() {
    this.initColumnsSetting()
  },
  methods: {
    getQueryParams() {
      let param = Object.assign({}, this.queryParam, this.isorter)
      param.field = this.getQueryField()
      param.accountId = this.currentAccountId
      param.initialAmount = this.currentInitialAmount
      param.currentPage = this.ipagination.current
      param.pageSize = this.ipagination.pageSize
      return param
    },
    show(record) {
      this.model = Object.assign({}, record)
      this.currentAccountId = record.id
      this.currentInitialAmount = record.initialAmount
      this.visible = true
      this.queryParam.accountId = record.id
      this.queryParam.initialAmount = record.initialAmount
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
      if (record.fromType === 'bill') {
        findBillDetailByNumber({ number: record.number }).then((res) => {
          if (res && res.code === 200) {
            this.$refs.billDetail.isCanBackCheck = false
            that.$refs.billDetail.show(res.data, record.type)
            that.$refs.billDetail.title = 'Détails'
          }
        })
      } else if (record.fromType === 'financial') {
        findFinancialDetailByNumber({ billNo: record.number }).then((res) => {
          if (res && res.code === 200) {
            this.$refs.financialDetail.isCanBackCheck = false
            that.$refs.financialDetail.show(res.data, record.type)
            that.$refs.financialDetail.title = 'Détails'
          }
        })
      }
    },
    exportExcel() {
      let list = []
      let head = "Numéro de document,Type,Informations sur l'unité,Montant,Solde,Date du document,Remarque"
      for (let i = 0; i < this.dataSource.length; i++) {
        let item = []
        let ds = this.dataSource[i]
        item.push(ds.number, ds.type, ds.supplierName, this.getRealChangeAmount(ds), ds.balance, ds.operTime, ds.remark)
        list.push(item)
      }
      let tip = 'Mouvements du compte'
      this.handleExportXlsPost('Mouvements du compte', 'Mouvements du compte', head, tip, list)
    },
    getRealChangeAmount(r) {
      if (r.aList && r.amList) {
        let aListArr = r.aList.toString().split(',')
        let amListArr = r.amList.toString().split(',')
        let res = 0
        for (let i = 0; i < aListArr.length; i++) {
          if (aListArr[i] == r.accountId) {
            res = amListArr[i]
          }
        }
        if (res > 0) {
          res = '+' + res
        }
        return res + '[Multi-comptes]'
      } else {
        if (r.changeAmount > 0) {
          return '+' + r.changeAmount
        } else {
          return r.changeAmount
        }
      }
    },
  },
}
</script>
<style scoped>
@import '~@assets/less/common.less';
</style>
