<!-- from 7 5 2 7 1 8 9 2 0 -->
<template>
  <a-row :gutter="24">
    <a-col :md="24">
      <a-card :style="cardStyle" :bordered="false">
        <!-- Zone de recherche -->
        <div class="table-page-search-wrapper">
          <a-form layout="inline" @keyup.enter.native="searchQuery">
            <a-row :gutter="24">
              <a-col :md="5" :sm="24">
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
                <a-form-item label="Informations sur le produit" :labelCol="labelCol" :wrapperCol="wrapperCol">
                  <a-input
                    placeholder="Veuillez saisir le code-barres, le nom, le code mnémonique, les spécifications, le modèle, etc."
                    v-model="queryParam.materialParam"
                  ></a-input>
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
              <a-col :md="7" :sm="24">
                <a-form-item>
                  <span
                    >Stock total : {{ currentStock }}，Montant total du stock : {{ currentStockPrice }}，Poids total :
                    {{ currentWeight }}</span
                  >
                </a-form-item>
              </a-col>
            </a-row>
            <template v-if="toggleSearchStatus">
              <a-row :gutter="24">
                <a-col :md="5" :sm="24">
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
                <a-col :md="6" :sm="24">
                  <a-form-item label="Emplacement/Étagère" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-input
                      style="width: 100%"
                      placeholder="Veuillez saisir l'emplacement/étagère pour la recherche"
                      v-model="queryParam.position"
                    ></a-input>
                  </a-form-item>
                </a-col>
                <a-col :md="6" :sm="24">
                  <a-form-item label="Stock zéro" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-select v-model="queryParam.zeroStock">
                      <a-select-option value="0">Masquer</a-select-option>
                      <a-select-option value="1">Afficher</a-select-option>
                    </a-select>
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
            <span slot="action" slot-scope="text, record">
              <a @click="showMaterialInOutList(record)">{{ record.id ? 'Mouvements' : '' }}</a>
              <a-divider type="vertical" />
              <a @click="showMaterialDepotStockList(record)">{{ record.id ? 'Distribution' : '' }}</a>
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
        <material-in-out-list ref="materialInOutList" @ok="modalFormOk"></material-in-out-list>
        <material-depot-stock-list ref="materialDepotStockList" @ok="modalFormOk"></material-depot-stock-list>
      </a-card>
    </a-col>
  </a-row>
</template>
<script>
import MaterialInOutList from './modules/MaterialInOutList'
import MaterialDepotStockList from './modules/MaterialDepotStockList'
import { JeecgListMixin } from '@/mixins/JeecgListMixin'
import { getAction, getFileAccessHttpUrl } from '@/api/manage'
import { queryMaterialCategoryTreeList } from '@/api/api'
import { getMpListShort } from '@/utils/util'
import JEllipsis from '@/components/jeecg/JEllipsis'
import moment from 'moment'
import Vue from 'vue'
export default {
  name: 'MaterialStock',
  mixins: [JeecgListMixin],
  components: {
    MaterialInOutList,
    MaterialDepotStockList,
    JEllipsis,
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
        categoryId: undefined,
        materialParam: '',
        position: '',
        zeroStock: '0',
        mpList: getMpListShort(Vue.ls.get('materialPropertyList')), // Attributs étendus
      },
      ipagination: {
        pageSize: 11,
        pageSizeOptions: ['11', '21', '31', '101', '201', '301', '1001', '2001', '3001'],
      },
      depotSelected: [],
      depotList: [],
      categoryTree: [],
      currentStock: '',
      currentStockPrice: '',
      currentWeight: '',
      pageName: 'materialStock',
      // Index par défaut
      defDataIndex: [
        'rowIndex',
        'action',
        'mBarCode',
        'name',
        'standard',
        'model',
        'color',
        'categoryName',
        'position',
        'unitName',
        'purchaseDecimal',
        'initialStock',
        'currentStock',
        'currentStockPrice',
        'currentWeight',
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
          width: 80,
          scopedSlots: { customRender: 'action' },
        },
        { title: 'Image', dataIndex: 'pic', width: 45, scopedSlots: { customRender: 'customPic' } },
        { title: 'Code-barres', dataIndex: 'mBarCode', width: 100, sorter: (a, b) => a.mBarCode - b.mBarCode },
        { title: 'Nom', dataIndex: 'name', width: 140, ellipsis: true },
        { title: 'Spécifications', dataIndex: 'standard', width: 100, ellipsis: true },
        { title: 'Modèle', dataIndex: 'model', width: 100, ellipsis: true },
        { title: 'Couleur', dataIndex: 'color', width: 60, ellipsis: true },
        { title: 'Marque', dataIndex: 'brand', width: 100, ellipsis: true },
        { title: 'Fabricant', dataIndex: 'mfrs', width: 100, ellipsis: true },
        { title: 'Catégorie', dataIndex: 'categoryName', width: 60, ellipsis: true },
        { title: 'Emplacement/Étagère', dataIndex: 'position', width: 60, ellipsis: true },
        { title: 'Unité', dataIndex: 'unitName', width: 60, ellipsis: true },
        {
          title: 'Prix de revient',
          dataIndex: 'purchaseDecimal',
          sorter: (a, b) => a.purchaseDecimal - b.purchaseDecimal,
          width: 60,
        },
        { title: 'Stock initial', dataIndex: 'initialStock', width: 60 },
        {
          title: 'Stock',
          dataIndex: 'currentStock',
          sorter: (a, b) => a.currentStock - b.currentStock,
          width: 60,
          scopedSlots: { customRender: 'customRenderStock' },
        },
        {
          title: 'Montant du stock',
          dataIndex: 'currentStockPrice',
          sorter: (a, b) => a.currentStockPrice - b.currentStockPrice,
          width: 80,
        },
        { title: 'Poids', dataIndex: 'currentWeight', sorter: (a, b) => a.currentWeight - b.currentWeight, width: 60 },
      ],
      url: {
        list: '/material/getListWithStock',
      },
    }
  },
  created() {
    this.getDepotData()
    this.loadCategoryTreeData()
    this.initColumnsSetting()
  },
  methods: {
    moment,
    getQueryParams() {
      let param = Object.assign({}, this.queryParam, this.isorter)
      if (this.depotSelected && this.depotSelected.length > 0) {
        param.depotIds = this.depotSelected.join()
      }
      param.field = this.getQueryField()
      param.currentPage = this.ipagination.current
      param.pageSize = this.ipagination.pageSize - 1
      return param
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
    getImgUrl(imgName, type) {
      if (imgName && imgName.split(',')) {
        type = type ? type + '/' : ''
        return getFileAccessHttpUrl('systemConfig/static/' + type + imgName.split(',')[0])
      } else {
        return ''
      }
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
    searchQuery() {
      this.loadData(1)
    },
    loadData(arg) {
      // Charger les données - si le paramètre 1 est passé, charger le contenu de la première page
      if (arg === 1) {
        this.ipagination.current = 1
      }
      let params = this.getQueryParams() // Conditions de recherche
      this.loading = true
      getAction(this.url.list, params).then((res) => {
        if (res.code === 200) {
          this.dataSource = res.data.rows
          this.ipagination.total = res.data.total
          this.tableAddTotalRow(this.columns, this.dataSource)
          this.currentStock = res.data.currentStock.toFixed(2)
          this.currentStockPrice = res.data.currentStockPrice.toFixed(2)
          this.currentWeight = res.data.currentWeight.toFixed(2)
        } else if (res.code === 510) {
          this.$message.warning(res.data)
        } else {
          this.$message.warning(res.data.message)
        }
        this.loading = false
      })
    },
    showMaterialInOutList(record) {
      let depotIds = ''
      if (this.depotSelected && this.depotSelected.length > 0) {
        depotIds = this.depotSelected.join()
      }
      this.$refs.materialInOutList.show(record, depotIds)
      this.$refs.materialInOutList.title = 'Voir les mouvements de stock du produit'
      this.$refs.materialInOutList.disableSubmit = false
    },
    showMaterialDepotStockList(record) {
      let depotIds = ''
      if (this.depotSelected && this.depotSelected.length > 0) {
        depotIds = this.depotSelected.join()
      }
      this.$refs.materialDepotStockList.show(record, depotIds)
      this.$refs.materialDepotStockList.title =
        'Voir la distribution du stock du produit (Code-barres : ' + record.mBarCode + '，Nom : ' + record.name + ')'
      this.$refs.materialDepotStockList.disableSubmit = false
    },
    exportExcel() {
      let list = []
      let head =
        'Code-barres,Nom,Spécifications,Modèle,Couleur,Marque,Fabricant,Catégorie,Emplacement/Étagère,Unité,Prix de revient,Stock initial,Stock,Montant du stock,Poids'
      for (let i = 0; i < this.dataSource.length; i++) {
        let item = []
        let ds = this.dataSource[i]
        item.push(
          ds.mBarCode,
          ds.name,
          ds.standard,
          ds.model,
          ds.color,
          ds.brand,
          ds.mfrs,
          ds.categoryName,
          ds.position,
          ds.unitName,
          ds.purchaseDecimal,
          ds.initialStock,
          ds.currentStock,
          ds.currentStockPrice,
          ds.currentWeight
        )
        list.push(item)
      }
      let tip = 'Recherche de stock de produit'
      this.handleExportXlsPost('Stock de produit', 'Stock de produit', head, tip, list)
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
