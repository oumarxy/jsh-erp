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
                <a-form-item label="Nom" :labelCol="labelCol" :wrapperCol="wrapperCol">
                  <a-input placeholder="Veuillez saisir le nom pour rechercher" v-model="queryParam.supplier"></a-input>
                </a-form-item>
              </a-col>
              <a-col :md="6" :sm="24">
                <a-form-item label="Contact" :labelCol="labelCol" :wrapperCol="wrapperCol">
                  <a-input
                    placeholder="Veuillez saisir le contact pour rechercher"
                    v-model="queryParam.contacts"
                  ></a-input>
                </a-form-item>
              </a-col>
              <a-col :md="6" :sm="24">
                <a-form-item label="Numéro de téléphone portable" :labelCol="labelCol" :wrapperCol="wrapperCol">
                  <a-input
                    placeholder="Veuillez saisir le numéro de téléphone portable pour rechercher"
                    v-model="queryParam.telephone"
                  ></a-input>
                </a-form-item>
              </a-col>
              <a-col :md="6" :sm="24">
                <span style="float: left; overflow: hidden" class="table-page-search-submitButtons">
                  <a-button type="primary" @click="searchQuery">Rechercher</a-button>
                  <a-button style="margin-left: 8px" @click="searchReset">Réinitialiser</a-button>
                  <a @click="handleToggleSearch" style="margin-left: 8px">
                    {{ toggleSearchStatus ? 'Masquer' : 'Développer' }}
                    <a-icon :type="toggleSearchStatus ? 'up' : 'down'" />
                  </a>
                </span>
              </a-col>
            </a-row>
            <template v-if="toggleSearchStatus">
              <a-row :gutter="24">
                <a-col :md="6" :sm="24">
                  <a-form-item label="Numéro de téléphone" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-input
                      placeholder="Veuillez saisir le numéro de téléphone pour rechercher"
                      v-model="queryParam.phonenum"
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
          <a-button v-if="btnEnableList.indexOf(3) > -1" @click="handleExportXls('供应商信息')" icon="download"
            >Exporter</a-button
          >
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
            :pagination="ipagination"
            :scroll="scroll"
            :loading="loading"
            :rowSelection="{ selectedRowKeys: selectedRowKeys, onChange: onSelectChange }"
            @change="handleTableChange"
          >
            <span slot="action" slot-scope="text, record">
              <a @click="handleEdit(record)">Modifier</a>
              <a-divider v-if="btnEnableList.indexOf(1) > -1" type="vertical" />
              <a-popconfirm
                v-if="btnEnableList.indexOf(1) > -1"
                title="Êtes-vous sûr de vouloir supprimer ?"
                @confirm="() => handleDelete(record.id)"
              >
                <a>Supprimer</a>
              </a-popconfirm>
            </span>
            <!-- Modèle de rendu d'état -->
            <template slot="customRenderFlag" slot-scope="enabled">
              <a-tag v-if="enabled" color="green">Activé</a-tag>
              <a-tag v-if="!enabled" color="orange">Désactivé</a-tag>
            </template>
          </a-table>
        </div>
        <!-- Zone du tableau - fin -->
        <!-- Zone du formulaire -->
        <vendor-modal ref="modalForm" @ok="modalFormOk"></vendor-modal>
        <import-file-modal ref="modalImportForm" @ok="modalFormOk"></import-file-modal>
      </a-card>
    </a-col>
  </a-row>
</template>
<!-- b y 7 5 2 7  1 8 9 2 0 -->
<script>
import VendorModal from './modules/VendorModal'
import ImportFileModal from '@/components/tools/ImportFileModal'
import { JeecgListMixin } from '@/mixins/JeecgListMixin'
import JDate from '@/components/jeecg/JDate'
import Vue from 'vue'
export default {
  name: 'VendorList',
  mixins: [JeecgListMixin],
  components: {
    VendorModal,
    ImportFileModal,
    JDate,
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
        supplier: '',
        type: '供应商',
        contacts: '',
        telephone: '',
        phonenum: '',
      },
      urlPath: '/system/vendor',
      ipagination: {
        pageSizeOptions: ['10', '20', '30', '100', '200'],
      },
      // En-têtes de colonnes
      columns: [
        {
          title: '#',
          dataIndex: '',
          key: 'rowIndex',
          width: 60,
          align: 'center',
          customRender: function (t, r, index) {
            return parseInt(index) + 1
          },
        },
        {
          title: 'Opération',
          dataIndex: 'action',
          width: 130,
          align: 'center',
          scopedSlots: { customRender: 'action' },
        },
        { title: 'Nom', dataIndex: 'supplier', width: 150, align: 'left' },
        { title: 'Contact', dataIndex: 'contacts', width: 70, align: 'left' },
        { title: 'Numéro de téléphone portable', dataIndex: 'telephone', width: 100, align: 'left' },
        { title: 'Numéro de téléphone', dataIndex: 'phoneNum', width: 100, align: 'left' },
        { title: 'Adresse e-mail', dataIndex: 'email', width: 150, align: 'left' },
        { title: 'Dettes initiales', dataIndex: 'beginNeedPay', width: 80, align: 'left' },
        { title: 'Dettes finales', dataIndex: 'allNeedPay', width: 80, align: 'left' },
        { title: 'Taux de taxe (%)', dataIndex: 'taxRate', width: 80, align: 'left' },
        { title: 'Tri', dataIndex: 'sort', width: 60, align: 'left' },
        {
          title: 'État',
          dataIndex: 'enabled',
          width: 60,
          align: 'center',
          scopedSlots: { customRender: 'customRenderFlag' },
        },
      ],
      url: {
        list: '/supplier/list',
        delete: '/supplier/delete',
        deleteBatch: '/supplier/deleteBatch',
        importExcelUrl: '/supplier/importVendor',
        exportXlsUrl: '/supplier/exportExcel',
        batchSetStatusUrl: '/supplier/batchSetStatus',
      },
    }
  },
  computed: {
    importExcelUrl: function () {
      return `${window._CONFIG['domianURL']}${this.url.importExcelUrl}`
    },
  },
  created() {},
  methods: {
    searchReset() {
      this.queryParam = {
        type: '供应商',
      }
      this.loadData(1)
    },
    handleImportXls() {
      let importExcelUrl = this.url.importExcelUrl
      let templateUrl = '/doc/vendor_template.xls'
      let templateName = 'Modèle Excel de fournisseur [Télécharger]'
      this.$refs.modalImportForm.initModal(importExcelUrl, templateUrl, templateName)
      this.$refs.modalImportForm.title = 'Importation de fournisseurs'
    },
    handleEdit: function (record) {
      this.$refs.modalForm.edit(record)
      this.$refs.modalForm.title = 'Modifier'
      this.$refs.modalForm.disableSubmit = false
      if (this.btnEnableList.indexOf(1) === -1) {
        this.$refs.modalForm.isReadOnly = true
      }
    },
  },
}
</script>
<style scoped>
@import '~@assets/less/common.less';
</style>
