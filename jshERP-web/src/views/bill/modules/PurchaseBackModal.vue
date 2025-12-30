<template>
  <j-modal
    :title="title"
    :width="width"
    :visible="visible"
    :confirmLoading="confirmLoading"
    :keyboard="false"
    :forceRender="true"
    v-bind:prefixNo="prefixNo"
    fullscreen
    switchFullscreen
    @cancel="handleCancel"
    :id="prefixNo"
    style="top: 20px; height: 95%"
  >
    <template slot="footer">
      <a-button @click="handleCancel">Annuler</a-button>
      <a-button v-if="billPrintFlag && isShowPrintBtn" @click="handlePrintPro('采购退货出库')"
        >Impression en trois exemplaires - Nouvelle version</a-button
      >
      <a-button v-if="billPrintFlag && isShowPrintBtn" @click="handlePrint('采购退货出库')"
        >Impression en trois exemplaires</a-button
      >
      <a-button v-if="checkFlag && isCanCheck" :loading="confirmLoading" @click="handleOkAndCheck"
        >Enregistrer et auditer</a-button
      >
      <a-button type="primary" :loading="confirmLoading" @click="handleOk">Enregistrer (Ctrl+S)</a-button>
      <!-- Lancer l'audit multi-niveaux -->
      <a-button v-if="!checkFlag" @click="handleWorkflow()" type="primary">Soumettre le processus</a-button>
    </template>
    <a-spin :spinning="confirmLoading">
      <a-form :form="form">
        <a-row class="form-row" :gutter="24">
          <a-col :lg="6" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Fournisseur">
              <a-select
                placeholder="Veuillez sélectionner le fournisseur"
                v-decorator="['organId', validatorRules.organId]"
                :disabled="!rowCanEdit"
                :dropdownMatchSelectWidth="false"
                showSearch
                optionFilterProp="children"
                @search="handleSearchSupplier"
              >
                <div slot="dropdownRender" slot-scope="menu">
                  <v-nodes :vnodes="menu" />
                  <a-divider style="margin: 4px 0" />
                  <div
                    v-if="quickBtn.vendor"
                    class="dropdown-btn"
                    @mousedown="(e) => e.preventDefault()"
                    @click="addSupplier"
                  >
                    <a-icon type="plus" /> Ajouter un fournisseur
                  </div>
                  <div class="dropdown-btn" @mousedown="(e) => e.preventDefault()" @click="initSupplier(0)">
                    <a-icon type="reload" /> Actualiser la liste
                  </div>
                </div>
                <a-select-option v-for="(item, index) in supList" :key="index" :value="item.id">
                  {{ item.supplier }}
                </a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
          <a-col :lg="6" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Date du document">
              <j-date v-decorator="['operTime', validatorRules.operTime]" :show-time="true" />
            </a-form-item>
          </a-col>
          <a-col :lg="6" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de document">
              <a-input
                placeholder="Veuillez saisir le numéro de document"
                v-decorator.trim="['number', validatorRules.number]"
              />
            </a-form-item>
          </a-col>
          <a-col :lg="6" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Document associé">
              <a-input-search
                placeholder="Veuillez sélectionner le document associé"
                v-decorator="['linkNumber']"
                @search="onSearchLinkNumber"
                :readOnly="true"
              />
            </a-form-item>
          </a-col>
        </a-row>
        <j-editable-table
          id="billModal"
          :ref="refKeys[0]"
          :loading="materialTable.loading"
          :columns="materialTable.columns"
          :dataSource="materialTable.dataSource"
          :minWidth="minWidth"
          :maxHeight="300"
          :rowNumber="false"
          :rowSelection="true"
          :actionButton="rowCanEdit"
          :actionDeleteButton="!rowCanEdit"
          :dragSortAndNumber="rowCanEdit"
          @valueChange="onValueChange"
          @added="onAdded"
          @deleted="onDeleted"
        >
          <template #buttonAfter>
            <a-row
              v-if="rowCanEdit"
              :gutter="24"
              style="float: left; padding-bottom: 5px; padding-right: 8px"
              data-step="4"
              data-title="Saisie par scan"
              data-intro="Cette fonctionnalité prend en charge la saisie par scan du code-barres du produit avec un scanner"
            >
              <a-col v-if="scanStatus" :md="6" :sm="24">
                <a-button @click="scanEnter" style="margin-right: 8px">Saisie par scan</a-button>
              </a-col>
              <a-col v-if="!scanStatus" :md="16" :sm="24" style="padding: 0 6px 0 12px">
                <a-input
                  placeholder="Veuillez scanner le code-barres ou le numéro de série et appuyer sur Entrée"
                  v-model="scanBarCode"
                  @pressEnter="scanPressEnter"
                  ref="scanBarCode"
                />
              </a-col>
              <a-col v-if="!scanStatus" :md="6" :sm="24" style="padding: 0px 12px 0 0">
                <a-button @click="stopScan" style="margin-right: 8px">Masquer le scan</a-button>
              </a-col>
            </a-row>
          </template>
          <template #depotBatchSet>
            <a-icon type="down" @click="handleBatchSetDepot" />
          </template>
          <template #depotAdd>
            <a-divider v-if="quickBtn.depot" style="margin: 4px 0" />
            <div v-if="quickBtn.depot" class="dropdown-btn" @click="addDepot"><a-icon type="plus" /> Ajouter</div>
            <div class="dropdown-btn" @mousedown="(e) => e.preventDefault()" @click="initDepot">
              <a-icon type="reload" /> Actualiser
            </div>
          </template>
        </j-editable-table>
        <a-row class="form-row" :gutter="24">
          <a-col :lg="24" :md="24" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="{ xs: { span: 24 }, sm: { span: 24 } }" label="">
              <a-textarea
                :rows="1"
                placeholder="Veuillez saisir une remarque"
                v-decorator="['remark']"
                style="margin-top: 8px"
              />
            </a-form-item>
          </a-col>
        </a-row>
        <a-row class="form-row" :gutter="24">
          <a-col :lg="6" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Taux de remise">
              <a-input
                style="width: 80%"
                placeholder="Veuillez saisir le taux de remise"
                v-decorator.trim="['discount']"
                suffix="%"
                @change="onChangeDiscount"
              />
            </a-form-item>
          </a-col>
          <a-col :lg="6" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Remise de remboursement">
              <a-input
                placeholder="Veuillez saisir la remise de paiement"
                v-decorator.trim="['discountMoney']"
                @change="onChangeDiscountMoney"
              />
            </a-form-item>
          </a-col>
          <a-col :lg="6" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Montant après remise">
              <a-input
                placeholder="Veuillez saisir le montant après remise"
                v-decorator.trim="['discountLastMoney']"
                :readOnly="true"
              />
            </a-form-item>
          </a-col>
          <a-col :lg="6" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Autres frais">
              <a-input
                placeholder="Veuillez saisir les autres frais"
                v-decorator.trim="['otherMoney']"
                @change="onChangeOtherMoney"
              />
            </a-form-item>
          </a-col>
        </a-row>
        <a-row class="form-row" :gutter="24">
          <a-col :lg="6" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Compte de règlement">
              <a-select
                style="width: 80%"
                placeholder="Veuillez sélectionner le compte de règlement"
                v-decorator="['accountId', validatorRules.accountId]"
                :dropdownMatchSelectWidth="false"
                allowClear
                @select="selectAccount"
              >
                <div slot="dropdownRender" slot-scope="menu">
                  <v-nodes :vnodes="menu" />
                  <a-divider style="margin: 4px 0" />
                  <div
                    v-if="quickBtn.account"
                    class="dropdown-btn"
                    @mousedown="(e) => e.preventDefault()"
                    @click="addAccount"
                  >
                    <a-icon type="plus" /> Ajouter
                  </div>
                  <div class="dropdown-btn" @mousedown="(e) => e.preventDefault()" @click="initAccount(0)">
                    <a-icon type="reload" /> Actualiser
                  </div>
                </div>
                <a-select-option v-for="(item, index) in accountList" :key="index" :value="item.id">
                  {{ item.name }}
                </a-select-option>
              </a-select>
              <a-tooltip title="Détails des comptes multiples">
                <a-button
                  type="default"
                  icon="folder"
                  style="margin-left: 8px"
                  size="small"
                  v-show="manyAccountBtnStatus"
                  @click="handleManyAccount"
                />
              </a-tooltip>
            </a-form-item>
          </a-col>
          <a-col :lg="6" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Remboursement actuel">
              <a-input
                placeholder="Veuillez saisir le remboursement actuel"
                v-decorator.trim="['changeAmount']"
                @change="onChangeChangeAmount"
              />
            </a-form-item>
          </a-col>
          <a-col :lg="6" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Dette actuelle">
              <a-input placeholder="Veuillez saisir la dette actuelle" v-decorator.trim="['debt']" :readOnly="true" />
            </a-form-item>
          </a-col>
          <a-col :lg="6" :md="12" :sm="24"> </a-col>
        </a-row>
        <a-row class="form-row" :gutter="24">
          <a-col :lg="6" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Pièce jointe">
              <j-upload v-model="fileList" bizPath="bill"></j-upload>
            </a-form-item>
          </a-col>
        </a-row>
      </a-form>
    </a-spin>
    <many-account-modal ref="manyAccountModalForm" @ok="manyAccountModalFormOk"></many-account-modal>
    <link-bill-list ref="linkBillList" @ok="linkBillListOk"></link-bill-list>
    <vendor-modal ref="vendorModalForm" @ok="vendorModalFormOk"></vendor-modal>
    <depot-modal ref="depotModalForm" @ok="depotModalFormOk"></depot-modal>
    <account-modal ref="accountModalForm" @ok="accountModalFormOk"></account-modal>
    <batch-set-depot ref="batchSetDepotModalForm" @ok="batchSetDepotModalFormOk"></batch-set-depot>
    <workflow-iframe ref="modalWorkflow" @ok="workflowModalFormOk"></workflow-iframe>
    <bill-print-iframe ref="modalPrint"></bill-print-iframe>
    <bill-print-pro-iframe ref="modalPrintPro"></bill-print-pro-iframe>
  </j-modal>
</template>
<script>
import pick from 'lodash.pick'
import ManyAccountModal from '../dialog/ManyAccountModal'
import LinkBillList from '../dialog/LinkBillList'
import VendorModal from '../../system/modules/VendorModal'
import DepotModal from '../../system/modules/DepotModal'
import AccountModal from '../../system/modules/AccountModal'
import BatchSetDepot from '../dialog/BatchSetDepot'
import WorkflowIframe from '@/components/tools/WorkflowIframe'
import BillPrintIframe from '../dialog/BillPrintIframe'
import BillPrintProIframe from '../dialog/BillPrintProIframe'
import { FormTypes } from '@/utils/JEditableTableUtil'
import { JEditableTableMixin } from '@/mixins/JEditableTableMixin'
import { BillModalMixin } from '../mixins/BillModalMixin'
import { getMpListShort } from '@/utils/util'
import JUpload from '@/components/jeecg/JUpload'
import JDate from '@/components/jeecg/JDate'
import Vue from 'vue'
import { getCurrentSystemConfig, findBySelectSup } from '@/api/api'
export default {
  name: 'PurchaseBackModal',
  mixins: [JEditableTableMixin, BillModalMixin],
  components: {
    ManyAccountModal,
    LinkBillList,
    VendorModal,
    DepotModal,
    AccountModal,
    BatchSetDepot,
    WorkflowIframe,
    BillPrintIframe,
    BillPrintProIframe,
    JUpload,
    JDate,
    VNodes: {
      functional: true,
      render: (h, ctx) => ctx.props.vnodes,
    },
  },
  data() {
    return {
      title: 'Opération',
      width: '1600px',
      moreStatus: false,
      // Nombre de lignes de données vides ajoutées par défaut dans le sous-tableau lors de l'ajout
      addDefaultRowNum: 1,
      visible: false,
      operTimeStr: '',
      prefixNo: 'CGTH',
      fileList: [],
      rowCanEdit: true,
      model: {},
      labelCol: {
        xs: { span: 24 },
        sm: { span: 8 },
      },
      wrapperCol: {
        xs: { span: 24 },
        sm: { span: 16 },
      },
      refKeys: ['materialDataTable'],
      activeKey: 'materialDataTable',
      materialTable: {
        loading: false,
        dataSource: [],
        columns: [
          {
            title: "Nom de l'entrepôt",
            key: 'depotId',
            width: '8%',
            type: FormTypes.select,
            placeholder: 'Veuillez sélectionner ${title}',
            options: [],
            allowSearch: true,
            validateRules: [{ required: true, message: '${title} ne peut pas être vide' }],
          },
          {
            title: 'Code-barres',
            key: 'barCode',
            width: '12%',
            type: FormTypes.popupJsh,
            kind: 'material',
            multi: true,
            validateRules: [{ required: true, message: '${title} ne peut pas être vide' }],
          },
          { title: 'Nom', key: 'name', width: '10%', type: FormTypes.normal },
          { title: 'Spécification', key: 'standard', width: '9%', type: FormTypes.normal },
          { title: 'Modèle', key: 'model', width: '9%', type: FormTypes.normal },
          { title: 'Couleur', key: 'color', width: '5%', type: FormTypes.normal },
          { title: 'Marque', key: 'brand', width: '6%', type: FormTypes.normal },
          { title: 'Fabricant', key: 'mfrs', width: '6%', type: FormTypes.normal },
          { title: 'Extension 1', key: 'otherField1', width: '4%', type: FormTypes.normal },
          { title: 'Extension 2', key: 'otherField2', width: '4%', type: FormTypes.normal },
          { title: 'Extension 3', key: 'otherField3', width: '4%', type: FormTypes.normal },
          { title: 'Stock', key: 'stock', width: '5%', type: FormTypes.normal },
          { title: 'Unité', key: 'unit', width: '4%', type: FormTypes.normal },
          { title: 'Numéro de série', key: 'snList', width: '12%', type: FormTypes.popupJsh, kind: 'sn', multi: true },
          { title: 'Numéro de lot', key: 'batchNumber', width: '7%', type: FormTypes.popupJsh, kind: 'batch', multi: false },
          { title: "Date d'expiration", key: 'expirationDate', width: '7%', type: FormTypes.input, readonly: true },
          { title: 'Multi-attributs', key: 'sku', width: '9%', type: FormTypes.normal },
          { title: "Quantité d'origine", key: 'preNumber', width: '5%', type: FormTypes.normal },
          { title: 'Déjà retourné', key: 'finishNumber', width: '5%', type: FormTypes.normal },
          {
            title: 'Quantité',
            key: 'operNumber',
            width: '5%',
            type: FormTypes.inputNumber,
            statistics: true,
            validateRules: [{ required: true, message: '${title} ne peut pas être vide' }],
          },
          { title: 'Prix unitaire', key: 'unitPrice', width: '5%', type: FormTypes.inputNumber },
          { title: 'Montant', key: 'allPrice', width: '5%', type: FormTypes.inputNumber, statistics: true },
          { title: 'Taux de taxe', key: 'taxRate', width: '4%', type: FormTypes.inputNumber, placeholder: '%' },
          {
            title: 'Montant de la taxe',
            key: 'taxMoney',
            width: '5%',
            type: FormTypes.inputNumber,
            readonly: true,
            statistics: true,
          },
          { title: 'Total TTC', key: 'taxLastMoney', width: '7%', type: FormTypes.inputNumber, statistics: true },
          { title: 'Remarque', key: 'remark', width: '6%', type: FormTypes.input },
          { title: 'ID associé', key: 'linkId', width: '5%', type: FormTypes.hidden },
          { title: 'Rééditer', key: 'isEdit', width: '5%', type: FormTypes.hidden },
        ],
      },
      confirmLoading: false,
      validatorRules: {
        operTime: {
          rules: [{ required: true, message: 'Veuillez saisir la date du document !' }],
        },
        number: {
          rules: [{ required: true, message: 'Veuillez saisir le numéro de document !' }],
        },
        organId: {
          rules: [{ required: true, message: 'Veuillez sélectionner le fournisseur !' }],
        },
        accountId: {
          rules: [{ required: true, message: 'Veuillez sélectionner le compte de règlement !' }],
        },
      },
      url: {
        add: '/depotHead/addDepotHeadAndDetail',
        edit: '/depotHead/updateDepotHeadAndDetail',
        detailList: '/depotItem/getDetailList',
      },
    }
  },
  created() {},
  methods: {
    // Cette méthode est appelée automatiquement après l'appel de la méthode edit()
    editAfter() {
      this.billStatus = '0'
      this.currentSelectDepotId = ''
      this.rowCanEdit = true
      this.materialTable.columns[1].type = FormTypes.popupJsh
      this.changeColumnHide()
      this.changeFormTypes(this.materialTable.columns, 'snList', 0)
      this.changeFormTypes(this.materialTable.columns, 'batchNumber', 0)
      this.changeFormTypes(this.materialTable.columns, 'expirationDate', 0)
      this.changeFormTypes(this.materialTable.columns, 'preNumber', 0)
      this.changeFormTypes(this.materialTable.columns, 'finishNumber', 0)
      if (this.action === 'add') {
        this.addInit(this.prefixNo)
        this.fileList = []
        this.$nextTick(() => {
          if (this.transferParam && this.transferParam.number) {
            let tp = this.transferParam
            this.linkBillListOk(
              tp.list,
              tp.number,
              tp.organId,
              tp.discountMoney,
              tp.deposit,
              tp.remark,
              this.defaultDepotId,
              tp.accountId
            )
          }
        })
      } else {
        if (this.model.linkNumber) {
          this.rowCanEdit = false
          this.materialTable.columns[1].type = FormTypes.normal
        }
        this.model.operTime = this.model.operTimeStr
        this.model.debt = (this.model.discountLastMoney + this.model.otherMoney - this.model.changeAmount).toFixed(2)
        if (this.model.accountId == null) {
          this.model.accountId = 0
          this.manyAccountBtnStatus = true
          this.accountIdList = this.model.accountIdList
          this.accountMoneyList = this.model.accountMoneyList
        } else {
          this.manyAccountBtnStatus = false
        }
        this.fileList = this.model.fileName
        this.$nextTick(() => {
          this.form.setFieldsValue(
            pick(
              this.model,
              'organId',
              'operTime',
              'number',
              'linkNumber',
              'remark',
              'discount',
              'discountMoney',
              'discountLastMoney',
              'otherMoney',
              'accountId',
              'changeAmount',
              'debt'
            )
          )
        })
        // Charger les données du sous-tableau
        let params = {
          headerId: this.model.id,
          mpList: getMpListShort(Vue.ls.get('materialPropertyList')), // Attributs étendus
          linkType: 'basic',
        }
        let url = this.readOnly ? this.url.detailList : this.url.detailList
        this.requestSubTableData(url, params, this.materialTable)
      }
      // Copier et ajouter un document - Initialiser le numéro et la date
      if (this.action === 'copyAdd') {
        this.model.id = ''
        this.model.tenantId = ''
        this.copyAddInit(this.prefixNo)
      }
      this.initSystemConfig()
      this.initSupplier(0)
      this.initDepot()
      this.initAccount(0)
      this.initPlatform()
      this.initQuickBtn()
      this.handleChangeOtherField()
    },
    // Organiser en formData lors de la soumission du document
    classifyIntoFormData(allValues) {
      let totalPrice = 0
      let billMain = Object.assign(this.model, allValues.formValue)
      let detailArr = allValues.tablesValue[0].values
      billMain.type = '出库'
      billMain.subType = '采购退货'
      for (let item of detailArr) {
        totalPrice += item.allPrice - 0
      }
      billMain.totalPrice = totalPrice
      if (billMain.accountId === 0) {
        billMain.accountId = ''
      }
      billMain.accountIdList = this.accountIdList.length > 0 ? JSON.stringify(this.accountIdList) : ''
      billMain.accountMoneyList = this.accountMoneyList.length > 0 ? JSON.stringify(this.accountMoneyList) : ''
      if (this.fileList && this.fileList.length > 0) {
        billMain.fileName = this.fileList
      } else {
        billMain.fileName = ''
      }
      if (this.model.id) {
        billMain.id = this.model.id
      }
      billMain.status = this.billStatus
      return {
        info: JSON.stringify(billMain),
        rows: JSON.stringify(detailArr),
      }
    },
    onSearchLinkNumber() {
      this.$refs.linkBillList.show('入库', '采购', '供应商', '1,2,3')
      this.$refs.linkBillList.title = "Veuillez sélectionner l'entrée d'achat"
    },
    linkBillListOk(selectBillDetailRows, linkNumber, organId, discountMoney, deposit, remark, depotId, accountId) {
      this.rowCanEdit = false
      this.materialTable.columns[1].type = FormTypes.normal
      this.changeFormTypes(this.materialTable.columns, 'preNumber', 1)
      this.changeFormTypes(this.materialTable.columns, 'finishNumber', 1)
      if (selectBillDetailRows && selectBillDetailRows.length > 0) {
        let listEx = []
        let allTaxLastMoney = 0
        for (let j = 0; j < selectBillDetailRows.length; j++) {
          let info = selectBillDetailRows[j]
          if (info.finishNumber > 0) {
            info.operNumber = info.preNumber - info.finishNumber
            info.allPrice = info.operNumber * info.unitPrice - 0
            let taxRate = info.taxRate - 0
            info.taxMoney = ((info.allPrice * taxRate) / 100).toFixed(2) - 0
            info.taxLastMoney = (info.allPrice + info.taxMoney).toFixed(2) - 0
          }
          info.linkId = info.id
          allTaxLastMoney += info.taxLastMoney
          if (info.operNumber > 0) {
            listEx.push(info)
            this.changeColumnShow(info)
          }
        }
        this.materialTable.dataSource = listEx
        /// Réassigner le montant après remise
        allTaxLastMoney = allTaxLastMoney ? allTaxLastMoney : 0
        let discount = 0
        if (allTaxLastMoney !== 0) {
          discount = ((discountMoney / allTaxLastMoney) * 100).toFixed(2) - 0
        }
        let discountLastMoney = (allTaxLastMoney - discountMoney).toFixed(2) - 0
        this.$nextTick(() => {
          this.form.setFieldsValue({
            organId: organId,
            linkNumber: linkNumber,
            discount: discount,
            discountMoney: discountMoney,
            discountLastMoney: discountLastMoney,
            changeAmount: discountLastMoney,
            accountId: accountId,
            remark: remark,
          })
          findBySelectSup({ organId: organId, limit: 1 }).then((res) => {
            this.supList = res && Array.isArray(res) ? res : []
          })
          getCurrentSystemConfig().then((res) => {
            if (res.code === 200 && res.data) {
              let flag = res.data.zeroChangeAmountFlag === '1' ? true : false
              if (flag) {
                // Changer le montant de recouvrement/paiement à 0
                let oldChangeAmount = this.form.getFieldValue('changeAmount') - 0
                this.form.setFieldsValue({ changeAmount: 0, debt: oldChangeAmount })
              }
            }
          })
        })
      }
    },
  },
}
</script>
<style scoped></style>
