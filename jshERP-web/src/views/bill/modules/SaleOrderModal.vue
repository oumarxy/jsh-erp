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
    switchHelp
    switchFullscreen
    @cancel="handleCancel"
    :id="prefixNo"
    style="top: 20px; height: 95%"
  >
    <template slot="footer">
      <a-button @click="handleCancel">Annuler</a-button>
      <a-button v-if="billPrintFlag && isShowPrintBtn" @click="handlePrintPro('销售订单')"
        >Impression en trois exemplaires - Nouvelle version</a-button
      >
      <a-button v-if="billPrintFlag && isShowPrintBtn" @click="handlePrint('销售订单')"
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
            <a-form-item
              :labelCol="labelCol"
              :wrapperCol="wrapperCol"
              label="Client"
              data-step="1"
              data-title="Client"
              data-intro="Le client doit être sélectionné. Si le client à sélectionner n'a pas encore été enregistré, vous pouvez cliquer sur Ajouter un client dans la liste déroulante pour l'enregistrer. Attention particulière : si le client n'apparaît pas dans la liste déroulante après l'enregistrement, veuillez vérifier si les permissions client correspondantes ont été attribuées à l'utilisateur actuel"
            >
              <a-select
                placeholder="Veuillez sélectionner le client"
                v-decorator="['organId', validatorRules.organId]"
                :dropdownMatchSelectWidth="false"
                showSearch
                optionFilterProp="children"
                @change="handleOrganChange"
                @search="handleSearchCustomer"
              >
                <div slot="dropdownRender" slot-scope="menu">
                  <v-nodes :vnodes="menu" />
                  <a-divider style="margin: 4px 0" />
                  <div
                    v-if="quickBtn.customer"
                    class="dropdown-btn"
                    @mousedown="(e) => e.preventDefault()"
                    @click="addCustomer"
                  >
                    <a-icon type="plus" /> Ajouter un client
                  </div>
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
          <a-col :lg="6" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Date du document">
              <j-date v-decorator="['operTime', validatorRules.operTime]" :show-time="true" />
            </a-form-item>
          </a-col>
          <a-col :lg="6" :md="12" :sm="24">
            <a-form-item
              :labelCol="labelCol"
              :wrapperCol="wrapperCol"
              label="Numéro de document"
              data-step="2"
              data-title="Numéro de document"
              data-intro="Le numéro de document est généré automatiquement et incrémenté automatiquement. Il commence par les initiales du type de document. La règle d'incrémentation est que chaque ouverture de page occupe automatiquement un nouveau numéro"
            >
              <a-input
                placeholder="Veuillez saisir le numéro de document"
                v-decorator.trim="['number', validatorRules.number]"
              />
            </a-form-item>
          </a-col>
          <a-col :lg="6" :md="12" :sm="24">
            <a-form-item
              :labelCol="labelCol"
              :wrapperCol="wrapperCol"
              label="Vendeur"
              data-step="3"
              data-title="Vendeur"
              data-intro="Les données des vendeurs proviennent du menu [Gestion des personnes en charge]"
            >
              <j-select-multiple
                placeholder="Veuillez sélectionner le vendeur"
                v-model="personList.value"
                :options="personList.options"
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
          :actionButton="true"
          :dragSortAndNumber="true"
          @valueChange="onValueChange"
          @added="onAdded"
          @deleted="onDeleted"
        >
          <template #buttonAfter>
            <a-row
              :gutter="24"
              style="float: left; padding-bottom: 5px"
              data-step="4"
              data-title="Saisie par scan"
              data-intro="Cette fonctionnalité prend en charge la saisie par scan du code-barres du produit avec un scanner"
            >
              <a-col v-if="scanStatus" :md="6" :sm="24">
                <a-button @click="scanEnter">Saisie par scan</a-button>
              </a-col>
              <a-col v-if="!scanStatus" :md="16" :sm="24" style="padding: 0 8px 0 12px">
                <a-input
                  placeholder="Veuillez scanner le code-barres du produit et appuyer sur Entrée"
                  v-model="scanBarCode"
                  @pressEnter="scanPressEnter"
                  ref="scanBarCode"
                />
              </a-col>
              <a-col v-if="!scanStatus" :md="6" :sm="24" style="padding: 0px 12px 0 0">
                <a-button @click="stopScan">Masquer le scan</a-button>
              </a-col>
            </a-row>
            <a-row :gutter="24" style="float: left; padding-bottom: 5px">
              <a-col :md="24" :sm="24">
                <a-button style="margin-left: 8px" @click="handleHistoryBillList"
                  ><a-icon type="history" />Documents historiques</a-button
                >
              </a-col>
            </a-row>
            <a-row :gutter="24" style="float: left; padding-bottom: 5px; padding-left: 20px">
              <a-button icon="import" @click="onImport(prefixNo)">Importer les détails</a-button>
            </a-row>
          </template>
        </j-editable-table>
        <a-row class="form-row" :gutter="24">
          <a-col :lg="24" :md="24" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="{ xs: { span: 24 }, sm: { span: 24 } }" label="">
              <a-textarea
                :rows="1"
                placeholder="Veuillez saisir la remarque"
                v-decorator="['remark']"
                style="margin-top: 8px"
              />
            </a-form-item>
          </a-col>
        </a-row>
        <a-row class="form-row" :gutter="24">
          <a-col :lg="6" :md="12" :sm="24">
            <a-form-item
              :labelCol="labelCol"
              :wrapperCol="wrapperCol"
              label="Taux de remise"
              data-step="5"
              data-title="Taux de remise"
              data-intro="Pourcentage de remise appliqué au montant total des produits dans les détails du document"
            >
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
            <a-form-item
              :labelCol="labelCol"
              :wrapperCol="wrapperCol"
              label="Remise de recouvrement"
              data-step="6"
              data-title="Remise de recouvrement"
              data-intro="Montant de remise appliqué au montant total des produits dans les détails du document"
            >
              <a-input
                placeholder="Veuillez saisir la remise de paiement"
                v-decorator.trim="['discountMoney']"
                @change="onChangeDiscountMoney"
              />
            </a-form-item>
          </a-col>
          <a-col :lg="6" :md="12" :sm="24">
            <a-form-item
              :labelCol="labelCol"
              :wrapperCol="wrapperCol"
              label="Montant après remise"
              data-step="7"
              data-title="Montant après remise"
              data-intro="Montant après application de la remise au montant total des produits dans les détails du document"
            >
              <a-input
                placeholder="Veuillez saisir le montant après remise"
                v-decorator.trim="['discountLastMoney']"
                :readOnly="true"
              />
            </a-form-item>
          </a-col>
          <a-col :lg="6" :md="12" :sm="24"></a-col>
        </a-row>
        <a-row class="form-row" :gutter="24">
          <a-col :lg="6" :md="12" :sm="24">
            <a-form-item
              :labelCol="labelCol"
              :wrapperCol="wrapperCol"
              label="Compte de règlement"
              data-step="8"
              data-title="Compte de règlement"
              data-intro="Si vous sélectionnez plusieurs comptes dans la liste déroulante, vous pouvez effectuer le règlement via plusieurs comptes de règlement"
            >
              <a-select
                style="width: 80%"
                placeholder="Veuillez sélectionner le compte de règlement"
                v-decorator="['accountId']"
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
            <a-form-item
              :labelCol="labelCol"
              :wrapperCol="wrapperCol"
              label="Acompte perçu"
              data-step="9"
              data-title="Acompte perçu"
              data-intro="Après avoir rempli l'acompte, il sera automatiquement calculé et déduit dans le document de sortie de vente"
            >
              <a-input
                placeholder="Veuillez saisir l'acompte perçu"
                v-decorator.trim="['changeAmount', validatorRules.price]"
                @change="onChangeChangeAmount"
              />
            </a-form-item>
          </a-col>
          <a-col :lg="6" :md="12" :sm="24"> </a-col>
          <a-col :lg="6" :md="12" :sm="24"> </a-col>
        </a-row>
        <a-row class="form-row" :gutter="24">
          <a-col :lg="6" :md="12" :sm="24">
            <a-form-item
              :labelCol="labelCol"
              :wrapperCol="wrapperCol"
              label="Pièce jointe"
              data-step="10"
              data-title="Pièce jointe"
              data-intro="Vous pouvez télécharger des images et documents liés au document, plusieurs fichiers sont pris en charge"
            >
              <j-upload v-model="fileList" bizPath="bill"></j-upload>
            </a-form-item>
          </a-col>
        </a-row>
      </a-form>
    </a-spin>
    <many-account-modal ref="manyAccountModalForm" @ok="manyAccountModalFormOk"></many-account-modal>
    <import-item-modal ref="importItemModalForm" @ok="importItemModalFormOk"></import-item-modal>
    <customer-modal ref="customerModalForm" @ok="customerModalFormOk"></customer-modal>
    <account-modal ref="accountModalForm" @ok="accountModalFormOk"></account-modal>
    <history-bill-list ref="historyBillListModalForm"></history-bill-list>
    <workflow-iframe ref="modalWorkflow" @ok="workflowModalFormOk"></workflow-iframe>
    <bill-print-iframe ref="modalPrint"></bill-print-iframe>
    <bill-print-pro-iframe ref="modalPrintPro"></bill-print-pro-iframe>
  </j-modal>
</template>
<script>
import pick from 'lodash.pick'
import ManyAccountModal from '../dialog/ManyAccountModal'
import ImportItemModal from '../dialog/ImportItemModal'
import CustomerModal from '../../system/modules/CustomerModal'
import AccountModal from '../../system/modules/AccountModal'
import HistoryBillList from '../dialog/HistoryBillList'
import WorkflowIframe from '@/components/tools/WorkflowIframe'
import BillPrintIframe from '../dialog/BillPrintIframe'
import BillPrintProIframe from '../dialog/BillPrintProIframe'
import { FormTypes } from '@/utils/JEditableTableUtil'
import { JEditableTableMixin } from '@/mixins/JEditableTableMixin'
import { BillModalMixin } from '../mixins/BillModalMixin'
import { getMpListShort, handleIntroJs } from '@/utils/util'
import JSelectMultiple from '@/components/jeecg/JSelectMultiple'
import JUpload from '@/components/jeecg/JUpload'
import JDate from '@/components/jeecg/JDate'
import Vue from 'vue'
export default {
  name: 'SaleOrderModal',
  mixins: [JEditableTableMixin, BillModalMixin],
  components: {
    ManyAccountModal,
    ImportItemModal,
    CustomerModal,
    AccountModal,
    HistoryBillList,
    WorkflowIframe,
    BillPrintIframe,
    BillPrintProIframe,
    JUpload,
    JDate,
    JSelectMultiple,
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
      prefixNo: 'XSDD',
      fileList: [],
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
          { title: '', key: 'hiddenKey', width: '1%', type: FormTypes.hidden },
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
          { title: 'Multi-attributs', key: 'sku', width: '4%', type: FormTypes.normal },
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
          rules: [{ required: true, message: 'Veuillez sélectionner le client !' }],
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
      this.changeColumnHide()
      if (this.action === 'add') {
        this.addInit(this.prefixNo)
        this.personList.value = ''
        this.fileList = []
        this.$nextTick(() => {
          handleIntroJs(this.prefixNo, 1)
        })
      } else {
        this.model.operTime = this.model.operTimeStr
        if (this.model.accountId == null && this.model.accountIdList) {
          this.model.accountId = 0
          this.manyAccountBtnStatus = true
          this.accountIdList = this.model.accountIdList
          this.accountMoneyList = this.model.accountMoneyList
        } else {
          this.manyAccountBtnStatus = false
        }
        this.personList.value = this.model.salesMan
        this.fileList = this.model.fileName
        this.$nextTick(() => {
          this.form.setFieldsValue(
            pick(
              this.model,
              'organId',
              'operTime',
              'number',
              'remark',
              'discount',
              'discountMoney',
              'discountLastMoney',
              'accountId',
              'changeAmount',
              'salesMan'
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
      this.initCustomer(0)
      this.initSalesman()
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
      billMain.type = '其它'
      billMain.subType = '销售订单'
      for (let item of detailArr) {
        item.depotId = '' // La commande n'a pas besoin d'entrepôt
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
      billMain.salesMan = this.personList.value
      billMain.status = this.billStatus
      return {
        info: JSON.stringify(billMain),
        rows: JSON.stringify(detailArr),
      }
    },
    handleHistoryBillList() {
      let organId = this.form.getFieldValue('organId')
      this.$refs.historyBillListModalForm.show('其它', '销售订单', '客户', organId)
      this.$refs.historyBillListModalForm.disableSubmit = false
    },
  },
}
</script>
<style scoped></style>
