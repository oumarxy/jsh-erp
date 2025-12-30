<template>
  <j-modal
    :title="title"
    :width="width"
    :visible="visible"
    :confirmLoading="confirmLoading"
    :keyboard="false"
    :forceRender="true"
    fullscreen
    switchFullscreen
    @cancel="handleCancel"
    :id="prefixNo"
    style="top: 20px; height: 95%"
  >
    <template slot="footer">
      <a-button @click="handleCancel">Annuler</a-button>
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
                :dropdownMatchSelectWidth="false"
                showSearch
                optionFilterProp="children"
                @change="onChangeOrgan"
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
                  <div class="dropdown-btn" @mousedown="(e) => e.preventDefault()" @click="initSupplier">
                    <a-icon type="reload" /> Actualiser
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
              <j-date v-decorator="['billTime', validatorRules.billTime]" :show-time="true" />
            </a-form-item>
          </a-col>
          <a-col :lg="6" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de document">
              <a-input
                placeholder="Veuillez saisir le numéro de document"
                v-decorator.trim="['billNo', validatorRules.billNo]"
              />
            </a-form-item>
          </a-col>
          <a-col :lg="6" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Personnel financier">
              <a-select
                placeholder="Veuillez sélectionner le personnel financier"
                v-decorator="['handsPersonId']"
                :dropdownMatchSelectWidth="false"
                showSearch
                optionFilterProp="children"
              >
                <div slot="dropdownRender" slot-scope="menu">
                  <v-nodes :vnodes="menu" />
                  <a-divider style="margin: 4px 0" />
                  <div
                    v-if="quickBtn.person"
                    class="dropdown-btn"
                    @mousedown="(e) => e.preventDefault()"
                    @click="addPerson"
                  >
                    <a-icon type="plus" /> Ajouter un responsable
                  </div>
                  <div class="dropdown-btn" @mousedown="(e) => e.preventDefault()" @click="initPerson">
                    <a-icon type="reload" /> Actualiser
                  </div>
                </div>
                <a-select-option v-for="(item, index) in personList" :key="index" :value="item.id">
                  {{ item.name }}
                </a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
        </a-row>
        <j-editable-table
          :ref="refKeys[0]"
          :loading="accountTable.loading"
          :columns="accountTable.columns"
          :dataSource="accountTable.dataSource"
          :minWidth="minWidth"
          :maxHeight="300"
          :rowNumber="true"
          :rowSelection="true"
          :actionButton="false"
          :actionDeleteButton="true"
          @deleted="onDeleted"
          @valueChange="onValueChange"
        >
          <template #buttonBefore>
            <a-row :gutter="24" style="float: left; padding-bottom: 8px">
              <a-col :md="12" :sm="24">
                <a-button type="primary" icon="plus" @click="handleClickAdd">Sélectionner le document</a-button>
              </a-col>
              <a-col :md="12" :sm="24" style="padding-left: 0">
                <a-button type="primary" icon="plus" @click="selectBeginNeed('供应商')"
                  >Sélectionner le solde initial</a-button
                >
              </a-col>
            </a-row>
          </template>
          <template #buttonAfter>
            <a-row :gutter="24" style="float: left; padding-bottom: 8px">
              <a-col :md="12" :sm="24">
                <a-button icon="link" @click="handleWaitNeed('供应商')">En attente de paiement</a-button>
              </a-col>
            </a-row>
          </template>
        </j-editable-table>
        <a-row class="form-row" :gutter="24">
          <a-col :lg="24" :md="24" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="{ xs: { span: 24 }, sm: { span: 24 } }" label="">
              <a-textarea
                :rows="2"
                placeholder="Veuillez saisir la remarque"
                v-decorator="['remark']"
                style="margin-top: 8px"
              />
            </a-form-item>
          </a-col>
        </a-row>
        <a-row class="form-row" :gutter="24">
          <a-col :lg="6" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Compte de paiement">
              <a-select
                placeholder="Veuillez sélectionner le compte de paiement"
                v-decorator="['accountId', validatorRules.accountId]"
                :dropdownMatchSelectWidth="false"
                showSearch
                optionFilterProp="children"
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
                  <div class="dropdown-btn" @mousedown="(e) => e.preventDefault()" @click="initAccount">
                    <a-icon type="reload" /> Actualiser
                  </div>
                </div>
                <a-select-option v-for="(item, index) in accountList" :key="index" :value="item.id">
                  {{ item.name }}
                </a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
          <a-col :lg="6" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Total des paiements">
              <a-input
                placeholder="Veuillez saisir le total des paiements"
                v-decorator.trim="['totalPrice']"
                :readOnly="true"
              />
            </a-form-item>
          </a-col>
          <a-col :lg="6" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Montant de remise">
              <a-input
                placeholder="Veuillez saisir le montant de remise"
                v-decorator.trim="['discountMoney', validatorRules.discountMoney]"
                @change="onChangeDiscountMoney"
              />
            </a-form-item>
          </a-col>
          <a-col :lg="6" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Paiement réel">
              <a-input
                placeholder="Veuillez saisir le paiement réel"
                v-decorator.trim="['changeAmount']"
                :readOnly="true"
              />
            </a-form-item>
          </a-col>
        </a-row>
        <a-row class="form-row" :gutter="24">
          <a-col :lg="6" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Pièce jointe">
              <j-upload v-model="fileList" bizPath="financial"></j-upload>
            </a-form-item>
          </a-col>
        </a-row>
      </a-form>
    </a-spin>
    <debt-bill-list ref="debtBillList" @ok="debtBillListOk"></debt-bill-list>
    <vendor-modal ref="vendorModalForm" @ok="vendorModalFormOk"></vendor-modal>
    <account-modal ref="accountModalForm" @ok="accountModalFormOk"></account-modal>
    <person-modal ref="personModalForm" @ok="personModalFormOk"></person-modal>
    <wait-need-list ref="waitNeedList" @ok="waitNeedListOk"></wait-need-list>
    <workflow-iframe ref="modalWorkflow" @ok="workflowModalFormOk"></workflow-iframe>
  </j-modal>
</template>
<script>
import pick from 'lodash.pick'
import DebtBillList from '../dialog/DebtBillList'
import VendorModal from '../../system/modules/VendorModal'
import AccountModal from '../../system/modules/AccountModal'
import PersonModal from '../../system/modules/PersonModal'
import WaitNeedList from '../dialog/WaitNeedList'
import WorkflowIframe from '@/components/tools/WorkflowIframe'
import { FormTypes } from '@/utils/JEditableTableUtil'
import { JEditableTableMixin } from '@/mixins/JEditableTableMixin'
import { FinancialModalMixin } from '../mixins/FinancialModalMixin'
import JUpload from '@/components/jeecg/JUpload'
import JDate from '@/components/jeecg/JDate'
export default {
  name: 'MoneyInModal',
  mixins: [JEditableTableMixin, FinancialModalMixin],
  components: {
    DebtBillList,
    VendorModal,
    AccountModal,
    PersonModal,
    WaitNeedList,
    WorkflowIframe,
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
      addDefaultRowNum: 0,
      visible: false,
      prefixNo: 'FK',
      model: {},
      fileList: [],
      labelCol: {
        xs: { span: 24 },
        sm: { span: 8 },
      },
      wrapperCol: {
        xs: { span: 24 },
        sm: { span: 16 },
      },
      refKeys: ['accountDataTable'],
      activeKey: 'accountDataTable',
      accountTable: {
        loading: false,
        dataSource: [],
        columns: [
          {
            title: "Numéro de document d'achat",
            key: 'billNumber',
            width: '20%',
            type: FormTypes.input,
            readonly: true,
          },
          {
            title: 'Dette à payer',
            key: 'needDebt',
            width: '10%',
            type: FormTypes.inputNumber,
            statistics: true,
            readonly: true,
          },
          {
            title: 'Dette payée',
            key: 'finishDebt',
            width: '10%',
            type: FormTypes.inputNumber,
            statistics: true,
            readonly: true,
          },
          {
            title: 'Paiement actuel',
            key: 'eachAmount',
            width: '10%',
            type: FormTypes.inputNumber,
            statistics: true,
            placeholder: 'Veuillez saisir ${title}',
            validateRules: [{ required: true, message: '${title} ne peut pas être vide' }],
          },
          {
            title: 'Remarque',
            key: 'remark',
            width: '20%',
            type: FormTypes.input,
            placeholder: 'Veuillez saisir ${title}',
          },
        ],
      },
      confirmLoading: false,
      validatorRules: {
        organId: {
          rules: [{ required: true, message: 'Veuillez sélectionner le fournisseur !' }],
        },
        billTime: {
          rules: [{ required: true, message: 'Veuillez sélectionner la date du document !' }],
        },
        billNo: {
          rules: [{ required: true, message: 'Veuillez saisir le numéro de document !' }],
        },
        accountId: {
          rules: [{ required: true, message: 'Veuillez sélectionner le compte de paiement !' }],
        },
        discountMoney: {
          rules: [{ required: true, message: 'Veuillez saisir le montant de remise !' }],
        },
        changeAmount: {
          rules: [{ required: true, message: 'Veuillez saisir le montant de recouvrement !' }],
        },
      },
      url: {
        add: '/accountHead/addAccountHeadAndDetail',
        edit: '/accountHead/updateAccountHeadAndDetail',
        detailList: '/accountItem/getDetailList',
      },
    }
  },
  created() {},
  methods: {
    // Cette méthode est appelée automatiquement après l'appel de la méthode edit()
    editAfter() {
      this.billStatus = '0'
      if (this.action === 'add') {
        this.addInit(this.prefixNo)
        this.fileList = []
        if (this.actionWithOrgan) {
          // Afficher automatiquement la liste des clients en attente de recouvrement
          let that = this
          setTimeout(function () {
            that.$refs.waitNeedList.show('供应商')
          }, 1000)
        }
      } else {
        this.model.billTime = this.model.billTimeStr
        this.$nextTick(() => {
          this.form.setFieldsValue(
            pick(
              this.model,
              'organId',
              'handsPersonId',
              'billTime',
              'billNo',
              'remark',
              'accountId',
              'totalPrice',
              'discountMoney',
              'changeAmount'
            )
          )
        })
        this.fileList = this.model.fileName
        // Charger les données du sous-tableau
        let params = {
          headerId: this.model.id,
        }
        let url = this.readOnly ? this.url.detailList : this.url.detailList
        this.requestSubTableData(url, params, this.accountTable)
      }
      this.initSystemConfig()
      this.initSupplier()
      this.initPerson()
      this.initAccount()
      this.initQuickBtn()
    },
    // Organiser en formData lors de la soumission du document
    classifyIntoFormData(allValues) {
      let totalPrice = 0
      let billMain = Object.assign(this.model, allValues.formValue)
      let detailArr = allValues.tablesValue[0].values
      billMain.type = '付款'
      for (let item of detailArr) {
        totalPrice += item.eachAmount - 0
      }
      billMain.totalPrice = 0 - totalPrice
      billMain.changeAmount = 0 - billMain.changeAmount
      if (this.fileList && this.fileList.length > 0) {
        billMain.fileName = this.fileList
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
    handleClickAdd() {
      let organId = this.form.getFieldValue('organId')
      if (organId) {
        this.$refs.debtBillList.show(organId, '入库', '采购', '供应商', '')
        this.$refs.debtBillList.title = "Veuillez sélectionner le document de dette d'achat"
      } else {
        this.$message.warning('Veuillez sélectionner le fournisseur !')
      }
    },
    handleClear() {
      this.accountTable.dataSource = []
    },
  },
}
</script>
<style scoped>
.action-button {
  margin-bottom: 8px;
}
.gap {
  padding-left: 8px;
}
</style>
