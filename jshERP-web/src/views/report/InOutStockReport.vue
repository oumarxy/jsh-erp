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
                <a-form-item label="Période de stock" :labelCol="labelCol" :wrapperCol="wrapperCol">
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
                  <span
                    >Stock total de la période : {{ totalStockStr }}，Montant total du stock :
                    {{ totalCountMoneyStr }}</span
                  >
                </a-form-item>
              </a-col>
            </a-row>
            <template v-if="toggleSearchStatus">
              <a-row :gutter="24">
                <a-col :md="6" :sm="24">
                  <a-form-item label="Entrepôt" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-select
                      mode="multiple"
                      :maxTagCount="1"
                      optionFilterProp="children"
                      showSearch
                      style="width: 100%"
                      placeholder="Veuillez sélectionner l'entrepôt"
                      v-model="depotSelected"
                    >
                      <a-select-option v-for="(depot, index) in depotList" :key="index" :value="depot.id">
                        {{ depot.depotName }}
                      </a-select-option>
                    </a-select>
                  </a-form-item>
                </a-col>
                <a-col :md="6" :sm="24">
                  <a-form-item label="Catégorie" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-tree-select
                      style="width: 100%"
                      :dropdownStyle="{ maxHeight: '200px', overflow: 'auto' }"
                      allow-clear
                      :treeData="categoryTree"
                      v-model="queryParam.categoryId"
                      placeholder="Veuillez sélectionner la catégorie"
                    >
                    </a-tree-select>
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
            <span slot="action" slot-scope="text, record">
              <a @click="showMaterialDepotStockList(record)">{{ record.id ? 'Distribution' : '' }}</a>
            </span>
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
            <template slot="customPic" slot-scope="text, record">
              <a-popover placement="right" trigger="click">
                <template slot="content">
                  <img :src="getImgUrl(record.imgName, record.imgLarge)" width="500px" />
                </template>
                <div class="item-info" v-if="record.imgName">
                  <img
                    v-if="record.imgName"
                    :src="getImgUrl(record.imgName, record.imgSmall)"
                    class="item-img"
                    title="Voir l'image en grand"
                  />
                </div>
              </a-popover>
            </template>
            <template slot="customRenderStock" slot-scope="text, record">
              <a-tooltip :title="record.bigUnitStock">
                {{ text }}
              </a-tooltip>
            </template>
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
        <material-depot-stock-list-with-time
          ref="materialDepotStockListWithTime"
          @ok="modalFormOk"
        ></material-depot-stock-list-with-time>
      </a-card>
    </a-col>
  </a-row>
</template>
<script>
import MaterialDepotStockListWithTime from './modules/MaterialDepotStockListWithTime'
import { JeecgListMixin } from '@/mixins/JeecgListMixin'
import { getAction, getFileAccessHttpUrl } from '@/api/manage'
import { queryMaterialCategoryTreeList } from '@/api/api'
import { getFormatDate, getMpListShort, getPrevMonthFormatDate } from '@/utils/util'
import JEllipsis from '@/components/jeecg/JEllipsis'
import moment from 'moment'
import Vue from 'vue'
export default {
  name: 'InOutStockReport',
  mixins: [JeecgListMixin],
  components: {
    MaterialDepotStockListWithTime,
    JEllipsis,
  },
  data() {
    return {
      // Conditions de recherche
      currentMonth: moment().format('YYYY-MM'),
      monthFormat: 'YYYY-MM',
      labelCol: {
        span: 5,
      },
      wrapperCol: {
        span: 18,
        offset: 1,
      },
      queryParam: {
        depotId: undefined,
        beginTime: getPrevMonthFormatDate(1),
        endTime: getFormatDate(),
        createTimeRange: [moment(getPrevMonthFormatDate(1)), moment(getFormatDate())],
        materialParam: '',
        categoryId: undefined,
        mpList: getMpListShort(Vue.ls.get('materialPropertyList')), // Attributs étendus
      },
      ipagination: {
        pageSize: 11,
        pageSizeOptions: ['11', '21', '31', '101', '201'],
      },
      depotSelected: [],
      depotList: [],
      categoryTree: [],
      totalStockStr: '0',
      totalCountMoneyStr: '0',
      pageName: 'inOutStockReport',
      // Index par défaut
      defDataIndex: [
        'rowIndex',
        'action',
        'barCode',
        'materialName',
        'materialStandard',
        'materialModel',
        'unitName',
        'unitPrice',
        'prevSum',
        'inSum',
        'outSum',
        'thisSum',
        'thisAllPrice',
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
          title: 'Détails du stock',
          dataIndex: 'action',
          align: 'center',
          width: 60,
          scopedSlots: { customRender: 'action' },
        },
        { title: 'Image', dataIndex: 'pic', width: 45, scopedSlots: { customRender: 'customPic' } },
        { title: 'Code-barres', dataIndex: 'barCode', sorter: (a, b) => a.barCode - b.barCode, width: 100 },
        { title: 'Nom', dataIndex: 'materialName', width: 120, ellipsis: true },
        { title: 'Spécifications', dataIndex: 'materialStandard', width: 80, ellipsis: true },
        { title: 'Modèle', dataIndex: 'materialModel', width: 80, ellipsis: true },
        { title: 'Couleur', dataIndex: 'materialColor', width: 50, ellipsis: true },
        { title: 'Marque', dataIndex: 'materialBrand', width: 80, ellipsis: true },
        { title: 'Fabricant', dataIndex: 'materialMfrs', width: 80, ellipsis: true },
        { title: 'Extension 1', dataIndex: 'otherField1', width: 50, ellipsis: true },
        { title: 'Extension 2', dataIndex: 'otherField2', width: 50, ellipsis: true },
        { title: 'Extension 3', dataIndex: 'otherField3', width: 50, ellipsis: true },
        { title: 'Unité', dataIndex: 'unitName', width: 60, ellipsis: true },
        { title: 'Prix de revient', dataIndex: 'unitPrice', sorter: (a, b) => a.unitPrice - b.unitPrice, width: 60 },
        {
          title: 'Quantité de stock de clôture précédente',
          dataIndex: 'prevSum',
          sorter: (a, b) => a.prevSum - b.prevSum,
          width: 80,
        },
        { title: "Quantité d'entrée", dataIndex: 'inSum', sorter: (a, b) => a.inSum - b.inSum, width: 60 },
        { title: 'Quantité de sortie', dataIndex: 'outSum', sorter: (a, b) => a.outSum - b.outSum, width: 60 },
        {
          title: 'Quantité de stock de clôture de la période',
          dataIndex: 'thisSum',
          sorter: (a, b) => a.thisSum - b.thisSum,
          width: 80,
          scopedSlots: { customRender: 'customRenderStock' },
        },
        {
          title: 'Montant de clôture',
          dataIndex: 'thisAllPrice',
          sorter: (a, b) => a.thisAllPrice - b.thisAllPrice,
          width: 60,
        },
      ],
      url: {
        list: '/depotItem/getInOutStock',
        totalCountMoney: '/depotItem/getInOutStockCountMoney',
      },
    }
  },
  created() {
    this.getDepotData()
    this.loadTreeData()
    this.getTotalCountMoney()
    this.initColumnsSetting()
    this.handleChangeOtherField(0)
  },
  methods: {
    moment,
    getQueryParams() {
      let param = Object.assign({}, this.queryParam, this.isorter)
      if (this.depotSelected && this.depotSelected.length > 0) {
        param.depotIds = this.depotSelected.join()
      }
      param.monthTime = this.queryParam.monthTime
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
    getDepotData() {
      getAction('/depot/findDepotByCurrentUser').then((res) => {
        if (res.code === 200) {
          this.depotList = res.data
        } else {
          this.$message.info(res.data)
        }
      })
    },
    getTotalCountMoney() {
      let param = Object.assign({}, this.queryParam, this.isorter)
      if (this.depotSelected && this.depotSelected.length > 0) {
        param.depotIds = this.depotSelected.join()
      }
      param.monthTime = this.queryParam.monthTime
      getAction(this.url.totalCountMoney, param).then((res) => {
        if (res && res.code === 200) {
          this.totalStockStr = res.data.totalStock.toFixed(2)
          this.totalCountMoneyStr = res.data.totalCount.toFixed(2)
        }
      })
    },
    onChange: function (value, dateString) {
      console.log(dateString)
      this.queryParam.monthTime = dateString
    },
    getImgUrl(imgName, type) {
      if (imgName && imgName.split(',')) {
        type = type ? type + '/' : ''
        return getFileAccessHttpUrl('systemConfig/static/' + type + imgName.split(',')[0])
      } else {
        return ''
      }
    },
    loadTreeData() {
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
    searchQuery() {
      if (this.queryParam.beginTime === '' || this.queryParam.endTime === '') {
        this.$message.warning('Veuillez sélectionner la période de stock !')
      } else {
        this.loadData(1)
        this.getTotalCountMoney()
      }
    },
    showMaterialDepotStockList(record) {
      let depotIds = ''
      if (this.depotSelected && this.depotSelected.length > 0) {
        depotIds = this.depotSelected.join()
      }
      this.$refs.materialDepotStockListWithTime.show(
        record,
        depotIds,
        this.queryParam.beginTime,
        this.queryParam.endTime
      )
      this.$refs.materialDepotStockListWithTime.title =
        "Voir la distribution du stock des statistiques d'achat-vente-stock (Code-barres : " +
        record.barCode +
        '，Nom : ' +
        record.materialName +
        ')'
      this.$refs.materialDepotStockListWithTime.disableSubmit = false
    },
    exportExcel() {
      let list = []
      let mpStr = getMpListShort(Vue.ls.get('materialPropertyList'))
      let head =
        'Code-barres,Nom,Spécifications,Modèle,Couleur,Marque,Fabricant,' +
        mpStr +
        ",Unité,Prix de revient,Quantité de stock de clôture précédente,Quantité d'entrée,Quantité de sortie,Quantité de stock de clôture de la période,Montant de clôture"
      for (let i = 0; i < this.dataSource.length; i++) {
        let item = []
        let ds = this.dataSource[i]
        item.push(
          ds.barCode,
          ds.materialName,
          ds.materialStandard,
          ds.materialModel,
          ds.materialColor,
          ds.materialBrand,
          ds.materialMfrs,
          ds.otherField1,
          ds.otherField2,
          ds.otherField3,
          ds.unitName,
          ds.unitPrice,
          ds.prevSum,
          ds.inSum,
          ds.outSum,
          ds.thisSum,
          ds.thisAllPrice
        )
        list.push(item)
      }
      let tip = 'Période de stock : ' + this.queryParam.beginTime + '~' + this.queryParam.endTime
      this.handleExportXlsPost("Statistiques d'achat-vente-stock", "Statistiques d'achat-vente-stock", head, tip, list)
    },
  },
}
</script>
<style scoped>
@import '~@assets/less/common.less';
</style>
<style scoped>
.item-info {
  float: left;
  width: 38px;
  height: 38px;
  margin-left: 6px;
}
.item-img {
  cursor: pointer;
  position: static;
  display: block;
  width: 100%;
  height: 100%;
  object-fit: cover;
}
</style>
