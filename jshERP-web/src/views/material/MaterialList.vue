<!-- by 7527189 2 0 -->
<template>
  <a-row :gutter="24">
    <a-col :md="24">
      <a-card :style="cardStyle" :bordered="false">
        <!-- Zone de recherche -->
        <div class="table-page-search-wrapper">
          <!-- Zone de recherche -->
          <a-form layout="inline" @keyup.enter.native="searchQuery">
            <a-row :gutter="24">
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
              <a-col :md="6" :sm="24">
                <a-form-item label="Mot-clé" :labelCol="labelCol" :wrapperCol="wrapperCol">
                  <a-input
                    placeholder="Veuillez saisir le code-barres, le nom, le code mnémonique, etc. pour rechercher"
                    v-model="queryParam.materialParam"
                  ></a-input>
                </a-form-item>
              </a-col>
              <a-col :md="6" :sm="24">
                <a-form-item label="Spécifications" :labelCol="labelCol" :wrapperCol="wrapperCol">
                  <a-input
                    placeholder="Veuillez saisir les spécifications pour rechercher"
                    v-model="queryParam.standard"
                  ></a-input>
                </a-form-item>
              </a-col>
              <span style="float: left; overflow: hidden" class="table-page-search-submitButtons">
                <a-col :md="6" :sm="24">
                  <a-button type="primary" @click="searchQuery">Rechercher</a-button>
                  <a-button style="margin-left: 8px" @click="searchReset">Réinitialiser</a-button>
                  <a @click="handleToggleSearch" style="margin-left: 8px">
                    {{ toggleSearchStatus ? 'Masquer' : 'Développer' }}
                    <a-icon :type="toggleSearchStatus ? 'up' : 'down'" />
                  </a>
                </a-col>
              </span>
            </a-row>
            <template v-if="toggleSearchStatus">
              <a-row :gutter="24">
                <a-col :md="6" :sm="24">
                  <a-form-item label="Modèle" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-input
                      placeholder="Veuillez saisir le modèle pour rechercher"
                      v-model="queryParam.model"
                    ></a-input>
                  </a-form-item>
                </a-col>
                <a-col :md="6" :sm="24">
                  <a-form-item label="Couleur" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-input
                      placeholder="Veuillez saisir la couleur pour rechercher"
                      v-model="queryParam.color"
                    ></a-input>
                  </a-form-item>
                </a-col>
                <a-col :md="6" :sm="24">
                  <a-form-item label="Marque" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-input
                      placeholder="Veuillez saisir la marque pour rechercher"
                      v-model="queryParam.brand"
                    ></a-input>
                  </a-form-item>
                </a-col>
                <a-col :md="6" :sm="24">
                  <a-form-item label="Fabricant" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-input
                      placeholder="Veuillez saisir le fabricant pour rechercher"
                      v-model="queryParam.mfrs"
                    ></a-input>
                  </a-form-item>
                </a-col>
                <a-col :md="6" :sm="24">
                  <a-form-item :label="queryTitle.mp1" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-input
                      :placeholder="'Veuillez saisir ' + queryTitle.mp1 + ' pour rechercher'"
                      v-model="queryParam.otherField1"
                    ></a-input>
                  </a-form-item>
                </a-col>
                <a-col :md="6" :sm="24">
                  <a-form-item :label="queryTitle.mp2" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-input
                      :placeholder="'Veuillez saisir ' + queryTitle.mp2 + ' pour rechercher'"
                      v-model="queryParam.otherField2"
                    ></a-input>
                  </a-form-item>
                </a-col>
                <a-col :md="6" :sm="24">
                  <a-form-item :label="queryTitle.mp3" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-input
                      :placeholder="'Veuillez saisir ' + queryTitle.mp3 + ' pour rechercher'"
                      v-model="queryParam.otherField3"
                    ></a-input>
                  </a-form-item>
                </a-col>
                <a-col :md="6" :sm="24">
                  <a-form-item label="État" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-select placeholder="Veuillez sélectionner l'état" v-model="queryParam.enabled">
                      <a-select-option value="1">Activé</a-select-option>
                      <a-select-option value="0">Désactivé</a-select-option>
                    </a-select>
                  </a-form-item>
                </a-col>
                <a-col :md="6" :sm="24">
                  <a-form-item label="Numéro de série" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-select placeholder="Avec ou sans numéro de série" v-model="queryParam.enableSerialNumber">
                      <a-select-option value="1">Oui</a-select-option>
                      <a-select-option value="0">Non</a-select-option>
                    </a-select>
                  </a-form-item>
                </a-col>
                <a-col :md="6" :sm="24">
                  <a-form-item label="Numéro de lot" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-select placeholder="Avec ou sans numéro de lot" v-model="queryParam.enableBatchNumber">
                      <a-select-option value="1">Oui</a-select-option>
                      <a-select-option value="0">Non</a-select-option>
                    </a-select>
                  </a-form-item>
                </a-col>
                <a-col :md="6" :sm="24">
                  <a-form-item label="Emplacement/Étagère" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-input
                      style="width: 100%"
                      placeholder="Veuillez saisir l'emplacement/étagère pour rechercher"
                      v-model="queryParam.position"
                    ></a-input>
                  </a-form-item>
                </a-col>
                <a-col :md="6" :sm="24">
                  <a-form-item label="Poids de base" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-input-number
                      style="width: 100%"
                      placeholder="Veuillez saisir le poids de base pour rechercher"
                      v-model="queryParam.weight"
                    ></a-input-number>
                  </a-form-item>
                </a-col>
                <a-col :md="6" :sm="24">
                  <a-form-item label="Durée de conservation" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-input-number
                      style="width: 100%"
                      placeholder="Veuillez saisir la durée de conservation pour rechercher"
                      v-model="queryParam.expiryNum"
                    ></a-input-number>
                  </a-form-item>
                </a-col>
                <a-col :md="6" :sm="24">
                  <a-form-item label="Remarque" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-input
                      placeholder="Veuillez saisir la remarque pour rechercher"
                      v-model="queryParam.remark"
                    ></a-input>
                  </a-form-item>
                </a-col>
              </a-row>
            </template>
          </a-form>
        </div>
        <!-- Zone des boutons d'action -->
        <div class="table-operator" style="margin-top: 5px">
          <a-button v-if="btnEnableList.indexOf(1) > -1" @click="handleAdd" type="primary" icon="plus"
            >Ajouter</a-button
          >
          <a-button v-if="btnEnableList.indexOf(1) > -1" @click="batchDel" icon="delete">Supprimer</a-button>
          <a-button v-if="btnEnableList.indexOf(1) > -1" @click="batchSetStatus(true)" icon="check-square"
            >Activer</a-button
          >
          <a-button v-if="btnEnableList.indexOf(1) > -1" @click="batchSetStatus(false)" icon="close-square"
            >Désactiver</a-button
          >
          <a-button v-if="btnEnableList.indexOf(1) > -1" @click="handleImportXls()" icon="import">Importer</a-button>
          <a-button
            v-if="btnEnableList.indexOf(3) > -1"
            @click="handleExportXls('Informations sur les produits')"
            icon="download"
            >Exporter</a-button
          >
          <a-button v-if="btnEnableList.indexOf(1) > -1" @click="batchEdit()" icon="edit">Modification en lot</a-button>
          <a-button v-if="btnEnableList.indexOf(1) > -1" @click="batchSetMaterialCurrentStock()" icon="stock"
            >Corriger le stock</a-button
          >
          <a-button v-if="btnEnableList.indexOf(1) > -1" @click="batchSetMaterialCurrentUnitPrice()" icon="fund"
            >Corriger le coût</a-button
          >
          <a-popover trigger="click" placement="right">
            <template slot="content">
              <a-checkbox-group @change="onColChange" v-model="settingDataIndex" :defaultValue="settingDataIndex">
                <a-row style="width: 500px">
                  <template v-for="(item, index) in defColumns">
                    <template>
                      <a-col :span="8">
                        <a-checkbox :value="item.dataIndex">
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
            <a-button icon="setting">Paramètres de colonnes</a-button>
          </a-popover>
        </div>
        <!-- Zone du tableau - début -->
        <div>
          <a-table
            ref="table"
            size="middle"
            bordered
            rowKey="id"
            :columns="columns"
            :dataSource="dataSource"
            :components="handleDrag(columns)"
            :pagination="ipagination"
            :scroll="scroll"
            :loading="loading"
            :rowSelection="{ selectedRowKeys: selectedRowKeys, onChange: onSelectChange, columnWidth: '40px' }"
            @change="handleTableChange"
          >
            <span slot="action" slot-scope="text, record">
              <a @click="handleEdit(record)">Modifier</a>
              <a-divider v-if="btnEnableList.indexOf(1) > -1" type="vertical" />
              <a v-if="btnEnableList.indexOf(1) > -1" @click="handleCopyAdd(record)">Copier</a>
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
            <template slot="customBarCode" slot-scope="text, record">
              {{ record.mBarCode }}
            </template>
            <template slot="customName" slot-scope="text, record">
              {{ record.name }}
              <a-tag v-if="record.enableSerialNumber == 1" color="orange">S</a-tag>
              <a-tag v-if="record.enableBatchNumber == 1" color="orange">L</a-tag>
            </template>
            <template slot="customRenderInitialStock" slot-scope="text, record">
              <a-tooltip :title="record.bigUnitInitialStock">
                {{ text }}
              </a-tooltip>
            </template>
            <template slot="customRenderStock" slot-scope="text, record">
              <a-tooltip :title="record.bigUnitStock">
                {{ text }}
              </a-tooltip>
            </template>
            <template slot="customRenderEnabled" slot-scope="enabled">
              <a-tag v-if="enabled" color="green">Activé</a-tag>
              <a-tag v-if="!enabled" color="orange">Désactivé</a-tag>
            </template>
          </a-table>
        </div>
        <!-- Zone du tableau - fin -->
        <!-- Zone du formulaire -->
        <material-modal ref="modalForm" @ok="modalFormOk"></material-modal>
        <import-file-modal ref="modalImportForm" @ok="modalFormOk"></import-file-modal>
        <batch-set-info-modal ref="batchSetInfoModalForm" @ok="modalFormOk"></batch-set-info-modal>
      </a-card>
    </a-col>
  </a-row>
</template>
<script>
import MaterialModal from './modules/MaterialModal'
import ImportFileModal from '@/components/tools/ImportFileModal'
import BatchSetInfoModal from './modules/BatchSetInfoModal'
import { queryMaterialCategoryTreeList } from '@/api/api'
import { postAction, getFileAccessHttpUrl } from '@/api/manage'
import { getMpListShort } from '@/utils/util'
import { JeecgListMixin } from '@/mixins/JeecgListMixin'
import JEllipsis from '@/components/jeecg/JEllipsis'
import JDate from '@/components/jeecg/JDate'
import Vue from 'vue'

export default {
  name: "MaterialList",
  mixins:[JeecgListMixin],
  components: {
    MaterialModal,
    ImportFileModal,
    BatchSetInfoModal,
    JEllipsis,
    JDate
  },
  data () {
    return {
      categoryTree:[],
      mPropertyListShort: '',
      model: {},
      labelCol: {
        span: 5
      },
      wrapperCol: {
        span: 18,
        offset: 1
      },
      queryTitle: {
        mp1: 'Extension 1',
        mp2: 'Extension 2',
        mp3: 'Extension 3'
      },
      // Conditions de recherche
      queryParam: {
        categoryId: undefined,
        materialParam:'',
        standard:'',
        model:'',
        color:'',
        brand:'',
        mfrs:'',
        otherField1:'',
        otherField2:'',
        otherField3:'',
        weight:'',
        expiryNum:'',
        enabled: undefined,
        enableSerialNumber: undefined,
        enableBatchNumber: undefined,
        position: '',
        remark:'',
        mpList: getMpListShort(Vue.ls.get('materialPropertyList'))  // Attributs d'extension
      },
      urlPath: '/material/material',
      ipagination:{
        pageSizeOptions: ['10', '20', '30', '50', '100', '200']
      },
      // Index réel
      settingDataIndex:[],
      // Colonnes réelles
      columns:[],
      // Index par défaut
      defDataIndex:['action','mBarCode','name','standard','model','color','categoryName','unit', 'stock',
        'purchaseDecimal','commodityDecimal','wholesaleDecimal','lowDecimal','enabled'],
      // Colonnes par défaut
      defColumns: [
        {
          title: 'Opération',
          dataIndex: 'action',
          align:"center",
          width: 100,
          scopedSlots: { customRender: 'action' },
        },
        {title: 'Image', dataIndex: 'pic', width: 60, scopedSlots: { customRender: 'customPic' }},
        {title: 'Code-barres', dataIndex: 'mBarCode', width: 120},
        {title: 'Nom', dataIndex: 'name', width: 160, scopedSlots: { customRender: 'customName' }},
        {title: 'Spécifications', dataIndex: 'standard', width: 120},
        {title: 'Modèle', dataIndex: 'model', width: 120},
        {title: 'Couleur', dataIndex: 'color', width: 70, ellipsis:true},
        {title: 'Marque', dataIndex: 'brand', width: 100, ellipsis:true},
        {title: 'Code mnémonique', dataIndex: 'mnemonic', width: 80, ellipsis:true},
        {title: 'Catégorie', dataIndex: 'categoryName', width: 100, ellipsis:true},
        {title: 'Extension 1', dataIndex: 'otherField1', width: 100, ellipsis:true},
        {title: 'Extension 2', dataIndex: 'otherField2', width: 100, ellipsis:true},
        {title: 'Extension 3', dataIndex: 'otherField3', width: 100, ellipsis:true},
        {title: 'Unité', dataIndex: 'unit', width: 100, ellipsis:true,
          customRender:function (t,r,index) {
            if (r) {
              let name = t?t:r.unitName
              if(r.sku) {
                return name + '[SKU]';
              } else {
                return name;
              }
            }
          }
        },
        {title: 'Poids de base', dataIndex: 'weight', width: 80},
        {title: 'Durée de conservation', dataIndex: 'expiryNum', width: 60},
        {title: 'Fabricant', dataIndex: 'mfrs', width: 120, ellipsis:true},
        {title: 'Stock initial', dataIndex: 'initialStock', width: 80,
          scopedSlots: { customRender: 'customRenderInitialStock' }
        },
        {title: 'Stock', dataIndex: 'stock', width: 80,
          scopedSlots: { customRender: 'customRenderStock' }
        },
        {title: "Prix d'achat", dataIndex: 'purchaseDecimal', width: 80},
        {title: 'Prix de détail', dataIndex: 'commodityDecimal', width: 80},
        {title: 'Prix de vente', dataIndex: 'wholesaleDecimal', width: 80},
        {title: 'Prix de vente minimum', dataIndex: 'lowDecimal', width: 80},
        {title: 'Emplacement/Étagère', dataIndex: 'position', width: 80},
        {title: 'Remarque', dataIndex: 'remark', width: 80},
        {title: 'État', dataIndex: 'enabled', align: "center", width: 60,
          scopedSlots: { customRender: 'customRenderEnabled' }
        }
      ],
      url: {
        list: "/material/list",
        delete: "/material/delete",
        deleteBatch: "/material/deleteBatch",
        importExcelUrl: "/material/importExcel",
        exportXlsUrl: "/material/exportExcel",
        batchSetStatusUrl: "/material/batchSetStatus",
        batchSetMaterialCurrentStockUrl: "/material/batchSetMaterialCurrentStock",
        batchSetMaterialCurrentUnitPriceUrl: "/material/batchSetMaterialCurrentUnitPrice",
      }
    }
  },
  created() {
    this.model = Object.assign({}, {});
    this.initColumnsSetting()
    this.loadTreeData()
    this.handleChangeOtherField(1)
  },
  computed: {
    importExcelUrl: function () {
      return `${window._CONFIG['domianURL']}${this.url.importExcelUrl}`;
    }
  },
  methods: {
    // Charger les colonnes d'initialisation
    initColumnsSetting(){
      let columnsStr = Vue.ls.get('materialColumns')
      if(columnsStr && columnsStr.indexOf(',')>-1) {
        this.settingDataIndex = columnsStr.split(',')
      } else {
        this.settingDataIndex = this.defDataIndex
      }
      this.columns = this.defColumns.filter(item => {
        return this.settingDataIndex.includes(item.dataIndex)
      })
    },
    // Événement de changement des paramètres de colonnes
    onColChange (checkedValues) {
      this.columns = this.defColumns.filter(item => {
        return checkedValues.includes(item.dataIndex)
      })
      let columnsStr = checkedValues.join()
      Vue.ls.set('materialColumns', columnsStr)
    },
    // Restaurer par défaut
    handleRestDefault() {
      Vue.ls.remove('materialColumns')
      this.initColumnsSetting()
    },
    loadTreeData(){
      let that = this;
      let params = {};
      params.id='';
      queryMaterialCategoryTreeList(params).then((res)=>{
        if(res){
          that.categoryTree = [];
          for (let i = 0; i < res.length; i++) {
            let temp = res[i];
            that.categoryTree.push(temp);
          }
        }
      })
    },
    batchSetMaterialCurrentStock () {
      if (this.selectedRowKeys.length <= 0) {
        this.$message.warning('Veuillez sélectionner au moins un enregistrement !');
      } else {
        let ids = "";
        for (let a = 0; a < this.selectedRowKeys.length; a++) {
          ids += this.selectedRowKeys[a] + ",";
        }
        let that = this;
        this.$confirm({
          title: "Confirmer l'opération",
          content: "Voulez-vous traiter les données sélectionnées ?",
          onOk: function () {
            that.loading = true;
            postAction(that.url.batchSetMaterialCurrentStockUrl, {ids: ids}).then((res) => {
              if(res.code === 200){
                that.$message.info('Correction du stock réussie !');
                that.loadData();
                that.onClearSelected();
              } else {
                that.$message.warning(res.data.message);
              }
            }).finally(() => {
              that.loading = false;
            });
          }
        });
      }
    },
    batchSetMaterialCurrentUnitPrice () {
      if (this.selectedRowKeys.length <= 0) {
        this.$message.warning('Veuillez sélectionner au moins un enregistrement !');
      } else {
        let ids = "";
        for (let a = 0; a < this.selectedRowKeys.length; a++) {
          ids += this.selectedRowKeys[a] + ",";
        }
        let that = this;
        this.$confirm({
          title: "Confirmer l'opération",
          content: "Voulez-vous traiter les données sélectionnées ?",
          onOk: function () {
            that.loading = true;
            postAction(that.url.batchSetMaterialCurrentUnitPriceUrl, {ids: ids}).then((res) => {
              if(res.code === 200){
                that.$message.info('Correction du coût réussie !');
                that.loadData();
                that.onClearSelected();
              } else {
                that.$message.warning(res.data.message);
              }
            }).finally(() => {
              that.loading = false;
            });
          }
        });
      }
    },
    batchEdit() {
      if (this.selectedRowKeys.length <= 0) {
        this.$message.warning('Veuillez sélectionner au moins un enregistrement !');
      } else {
        let ids = "";
        for (let a = 0; a < this.selectedRowKeys.length; a++) {
          if(a === this.selectedRowKeys.length-1) {
            ids += this.selectedRowKeys[a]
          } else {
            ids += this.selectedRowKeys[a] + ','
          }
        }
        this.$refs.batchSetInfoModalForm.edit(ids);
        this.$refs.batchSetInfoModalForm.title = "Modification en lot";
      }
    },
    handleAdd: function () {
      this.$refs.modalForm.action = "add";
      this.$refs.modalForm.add();
      this.$refs.modalForm.title = "Ajouter";
      this.$refs.modalForm.disableSubmit = false;
    },
    handleEdit: function (record) {
      this.$refs.modalForm.action = "edit";
      this.$refs.modalForm.edit(record);
      this.$refs.modalForm.title = "Modifier";
      this.$refs.modalForm.disableSubmit = false;
      if(this.btnEnableList.indexOf(1)===-1) {
        this.$refs.modalForm.showOkFlag = false
      }
    },
    handleCopyAdd(record) {
      this.$refs.modalForm.action = "copyAdd";
      this.$refs.modalForm.edit(record);
      this.$refs.modalForm.title = "Copier et ajouter";
      this.$refs.modalForm.disableSubmit = false;
    },
    getImgUrl(imgName, type) {
      if(imgName && imgName.split(',')) {
        type = type? type + '/':''
        return getFileAccessHttpUrl('systemConfig/static/' + type + imgName.split(',')[0])
      } else {
        return ''
      }
    },
    handleImportXls() {
      let importExcelUrl = this.url.importExcelUrl
      let templateUrl = '/doc/goods_template.xls'
      let templateName = 'Modèle Excel de produits [Télécharger]'
      this.$refs.modalImportForm.initModal(importExcelUrl, templateUrl, templateName);
      this.$refs.modalImportForm.title = "Importation de produits";
    },
    searchReset() {
      this.queryParam = {
        mpList: getMpListShort(Vue.ls.get('materialPropertyList'))  // Attributs d'extension
      }
      this.loadData(1);
    }
  }
}
</script>
<style scoped>
@import '~@assets/less/common.less';
</style>
<style>
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
