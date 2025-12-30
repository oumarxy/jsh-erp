<template>
  <j-modal
    :title="title"
    :width="width"
    :visible="visible"
    :maskClosable="false"
    :forceRender="true"
    :style="modalStyle"
    fullscreen
    switchFullscreen
    @cancel="handleCancel"
    wrapClassName="ant-modal-cust-warp"
  >
    <template slot="footer">
      <a-button key="back" @click="handleCancel">Annuler (ESC)</a-button>
      <!-- Ici pour résoudre le problème de cache -->
      <a-button v-if="financialType === '收预付款'" v-print="'#advanceInPrint'">Imprimer</a-button>
      <a-button v-if="financialType === '转账'" v-print="'#giroPrint'">Imprimer</a-button>
      <a-button v-if="financialType === '收入'" v-print="'#itemInPrint'">Imprimer</a-button>
      <a-button v-if="financialType === '支出'" v-print="'#itemOutPrint'">Imprimer</a-button>
      <a-button v-if="financialType === '收款'" v-print="'#moneyInPrint'">Imprimer</a-button>
      <a-button v-if="financialType === '付款'" v-print="'#moneyOutPrint'">Imprimer</a-button>
      <!-- Désauditer -->
      <a-button v-if="checkFlag && isCanBackCheck && model.status === '1'" @click="handleBackCheck()"
        >Désauditer</a-button
      >
    </template>
    <a-form :form="form">
      <!-- Prépaiement -->
      <template v-if="financialType === '收预付款'">
        <section ref="print" id="advanceInPrint">
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Membre payeur">
                <a-input v-decorator="['id']" hidden />
                {{ model.organName }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Personnel financier">
                {{ model.handsPersonName }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Date du document">
                {{ model.billTimeStr }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de document">
                {{ model.billNo }}
              </a-form-item>
            </a-col>
          </a-row>
          <a-table
            ref="table"
            size="middle"
            bordered
            rowKey="id"
            :pagination="false"
            :loading="loading"
            :columns="advanceInColumns"
            :dataSource="dataSource"
          >
          </a-table>
          <a-row class="form-row" :gutter="24">
            <a-col :lg="24" :md="24" :sm="24">
              <a-form-item
                :labelCol="labelCol"
                :wrapperCol="{ xs: { span: 24 }, sm: { span: 24 } }"
                label=""
                style="padding: 20px 10px"
              >
                {{ model.remark }}
              </a-form-item>
            </a-col>
          </a-row>
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Montant total">
                {{ model.totalPrice }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Montant de recouvrement">
                {{ model.changeAmount }}
              </a-form-item>
            </a-col>
            <a-col :span="6"></a-col>
            <a-col :span="6"></a-col>
            <a-col :span="6"></a-col>
          </a-row>
        </section>
      </template>
      <!-- Virement -->
      <template v-if="financialType === '转账'">
        <section ref="print" id="giroPrint">
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Personnel financier">
                <a-input v-decorator="['id']" hidden />
                {{ model.handsPersonName }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Date du document">
                {{ model.billTimeStr }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de document">
                {{ model.billNo }}
              </a-form-item>
            </a-col>
            <a-col :span="6"></a-col>
          </a-row>
          <a-table
            ref="table"
            size="middle"
            bordered
            rowKey="id"
            :pagination="false"
            :loading="loading"
            :columns="giroColumns"
            :dataSource="dataSource"
          >
          </a-table>
          <a-row class="form-row" :gutter="24">
            <a-col :lg="24" :md="24" :sm="24">
              <a-form-item
                :labelCol="labelCol"
                :wrapperCol="{ xs: { span: 24 }, sm: { span: 24 } }"
                label=""
                style="padding: 20px 10px"
              >
                {{ model.remark }}
              </a-form-item>
            </a-col>
          </a-row>
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Compte de paiement">
                {{ model.accountName }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Montant réellement payé">
                {{ model.changeAmount }}
              </a-form-item>
            </a-col>
            <a-col :span="6"></a-col>
            <a-col :span="6"></a-col>
          </a-row>
        </section>
      </template>
      <!-- Recette -->
      <template v-if="financialType === '收入'">
        <section ref="print" id="itemInPrint">
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Unité de correspondance">
                <a-input v-decorator="['id']" hidden />
                {{ model.organName }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Personnel financier">
                {{ model.handsPersonName }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Date du document">
                {{ model.billTimeStr }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de document">
                {{ model.billNo }}
              </a-form-item>
            </a-col>
          </a-row>
          <a-table
            ref="table"
            size="middle"
            bordered
            rowKey="id"
            :pagination="false"
            :loading="loading"
            :columns="itemInColumns"
            :dataSource="dataSource"
          >
          </a-table>
          <a-row class="form-row" :gutter="24">
            <a-col :lg="24" :md="24" :sm="24">
              <a-form-item
                :labelCol="labelCol"
                :wrapperCol="{ xs: { span: 24 }, sm: { span: 24 } }"
                label=""
                style="padding: 20px 10px"
              >
                {{ model.remark }}
              </a-form-item>
            </a-col>
          </a-row>
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Compte de recette">
                {{ model.accountName }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Montant de recette">
                {{ model.changeAmount }}
              </a-form-item>
            </a-col>
            <a-col :span="6"></a-col>
            <a-col :span="6"></a-col>
          </a-row>
        </section>
      </template>
      <!-- Dépense -->
      <template v-if="financialType === '支出'">
        <section ref="print" id="itemOutPrint">
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Unité de correspondance">
                <a-input v-decorator="['id']" hidden />
                {{ model.organName }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Personnel financier">
                {{ model.handsPersonName }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Date du document">
                {{ model.billTimeStr }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de document">
                {{ model.billNo }}
              </a-form-item>
            </a-col>
          </a-row>
          <a-table
            ref="table"
            size="middle"
            bordered
            rowKey="id"
            :pagination="false"
            :loading="loading"
            :columns="itemOutColumns"
            :dataSource="dataSource"
          >
          </a-table>
          <a-row class="form-row" :gutter="24">
            <a-col :lg="24" :md="24" :sm="24">
              <a-form-item
                :labelCol="labelCol"
                :wrapperCol="{ xs: { span: 24 }, sm: { span: 24 } }"
                label=""
                style="padding: 20px 10px"
              >
                {{ model.remark }}
              </a-form-item>
            </a-col>
          </a-row>
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Compte de dépense">
                {{ model.accountName }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Montant de dépense">
                {{ model.changeAmount }}
              </a-form-item>
            </a-col>
            <a-col :span="6"></a-col>
            <a-col :span="6"></a-col>
          </a-row>
        </section>
      </template>
      <!-- Recouvrement -->
      <template v-if="financialType === '收款'">
        <section ref="print" id="moneyInPrint">
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Client">
                <a-input v-decorator="['id']" hidden />
                {{ model.organName }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Personnel financier">
                {{ model.handsPersonName }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Date du document">
                {{ model.billTimeStr }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de document">
                {{ model.billNo }}
              </a-form-item>
            </a-col>
          </a-row>
          <a-table
            ref="table"
            size="middle"
            bordered
            rowKey="id"
            :pagination="false"
            :loading="loading"
            :columns="moneyInColumns"
            :dataSource="dataSource"
          >
          </a-table>
          <a-row class="form-row" :gutter="24">
            <a-col :lg="24" :md="24" :sm="24">
              <a-form-item
                :labelCol="labelCol"
                :wrapperCol="{ xs: { span: 24 }, sm: { span: 24 } }"
                label=""
                style="padding: 20px 10px"
              >
                {{ model.remark }}
              </a-form-item>
            </a-col>
          </a-row>
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Compte de recouvrement">
                {{ model.accountName }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Total des recouvrements">
                {{ model.totalPrice }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Montant de remise">
                {{ model.discountMoney }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Recouvrement réel">
                {{ model.changeAmount }}
              </a-form-item>
            </a-col>
          </a-row>
        </section>
      </template>
      <!-- Paiement -->
      <template v-if="financialType === '付款'">
        <section ref="print" id="moneyOutPrint">
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Fournisseur">
                <a-input v-decorator="['id']" hidden />
                {{ model.organName }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Personnel financier">
                {{ model.handsPersonName }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Date du document">
                {{ model.billTimeStr }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de document">
                {{ model.billNo }}
              </a-form-item>
            </a-col>
          </a-row>
          <a-table
            ref="table"
            size="middle"
            bordered
            rowKey="id"
            :pagination="false"
            :loading="loading"
            :columns="moneyOutColumns"
            :dataSource="dataSource"
          >
          </a-table>
          <a-row class="form-row" :gutter="24">
            <a-col :lg="24" :md="24" :sm="24">
              <a-form-item
                :labelCol="labelCol"
                :wrapperCol="{ xs: { span: 24 }, sm: { span: 24 } }"
                label=""
                style="padding: 20px 10px"
              >
                {{ model.remark }}
              </a-form-item>
            </a-col>
          </a-row>
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Compte de paiement">
                {{ model.accountName }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Total des paiements">
                {{ model.totalPrice }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Montant de remise">
                {{ model.discountMoney }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Paiement réel">
                {{ model.changeAmount }}
              </a-form-item>
            </a-col>
          </a-row>
        </section>
      </template>
      <template v-if="fileList && fileList.length > 0">
        <a-row class="form-row" :gutter="24">
          <a-col :span="12">
            <a-form-item
              :labelCol="{ xs: { span: 24 }, sm: { span: 3 } }"
              :wrapperCol="{ xs: { span: 24 }, sm: { span: 21 } }"
              label="Pièce jointe"
            >
              <j-upload v-model="fileList" bizPath="bill" :disabled="true" :buttonVisible="false"></j-upload>
            </a-form-item>
          </a-col>
          <a-col :span="12"></a-col>
        </a-row>
      </template>
    </a-form>
  </j-modal>
</template>
<script>
import pick from 'lodash.pick'
import { getAction, postAction } from '@/api/manage'
import { findFinancialDetailByNumber, getCurrentSystemConfig } from '@/api/api'
import { getCheckFlag } from '@/utils/util'
import JUpload from '@/components/jeecg/JUpload'

export default {
  name: 'FinancialDetail',
  components: {
    JUpload
  },
  data () {
    return {
      title: "Détails",
      width: '1600px',
      visible: false,
      modalStyle: '',
      model: {},
      isCanBackCheck: true,
      financialType: '',
      fileList: [],
      /* L'audit inverse original est-il activé */
      checkFlag: true,
      labelCol: {
        xs: { span: 24 },
        sm: { span: 6 },
      },
      wrapperCol: {
        xs: { span: 24 },
        sm: { span: 16 },
      },
      form: this.$form.createForm(this),
      loading: false,
      dataSource: [],
      url: {
        detailList: '/accountItem/getDetailList',
        batchSetStatusUrl: '/accountHead/batchSetStatus'
      },
      advanceInColumns: [
        { title: '#',dataIndex:'',width:'5%',align:'center',customRender:function(t,r,index){return parseInt(index)+1;}},
        { title: 'Nom du compte',dataIndex: 'accountName',width: '30%'},
        { title: 'Montant',dataIndex: 'eachAmount', width: '30%'},
        { title: 'Remarque',dataIndex: 'remark', width: '30%'}
      ],
      giroColumns: [
        { title: '#',dataIndex:'',width:'5%',align:'center',customRender:function(t,r,index){return parseInt(index)+1;}},
        { title: 'Nom du compte',dataIndex: 'accountName',width: '30%'},
        { title: 'Montant',dataIndex: 'eachAmount', width: '30%'},
        { title: 'Remarque',dataIndex: 'remark', width: '30%'}
      ],
      itemInColumns: [
        { title: '#',dataIndex:'',width:'5%',align:'center',customRender:function(t,r,index){return parseInt(index)+1;}},
        { title: 'Projet de recette',dataIndex: 'inOutItemName',width: '30%'},
        { title: 'Montant',dataIndex: 'eachAmount', width: '30%'},
        { title: 'Remarque',dataIndex: 'remark', width: '30%'}
      ],
      itemOutColumns: [
        { title: '#',dataIndex:'',width:'5%',align:'center',customRender:function(t,r,index){return parseInt(index)+1;}},
        { title: 'Projet de dépense',dataIndex: 'inOutItemName',width: '30%'},
        { title: 'Montant',dataIndex: 'eachAmount', width: '30%'},
        { title: 'Remarque',dataIndex: 'remark', width: '30%'}
      ],
      moneyInColumns: [
        { title: '#',dataIndex:'',width:'5%',align:'center',customRender:function(t,r,index){return parseInt(index)+1;}},
        { title: 'Numéro de document de vente', dataIndex: 'billNumber', width: '20%' },
        { title: 'Créance à recouvrer',dataIndex: 'needDebt', width: '10%'},
        { title: 'Créance recouvrée',dataIndex: 'finishDebt', width: '10%'},
        { title: 'Recouvrement actuel',dataIndex: 'eachAmount', width: '10%'},
        { title: 'Remarque',dataIndex: 'remark', width: '20%'}
      ],
      moneyOutColumns: [
        { title: '#',dataIndex:'',width:'5%',align:'center',customRender:function(t,r,index){return parseInt(index)+1;}},
        { title: "Numéro de document d'achat", dataIndex: 'billNumber', width: '20%' },
        { title: 'Dette à payer',dataIndex: 'needDebt', width: '10%'},
        { title: 'Dette payée',dataIndex: 'finishDebt', width: '10%'},
        { title: 'Paiement actuel',dataIndex: 'eachAmount', width: '10%'},
        { title: 'Remarque',dataIndex: 'remark', width: '20%'}
      ],
    }
  },
  created () {
    let realScreenWidth = window.screen.width
    this.width = realScreenWidth<1500?'1200px':'1550px'
  },
  methods: {
    show(record, type, prefixNo) {
      // Rechercher une information financière unique
      findFinancialDetailByNumber({ billNo: record.billNo }).then((res) => {
        if (res && res.code === 200) {
          let item = res.data
          this.financialType = type
          this.prefixNo = prefixNo
          // Téléchargement de pièce jointe
          this.fileList = item.fileName
          this.visible = true
          this.modalStyle = 'top:20px;height: 95%;'
          this.model = Object.assign({}, item)
          this.$nextTick(() => {
            this.form.setFieldsValue(pick(this.model, 'id'))
          });
          let params = {
            headerId: this.model.id,
          }
          let url = this.readOnly ? this.url.detailList : this.url.detailList;
          this.requestSubTableData(url, params);
          this.getSystemConfig()
        }
      })
    },
    requestSubTableData(url, params, success) {
      this.loading = true
      getAction(url, params).then(res => {
        if(res && res.code === 200){
          this.dataSource = res.data.rows
          typeof success === 'function' ? success(res) : ''
        }
      }).finally(() => {
        this.loading = false
      })
    },
    getSystemConfig() {
      getCurrentSystemConfig().then((res) => {
        if(res.code === 200 && res.data){
          let multiBillType = res.data.multiBillType
          let multiLevelApprovalFlag = res.data.multiLevelApprovalFlag
          this.checkFlag = getCheckFlag(multiBillType, multiLevelApprovalFlag, this.prefixNo)
        }
      })
    },
    handleBackCheck() {
      let that = this
      this.$confirm({
        title: "Confirmer l'opération",
        content: "Voulez-vous désauditer ce document ?",
        onOk: function () {
          that.loading = true
          postAction(that.url.batchSetStatusUrl, {status: '0', ids: that.model.id}).then((res) => {
            if(res.code === 200){
              that.$emit('ok')
              that.loading = false
              that.close()
            } else {
              that.$message.warning(res.data.message)
              that.loading = false
            }
          }).finally(() => {
          })
        }
      })
    },
    handleCancel() {
      this.close()
    },
    close() {
      this.$emit('close')
      this.visible = false
      this.modalStyle = ''
    },
  }
}
</script>

<style scoped></style>
