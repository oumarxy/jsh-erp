<!-- from 7 5 2 7 1 8 9 2 0 -->
<template>
  <a-row :gutter="24">
    <a-col :md="24">
      <a-card :style="cardStyle" :bordered="false">
        <!-- Zone de recherche -->
        <div class="table-page-search-wrapper">
          <a-form layout="inline" @keyup.enter.native="searchQuery">
            <a-row :gutter="24">
              <a-col :md="6" :sm="24">
                <a-form-item label="Informations sur le produit" :labelCol="labelCol" :wrapperCol="wrapperCol">
                  <a-input
                    placeholder="Veuillez saisir le code-barres, le nom, le code mnémonique, les spécifications, le modèle, etc."
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
                  />
                </a-form-item>
              </a-col>
              <a-col :md="6" :sm="24">
                <span style="float: left; overflow: hidden" class="table-page-search-submitButtons">
                  <a-button type="primary" @click="searchQuery">Rechercher</a-button>
                  <a-button style="margin-left: 8px" v-print="'#reportPrint'" icon="printer">Imprimer</a-button>
                  <a-button style="margin-left: 8px" @click="exportExcel" icon="download">Exporter</a-button>
                  <a @click="handleToggleSearch" style="margin-left: 8px">
                    {{ toggleSearchStatus ? 'Masquer' : 'Développer' }}
                    <a-icon :type="toggleSearchStatus ? 'up' : 'down'" />
                  </a>
                </span>
              </a-col>
              <a-col :md="6" :sm="24">
                <a-form-item>
                  <span>Quantité totale : {{ operNumberTotalStr }}，Montant total : {{ allPriceTotalStr }}</span>
                </a-form-item>
              </a-col>
            </a-row>
            <template v-if="toggleSearchStatus">
              <a-row :gutter="24">
                <a-col :md="6" :sm="24">
                  <a-form-item label="Numéro de document" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-input placeholder="Veuillez saisir le numéro de document" v-model="queryParam.number"></a-input>
                  </a-form-item>
                </a-col>
                <a-col :md="6" :sm="24">
                  <a-form-item label="Unité de correspondance" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-select
                      placeholder="Veuillez sélectionner l'unité de correspondance"
                      v-model="queryParam.organId"
                      :dropdownMatchSelectWidth="false"
                      showSearch
                      allow-clear
                      optionFilterProp="children"
                      @search="handleSearchOrgan"
                    >
                      <div slot="dropdownRender" slot-scope="menu">
                        <v-nodes :vnodes="menu" />
                        <a-divider style="margin: 4px 0" />
                        <div class="dropdown-btn" @mousedown="(e) => e.preventDefault()" @click="initOrgan">
                          <a-icon type="reload" /> Actualiser la liste
                        </div>
                      </div>
                      <a-select-option v-for="(item, index) in organList" :key="index" :value="item.id">
                        {{ item.supplier }}
                      </a-select-option>
                    </a-select>
                  </a-form-item>
                </a-col>
                <a-col :md="6" :sm="24">
                  <a-form-item label="Entrepôt" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-select
                      optionFilterProp="children"
                      :dropdownMatchSelectWidth="false"
                      showSearch
                      allow-clear
                      style="width: 100%"
                      placeholder="Veuillez sélectionner l'entrepôt"
                      v-model="queryParam.depotId"
                    >
                      <a-select-option v-for="(depot, index) in depotList" :value="depot.id" :key="index">
                        {{ depot.depotName }}
                      </a-select-option>
                    </a-select>
                  </a-form-item>
                </a-col>
                <a-col :md="6" :sm="24">
                  <a-form-item label="Opérateur" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-select
                      placeholder="Veuillez sélectionner l'opérateur"
                      showSearch
                      allow-clear
                      optionFilterProp="children"
                      v-model="queryParam.creator"
                    >
                      <a-select-option v-for="(item, index) in userList" :key="index" :value="item.id">
                        {{ item.userName }}
                      </a-select-option>
                    </a-select>
                  </a-form-item>
                </a-col>
                <a-col :md="6" :sm="24" v-if="orgaTree.length">
                  <a-form-item label="Organisation" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-tree-select
                      style="width: 100%"
                      allow-clear
                      :treeData="orgaTree"
                      v-model="queryParam.organizationId"
                      placeholder="Veuillez sélectionner l'organisation"
                    >
                    </a-tree-select>
                  </a-form-item>
                </a-col>
                <a-col :md="6" :sm="24">
                  <a-form-item label="Catégorie de produit" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-tree-select
                      style="width: 100%"
                      :dropdownStyle="{ maxHeight: '200px', overflow: 'auto' }"
                      allow-clear
                      :treeData="categoryTree"
                      v-model="queryParam.categoryId"
                      placeholder="Veuillez sélectionner la catégorie de produit"
                    >
                    </a-tree-select>
                  </a-form-item>
                </a-col>
                <a-col :md="6" :sm="24">
                  <a-form-item label="Remarque" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-input placeholder="Veuillez saisir la remarque" v-model="queryParam.remark"></a-input>
                  </a-form-item>
                </a-col>
              </a-row>
            </template>
          </a-form>
        </div>
        <!-- Zone du tableau - début -->
        <section ref="print" id="reportPrint">
          <a-table
            bordered
            ref="table"
            size="middle"
            rowKey="id"
            :columns="columns"
            :dataSource="dataSource"
            :components="handleDrag(columns)"
            :pagination="false"
            :scroll="scroll"
            :loading="loading"
            @change="handleTableChange"
          >
            <span slot="customTitle">
              <a-popover trigger="click" placement="right">
                <template slot="content">
                  <a-checkbox-group @change="onColChange" v-model="settingDataIndex" :defaultValue="settingDataIndex">
                    <a-row style="width: 600px">
                      <template v-for="(item, index) in defColumns">
                        <template>
                          <a-col :span="6">
                            <a-checkbox
                              :value="item.dataIndex"
                              v-if="item.dataIndex === 'rowIndex'"
                              disabled
                            ></a-checkbox>
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
            <span slot="numberCustomRender" slot-scope="text, record">
              <a @click="myHandleDetail(record)">{{ record.number }}</a>
            </span>
          </a-table>
          <a-row :gutter="24" style="margin-top: 8px; text-align: right">
            <a-col :md="24" :sm="24">
              <a-pagination
                @change="paginationChange"
                @showSizeChange="paginationShowSizeChange"
                size="small"
                show-size-changer
                :showQuickJumper="true"
                :current="ipagination.current"
                :page-size="ipagination.pageSize"
                :page-size-options="ipagination.pageSizeOptions"
                :total="ipagination.total"
                :show-total="(total, range) => `Total ${total - Math.ceil(total / ipagination.pageSize)} entrées`"
              >
                <template slot="buildOptionText" slot-scope="props">
                  <span>{{ props.value - 1 }} entrées/page</span>
                </template>
              </a-pagination>
            </a-col>
          </a-row>
        </section>
        <!-- Zone du tableau - fin -->
        <!-- Zone du formulaire -->
        <bill-detail ref="modalDetail"></bill-detail>
      </a-card>
    </a-col>
  </a-row>
</template>
<script>
import BillDetail from '../bill/dialog/BillDetail'
import { JeecgListMixin } from '@/mixins/JeecgListMixin'
import { getFormatDate, getPrevMonthFormatDate } from '@/utils/util'
import { getAction } from '@/api/manage'
import {
  findBySelectOrgan,
  findBillDetailByNumber,
  getUserList,
  queryMaterialCategoryTreeList,
  getAllOrganizationTreeByUser,
} from '@/api/api'
import JEllipsis from '@/components/jeecg/JEllipsis'
import moment from 'moment'
import Vue from 'vue'
export default {
  name: 'InDetail',
  mixins: [JeecgListMixin],
  components: {
    BillDetail,
    JEllipsis,
    VNodes: {
      functional: true,
      render: (h, ctx) => ctx.props.vnodes,
    },
  },
  data() {
    return {
      labelCol: {
        span: 5,
      },
      wrapperCol: {
        span: 18,
        offset: 1,
      },
      // Conditions de recherche
      queryParam: {
        organId: undefined,
        number: '',
        materialParam: '',
        depotId: undefined,
        beginTime: getPrevMonthFormatDate(3),
        endTime: getFormatDate(),
        createTimeRange: [moment(getPrevMonthFormatDate(3)), moment(getFormatDate())],
        type: '入库',
        creator: undefined,
        organizationId: undefined,
        remark: '',
      },
      ipagination: {
        pageSize: 11,
        pageSizeOptions: ['11', '21', '31', '101', '201', '301', '1001', '2001', '3001'],
      },
      organList: [],
      depotList: [],
      userList: [],
      orgaTree: [],
      categoryTree: [],
      operNumberTotalStr: '0',
      allPriceTotalStr: '0',
      setTimeFlag: null,
      tabKey: '1',
      pageName: 'inDetail',
      // Index par défaut
      defDataIndex: [
        'rowIndex',
        'number',
        'barCode',
        'mname',
        'standard',
        'model',
        'mUnit',
        'operNumber',
        'unitPrice',
        'allPrice',
        'taxRate',
        'taxMoney',
        'sname',
        'dname',
        'operTime',
        'newRemark',
      ],
      // Colonnes par défaut
      defColumns: [
        {
          dataIndex: 'rowIndex',
          width: 40,
          align: 'center',
          slots: { title: 'customTitle' },
          customRender: function (t, r, index) {
            return t !== 'Total' ? parseInt(index) + 1 : t
          },
        },
        {
          title: 'Numéro de document',
          dataIndex: 'number',
          width: 100,
          scopedSlots: { customRender: 'numberCustomRender' },
        },
        { title: 'Code-barres', dataIndex: 'barCode', sorter: (a, b) => a.barCode - b.barCode, width: 80 },
        { title: 'Nom', dataIndex: 'mname', width: 120, ellipsis: true },
        { title: 'Spécifications', dataIndex: 'standard', width: 60, ellipsis: true },
        { title: 'Modèle', dataIndex: 'model', width: 60, ellipsis: true },
        { title: 'Couleur', dataIndex: 'color', width: 40, ellipsis: true },
        { title: 'Marque', dataIndex: 'brand', width: 60, ellipsis: true },
        { title: 'Fabricant', dataIndex: 'mfrs', width: 60, ellipsis: true },
        { title: 'Unité', dataIndex: 'mUnit', width: 50, ellipsis: true },
        { title: 'Multi-attributs', dataIndex: 'sku', width: 100, ellipsis: true },
        { title: 'Quantité', dataIndex: 'operNumber', sorter: (a, b) => a.operNumber - b.operNumber, width: 60 },
        { title: 'Prix unitaire', dataIndex: 'unitPrice', sorter: (a, b) => a.unitPrice - b.unitPrice, width: 60 },
        { title: 'Montant', dataIndex: 'allPrice', sorter: (a, b) => a.allPrice - b.allPrice, width: 60 },
        { title: 'Taux de taxe (%)', dataIndex: 'taxRate', width: 60 },
        { title: 'Montant de la taxe', dataIndex: 'taxMoney', sorter: (a, b) => a.taxMoney - b.taxMoney, width: 60 },
        { title: 'Unité de correspondance', dataIndex: 'sname', width: 80, ellipsis: true },
        { title: 'Entrepôt', dataIndex: 'dname', width: 80, ellipsis: true },
        { title: "Date d'entrée", dataIndex: 'operTime', width: 70 },
        { title: 'Remarque', dataIndex: 'newRemark', width: 100, ellipsis: true },
      ],
      url: {
        list: '/depotHead/findInOutDetail',
      },
    }
  },
  created() {
    this.getDepotData()
    this.initOrgan()
    this.initUser()
    this.loadAllOrgaData()
    this.loadCategoryTreeData()
    this.initColumnsSetting()
  },
  methods: {
    moment,
    getQueryParams() {
      let param = Object.assign({}, this.queryParam, this.isorter)
      param.field = this.getQueryField()
      param.currentPage = this.ipagination.current
      param.pageSize = this.ipagination.pageSize - 1
      return param
    },
    onDateChange: function (value, dateString) {
      this.queryParam.beginTime = dateString[0]
      this.queryParam.endTime = dateString[1]
      if (dateString[0] && dateString[1]) {
        this.queryParam.createTimeRange = [moment(dateString[0]), moment(dateString[1])]
      }
    },
    loadData(arg) {
      if (arg === 1) {
        this.ipagination.current = 1
      }
      let params = this.getQueryParams() // Conditions de recherche
      this.loading = true
      getAction(this.url.list, params).then((res) => {
        if (res.code === 200) {
          this.dataSource = res.data.rows
          this.ipagination.total = res.data.total
          this.operNumberTotalStr = res.data.operNumberTotal.toFixed(2)
          this.allPriceTotalStr = res.data.allPriceTotal.toFixed(2)
          this.tableAddTotalRow(this.columns, this.dataSource)
        } else if (res.code === 510) {
          this.$message.warning(res.data)
        } else {
          this.$message.warning(res.data.message)
        }
        this.loading = false
      })
    },
    initOrgan() {
      let that = this
      findBySelectOrgan({ limit: 1 }).then((res) => {
        if (res) {
          that.organList = res
        }
      })
    },
    handleSearchOrgan(value) {
      let that = this
      if (this.setTimeFlag != null) {
        clearTimeout(this.setTimeFlag)
      }
      this.setTimeFlag = setTimeout(() => {
        findBySelectOrgan({ key: value, limit: 1 }).then((res) => {
          if (res) {
            that.organList = res
          }
        })
      }, 500)
    },
    getDepotData() {
      getAction('/depot/findDepotByCurrentUser').then((res) => {
        if (res.code === 200) {
          this.depotList = res.data
        } else {
          this.$message.info(res.data)
        }
      })
    },
    initUser() {
      getUserList({}).then((res) => {
        if (res) {
          this.userList = res
        }
      })
    },
    loadAllOrgaData() {
      let that = this
      let params = {}
      getAllOrganizationTreeByUser(params).then((res) => {
        if (res) {
          that.orgaTree = res
        }
      })
    },
    loadCategoryTreeData() {
      let that = this
      let params = {}
      params.id = ''
      queryMaterialCategoryTreeList(params).then((res) => {
        if (res) {
          that.categoryTree = []
          for (let i = 0; i < res.length; i++) {
            let temp = res[i]
            that.categoryTree.push(temp)
          }
        }
      })
    },
    myHandleDetail(record) {
      findBillDetailByNumber({ number: record.number }).then((res) => {
        if (res && res.code === 200) {
          this.$refs.modalDetail.isCanBackCheck = false
          this.handleDetail(res.data, record.newType)
        }
      })
    },
    searchQuery() {
      if (this.queryParam.beginTime == '' || this.queryParam.endTime == '') {
        this.$message.warning('Veuillez sélectionner la date du document !')
      } else {
        this.loadData(1)
      }
    },
    exportExcel() {
      let list = []
      let head =
        "Numéro de document,Code-barres,Nom,Spécifications,Modèle,Couleur,Marque,Fabricant,Unité,Multi-attributs,Quantité,Prix unitaire,Montant,Taux de taxe (%),Montant de la taxe,Unité de correspondance,Entrepôt,Date d'entrée,Remarque"
      for (let i = 0; i < this.dataSource.length; i++) {
        let item = []
        let ds = this.dataSource[i]
        item.push(
          ds.number,
          ds.barCode,
          ds.mname,
          ds.standard,
          ds.model,
          ds.color,
          ds.brand,
          ds.mfrs,
          ds.mUnit,
          ds.sku,
          ds.operNumber,
          ds.unitPrice,
          ds.allPrice,
          ds.taxRate,
          ds.taxMoney,
          ds.sname,
          ds.dname,
          ds.operTime,
          ds.newRemark
        )
        list.push(item)
      }
      let tip = 'Date du document : ' + this.queryParam.beginTime + '~' + this.queryParam.endTime
      this.handleExportXlsPost("Détails d'entrée", "Détails d'entrée", head, tip, list)
    },
  },
}
</script>
<style scoped>
@import '~@assets/less/common.less';
</style>
