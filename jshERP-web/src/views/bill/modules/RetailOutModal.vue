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
      <a-button v-if="billPrintFlag && isShowPrintBtn" @click="handlePrintPro('Sortie de détail')"
        >Impression en trois exemplaires - Nouvelle version</a-button
      >
      <a-button v-if="billPrintFlag && isShowPrintBtn" @click="handlePrint('Sortie de détail')"
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
              label="Numéro de carte membre"
              data-step="1"
              data-title="Numéro de carte membre"
              data-intro="Si le numéro de carte membre à sélectionner n'a pas encore été enregistré, vous pouvez cliquer sur Ajouter un membre dans la liste déroulante pour l'enregistrer"
            >
              <a-select
                placeholder="Veuillez sélectionner le numéro de carte membre"
                v-decorator="['organId']"
                :dropdownMatchSelectWidth="false"
                showSearch
                optionFilterProp="children"
                @change="onChangeOrgan"
                @search="handleSearchRetail"
              >
                <div slot="dropdownRender" slot-scope="menu">
                  <v-nodes :vnodes="menu" />
                  <a-divider style="margin: 4px 0" />
                  <div
                    v-if="quickBtn.member"
                    class="dropdown-btn"
                    @mousedown="(e) => e.preventDefault()"
                    @click="addMember"
                  >
                    <a-icon type="plus" /> Ajouter un membre
                  </div>
                  <div class="dropdown-btn" @mousedown="(e) => e.preventDefault()" @click="initRetail(0)">
                    <a-icon type="reload" /> Actualiser la liste
                  </div>
                </div>
                <a-select-option v-for="(item, index) in retailList" :key="index" :value="item.id">
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
              label="Type de paiement"
              data-step="3"
              data-title="Type de paiement"
              data-intro="Le type de paiement peut être paiement comptant ou prépaiement. Lorsqu'un membre est sélectionné, si ce membre a un prépaiement, le montant du prépaiement sera affiché ici, et le système sélectionnera par défaut le prépaiement en priorité"
            >
              <a-select
                placeholder="Veuillez sélectionner le type de paiement"
                v-decorator="['payType']"
                :dropdownMatchSelectWidth="false"
              >
                <a-select-option v-for="(item, index) in payTypeList" :key="index" :value="item.value">
                  {{ item.text }}
                </a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
        </a-row>
        <a-row class="form-row" :gutter="24">
          <a-col :lg="18" :md="12" :sm="24">
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
                  style="float: left"
                  data-step="4"
                  data-title="Saisie par scan"
                  data-intro="Cette fonctionnalité prend en charge la saisie par scan du code-barres du produit avec un scanner"
                >
                  <a-col v-if="scanStatus" :md="6" :sm="24">
                    <a-button @click="scanEnter">Saisie par scan</a-button>
                  </a-col>
                  <a-col v-if="!scanStatus" :md="16" :sm="24" style="padding: 0 6px 0 12px">
                    <a-input
                      placeholder="Veuillez scanner le code-barres ou le numéro de série et appuyer sur Entrée"
                      v-model="scanBarCode"
                      @pressEnter="scanPressEnter"
                      ref="scanBarCode"
                    />
                  </a-col>
                  <a-col v-if="!scanStatus" :md="6" :sm="24" style="padding: 0px 18px 0 0">
                    <a-button @click="stopScan">Masquer le scan</a-button>
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
                  label="Pièce jointe"
                  data-step="9"
                  data-title="Pièce jointe"
                  data-intro="Vous pouvez télécharger des images et documents liés au document, plusieurs fichiers sont pris en charge"
                >
                  <j-upload v-model="fileList" bizPath="bill"></j-upload>
                </a-form-item>
              </a-col>
            </a-row>
          </a-col>
          <div class="sign">
            <a-col :lg="6" :md="12" :sm="24">
              <a-row class="form-row" :gutter="24">
                <a-col :lg="24" :md="6" :sm="6"><br /><br /></a-col>
                <a-col :lg="24" :md="6" :sm="6">
                  <a-form-item
                    :labelCol="labelCol"
                    :wrapperCol="wrapperCol"
                    data-step="5"
                    data-title="Montant du document"
                    data-intro="Le montant du document est égal au montant total des produits à gauche"
                  >
                    <span slot="label" style="font-size: 20px; line-height: 20px">Montant du document</span>
                    <a-input v-decorator.trim="['changeAmount']" :style="{ color: 'purple' }" :readOnly="true" />
                  </a-form-item>
                </a-col>
                <a-col :lg="24" :md="6" :sm="6">
                  <a-form-item
                    :labelCol="labelCol"
                    :wrapperCol="wrapperCol"
                    data-step="6"
                    data-title="Montant reçu"
                    data-intro="Le montant reçu est le montant réel perçu par le caissier auprès de l'utilisateur"
                  >
                    <span slot="label" style="font-size: 20px; line-height: 20px">Montant reçu</span>
                    <a-input
                      v-decorator.trim="['getAmount']"
                      :style="{ color: 'red' }"
                      defaultValue="0"
                      @change="onChangeGetAmount"
                    />
                  </a-form-item>
                </a-col>
                <a-col :lg="24" :md="6" :sm="6">
                  <a-form-item
                    :labelCol="labelCol"
                    :wrapperCol="wrapperCol"
                    data-step="7"
                    data-title="Monnaie rendue"
                    data-intro="La monnaie rendue est égale au montant reçu moins le montant réellement reçu"
                  >
                    <span slot="label" style="font-size: 20px; line-height: 20px">Monnaie rendue</span>
                    <a-input
                      v-decorator.trim="['backAmount']"
                      :style="{ color: 'green' }"
                      :readOnly="true"
                      defaultValue="0"
                    />
                  </a-form-item>
                </a-col>
                <a-col :lg="24" :md="6" :sm="6">
                  <a-form-item
                    :labelCol="labelCol"
                    :wrapperCol="wrapperCol"
                    data-step="8"
                    data-title="Compte de recouvrement"
                    data-intro="Les informations du compte de recouvrement proviennent de [Compte de règlement] dans le menu Données de base"
                  >
                    <span slot="label" style="font-size: 20px; line-height: 20px">Compte de recouvrement</span>
                    <a-select
                      placeholder="Veuillez sélectionner le compte de recouvrement"
                      style="font-size: 20px"
                      v-decorator="['accountId', validatorRules.accountId]"
                      :dropdownMatchSelectWidth="false"
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
                  </a-form-item>
                </a-col>
              </a-row>
            </a-col>
          </div>
        </a-row>
      </a-form>
    </a-spin>
    <member-modal ref="memberModalForm" @ok="memberModalFormOk"></member-modal>
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
import MemberModal from '../../system/modules/MemberModal'
import DepotModal from '../../system/modules/DepotModal'
import AccountModal from '../../system/modules/AccountModal'
import BatchSetDepot from '../dialog/BatchSetDepot'
import WorkflowIframe from '@/components/tools/WorkflowIframe'
import BillPrintIframe from '../dialog/BillPrintIframe'
import BillPrintProIframe from '../dialog/BillPrintProIframe'
import { FormTypes } from '@/utils/JEditableTableUtil'
import { JEditableTableMixin } from '@/mixins/JEditableTableMixin'
import { BillModalMixin } from '../mixins/BillModalMixin'
import { getMpListShort,handleIntroJs } from "@/utils/util"
import { getAccount } from '@/api/api'
import { getAction } from '@/api/manage'
import JUpload from '@/components/jeecg/JUpload'
import JDate from '@/components/jeecg/JDate'
import Vue from 'vue'
export default {
  name: "RetailOutModal",
  mixins: [JEditableTableMixin, BillModalMixin],
  components: {
    MemberModal,
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
    }
  },
  data () {
    return {
      title:"Opération",
      width: '1600px',
      moreStatus: false,
      // Nombre de lignes de données vides ajoutées par défaut dans le sous-tableau lors de l'ajout
      addDefaultRowNum: 1,
      visible: false,
      operTimeStr: '',
      prefixNo: 'LSCK',
      fileList:[],
      payTypeList: [],
      minWidth: 1100,
      model: {},
      labelCol: {
        xs: { span: 24 },
        sm: { span: 8 },
      },
      wrapperCol: {
        xs: { span: 24 },
        sm: { span: 16 },
      },
      refKeys: ['materialDataTable', ],
      activeKey: 'materialDataTable',
      materialTable: {
        loading: false,
        dataSource: [],
        columns: [
          { title: "Nom de l'entrepôt", key: 'depotId', width: '10%', type: FormTypes.select, placeholder: 'Veuillez sélectionner ${title}', options: [],
            allowSearch:true, validateRules: [{ required: true, message: '${title} ne peut pas être vide' }]
          },
          { title: 'Code-barres', key: 'barCode', width: '16%', type: FormTypes.popupJsh, kind: 'material', multi: true,
            validateRules: [{ required: true, message: '${title} ne peut pas être vide' }]
          },
          { title: 'Nom', key: 'name', width: '12%', type: FormTypes.normal },
          { title: 'Spécification', key: 'standard', width: '10%', type: FormTypes.normal },
          { title: 'Modèle', key: 'model', width: '10%', type: FormTypes.normal },
          { title: 'Couleur', key: 'color', width: '5%', type: FormTypes.normal },
          { title: 'Marque', key: 'brand', width: '6%', type: FormTypes.normal },
          { title: 'Fabricant', key: 'mfrs', width: '6%', type: FormTypes.normal },
          { title: 'Extension 1', key: 'otherField1', width: '4%', type: FormTypes.normal },
          { title: 'Extension 2', key: 'otherField2', width: '4%', type: FormTypes.normal },
          { title: 'Extension 3', key: 'otherField3', width: '4%', type: FormTypes.normal },
          { title: 'Stock', key: 'stock', width: '5%', type: FormTypes.normal },
          { title: 'Unité', key: 'unit', width: '5%', type: FormTypes.normal },
          { title: 'Numéro de série', key: 'snList', width: '12%', type: FormTypes.popupJsh, kind: 'sn', multi: true },
          { title: 'Numéro de lot', key: 'batchNumber', width: '8%', type: FormTypes.popupJsh, kind: 'batch', multi: false },
          { title: "Date d'expiration", key: 'expirationDate',width: '9%', type: FormTypes.input, readonly: true },
          { title: 'Multi-attributs', key: 'sku', width: '9%', type: FormTypes.normal },
          { title: 'Quantité', key: 'operNumber', width: '6%', type: FormTypes.inputNumber, statistics: true,
            validateRules: [{ required: true, message: '${title} ne peut pas être vide' }]
          },
          { title: 'Prix unitaire', key: 'unitPrice', width: '6%', type: FormTypes.inputNumber},
          { title: 'Montant', key: 'allPrice', width: '6%', type: FormTypes.inputNumber, statistics: true },
          { title: 'Remarque', key: 'remark', width: '7%', type: FormTypes.input }
        ]
      },
      confirmLoading: false,
      validatorRules:{
        operTime:{
          rules: [
            { required: true, message: 'Veuillez saisir la date du document !' }
          ]
        },
        number:{
          rules: [
            { required: true, message: 'Veuillez saisir le numéro de document !' }
          ]
        },
        accountId:{
          rules: [
            { required: true, message: 'Veuillez sélectionner le compte de règlement !' }
          ]
        }
      },
      url: {
        add: '/depotHead/addDepotHeadAndDetail',
        edit: '/depotHead/updateDepotHeadAndDetail',
        detailList: '/depotItem/getDetailList'
      }
    }
  },
  created () {
    this.initPayTypeList()
    let realScreenWidth = window.screen.width
    this.minWidth = realScreenWidth<1500?800:1100
  },
  methods: {
    // Cette méthode est appelée automatiquement après l'appel de la méthode edit()
    editAfter() {
      this.billStatus = '0'
      this.currentSelectDepotId = ''
      this.changeColumnHide()
      this.changeFormTypes(this.materialTable.columns, 'snList', 0)
      this.changeFormTypes(this.materialTable.columns, 'batchNumber', 0)
      this.changeFormTypes(this.materialTable.columns, 'expirationDate', 0)
      if (this.action === 'add') {
        this.addInit(this.prefixNo)
        this.fileList = []
        this.$nextTick(() => {
          handleIntroJs(this.prefixNo, 1)
        })
        this.$nextTick(() => {
          this.form.setFieldsValue({'payType': '现付', 'getAmount':0, 'backAmount':0})
        })
      } else {
        this.model.operTime = this.model.operTimeStr
        if(this.model.backAmount) {
          this.model.getAmount = (this.model.changeAmount + this.model.backAmount).toFixed(2)
        } else {
          this.model.getAmount = this.model.changeAmount
        }
        this.fileList = this.model.fileName
        if(this.model.payType === '预付款'){
          this.payTypeList = []
          this.payTypeList.push({"value":"预付款", "text":"Prépaiement"})
          this.payTypeList.push({"value":"现付", "text":"Paiement comptant"})
        }
        this.$nextTick(() => {
          this.form.setFieldsValue(pick(this.model,'organId', 'operTime', 'number', 'payType', 'remark',
            'discount','discountMoney','discountLastMoney','otherMoney','accountId','changeAmount','getAmount','backAmount'))
        });
        // Charger les données du sous-tableau
        let params = {
          headerId: this.model.id,
          mpList: getMpListShort(Vue.ls.get('materialPropertyList')),  // Attributs étendus
          linkType: 'basic'
        }
        let url = this.readOnly ? this.url.detailList : this.url.detailList;
        this.requestSubTableData(url, params, this.materialTable);
      }
      // Copier et ajouter un document - Initialiser le numéro et la date
      if(this.action === 'copyAdd') {
        this.model.id = ''
        this.model.tenantId = ''
        this.copyAddInit(this.prefixNo)
      }
      this.initSystemConfig()
      this.initRetail(0)
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
      billMain.subType = '零售'
      for(let item of detailArr){
        totalPrice += item.allPrice-0
      }
      billMain.totalPrice = totalPrice
      if(this.fileList && this.fileList.length > 0) {
        billMain.fileName = this.fileList
      } else {
        billMain.fileName = ''
      }
      if(this.model.id){
        billMain.id = this.model.id
      }
      billMain.status = this.billStatus
      return {
        info: JSON.stringify(billMain),
        rows: JSON.stringify(detailArr),
      }
    },
    // Charger les types de paiement
    initPayTypeList() {
      this.payTypeList.push({"value":"现付", "text":"Paiement comptant"})
    },
    initAccount(isChecked){
      getAccount({}).then((res)=>{
        if(res && res.code === 200) {
          this.accountList = res.data.accountList
          if(isChecked && this.accountList.length>0) {
            this.form.setFieldsValue({'accountId': this.accountList[0].id})
          }
        }
      })
    },
    // Événement déclenché lors de la sélection d'un membre
    onChangeOrgan(value) {
      getAction("/supplier/info", {id: value}).then(res=>{
        if(res && res.code === 200){
          this.payTypeList = []
          let info = res.data.info
          if(info.advanceIn) {
            this.payTypeList.push({"value":"预付款", "text":"Prépaiement (" + info.advanceIn + ")"})
            this.payTypeList.push({"value":"现付", "text":"Paiement comptant"})
            this.$nextTick(() => {
              this.form.setFieldsValue({'payType': '预付款'})
            })
          } else {
            this.payTypeList.push({"value":"现付", "text":"Paiement comptant"})
            this.$nextTick(() => {
              this.form.setFieldsValue({'payType': '现付'})
            })
          }
        }
      })
    },
    // Modifier les valeurs du montant réellement reçu et du montant reçu
    autoChangePrice(target) {
      let allLastMoney = target.statisticsColumns.allPrice
      this.$nextTick(() => {
        this.form.setFieldsValue({'changeAmount':allLastMoney,'getAmount':allLastMoney,'backAmount':0})
      });
    },
    // Modifier le montant reçu
    onChangeGetAmount(e) {
      const value = e.target.value
      let changeAmount = this.form.getFieldValue('changeAmount')-0
      let backAmount = (value - changeAmount).toFixed(2)-0
      this.$nextTick(() => {
        this.form.setFieldsValue({'backAmount':backAmount})
      });
    }
  }
}
</script>
<style scoped>
.sign .ant-input {
  font-size: 30px;
  font-weight: bolder;
  text-align: center;
  border-left-width: 0px !important;
  border-top-width: 0px !important;
  border-right-width: 0px !important;
}
</style>
