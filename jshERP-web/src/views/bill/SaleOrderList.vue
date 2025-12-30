<!-- create jishenghua-->
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
                  <a-form-item label="État du document" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-select
                      placeholder="Veuillez sélectionner l'état du document"
                      allow-clear
                      v-model="queryParam.status"
                    >
                      <a-select-option value="0">Non audité</a-select-option>
                      <a-select-option value="9" v-if="!checkFlag">En cours d'audit</a-select-option>
                      <a-select-option value="1">Audité</a-select-option>
                      <a-select-option value="3">Vente partielle</a-select-option>
                      <a-select-option value="2">Vente terminée</a-select-option>
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
          <a-button
            v-if="quickBtn.saleOut.indexOf(1) > -1 && btnEnableList.indexOf(1) > -1"
            icon="share-alt"
            @click="transferBill('转销售出库', quickBtn.saleOut)"
            >Convertir en sortie de vente</a-button
          >
          <a-button
            v-if="quickBtn.purchaseOrder.indexOf(1) > -1 && purchaseBySaleFlag && btnEnableList.indexOf(1) > -1"
            icon="share-alt"
            @click="transferBill('转采购订单-以销定购', quickBtn.purchaseOrder)"
            >Convertir en commande d'achat - Achat basé sur la vente</a-button
          >
          <a-tooltip title="Les documents avec l'état 'Vente partielle' peuvent être forcés à terminé">
            <a-button v-if="btnEnableList.indexOf(1) > -1" icon="issues-close" @click="batchForceClose"
              >Forcer la clôture</a-button
            >
          </a-tooltip>
          <a-tooltip title="Les documents avec l'état 'Achat partiel' peuvent être forcés à terminé">
            <a-button
              v-if="purchaseBySaleFlag && btnEnableList.indexOf(1) > -1"
              icon="issues-close"
              @click="batchForceClosePurchase"
              >Forcer la clôture - Achat basé sur la vente</a-button
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
                  <a-col v-for="item in defColumns" :key="item.dataIndex" :span="8">
                    <a-checkbox :value="item.dataIndex">
                      <j-ellipsis :value="item.title" :length="10"></j-ellipsis>
                    </a-checkbox>
                  </a-col>
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
            title="La commande de vente n'implique pas de montant de recouvrement. La commande de vente peut être convertie en document de sortie de vente, mais la commande de vente doit d'abord être audité. Après avoir coché les documents, vous pouvez effectuer des opérations par lots (suppression, audit, désaudit)"
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
              <a @click="myHandleDetail(record, '销售订单', prefixNo)">Voir</a>
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
              <a-tag v-if="status == '2'" color="cyan">Vente terminée</a-tag>
              <a-tag v-if="status == '3'" color="blue">Vente partielle</a-tag>
              <a-tag v-if="status == '9'" color="orange">En cours d'audit</a-tag>
            </template>
            <template slot="customRenderPurchaseStatus" slot-scope="purchaseStatus">
              <a-tag v-if="purchaseStatus == '0'" color="red">Non acheté</a-tag>
              <a-tag v-if="purchaseStatus == '2'" color="cyan">Achat terminé</a-tag>
              <a-tag v-if="purchaseStatus == '3'" color="blue">Achat partiel</a-tag>
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
        <sale-order-modal ref="modalForm" @ok="modalFormOk" @close="modalFormClose"></sale-order-modal>
        <sale-out-modal ref="transferModalForm" @ok="modalFormOk" @close="modalFormClose"></sale-out-modal>
        <purchase-order-modal
          ref="transferPurchaseModalForm"
          @ok="modalFormOk"
          @close="modalFormClose"
        ></purchase-order-modal>
        <bill-detail ref="modalDetail" @ok="modalFormOk" @close="modalFormClose"></bill-detail>
        <bill-excel-iframe ref="billExcelIframe" @ok="modalFormOk" @close="modalFormClose"></bill-excel-iframe>
      </a-card>
    </a-col>
  </a-row>
</template>
<script>
import SaleOrderModal from './modules/SaleOrderModal'
import SaleOutModal from './modules/SaleOutModal'
import PurchaseOrderModal from './modules/PurchaseOrderModal'
import BillDetail from './dialog/BillDetail'
import BillExcelIframe from '@/components/tools/BillExcelIframe'
import { JeecgListMixin } from '@/mixins/JeecgListMixin'
import { BillListMixin } from './mixins/BillListMixin'
import { getCurrentSystemConfig } from '@/api/api'
import JEllipsis from '@/components/jeecg/JEllipsis'
import JDate from '@/components/jeecg/JDate'
import Vue from 'vue'
export default {
  name: 'SaleOrderList',
  mixins: [JeecgListMixin, BillListMixin],
  components: {
    SaleOrderModal,
    SaleOutModal,
    PurchaseOrderModal,
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
        type: '其它',
        subType: '销售订单',
        organId: undefined,
        depotId: undefined,
        creator: undefined,
        status: undefined,
        salesMan: undefined,
        remark: '',
      },
      prefixNo: 'XSDD',
      urlPath: '/bill/sale_order',
      // Interrupteur d'achat basé sur la vente
      purchaseBySaleFlag: false,
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
        'changeAmount',
        'status',
        'purchaseStatus',
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
        { title: 'Numéro de document', dataIndex: 'number', width: 140 },
        { title: 'Informations produit', dataIndex: 'materialsList', width: 220, ellipsis: true },
        { title: 'Date du document', dataIndex: 'operTimeStr', width: 145 },
        { title: 'Vendeur', dataIndex: 'salesManStr', width: 120 },
        { title: 'Opérateur', dataIndex: 'userName', width: 80, ellipsis: true },
        { title: 'Quantité', dataIndex: 'materialCount', width: 60 },
        { title: 'Montant total', dataIndex: 'totalPrice', width: 80 },
        {
          title: 'Total TTC',
          dataIndex: 'totalTaxLastMoney',
          width: 80,
          customRender: function (text, record, index) {
            if (record.discountLastMoney) {
              return (record.discountMoney + record.discountLastMoney).toFixed(2)
            } else {
              return record.totalPrice
            }
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
        { title: 'Remise de recouvrement', dataIndex: 'discountMoney', width: 80 },
        { title: 'Montant après remise', dataIndex: 'discountLastMoney', width: 100 },
        { title: 'Compte de règlement', dataIndex: 'accountName', width: 80 },
        { title: 'Acompte perçu', dataIndex: 'changeAmount', width: 80 },
        { title: 'Remarque', dataIndex: 'remark', width: 200 },
        {
          title: "Progression de l'achat",
          dataIndex: 'purchaseStatus',
          width: 80,
          align: 'center',
          scopedSlots: { customRender: 'customRenderPurchaseStatus' },
        },
        {
          title: 'État',
          dataIndex: 'status',
          width: 70,
          align: 'center',
          scopedSlots: { customRender: 'customRenderStatus' },
        },
      ],
      url: {
        list: '/depotHead/list',
        delete: '/depotHead/delete',
        deleteBatch: '/depotHead/deleteBatch',
        forceCloseBatch: '/depotHead/forceCloseBatch',
        forceClosePurchaseBatch: '/depotHead/forceClosePurchaseBatch',
        batchSetStatusUrl: '/depotHead/batchSetStatus',
      },
    }
  },
  created() {
    this.initSystemConfig()
    this.initCustomer()
    this.initSalesman()
    this.initUser()
    this.getSystemConfig()
    this.initQuickBtn()
    this.getDepotByCurrentUser()
  },
  computed: {},
  methods: {
    getSystemConfig() {
      let statusIndex = 0
      for (let i = 0; i < this.columns.length; i++) {
        if (this.columns[i].dataIndex === 'purchaseStatus') {
          statusIndex = i
        }
      }
      getCurrentSystemConfig().then((res) => {
        if (res.code === 200 && res.data) {
          let purchaseBySaleFlag = res.data.purchaseBySaleFlag
          if (purchaseBySaleFlag === '0') {
            if (statusIndex > 0) {
              // Supprimer la colonne de progression d'achat
              this.columns.splice(statusIndex, 1)
            }
          } else {
            if (statusIndex === 0) {
              let purchaseStatusObj = {
                title: "Progression de l'achat",
                dataIndex: 'purchaseStatus',
                width: 70,
                align: 'center',
                scopedSlots: { customRender: 'customRenderPurchaseStatus' },
              }
              // Ajouter la colonne de progression d'achat
              this.columns.splice(statusIndex - 1, 0, purchaseStatusObj)
            }
          }
        } else {
          if (statusIndex > 0) {
            // Supprimer la colonne de progression d'achat
            this.columns.splice(statusIndex, 1)
          }
        }
      })
    },
    searchQuery() {
      this.loadData(1)
      this.getSystemConfig()
    },
  },
}
</script>
<style scoped>
@import '~@assets/less/common.less';
</style>
