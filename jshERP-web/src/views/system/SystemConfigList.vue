<template>
  <a-card :style="cardStyle" :bordered="false">
    <a-spin :spinning="confirmLoading">
      <a-form :form="form">
        <a-row class="form-row" :gutter="24">
          <a-col :lg="12" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Nom de l'entreprise">
              <a-input
                placeholder="Veuillez saisir le nom de l'entreprise"
                v-decorator.trim="['companyName']"
                @change="handleCompanyName"
              />
            </a-form-item>
          </a-col>
          <a-col :lg="12" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Contact">
              <a-input
                placeholder="Veuillez saisir le contact"
                v-decorator.trim="['companyContacts']"
                @change="handleCompanyContacts"
              />
            </a-form-item>
          </a-col>
        </a-row>
        <a-row class="form-row" :gutter="24">
          <a-col :lg="12" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Adresse de l'entreprise">
              <a-input
                placeholder="Veuillez saisir l'adresse de l'entreprise"
                v-decorator.trim="['companyAddress']"
                @change="handleCompanyAddress"
              />
            </a-form-item>
          </a-col>
          <a-col :lg="12" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Téléphone de l'entreprise">
              <a-input
                placeholder="Veuillez saisir le téléphone de l'entreprise"
                v-decorator.trim="['companyTel']"
                @change="handleCompanyTel"
              />
            </a-form-item>
          </a-col>
        </a-row>
        <a-row class="form-row" :gutter="24">
          <a-col :lg="12" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Fax de l'entreprise">
              <a-input
                placeholder="Veuillez saisir le fax de l'entreprise"
                v-decorator.trim="['companyFax']"
                @change="handleCompanyFax"
              />
            </a-form-item>
          </a-col>
          <a-col :lg="12" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Code postal de l'entreprise">
              <a-input
                placeholder="Veuillez saisir le code postal de l'entreprise"
                v-decorator.trim="['companyPostCode']"
                @change="handleCompanyPostCode"
              />
            </a-form-item>
          </a-col>
        </a-row>
        <a-row class="form-row" :gutter="24">
          <a-col :lg="12" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Accord de vente">
              <a-input
                placeholder="Veuillez saisir l'accord de vente"
                v-decorator.trim="['saleAgreement']"
                @change="handleSaleAgreement"
              />
            </a-form-item>
          </a-col>
          <a-col :lg="12" :md="12" :sm="24"></a-col>
        </a-row>
        <a-row class="form-row" :gutter="24">
          <a-col :lg="12" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Attribution des permissions d'entrepôt">
              <a-switch
                checked-children="Activé"
                un-checked-children="Fermé"
                v-model="depotFlagSwitch"
                @change="onDepotChange"
              ></a-switch>
              （Après activation, vous devez aller dans <b>Gestion des utilisateurs</b> pour
              <b>attribuer des entrepôts</b>, pour les scénarios où une personne dédiée gère les entrepôts）
            </a-form-item>
          </a-col>
          <a-col :lg="12" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Attribution des permissions de client">
              <a-switch
                checked-children="Activé"
                un-checked-children="Fermé"
                v-model="customerFlagSwitch"
                @change="onCustomerChange"
              ></a-switch>
              （Après activation, vous devez aller dans <b>Gestion des utilisateurs</b> pour
              <b>attribuer des clients</b>, pour les scénarios où les vendeurs ne peuvent voir que leurs propres
              clients）
            </a-form-item>
          </a-col>
        </a-row>
        <a-row class="form-row" :gutter="24">
          <a-col :lg="12" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Prise en charge du stock négatif">
              <a-switch
                checked-children="Activé"
                un-checked-children="Fermé"
                v-model="minusStockFlagSwitch"
                @change="onMinusStockChange"
              ></a-switch>
              （Après activation, les documents <b>supportent le stock négatif</b> lors de la saisie, et ne signaleront
              plus l'insuffisance de stock）
            </a-form-item>
          </a-col>
          <a-col :lg="12" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Achat basé sur la vente">
              <a-switch
                checked-children="Activé"
                un-checked-children="Fermé"
                v-model="purchaseBySaleFlagSwitch"
                @change="onPurchaseBySaleChange"
              ></a-switch>
              （Après activation, les <b>commandes d'achat</b> seront personnalisées selon les
              <b>commandes de vente</b>, puis les marchandises seront envoyées aux clients après réception）
            </a-form-item>
          </a-col>
        </a-row>
        <a-row class="form-row" :gutter="24">
          <a-col :lg="12" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Dépassement des documents associés">
              <a-switch
                checked-children="Activé"
                un-checked-children="Fermé"
                v-model="overLinkBillFlagSwitch"
                @change="onOverLinkBillChange"
              ></a-switch>
              （Après activation, permet aux documents actuels de <b>dépasser les documents associés</b> en quantité de
              produits pour les entrées et sorties）
            </a-form-item>
          </a-col>
          <a-col :lg="12" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Mise à jour du prix unitaire">
              <a-switch
                checked-children="Activé"
                un-checked-children="Fermé"
                v-model="updateUnitPriceFlagSwitch"
                @change="onUpdateUnitPriceChange"
              ></a-switch>
              （Après activation, le prix unitaire des produits sera automatiquement mis à jour selon la saisie des
              documents, l'état par défaut est activé）
            </a-form-item>
          </a-col>
        </a-row>
        <a-row class="form-row" :gutter="24">
          <a-col :lg="12" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Validation stricte">
              <a-switch
                checked-children="Activé"
                un-checked-children="Fermé"
                v-model="forceApprovalFlagSwitch"
                @change="onForceApprovalChange"
              ></a-switch>
              （Après activation, seuls les documents <b>validés</b> peuvent générer du stock, ce qui concerne les
              rapports liés à la consultation du stock. Après activation ou désactivation, vous devez aller dans
              <b>Gestion des produits</b> pour <b>corriger le stock en lot</b>, veuillez opérer avec prudence selon les
              besoins réels）
            </a-form-item>
          </a-col>
          <a-col :lg="12" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Gestion des entrées et sorties">
              <a-switch
                checked-children="Activé"
                un-checked-children="Fermé"
                v-model="inOutManageFlagSwitch"
                @change="onInOutManageChange"
              ></a-switch>
              （Après activation, tous les documents liés aux achats et ventes doivent passer par les documents
              <b>d'autres entrées et sorties</b> pour générer du stock. Après activation ou désactivation, vous devez
              aller dans <b>Gestion des produits</b> pour <b>corriger le stock en lot</b>, veuillez opérer avec prudence
              selon les besoins réels）
            </a-form-item>
          </a-col>
        </a-row>
        <a-row class="form-row" :gutter="24">
          <a-col :lg="12" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Multi-comptes">
              <a-switch
                checked-children="Activé"
                un-checked-children="Fermé"
                v-model="multiAccountFlagSwitch"
                @change="onMultiAccountChange"
              ></a-switch>
              （Après activation, les comptes de règlement des documents tels que commandes d'achat, entrées d'achat,
              retours d'achat, commandes de vente, sorties de vente, retours de vente, etc. peuvent être sélectionnés en
              multi-comptes）
            </a-form-item>
          </a-col>
          <a-col :lg="12" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Prix moyen mobile">
              <a-switch
                checked-children="Activé"
                un-checked-children="Fermé"
                v-model="moveAvgPriceFlagSwitch"
                @change="onMoveAvgPriceChange"
              ></a-switch>
              （Par défaut désactivé, le prix de revient est égal au prix d'achat saisi sur la page d'informations
              produit. Après activation, le prix de revient sera calculé par moyenne mobile, vous devez aller dans
              <b>Gestion des produits</b> pour <b>corriger le coût en lot</b>, veuillez opérer avec prudence selon les
              besoins réels）
            </a-form-item>
          </a-col>
        </a-row>
        <a-row class="form-row" :gutter="24">
          <a-col :lg="12" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Validation avant impression">
              <a-switch
                checked-children="Activé"
                un-checked-children="Fermé"
                v-model="auditPrintFlagSwitch"
                @change="onAuditPrintChange"
              ></a-switch>
              （Après activation, tous les documents sous Gestion de la vente au détail, Gestion des achats, Gestion des
              ventes et Gestion des entrepôts doivent être validés avant l'impression）
            </a-form-item>
          </a-col>
          <a-col :lg="12" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Paiement zéro">
              <a-switch
                checked-children="Activé"
                un-checked-children="Fermé"
                v-model="zeroChangeAmountFlagSwitch"
                @change="onZeroChangeAmountChange"
              ></a-switch>
              （Après activation, lors de la création d'un document de sortie de vente, <b>ce paiement</b> est par
              défaut à 0, idem pour les documents d'entrée d'achat）
            </a-form-item>
          </a-col>
        </a-row>
        <a-row class="form-row" :gutter="24">
          <a-col :lg="12" :md="12" :sm="24">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Prix unitaire statique du client">
              <a-switch
                checked-children="Activé"
                un-checked-children="Fermé"
                v-model="customerStaticPriceFlagSwitch"
                @change="onCustomerStaticPriceChange"
              ></a-switch>
              （Après activation, le prix unitaire des sorties de vente du client ne sera pas obtenu à partir du prix
              unitaire des documents historiques de ce client, mais uniquement à partir des informations produit）
            </a-form-item>
          </a-col>
          <a-col :lg="12" :md="12" :sm="24" v-if="isShowApproval">
            <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Validation multi-niveaux">
              <a-switch
                checked-children="Activé"
                un-checked-children="Fermé"
                v-model="multiLevelApprovalFlagSwitch"
                @change="onMultiLevelApprovalChange"
              ></a-switch>
              <a-select
                placeholder="Veuillez sélectionner le type de processus"
                v-model="multiBillTypeSelect"
                style="width: 400px; padding-left: 10px"
                mode="multiple"
                :maxTagCount="6"
                :dropdownMatchSelectWidth="false"
                showSearch
                allow-clear
                optionFilterProp="children"
                @change="onMultiBillTypeChange"
              >
                <a-select-option v-for="(item, index) in billTypeList" :key="index" :value="item.key">
                  {{ item.value }}
                </a-select-option>
              </a-select>
              <br />（Après activation, la validation multi-niveaux nécessite la configuration d'un processus, après
              activation, vous devez actualiser le navigateur pour voir l'effet）<a-button
                type="link"
                @click="handleReload"
                >Cliquer pour actualiser</a-button
              >
            </a-form-item>
          </a-col>
        </a-row>
      </a-form>
    </a-spin>
  </a-card>
</template>
<!-- b y 7 5 2 7  1 8 9 2 0 -->
<script>
import pick from 'lodash.pick'
import JSelectMultiple from '@/components/jeecg/JSelectMultiple'
import { addSystemConfig, editSystemConfig } from '@/api/api'
import { autoJumpNextInput } from '@/utils/util'
import { getAction } from '@/api/manage'
import { mixinDevice } from '@/utils/mixin.js'

export default {
  name: 'SystemConfigList',
  mixins: [mixinDevice],
  components: {
    JSelectMultiple,
  },
  data() {
    return {
      title: 'Opération',
      cardStyle: '',
      visible: true,
      model: {},
      depotFlagSwitch: false, // État des permissions d'entrepôt
      customerFlagSwitch: false, // État des permissions de client
      minusStockFlagSwitch: false, // État du stock négatif
      purchaseBySaleFlagSwitch: false, // État de l'achat basé sur la vente
      overLinkBillFlagSwitch: false, // État du dépassement des documents associés
      updateUnitPriceFlagSwitch: true, // État de la mise à jour du prix unitaire
      forceApprovalFlagSwitch: false, // Validation stricte
      inOutManageFlagSwitch: false, // Gestion des entrées et sorties
      multiLevelApprovalFlagSwitch: false, // Validation multi-niveaux
      originalMultiLevelApprovalFlag: '0', // État original de la validation multi-niveaux
      multiBillTypeSelect: [], // Type de document
      originalMultiBillTypeSelect: [], // Type de document original
      isShowApproval: false, // Afficher la validation multi-niveaux
      multiAccountFlagSwitch: false, // Multi-comptes
      moveAvgPriceFlagSwitch: false, // Prix moyen mobile
      auditPrintFlagSwitch: false, // Validation avant impression
      zeroChangeAmountFlagSwitch: false, // Paiement zéro
      customerStaticPriceFlagSwitch: false, // Prix unitaire statique du client
      labelCol: {
        xs: { span: 24 },
        sm: { span: 5 },
      },
      wrapperCol: {
        xs: { span: 24 },
        sm: { span: 16 },
      },
      confirmLoading: false,
      form: this.$form.createForm(this),
      billTypeList: [
        { key: 'LSCK', value: 'Sortie de vente au détail' },
        { key: 'LSTH', value: 'Retour de vente au détail' },
        { key: 'QGD', value: '请购单' },
        { key: 'CGDD', value: '采购订单' },
        { key: 'CGRK', value: '采购入库' },
        { key: 'CGTH', value: '采购退货' },
        { key: 'XSDD', value: '销售订单' },
        { key: 'XSCK', value: '销售出库' },
        { key: 'XSTH', value: '销售退货' },
        { key: 'QTRK', value: 'Autre entrée' },
        { key: 'QTCK', value: 'Autre sortie' },
        { key: 'DBCK', value: '调拨' },
        { key: 'ZZD', value: '组装单' },
        { key: 'CXD', value: '拆卸单' },
        { key: 'SR', value: '收入' },
        { key: 'ZC', value: '支出' },
        { key: 'SK', value: '收款' },
        { key: 'FK', value: '付款' },
        { key: 'ZZ', value: '转账' },
        { key: 'SYF', value: '收预付款' },
      ],
    }
  },
  created() {
    this.init()
    this.loadPlugins()
    if (this.isDesktop()) {
      this.cardStyle = 'height:' + (document.documentElement.clientHeight - 125) + 'px'
    }
  },
  methods: {
    // Initialiser et charger le contenu
    init() {
      let param = {
        search: { companyName: '' },
        currentPage: 1,
        pageSize: 10,
      }
      getAction('/systemConfig/list', param).then((res) => {
        if (res.code === 200) {
          let record = res.data.rows[0]
          this.form.resetFields()
          this.model = Object.assign({}, record)
          this.visible = true
          this.$nextTick(() => {
            this.form.setFieldsValue(
              pick(
                this.model,
                'companyName',
                'companyContacts',
                'companyAddress',
                'companyTel',
                'companyFax',
                'companyPostCode',
                'saleAgreement'
              )
            )
          })
          if (record.id) {
            if (record.depotFlag != null) {
              this.depotFlagSwitch = record.depotFlag == '1' ? true : false
            }
            if (record.customerFlag != null) {
              this.customerFlagSwitch = record.customerFlag == '1' ? true : false
            }
            if (record.minusStockFlag != null) {
              this.minusStockFlagSwitch = record.minusStockFlag == '1' ? true : false
            }
            if (record.purchaseBySaleFlag != null) {
              this.purchaseBySaleFlagSwitch = record.purchaseBySaleFlag == '1' ? true : false
            }
            if (record.overLinkBillFlag != null) {
              this.overLinkBillFlagSwitch = record.overLinkBillFlag == '1' ? true : false
            }
            if (record.updateUnitPriceFlag != null) {
              this.updateUnitPriceFlagSwitch = record.updateUnitPriceFlag == '1' ? true : false
            }
            if (record.forceApprovalFlag != null) {
              this.forceApprovalFlagSwitch = record.forceApprovalFlag == '1' ? true : false
            }
            if (record.inOutManageFlag != null) {
              this.inOutManageFlagSwitch = record.inOutManageFlag == '1' ? true : false
            }
            if (record.multiLevelApprovalFlag != null) {
              this.multiLevelApprovalFlagSwitch = record.multiLevelApprovalFlag == '1' ? true : false
              this.originalMultiLevelApprovalFlag = record.multiLevelApprovalFlag
            }
            if (record.multiBillType != null && record.multiBillType != '') {
              this.multiBillTypeSelect = record.multiBillType.split(',')
              this.originalMultiBillTypeSelect = record.multiBillType
            }
            if (record.multiAccountFlag != null) {
              this.multiAccountFlagSwitch = record.multiAccountFlag == '1' ? true : false
            }
            if (record.moveAvgPriceFlag != null) {
              this.moveAvgPriceFlagSwitch = record.moveAvgPriceFlag == '1' ? true : false
            }
            if (record.auditPrintFlag != null) {
              this.auditPrintFlagSwitch = record.auditPrintFlag == '1' ? true : false
            }
            if (record.zeroChangeAmountFlag != null) {
              this.zeroChangeAmountFlagSwitch = record.zeroChangeAmountFlag == '1' ? true : false
            }
            if (record.customerStaticPriceFlag != null) {
              this.customerStaticPriceFlagSwitch = record.customerStaticPriceFlag == '1' ? true : false
            }
          }
        } else {
          this.$message.info(res.data)
        }
      })
    },
    loadPlugins() {
      // Vérifier si le plugin de validation multi-niveaux existe
      getAction('/plugin/checkByPluginId', { pluginIds: 'workflow' }).then((res) => {
        if (res.code === 200) {
          if (res.data) {
            this.isShowApproval = true
          }
        }
      })
      // Vérifier si le plugin d'inventaire existe
      getAction('/plugin/checkByPluginId', { pluginIds: 'stock-check' }).then((res) => {
        if (res.code === 200) {
          if (res.data) {
            this.billTypeList.push(
              { key: 'PDLR', value: "Saisie d'inventaire" },
              { key: 'PDFP', value: 'Re-inventaire' }
            )
            // Vérifier si le plugin de production existe
            getAction('/plugin/checkByPluginId', { pluginIds: 'produce' }).then((res) => {
              if (res.code === 200) {
                if (res.data) {
                  this.billTypeList.push(
                    { key: 'SC', value: 'Tâche de production' },
                    { key: 'WW', value: 'Tâche sous-traitée' }
                  )
                }
              }
            })
          }
        }
      })
    },
    handleCompanyName(event) {
      this.model.companyName = event.target.value
      if (this.model.companyName && this.model.companyName.length > 30) {
        this.$message.warning("La longueur du nom de l'entreprise dépasse 30 caractères")
      } else {
        this.handleChange()
      }
    },
    handleCompanyContacts(event) {
      this.model.companyContacts = event.target.value
      this.handleChange()
    },
    handleCompanyAddress(event) {
      this.model.companyAddress = event.target.value
      this.handleChange()
    },
    handleCompanyTel(event) {
      this.model.companyTel = event.target.value
      this.handleChange()
    },
    handleCompanyFax(event) {
      this.model.companyFax = event.target.value
      this.handleChange()
    },
    handleCompanyPostCode(event) {
      this.model.companyPostCode = event.target.value
      this.handleChange()
    },
    handleSaleAgreement(event) {
      this.model.saleAgreement = event.target.value
      if (this.model.saleAgreement && this.model.saleAgreement.length > 400) {
        this.$message.warning("La longueur de l'accord de vente dépasse 400 caractères")
      } else {
        this.handleChange()
      }
    },
    onDepotChange(checked) {
      this.model.depotFlag = checked ? '1' : '0'
      this.handleChange()
    },
    onCustomerChange(checked) {
      this.model.customerFlag = checked ? '1' : '0'
      this.handleChange()
    },
    onMinusStockChange(checked) {
      this.model.minusStockFlag = checked ? '1' : '0'
      this.handleChange()
    },
    onPurchaseBySaleChange(checked) {
      this.model.purchaseBySaleFlag = checked ? '1' : '0'
      this.handleChange()
    },
    onOverLinkBillChange(checked) {
      this.model.overLinkBillFlag = checked ? '1' : '0'
      this.handleChange()
    },
    onUpdateUnitPriceChange(checked) {
      this.model.updateUnitPriceFlag = checked ? '1' : '0'
      this.handleChange()
    },
    onForceApprovalChange(checked) {
      this.model.forceApprovalFlag = checked ? '1' : '0'
      this.handleChange()
    },
    onInOutManageChange(checked) {
      this.model.inOutManageFlag = checked ? '1' : '0'
      this.handleChange()
    },
    onMultiLevelApprovalChange(checked) {
      this.model.multiLevelApprovalFlag = checked ? '1' : '0'
      if (!checked) {
        this.multiBillTypeSelect = []
        this.model.multiBillType = ''
      }
      this.handleChange()
    },
    onMultiBillTypeChange() {
      this.model.multiBillType = this.multiBillTypeSelect.join(',')
      this.handleChange()
    },
    onMultiAccountChange(checked) {
      this.model.multiAccountFlag = checked ? '1' : '0'
      this.handleChange()
    },
    onMoveAvgPriceChange(checked) {
      this.model.moveAvgPriceFlag = checked ? '1' : '0'
      this.handleChange()
    },
    onAuditPrintChange(checked) {
      this.model.auditPrintFlag = checked ? '1' : '0'
      this.handleChange()
    },
    onZeroChangeAmountChange(checked) {
      this.model.zeroChangeAmountFlag = checked ? '1' : '0'
      this.handleChange()
    },
    onCustomerStaticPriceChange(checked) {
      this.model.customerStaticPriceFlag = checked ? '1' : '0'
      this.handleChange()
    },
    // Modifier le contenu
    handleChange() {
      this.confirmLoading = true
      let obj
      if (!this.model.id) {
        obj = addSystemConfig(this.model)
      } else {
        obj = editSystemConfig(this.model)
      }
      obj
        .then((res) => {
          if (res.code === 200) {
            this.init()
          } else {
            this.$message.warning(res.data.message)
          }
        })
        .finally(() => {
          this.confirmLoading = false
        })
    },
    // Actualiser le navigateur
    handleReload() {
      location.reload()
    },
  },
}
</script>
<style scoped>
@import '~@assets/less/common.less';
</style>
