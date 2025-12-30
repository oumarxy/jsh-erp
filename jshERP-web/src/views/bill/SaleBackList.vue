<!-- create ji sheng hua-->
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
                <a-form-item label="Numéro de document" :labelCol="labelCol" :wrapperCol="wrapperCol">
                  <a-input placeholder="Veuillez saisir le numéro de document" v-model="queryParam.number"></a-input>
                </a-form-item>
              </a-col>
              <a-col :md="6" :sm="24">
                <a-form-item label="Informations produit" :labelCol="labelCol" :wrapperCol="wrapperCol">
                  <a-input
                    placeholder="Veuillez saisir le code-barres, nom, code mnémonique, spécification, modèle, etc."
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
                  <a-form-item label="Client" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-select
                      placeholder="Veuillez sélectionner le client"
                      showSearch
                      allow-clear
                      optionFilterProp="children"
                      v-model="queryParam.organId"
                      @search="handleSearchCustomer"
                    >
                      <div slot="dropdownRender" slot-scope="menu">
                        <v-nodes :vnodes="menu" />
                        <a-divider style="margin: 4px 0" />
                        <div class="dropdown-btn" @mousedown="(e) => e.preventDefault()" @click="initCustomer(0)">
                          <a-icon type="reload" /> Actualiser la liste
                        </div>
                      </div>
                      <a-select-option v-for="(item, index) in cusList" :key="index" :value="item.id">
                        {{ item.supplier }}
                      </a-select-option>
                    </a-select>
                  </a-form-item>
                </a-col>
                <a-col :md="6" :sm="24">
                  <a-form-item label="Nom de l'entrepôt" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-select
                      placeholder="Veuillez sélectionner l'entrepôt"
                      showSearch
                      allow-clear
                      optionFilterProp="children"
                      v-model="queryParam.depotId"
                    >
                      <a-select-option v-for="(depot, index) in depotList" :key="index" :value="depot.id">
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
                <a-col :md="6" :sm="24">
                  <a-form-item label="Document associé" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-input
                      placeholder="Veuillez saisir le document associé"
                      v-model="queryParam.linkNumber"
                    ></a-input>
                  </a-form-item>
                </a-col>
                <a-col :md="6" :sm="24">
                  <a-form-item label="Compte de règlement" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-select
                      placeholder="Veuillez sélectionner le compte de règlement"
                      showSearch
                      allow-clear
                      optionFilterProp="children"
                      v-model="queryParam.accountId"
                    >
                      <a-select-option v-for="(item, index) in accountList" :key="index" :value="item.id">
                        {{ item.name }}
                      </a-select-option>
                    </a-select>
                  </a-form-item>
                </a-col>
                <a-col :md="6" :sm="24">
                  <a-form-item label="État du document" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-select
                      placeholder="Veuillez sélectionner l'état du document"
                      allow-clear
                      v-model="queryParam.status"
                    >
                      <a-select-option value="0">Non audité</a-select-option>
                      <a-select-option value="9" v-if="!checkFlag">En cours d'audit</a-select-option>
                      <a-select-option value="1">Audité</a-select-option>
                      <a-select-option value="3">Entrée partielle</a-select-option>
                      <a-select-option value="2">Entrée terminée</a-select-option>
                    </a-select>
                  </a-form-item>
                </a-col>
                <a-col :md="6" :sm="24">
                  <a-form-item label="Vendeur" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-select
                      placeholder="Veuillez sélectionner le vendeur"
                      showSearch
                      allow-clear
                      optionFilterProp="children"
                      v-model="queryParam.salesMan"
                    >
                      <a-select-option v-for="(item, index) in salesManList" :key="index" :value="item.value">
                        {{ item.text }}
                      </a-select-option>
                    </a-select>
                  </a-form-item>
                </a-col>
                <a-col :md="6" :sm="24">
                  <a-form-item label="Remarque du document" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-input
                      placeholder="Veuillez saisir la remarque du document"
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
          <a-button v-if="btnEnableList.indexOf(1) > -1" @click="myHandleAdd" type="primary" icon="plus"
            >Ajouter</a-button
          >
          <a-button v-if="btnEnableList.indexOf(1) > -1" icon="delete" @click="batchDel">Supprimer</a-button>
          <a-tooltip title="Les documents avec l'état 'Entrée partielle' peuvent être forcés à terminé">
            <a-button
              v-if="inOutManageFlag && btnEnableList.indexOf(1) > -1"
              icon="issues-close"
              @click="batchForceClose"
              >Forcer la clôture</a-button
            >
          </a-tooltip>
          <a-button v-if="checkFlag && btnEnableList.indexOf(2) > -1" icon="check" @click="batchSetStatus(1)"
            >Auditer</a-button
          >
          <a-button v-if="checkFlag && btnEnableList.indexOf(7) > -1" icon="stop" @click="batchSetStatus(0)"
            >Désauditer</a-button
          >
          <a-button v-if="isShowExcel && btnEnableList.indexOf(3) > -1" icon="download" @click="handleExport"
            >Exporter</a-button
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
                    Restaurer la configuration par défaut des colonnes :
                    <a-button @click="handleRestDefault" type="link" size="small">Restaurer par défaut</a-button>
                  </a-col>
                </a-row>
              </a-checkbox-group>
            </template>
            <a-button icon="setting">Paramètres de colonnes</a-button>
          </a-popover>
          <a-tooltip
            placement="left"
            title="Utilisé pour les retours de documents de sortie de vente. Le document de retour de vente peut être converti depuis un document de sortie de vente ou créé séparément."
            slot="action"
          >
            <a-icon v-if="btnEnableList.indexOf(1) > -1" type="question-circle" style="font-size: 20px; float: right" />
          </a-tooltip>
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
            :rowSelection="{ selectedRowKeys: selectedRowKeys, onChange: onSelectChange }"
            :expandedRowKeys="expandedRowKeys"
            @expand="onExpand"
            @change="handleTableChange"
          >
            <span slot="action" slot-scope="text, record">
              <a @click="myHandleDetail(record, '销售退货入库', prefixNo)">Voir</a>
              <a-divider v-if="btnEnableList.indexOf(1) > -1" type="vertical" />
              <a v-if="btnEnableList.indexOf(1) > -1" @click="myHandleEdit(record)">Modifier</a>
              <a-divider v-if="btnEnableList.indexOf(1) > -1" type="vertical" />
              <a v-if="btnEnableList.indexOf(1) > -1" @click="myHandleCopyAdd(record)">Copier</a>
              <a-divider v-if="btnEnableList.indexOf(1) > -1" type="vertical" />
              <a-popconfirm
                v-if="btnEnableList.indexOf(1) > -1"
                title="Êtes-vous sûr de vouloir supprimer ?"
                @confirm="() => myHandleDelete(record)"
              >
                <a>Supprimer</a>
              </a-popconfirm>
            </span>
            <template slot="customRenderStatus" slot-scope="status">
              <a-tag v-if="status == '0'" color="red">Non audité</a-tag>
              <a-tag v-if="status == '1'" color="green">Audité</a-tag>
              <a-tag v-if="status == '2'" color="cyan">Entrée terminée</a-tag>
              <a-tag v-if="status == '3'" color="blue">Entrée partielle</a-tag>
              <a-tag v-if="status == '9'" color="orange">En cours d'audit</a-tag>
            </template>
            <a-table
              bordered
              size="small"
              slot="expandedRowRender"
              slot-scope="record"
              :loading="record.loading"
              :columns="detailColumns"
              :dataSource="record.childrens"
              :row-key="(record) => record.id"
              :pagination="false"
            >
            </a-table>
          </a-table>
        </div>
        <!-- Zone du tableau - fin -->
        <!-- Zone du formulaire -->
        <sale-back-modal ref="modalForm" @ok="modalFormOk" @close="modalFormClose"></sale-back-modal>
        <bill-detail ref="modalDetail" @ok="modalFormOk" @close="modalFormClose"></bill-detail>
        <bill-excel-iframe ref="billExcelIframe" @ok="modalFormOk" @close="modalFormClose"></bill-excel-iframe>
      </a-card>
    </a-col>
  </a-row>
</template>
<script>
import SaleBackModal from './modules/SaleBackModal'
import BillDetail from './dialog/BillDetail'
import BillExcelIframe from '@/components/tools/BillExcelIframe'
import { JeecgListMixin } from '@/mixins/JeecgListMixin'
import { BillListMixin } from './mixins/BillListMixin'
import JEllipsis from '@/components/jeecg/JEllipsis'
import JDate from '@/components/jeecg/JDate'
import Vue from 'vue'
export default {
  name: 'SaleBackList',
  mixins: [JeecgListMixin, BillListMixin],
  components: {
    SaleBackModal,
    BillDetail,
    BillExcelIframe,
    JEllipsis,
    JDate,
    VNodes: {
      functional: true,
      render: (h, ctx) => ctx.props.vnodes,
    },
  },
  data() {
    return {
      // Conditions de recherche
      queryParam: {
        number: '',
        materialParam: '',
        type: '入库',
        subType: '销售退货',
        organId: undefined,
        depotId: undefined,
        creator: undefined,
        linkNumber: '',
        accountId: undefined,
        status: undefined,
        salesMan: undefined,
        remark: '',
      },
      prefixNo: 'XSTH',
      urlPath: '/bill/sale_back',
      // Interrupteur de gestion d'entrée/sortie, adapté aux scénarios de gestion d'entrepôt indépendante
      inOutManageFlag: false,
      labelCol: {
        span: 5,
      },
      wrapperCol: {
        span: 18,
        offset: 1,
      },
      // Index par défaut
      defDataIndex: [
        'action',
        'organName',
        'number',
        'materialsList',
        'operTimeStr',
        'userName',
        'materialCount',
        'totalPrice',
        'totalTaxLastMoney',
        'needBackMoney',
        'changeAmount',
        'debt',
        'status',
      ],
      // Colonnes par défaut
      defColumns: [
        {
          title: 'Opération',
          dataIndex: 'action',
          align: 'center',
          width: 180,
          scopedSlots: { customRender: 'action' },
        },
        { title: 'Client', dataIndex: 'organName', width: 120, ellipsis: true },
        {
          title: 'Numéro de document',
          dataIndex: 'number',
          width: 160,
          customRender: function (text, record, index) {
            text = record.linkNumber ? text + '[转]' : text
            return text
          },
        },
        { title: 'Document associé', dataIndex: 'linkNumber', width: 140 },
        { title: 'Informations produit', dataIndex: 'materialsList', width: 220, ellipsis: true },
        { title: 'Date du document', dataIndex: 'operTimeStr', width: 145 },
        { title: 'Opérateur', dataIndex: 'userName', width: 80, ellipsis: true },
        { title: 'Quantité', dataIndex: 'materialCount', width: 60 },
        { title: 'Montant total', dataIndex: 'totalPrice', width: 80 },
        {
          title: 'Total TTC',
          dataIndex: 'totalTaxLastMoney',
          width: 80,
          customRender: function (text, record, index) {
            return (record.discountMoney + record.discountLastMoney).toFixed(2)
          },
        },
        {
          title: 'Taux de remise',
          dataIndex: 'discount',
          width: 60,
          customRender: function (text, record, index) {
            return text ? text + '%' : ''
          },
        },
        { title: 'Remise de remboursement', dataIndex: 'discountMoney', width: 80 },
        { title: 'Autres frais', dataIndex: 'otherMoney', width: 80 },
        {
          title: 'Montant à rembourser',
          dataIndex: 'needBackMoney',
          width: 80,
          customRender: function (text, record, index) {
            let needBackMoney = record.discountLastMoney + record.otherMoney
            return needBackMoney ? needBackMoney.toFixed(2) : 0
          },
        },
        { title: 'Compte de règlement', dataIndex: 'accountName', width: 80 },
        { title: 'Remboursement actuel', dataIndex: 'changeAmount', width: 80 },
        { title: 'Dette actuelle', dataIndex: 'debt', width: 80 },
        { title: 'Vendeur', dataIndex: 'salesManStr', width: 120 },
        { title: 'Remarque', dataIndex: 'remark', width: 200 },
        {
          title: 'État',
          dataIndex: 'status',
          width: 80,
          align: 'center',
          scopedSlots: { customRender: 'customRenderStatus' },
        },
      ],
      url: {
        list: '/depotHead/list',
        delete: '/depotHead/delete',
        deleteBatch: '/depotHead/deleteBatch',
        forceCloseBatch: '/depotHead/forceCloseBatch',
        batchSetStatusUrl: '/depotHead/batchSetStatus',
      },
    }
  },
  computed: {},
  created() {
    this.initSystemConfig()
    this.initCustomer()
    this.initSalesman()
    this.getDepotData()
    this.initUser()
    this.initAccount()
  },
  methods: {},
}
</script>
<style scoped>
@import '~@assets/less/common.less';
</style>
