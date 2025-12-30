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
    style="top:20px;height: 95%;">
    <template slot="footer">
      <a-button @click="handleCancel">Annuler</a-button>
      <a-button v-if="checkFlag && isCanCheck" :loading="confirmLoading" @click="handleOkAndCheck">Enregistrer et auditer</a-button>
      <a-button type="primary" :loading="confirmLoading" @click="handleOk">Enregistrer (Ctrl+S)</a-button>
      <!-- Lancer l'audit multi-niveaux -->
      <a-button v-if="!checkFlag" @click="handleWorkflow()" type="primary">Soumettre le processus</a-button>
    </template>
    <a-spin :spinning="confirmLoading">
      <a-form :form="form">
        <a-row class="form-row" :gutter="24">
          <a-col :lg="6" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Unité de correspondance">
              <a-select placeholder="Veuillez sélectionner l'unité de correspondance" v-decorator="[ 'organId', validatorRules.organId ]"
                :dropdownMatchSelectWidth="false" showSearch optionFilterProp="children" @search="handleSearchOrgan">
                <div slot="dropdownRender" slot-scope="menu">
                  <v-nodes :vnodes="menu" />
                  <a-divider style="margin: 4px 0;" />
                  <div class="dropdown-btn" @mousedown="e => e.preventDefault()" @click="initOrgan"><a-icon type="reload" /> Actualiser la liste</div>
                </div>
                <a-select-option v-for="(item,index) in organList" :key="index" :value="item.id">
                  {{ item.supplier }}
                </a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
          <a-col :lg="6" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Date du document">
              <j-date v-decorator="['billTime', validatorRules.billTime ]" :show-time="true"/>
            </a-form-item>
          </a-col>
          <a-col :lg="6" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de document">
              <a-input placeholder="Veuillez saisir le numéro de document" v-decorator.trim="[ 'billNo', validatorRules.billNo ]" />
            </a-form-item>
          </a-col>
          <a-col :lg="6" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Personnel financier">
              <a-select placeholder="Veuillez sélectionner le personnel financier" v-decorator="[ 'handsPersonId' ]"
                        :dropdownMatchSelectWidth="false" showSearch optionFilterProp="children">
                <div slot="dropdownRender" slot-scope="menu">
                  <v-nodes :vnodes="menu" />
                  <a-divider style="margin: 4px 0;" />
                  <div v-if="quickBtn.person" class="dropdown-btn" @mousedown="e => e.preventDefault()" @click="addPerson"><a-icon type="plus" /> Ajouter un responsable</div>
                  <div class="dropdown-btn" @mousedown="e => e.preventDefault()" @click="initPerson"><a-icon type="reload" /> Actualiser</div>
                </div>
                <a-select-option v-for="(item,index) in personList" :key="index" :value="item.id">
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
          :actionButton="true"
          @added="onAdded"
          @valueChange="onValueChange">
          <template #inOutItemAdd>
            <a-divider v-if="quickBtn.inOutItem" style="margin: 4px 0;" />
            <div v-if="quickBtn.inOutItem" class="dropdown-btn" @click="addInOutItem('in')"><a-icon type="plus" /> Ajouter un projet de recettes/dépenses</div>
            <div class="dropdown-btn" @mousedown="e => e.preventDefault()" @click="initInOutItem('in')"><a-icon type="reload" /> Actualiser la liste</div>
          </template>
        </j-editable-table>
        <a-row class="form-row" :gutter="24">
          <a-col :lg="24" :md="24" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="{xs: { span: 24 },sm: { span: 24 }}" label="">
              <a-textarea :rows="2" placeholder="Veuillez saisir la remarque" v-decorator="[ 'remark' ]" style="margin-top:8px;"/>
            </a-form-item>
          </a-col>
        </a-row>
        <a-row class="form-row" :gutter="24">
          <a-col :lg="6" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Compte de recette">
              <a-select placeholder="Veuillez sélectionner le compte de recette" v-decorator="[ 'accountId', validatorRules.accountId ]"
                :dropdownMatchSelectWidth="false" showSearch optionFilterProp="children">
                <div slot="dropdownRender" slot-scope="menu">
                  <v-nodes :vnodes="menu" />
                  <a-divider style="margin: 4px 0;" />
                  <div v-if="quickBtn.account" class="dropdown-btn" @mousedown="e => e.preventDefault()" @click="addAccount"><a-icon type="plus" /> Ajouter</div>
                  <div class="dropdown-btn" @mousedown="e => e.preventDefault()" @click="initAccount"><a-icon type="reload" /> Actualiser</div>
                </div>
                <a-select-option v-for="(item,index) in accountList" :key="index" :value="item.id">
                  {{ item.name }}
                </a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
          <a-col :lg="6" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Montant de recette">
              <a-input placeholder="Veuillez saisir le montant de recette" v-decorator.trim="[ 'changeAmount', validatorRules.changeAmount ]" :readOnly="true"/>
            </a-form-item>
          </a-col>
          <a-col :lg="6" :md="12" :sm="24">
          </a-col>
          <a-col :lg="6" :md="12" :sm="24">
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
    <account-modal ref="accountModalForm" @ok="accountModalFormOk"></account-modal>
    <person-modal ref="personModalForm" @ok="personModalFormOk"></person-modal>
    <workflow-iframe ref="modalWorkflow" @ok="workflowModalFormOk"></workflow-iframe>
    <in-out-item-modal ref="inOutItemModalForm" @ok="inOutItemModalFormOk('in')"></in-out-item-modal>
  </j-modal>
</template>
<script>
  import pick from 'lodash.pick'
  import AccountModal from '../../system/modules/AccountModal'
  import PersonModal from '../../system/modules/PersonModal'
  import WorkflowIframe from '@/components/tools/WorkflowIframe'
  import InOutItemModal from '../../system/modules/InOutItemModal'
  import { FormTypes } from '@/utils/JEditableTableUtil'
  import { JEditableTableMixin } from '@/mixins/JEditableTableMixin'
  import { FinancialModalMixin } from '../mixins/FinancialModalMixin'
  import JUpload from '@/components/jeecg/JUpload'
  import JDate from '@/components/jeecg/JDate'
  export default {
    name: "ItemInModal",
    mixins: [JEditableTableMixin, FinancialModalMixin],
    components: {
      AccountModal,
      PersonModal,
      WorkflowIframe,
      InOutItemModal,
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
        prefixNo: 'SR',
        model: {},
        fileList:[],
        labelCol: {
          xs: { span: 24 },
          sm: { span: 8 },
        },
        wrapperCol: {
          xs: { span: 24 },
          sm: { span: 16 },
        },
        refKeys: ['accountDataTable', ],
        activeKey: 'accountDataTable',
        accountTable: {
          loading: false,
          dataSource: [],
          columns: [
            { title: 'Projet de recette',key: 'inOutItemId',width: '20%', type: FormTypes.select, placeholder: 'Veuillez sélectionner ${title}', options: [],
              allowSearch:true, validateRules: [{ required: true, message: '${title} ne peut pas être vide' }]
            },
            { title: 'Montant',key: 'eachAmount', width: '10%', type: FormTypes.inputNumber, statistics: true, placeholder: 'Veuillez saisir ${title}',
              validateRules: [{ required: true, message: '${title} ne peut pas être vide' }]
            },
            { title: 'Remarque',key: 'remark', width: '30%', type: FormTypes.input, placeholder: 'Veuillez saisir ${title}'}
          ]
        },
        confirmLoading: false,
        validatorRules:{
          billTime:{
            rules: [
              { required: true, message: 'Veuillez sélectionner la date du document !' }
            ]
          },
          billNo:{
            rules: [
              { required: true, message: 'Veuillez saisir le numéro de document !' }
            ]
          },
          accountId:{
            rules: [
              { required: true, message: 'Veuillez sélectionner le compte de recette !' }
            ]
          },
          changeAmount:{
            rules: [
              { required: true, message: 'Veuillez saisir le montant de recette !' }
            ]
          }
        },
        url: {
          add: '/accountHead/addAccountHeadAndDetail',
          edit: '/accountHead/updateAccountHeadAndDetail',
          detailList: '/accountItem/getDetailList'
        }
      }
    },
    created () {
    },
    methods: {
      // Cette méthode est appelée automatiquement après l'appel de la méthode edit()
      editAfter() {
        this.billStatus = '0'
        if (this.action === 'add') {
          this.addInit(this.prefixNo)
          this.fileList = []
        } else {
          this.model.billTime = this.model.billTimeStr
          this.$nextTick(() => {
            this.form.setFieldsValue(pick(this.model,'organId', 'handsPersonId', 'billTime', 'billNo', 'remark',
                   'accountId','changeAmount'))
          });
          this.fileList = this.model.fileName
          // Charger les données du sous-tableau
          let params = {
            headerId: this.model.id
          }
          let url = this.readOnly ? this.url.detailList : this.url.detailList;
          this.requestSubTableData(url, params, this.accountTable);
        }
        this.initSystemConfig()
        this.initOrgan()
        this.initPerson()
        this.initInOutItem('in')
        this.initAccount()
        this.initQuickBtn()
      },
      // Organiser en formData lors de la soumission du document
      classifyIntoFormData(allValues) {
        let totalPrice = 0
        let billMain = Object.assign(this.model, allValues.formValue)
        let detailArr = allValues.tablesValue[0].values
        billMain.type = '收入'
        for(let item of detailArr){
          totalPrice += item.eachAmount-0
        }
        billMain.totalPrice = totalPrice
        if(this.fileList && this.fileList.length > 0) {
          billMain.fileName = this.fileList
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
      // Modifier la valeur de la dette actuelle
      autoChangeAmount(target) {
        let allEachAmount = target.statisticsColumns.eachAmount-0
        this.$nextTick(() => {
          this.form.setFieldsValue({'changeAmount':allEachAmount})
        });
      }
    }
  }
</script>
<style scoped>

</style>