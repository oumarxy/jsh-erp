import Vue from 'vue'
import { getAction, postAction } from '@/api/manage'
import { FormTypes } from '@/utils/JEditableTableUtil'
import {
  findBillDetailByNumber,
  findBySelectSup,
  findBySelectCus,
  findBySelectRetail,
  getUserList,
  getAccount,
  waitBillCount,
  getCurrentSystemConfig,
  getPlatformConfigByKey,
  getPersonByNumType,
} from '@/api/api'
import { getCheckFlag, getFormatDate, getMpListShort, getPrevMonthFormatDate } from '@/utils/util'
import moment from 'moment'
import pick from 'lodash.pick'

export const BillListMixin = {
  data() {
    return {
      /* Vérifier si l'audit original est activé */
      checkFlag: true,
      /* Vérifier si Excel pour les documents est activé */
      isShowExcel: false,
      // Interrupteur de scénario d'achat basé sur les ventes
      purchaseBySaleFlag: false,
      setTimeFlag: null,
      waitTotal: 0,
      dateFormat: 'YYYY-MM-DD',
      billExcelUrl: '',
      defaultDepotId: '',
      supList: [],
      cusList: [],
      retailList: [],
      salesManList: [],
      userList: [],
      accountList: [],
      // Index réel
      settingDataIndex: [],
      // Stocker les clés des lignes développées
      expandedRowKeys: [],
      // Colonnes réelles
      columns: [],
      // En-têtes de détail
      detailColumns: [],
      // Définition des colonnes
      defDetailColumns: [],
      retailOutColumns: [
        { title: "Nom de l'entrepôt", dataIndex: 'depotName' },
        { title: 'Code-barres', dataIndex: 'barCode' },
        { title: 'Nom', dataIndex: 'name' },
        { title: 'Spécification', dataIndex: 'standard' },
        { title: 'Modèle', dataIndex: 'model' },
        { title: 'Couleur', dataIndex: 'color' },
        { title: 'Marque', dataIndex: 'brand' },
        { title: 'Fabricant', dataIndex: 'mfrs' },
        { title: 'Extension 1', dataIndex: 'otherField1' },
        { title: 'Extension 2', dataIndex: 'otherField2' },
        { title: 'Extension 3', dataIndex: 'otherField3' },
        { title: 'Stock', dataIndex: 'stock' },
        { title: 'Unité', dataIndex: 'unit' },
        { title: 'Numéro de série', dataIndex: 'snList', width: 300 },
        { title: 'Numéro de lot', dataIndex: 'batchNumber' },
        { title: "Date d'expiration", dataIndex: 'expirationDate' },
        { title: 'Multi-attributs', dataIndex: 'sku' },
        { title: 'Quantité', dataIndex: 'operNumber' },
        { title: 'Prix unitaire', dataIndex: 'unitPrice' },
        { title: 'Montant', dataIndex: 'allPrice' },
        { title: 'Poids', dataIndex: 'weight' },
        { title: 'Emplacement/Étagère', dataIndex: 'position' },
        { title: 'Remarque', dataIndex: 'remark' },
      ],
      retailBackColumns: [
        { title: "Nom de l'entrepôt", dataIndex: 'depotName' },
        { title: 'Code-barres', dataIndex: 'barCode' },
        { title: 'Nom', dataIndex: 'name' },
        { title: 'Spécification', dataIndex: 'standard' },
        { title: 'Modèle', dataIndex: 'model' },
        { title: 'Couleur', dataIndex: 'color' },
        { title: 'Marque', dataIndex: 'brand' },
        { title: 'Fabricant', dataIndex: 'mfrs' },
        { title: 'Extension 1', dataIndex: 'otherField1' },
        { title: 'Extension 2', dataIndex: 'otherField2' },
        { title: 'Extension 3', dataIndex: 'otherField3' },
        { title: 'Stock', dataIndex: 'stock' },
        { title: 'Unité', dataIndex: 'unit' },
        { title: 'Numéro de série', dataIndex: 'snList', width: 300 },
        { title: 'Numéro de lot', dataIndex: 'batchNumber' },
        { title: "Date d'expiration", dataIndex: 'expirationDate' },
        { title: 'Multi-attributs', dataIndex: 'sku' },
        { title: 'Quantité', dataIndex: 'operNumber' },
        { title: 'Prix unitaire', dataIndex: 'unitPrice' },
        { title: 'Montant', dataIndex: 'allPrice' },
        { title: 'Poids', dataIndex: 'weight' },
        { title: 'Emplacement/Étagère', dataIndex: 'position' },
        { title: 'Remarque', dataIndex: 'remark' },
      ],
      purchaseApplyColumns: [
        { title: 'Code-barres', dataIndex: 'barCode' },
        { title: 'Nom', dataIndex: 'name' },
        { title: 'Spécification', dataIndex: 'standard' },
        { title: 'Modèle', dataIndex: 'model' },
        { title: 'Couleur', dataIndex: 'color' },
        { title: 'Marque', dataIndex: 'brand' },
        { title: 'Fabricant', dataIndex: 'mfrs' },
        { title: 'Extension 1', dataIndex: 'otherField1' },
        { title: 'Extension 2', dataIndex: 'otherField2' },
        { title: 'Extension 3', dataIndex: 'otherField3' },
        { title: 'Unité', dataIndex: 'unit' },
        { title: 'Multi-attributs', dataIndex: 'sku' },
        { title: 'Quantité', dataIndex: 'operNumber' },
        { title: 'Acheté', dataIndex: 'finishNumber' },
        { title: 'Remarque', dataIndex: 'remark' },
      ],
      purchaseOrderColumns: [
        { title: 'Code-barres', dataIndex: 'barCode' },
        { title: 'Nom', dataIndex: 'name' },
        { title: 'Spécification', dataIndex: 'standard' },
        { title: 'Modèle', dataIndex: 'model' },
        { title: 'Couleur', dataIndex: 'color' },
        { title: 'Marque', dataIndex: 'brand' },
        { title: 'Fabricant', dataIndex: 'mfrs' },
        { title: 'Extension 1', dataIndex: 'otherField1' },
        { title: 'Extension 2', dataIndex: 'otherField2' },
        { title: 'Extension 3', dataIndex: 'otherField3' },
        { title: 'Stock', dataIndex: 'stock' },
        { title: 'Unité', dataIndex: 'unit' },
        { title: 'Multi-attributs', dataIndex: 'sku' },
        { title: 'Quantité', dataIndex: 'operNumber' },
        { title: 'Acheté', dataIndex: 'finishNumber' },
        { title: 'Prix unitaire', dataIndex: 'unitPrice' },
        { title: 'Montant', dataIndex: 'allPrice' },
        { title: 'Taux de taxe (%)', dataIndex: 'taxRate' },
        { title: 'Montant de la taxe', dataIndex: 'taxMoney' },
        { title: 'Total TTC', dataIndex: 'taxLastMoney' },
        { title: 'Remarque', dataIndex: 'remark' },
      ],
      purchaseInColumns: [
        { title: "Nom de l'entrepôt", dataIndex: 'depotName' },
        { title: 'Code-barres', dataIndex: 'barCode' },
        { title: 'Nom', dataIndex: 'name' },
        { title: 'Spécification', dataIndex: 'standard' },
        { title: 'Modèle', dataIndex: 'model' },
        { title: 'Couleur', dataIndex: 'color' },
        { title: 'Marque', dataIndex: 'brand' },
        { title: 'Fabricant', dataIndex: 'mfrs' },
        { title: 'Extension 1', dataIndex: 'otherField1' },
        { title: 'Extension 2', dataIndex: 'otherField2' },
        { title: 'Extension 3', dataIndex: 'otherField3' },
        { title: 'Stock', dataIndex: 'stock' },
        { title: 'Unité', dataIndex: 'unit' },
        { title: 'Numéro de série', dataIndex: 'snList', width: 300 },
        { title: 'Numéro de lot', dataIndex: 'batchNumber' },
        { title: "Date d'expiration", dataIndex: 'expirationDate' },
        { title: 'Multi-attributs', dataIndex: 'sku' },
        { title: 'Quantité', dataIndex: 'operNumber' },
        { title: 'Entré en stock', dataIndex: 'finishNumber' },
        { title: 'Prix unitaire', dataIndex: 'unitPrice' },
        { title: 'Montant', dataIndex: 'allPrice' },
        { title: 'Taux de taxe (%)', dataIndex: 'taxRate' },
        { title: 'Montant de la taxe', dataIndex: 'taxMoney' },
        { title: 'Total TTC', dataIndex: 'taxLastMoney' },
        { title: 'Poids', dataIndex: 'weight' },
        { title: 'Emplacement/Étagère', dataIndex: 'position' },
        { title: 'Remarque', dataIndex: 'remark' },
      ],
      purchaseBackColumns: [
        { title: "Nom de l'entrepôt", dataIndex: 'depotName' },
        { title: 'Code-barres', dataIndex: 'barCode' },
        { title: 'Nom', dataIndex: 'name' },
        { title: 'Spécification', dataIndex: 'standard' },
        { title: 'Modèle', dataIndex: 'model' },
        { title: 'Couleur', dataIndex: 'color' },
        { title: 'Marque', dataIndex: 'brand' },
        { title: 'Fabricant', dataIndex: 'mfrs' },
        { title: 'Extension 1', dataIndex: 'otherField1' },
        { title: 'Extension 2', dataIndex: 'otherField2' },
        { title: 'Extension 3', dataIndex: 'otherField3' },
        { title: 'Stock', dataIndex: 'stock' },
        { title: 'Unité', dataIndex: 'unit' },
        { title: 'Numéro de série', dataIndex: 'snList', width: 300 },
        { title: 'Numéro de lot', dataIndex: 'batchNumber' },
        { title: "Date d'expiration", dataIndex: 'expirationDate' },
        { title: 'Multi-attributs', dataIndex: 'sku' },
        { title: 'Quantité', dataIndex: 'operNumber' },
        { title: 'Sorti du stock', dataIndex: 'finishNumber' },
        { title: 'Prix unitaire', dataIndex: 'unitPrice' },
        { title: 'Montant', dataIndex: 'allPrice' },
        { title: 'Taux de taxe (%)', dataIndex: 'taxRate' },
        { title: 'Montant de la taxe', dataIndex: 'taxMoney' },
        { title: 'Total TTC', dataIndex: 'taxLastMoney' },
        { title: 'Poids', dataIndex: 'weight' },
        { title: 'Emplacement/Étagère', dataIndex: 'position' },
        { title: 'Remarque', dataIndex: 'remark' },
      ],
      saleOrderColumns: [
        { title: 'Code-barres', dataIndex: 'barCode' },
        { title: 'Nom', dataIndex: 'name' },
        { title: 'Spécification', dataIndex: 'standard' },
        { title: 'Modèle', dataIndex: 'model' },
        { title: 'Couleur', dataIndex: 'color' },
        { title: 'Marque', dataIndex: 'brand' },
        { title: 'Fabricant', dataIndex: 'mfrs' },
        { title: 'Extension 1', dataIndex: 'otherField1' },
        { title: 'Extension 2', dataIndex: 'otherField2' },
        { title: 'Extension 3', dataIndex: 'otherField3' },
        { title: 'Stock', dataIndex: 'stock' },
        { title: 'Unité', dataIndex: 'unit' },
        { title: 'Multi-attributs', dataIndex: 'sku' },
        { title: 'Quantité', dataIndex: 'operNumber' },
        { title: 'Vendu', dataIndex: 'finishNumber' },
        { title: 'Prix unitaire', dataIndex: 'unitPrice' },
        { title: 'Montant', dataIndex: 'allPrice' },
        { title: 'Taux de taxe (%)', dataIndex: 'taxRate' },
        { title: 'Montant de la taxe', dataIndex: 'taxMoney' },
        { title: 'Total TTC', dataIndex: 'taxLastMoney' },
        { title: 'Remarque', dataIndex: 'remark' },
      ],
      saleOutColumns: [
        { title: "Nom de l'entrepôt", dataIndex: 'depotName' },
        { title: 'Code-barres', dataIndex: 'barCode' },
        { title: 'Nom', dataIndex: 'name' },
        { title: 'Spécification', dataIndex: 'standard' },
        { title: 'Modèle', dataIndex: 'model' },
        { title: 'Couleur', dataIndex: 'color' },
        { title: 'Marque', dataIndex: 'brand' },
        { title: 'Fabricant', dataIndex: 'mfrs' },
        { title: 'Extension 1', dataIndex: 'otherField1' },
        { title: 'Extension 2', dataIndex: 'otherField2' },
        { title: 'Extension 3', dataIndex: 'otherField3' },
        { title: 'Stock', dataIndex: 'stock' },
        { title: 'Unité', dataIndex: 'unit' },
        { title: 'Numéro de série', dataIndex: 'snList', width: 300 },
        { title: 'Numéro de lot', dataIndex: 'batchNumber' },
        { title: "Date d'expiration", dataIndex: 'expirationDate' },
        { title: 'Multi-attributs', dataIndex: 'sku' },
        { title: 'Quantité', dataIndex: 'operNumber' },
        { title: 'Sorti du stock', dataIndex: 'finishNumber' },
        { title: 'Prix unitaire', dataIndex: 'unitPrice' },
        { title: 'Montant', dataIndex: 'allPrice' },
        { title: 'Taux de taxe (%)', dataIndex: 'taxRate' },
        { title: 'Montant de la taxe', dataIndex: 'taxMoney' },
        { title: 'Total TTC', dataIndex: 'taxLastMoney' },
        { title: 'Poids', dataIndex: 'weight' },
        { title: 'Emplacement/Étagère', dataIndex: 'position' },
        { title: 'Remarque', dataIndex: 'remark' },
      ],
      saleBackColumns: [
        { title: "Nom de l'entrepôt", dataIndex: 'depotName' },
        { title: 'Code-barres', dataIndex: 'barCode' },
        { title: 'Nom', dataIndex: 'name' },
        { title: 'Spécification', dataIndex: 'standard' },
        { title: 'Modèle', dataIndex: 'model' },
        { title: 'Couleur', dataIndex: 'color' },
        { title: 'Marque', dataIndex: 'brand' },
        { title: 'Fabricant', dataIndex: 'mfrs' },
        { title: 'Extension 1', dataIndex: 'otherField1' },
        { title: 'Extension 2', dataIndex: 'otherField2' },
        { title: 'Extension 3', dataIndex: 'otherField3' },
        { title: 'Stock', dataIndex: 'stock' },
        { title: 'Unité', dataIndex: 'unit' },
        { title: 'Numéro de série', dataIndex: 'snList', width: 300 },
        { title: 'Numéro de lot', dataIndex: 'batchNumber' },
        { title: "Date d'expiration", dataIndex: 'expirationDate' },
        { title: 'Multi-attributs', dataIndex: 'sku' },
        { title: 'Quantité', dataIndex: 'operNumber' },
        { title: 'Entré en stock', dataIndex: 'finishNumber' },
        { title: 'Prix unitaire', dataIndex: 'unitPrice' },
        { title: 'Montant', dataIndex: 'allPrice' },
        { title: 'Taux de taxe (%)', dataIndex: 'taxRate' },
        { title: 'Montant de la taxe', dataIndex: 'taxMoney' },
        { title: 'Total TTC', dataIndex: 'taxLastMoney' },
        { title: 'Poids', dataIndex: 'weight' },
        { title: 'Emplacement/Étagère', dataIndex: 'position' },
        { title: 'Remarque', dataIndex: 'remark' },
      ],
      otherInColumns: [
        { title: "Nom de l'entrepôt", dataIndex: 'depotName' },
        { title: 'Code-barres', dataIndex: 'barCode' },
        { title: 'Nom', dataIndex: 'name' },
        { title: 'Spécification', dataIndex: 'standard' },
        { title: 'Modèle', dataIndex: 'model' },
        { title: 'Couleur', dataIndex: 'color' },
        { title: 'Marque', dataIndex: 'brand' },
        { title: 'Fabricant', dataIndex: 'mfrs' },
        { title: 'Extension 1', dataIndex: 'otherField1' },
        { title: 'Extension 2', dataIndex: 'otherField2' },
        { title: 'Extension 3', dataIndex: 'otherField3' },
        { title: 'Stock', dataIndex: 'stock' },
        { title: 'Unité', dataIndex: 'unit' },
        { title: 'Numéro de série', dataIndex: 'snList', width: 300 },
        { title: 'Numéro de lot', dataIndex: 'batchNumber' },
        { title: "Date d'expiration", dataIndex: 'expirationDate' },
        { title: 'Multi-attributs', dataIndex: 'sku' },
        { title: 'Quantité', dataIndex: 'operNumber' },
        { title: 'Prix unitaire', dataIndex: 'unitPrice' },
        { title: 'Montant', dataIndex: 'allPrice' },
        { title: 'Poids', dataIndex: 'weight' },
        { title: 'Emplacement/Étagère', dataIndex: 'position' },
        { title: 'Remarque', dataIndex: 'remark' },
      ],
      otherOutColumns: [
        { title: "Nom de l'entrepôt", dataIndex: 'depotName' },
        { title: 'Code-barres', dataIndex: 'barCode' },
        { title: 'Nom', dataIndex: 'name' },
        { title: 'Spécification', dataIndex: 'standard' },
        { title: 'Modèle', dataIndex: 'model' },
        { title: 'Couleur', dataIndex: 'color' },
        { title: 'Marque', dataIndex: 'brand' },
        { title: 'Fabricant', dataIndex: 'mfrs' },
        { title: 'Extension 1', dataIndex: 'otherField1' },
        { title: 'Extension 2', dataIndex: 'otherField2' },
        { title: 'Extension 3', dataIndex: 'otherField3' },
        { title: 'Stock', dataIndex: 'stock' },
        { title: 'Unité', dataIndex: 'unit' },
        { title: 'Numéro de série', dataIndex: 'snList', width: 300 },
        { title: 'Numéro de lot', dataIndex: 'batchNumber' },
        { title: "Date d'expiration", dataIndex: 'expirationDate' },
        { title: 'Multi-attributs', dataIndex: 'sku' },
        { title: 'Quantité', dataIndex: 'operNumber' },
        { title: 'Prix unitaire', dataIndex: 'unitPrice' },
        { title: 'Montant', dataIndex: 'allPrice' },
        { title: 'Poids', dataIndex: 'weight' },
        { title: 'Emplacement/Étagère', dataIndex: 'position' },
        { title: 'Remarque', dataIndex: 'remark' },
      ],
      allocationOutColumns: [
        { title: "Nom de l'entrepôt", dataIndex: 'depotName' },
        { title: 'Code-barres', dataIndex: 'barCode' },
        { title: 'Nom', dataIndex: 'name' },
        { title: 'Spécification', dataIndex: 'standard' },
        { title: 'Modèle', dataIndex: 'model' },
        { title: 'Couleur', dataIndex: 'color' },
        { title: 'Marque', dataIndex: 'brand' },
        { title: 'Fabricant', dataIndex: 'mfrs' },
        { title: 'Extension 1', dataIndex: 'otherField1' },
        { title: 'Extension 2', dataIndex: 'otherField2' },
        { title: 'Extension 3', dataIndex: 'otherField3' },
        { title: 'Stock', dataIndex: 'stock' },
        { title: 'Entrepôt de destination', dataIndex: 'anotherDepotName' },
        { title: 'Unité', dataIndex: 'unit' },
        { title: 'Multi-attributs', dataIndex: 'sku' },
        { title: 'Quantité', dataIndex: 'operNumber' },
        { title: 'Prix unitaire', dataIndex: 'unitPrice' },
        { title: 'Montant', dataIndex: 'allPrice' },
        { title: 'Poids', dataIndex: 'weight' },
        { title: 'Emplacement/Étagère', dataIndex: 'position' },
        { title: 'Remarque', dataIndex: 'remark' },
      ],
      assembleColumns: [
        { title: 'Type de produit', dataIndex: 'mType' },
        { title: "Nom de l'entrepôt", dataIndex: 'depotName' },
        { title: 'Code-barres', dataIndex: 'barCode' },
        { title: 'Nom', dataIndex: 'name' },
        { title: 'Spécification', dataIndex: 'standard' },
        { title: 'Modèle', dataIndex: 'model' },
        { title: 'Couleur', dataIndex: 'color' },
        { title: 'Marque', dataIndex: 'brand' },
        { title: 'Fabricant', dataIndex: 'mfrs' },
        { title: 'Extension 1', dataIndex: 'otherField1' },
        { title: 'Extension 2', dataIndex: 'otherField2' },
        { title: 'Extension 3', dataIndex: 'otherField3' },
        { title: 'Stock', dataIndex: 'stock' },
        { title: 'Unité', dataIndex: 'unit' },
        { title: 'Multi-attributs', dataIndex: 'sku' },
        { title: 'Quantité', dataIndex: 'operNumber' },
        { title: 'Prix unitaire', dataIndex: 'unitPrice' },
        { title: 'Montant', dataIndex: 'allPrice' },
        { title: 'Remarque', dataIndex: 'remark' },
      ],
      disassembleColumns: [
        { title: 'Type de produit', dataIndex: 'mType' },
        { title: "Nom de l'entrepôt", dataIndex: 'depotName' },
        { title: 'Code-barres', dataIndex: 'barCode' },
        { title: 'Nom', dataIndex: 'name' },
        { title: 'Spécification', dataIndex: 'standard' },
        { title: 'Modèle', dataIndex: 'model' },
        { title: 'Couleur', dataIndex: 'color' },
        { title: 'Marque', dataIndex: 'brand' },
        { title: 'Fabricant', dataIndex: 'mfrs' },
        { title: 'Extension 1', dataIndex: 'otherField1' },
        { title: 'Extension 2', dataIndex: 'otherField2' },
        { title: 'Extension 3', dataIndex: 'otherField3' },
        { title: 'Stock', dataIndex: 'stock' },
        { title: 'Unité', dataIndex: 'unit' },
        { title: 'Multi-attributs', dataIndex: 'sku' },
        { title: 'Quantité', dataIndex: 'operNumber' },
        { title: 'Prix unitaire', dataIndex: 'unitPrice' },
        { title: 'Montant', dataIndex: 'allPrice' },
        { title: 'Remarque', dataIndex: 'remark' },
      ],
      stockCheckReplayColumns: [
        { title: "Nom de l'entrepôt", dataIndex: 'depotName' },
        { title: 'Code-barres', dataIndex: 'barCode' },
        { title: 'Nom', dataIndex: 'name' },
        { title: 'Spécification', dataIndex: 'standard' },
        { title: 'Modèle', dataIndex: 'model' },
        { title: 'Marque', dataIndex: 'brand' },
        { title: 'Fabricant', dataIndex: 'mfrs' },
        { title: 'Extension 1', dataIndex: 'otherField1' },
        { title: 'Extension 2', dataIndex: 'otherField2' },
        { title: 'Extension 3', dataIndex: 'otherField3' },
        { title: 'Stock', dataIndex: 'stock' },
        { title: 'Unité', dataIndex: 'unit' },
        { title: 'Multi-attributs', dataIndex: 'sku' },
        { title: 'Quantité', dataIndex: 'operNumber' },
        { title: 'Prix unitaire', dataIndex: 'unitPrice' },
        { title: 'Montant', dataIndex: 'allPrice' },
        { title: 'Remarque', dataIndex: 'remark' },
      ],
      quickBtn: {
        retailBack: '',
        purchaseOrder: '',
        purchaseIn: '',
        purchaseBack: '',
        saleOut: '',
        saleBack: '',
      },
      queryParam: {
        beginTime: getPrevMonthFormatDate(3),
        endTime: getFormatDate(),
        createTimeRange: [moment(getPrevMonthFormatDate(3)), moment(getFormatDate())],
      },
    }
  },
  computed: {
    importExcelUrl: function () {
      return `${window._CONFIG['domianURL']}/${this.url.importExcelUrl}`
    },
    isBatchDelEnabled: function () {
      for (let i = 0; i < this.selectedRowKeys.length; i++) {
        if (!this.selectionRows[i].actionsEnabled.delete) {
          return false
        }
      }
      return true
    },
  },
  created() {
    this.initColumnsSetting()
    this.isShowExcel = Vue.ls.get('isShowExcel')
  },
  methods: {
    loadData(arg) {
      // Réinitialiser l'état d'expansion
      this.expandedRowKeys = []
      if (arg === 1) {
        this.ipagination.current = 1
      }
      let params = this.getQueryParams() // Conditions de requête
      this.loading = true
      getAction(this.url.list, params).then((res) => {
        if (res.code === 200) {
          this.dataSource = res.data.rows
          this.ipagination.total = res.data.total
          this.tableAddTotalRow(this.columns, this.dataSource)
        } else if (res.code === 510) {
          this.$message.warning(res.data)
        } else {
          this.$message.warning(res.data.message)
        }
        this.loading = false
        this.onClearSelected()
      })
    },
    myHandleAdd() {
      this.$refs.modalForm.action = 'add'
      if (this.btnEnableList.indexOf(2) === -1) {
        this.$refs.modalForm.isCanCheck = false
      }
      this.handleAdd()
    },
    myHandleCopyAdd(record) {
      this.$refs.modalForm.action = 'copyAdd'
      if (this.btnEnableList.indexOf(2) === -1) {
        this.$refs.modalForm.isCanCheck = false
      }
      // Lors de la copie d'un document, il faut supprimer les informations relatives aux documents associés
      record.linkNumber = ''
      record.billType = ''
      record.deposit = ''
      this.$refs.modalForm.edit(record)
      this.$refs.modalForm.title = 'Copier et ajouter'
      this.$refs.modalForm.disableSubmit = false
      // Activer le mode d'édition des détails
      this.$refs.modalForm.rowCanEdit = true
      let columnIndex = record.subType === '组装单' || record.subType === '拆卸单' ? 2 : 1
      this.$refs.modalForm.materialTable.columns[columnIndex].type = FormTypes.popupJsh
    },
    myHandleEdit(record) {
      if (record.status === '0') {
        this.$refs.modalForm.action = 'edit'
        if (this.btnEnableList.indexOf(2) === -1) {
          this.$refs.modalForm.isCanCheck = false
        }
        // Interroger les informations d'un document unique
        findBillDetailByNumber({ number: record.number }).then((res) => {
          if (res && res.code === 200) {
            let item = res.data
            this.handleEdit(item)
          }
        })
      } else {
        this.$message.warning(
          "Désolé, seuls les documents non audités peuvent être modifiés, veuillez d'abord effectuer une désaudit !"
        )
      }
    },
    myHandleDelete(record) {
      if (record.status === '0') {
        this.handleDelete(record.id)
      } else {
        this.$message.warning(
          "Désolé, seuls les documents non audités peuvent être supprimés, veuillez d'abord effectuer une désaudit !"
        )
      }
    },
    myHandleDetail(record, type, prefixNo) {
      if (this.btnEnableList.indexOf(7) === -1) {
        this.$refs.modalDetail.isCanBackCheck = false
      }
      this.handleDetail(record, type, prefixNo)
    },
    batchForceClose: function () {
      if (!this.url.forceCloseBatch) {
        this.$message.error("Veuillez définir l'attribut url.forceCloseBatch !")
        return
      }
      if (this.selectedRowKeys.length <= 0) {
        this.$message.warning('Veuillez sélectionner un enregistrement !')
      } else {
        let ids = ''
        for (let a = 0; a < this.selectedRowKeys.length; a++) {
          ids += this.selectedRowKeys[a] + ','
        }
        let that = this
        this.$confirm({
          title: 'Confirmer la clôture forcée',
          content: 'Voulez-vous forcer la clôture des données sélectionnées ?',
          onOk: function () {
            that.loading = true
            postAction(that.url.forceCloseBatch, { ids: ids })
              .then((res) => {
                if (res.code === 200) {
                  that.loadData()
                } else {
                  that.$message.warning(res.data.message)
                }
              })
              .finally(() => {
                that.loading = false
              })
          },
        })
      }
    },
    batchForceClosePurchase: function () {
      if (!this.url.forceClosePurchaseBatch) {
        this.$message.error("Veuillez définir l'attribut url.forceClosePurchaseBatch !")
        return
      }
      if (this.selectedRowKeys.length <= 0) {
        this.$message.warning('Veuillez sélectionner un enregistrement !')
      } else {
        let ids = ''
        for (let a = 0; a < this.selectedRowKeys.length; a++) {
          ids += this.selectedRowKeys[a] + ','
        }
        let that = this
        this.$confirm({
          title: 'Confirmer la clôture forcée (achat basé sur les ventes)',
          content: 'Voulez-vous forcer la clôture des données sélectionnées ?',
          onOk: function () {
            that.loading = true
            postAction(that.url.forceClosePurchaseBatch, { ids: ids })
              .then((res) => {
                if (res.code === 200) {
                  that.loadData()
                } else {
                  that.$message.warning(res.data.message)
                }
              })
              .finally(() => {
                that.loading = false
              })
          },
        })
      }
    },
    handleApprove(record) {
      this.$refs.modalForm.action = 'approve'
      this.$refs.modalForm.edit(record)
      this.$refs.modalForm.title = 'Audit'
    },
    searchReset() {
      this.queryParam = {
        type: this.queryParam.type,
        subType: this.queryParam.subType,
        beginTime: getPrevMonthFormatDate(3),
        endTime: getFormatDate(),
        createTimeRange: [moment(getPrevMonthFormatDate(3)), moment(getFormatDate())],
      }
      this.loadData(1)
    },
    onDateChange: function (value, dateString) {
      this.queryParam.beginTime = dateString[0]
      this.queryParam.endTime = dateString[1]
      if (dateString[0] && dateString[1]) {
        this.queryParam.createTimeRange = [moment(dateString[0]), moment(dateString[1])]
      }
    },
    onDateOk(value) {
      console.log(value)
    },
    initSystemConfig() {
      getCurrentSystemConfig().then((res) => {
        if (res.code === 200 && res.data) {
          let multiBillType = res.data.multiBillType
          let multiLevelApprovalFlag = res.data.multiLevelApprovalFlag
          this.checkFlag = getCheckFlag(multiBillType, multiLevelApprovalFlag, this.prefixNo)
          this.purchaseBySaleFlag = res.data.purchaseBySaleFlag === '1' ? true : false
          this.inOutManageFlag = res.data.inOutManageFlag === '1' ? true : false
        }
      })
      getPlatformConfigByKey({ platformKey: 'bill_excel_url' }).then((res) => {
        if (res && res.code === 200) {
          if (res.data.platformValue) {
            this.billExcelUrl = res.data.platformValue
          }
        }
      })
    },
    initSupplier() {
      let that = this
      findBySelectSup({ limit: 1 }).then((res) => {
        if (res) {
          that.supList = res
        }
      })
    },
    initCustomer() {
      let that = this
      findBySelectCus({ limit: 1 }).then((res) => {
        if (res) {
          that.cusList = res
        }
      })
    },
    initRetail() {
      let that = this
      findBySelectRetail({ limit: 1 }).then((res) => {
        if (res) {
          that.retailList = res
        }
      })
    },
    initSalesman() {
      let that = this
      getPersonByNumType({ type: 1 }).then((res) => {
        if (res) {
          that.salesManList = res
        }
      })
    },
    getDepotData() {
      getAction('/depot/findDepotByCurrentUser').then((res) => {
        if (res.code === 200) {
          this.depotList = res.data
        } else {
          this.$message.info(res.data)
        }
      })
    },
    initUser() {
      getUserList({}).then((res) => {
        if (res) {
          this.userList = res
        }
      })
    },
    initAccount() {
      getAccount({}).then((res) => {
        if (res && res.code === 200) {
          this.accountList = res.data.accountList
        }
      })
    },
    initWaitBillCount(type, subType, status) {
      waitBillCount({
        search: {
          type: type,
          subType: subType,
          status: status,
        },
      }).then((res) => {
        if (res && res.code === 200) {
          this.waitTotal = res.data.total
        }
      })
    },
    // Charger les colonnes d'initialisation
    initColumnsSetting() {
      let columnsStr = Vue.ls.get(this.prefixNo)
      if (columnsStr && columnsStr.indexOf(',') > -1) {
        this.settingDataIndex = columnsStr.split(',')
      } else {
        this.settingDataIndex = this.defDataIndex
      }
      this.columns = this.defColumns.filter((item) => {
        if (this.purchaseBySaleFlag) {
          // Achat basé sur les ventes - activé
          return this.settingDataIndex.includes(item.dataIndex)
        } else {
          // Achat basé sur les ventes - désactivé
          if (this.prefixNo === 'CGDD') {
            // La commande d'achat n'affiche que les colonnes autres que la commande associée
            if (item.dataIndex !== 'linkNumber') {
              return this.settingDataIndex.includes(item.dataIndex)
            }
          } else {
            return this.settingDataIndex.includes(item.dataIndex)
          }
        }
      })
    },
    // Charger les boutons rapides : transfert d'entrée, transfert de sortie, etc.
    initQuickBtn() {
      let btnStrList = Vue.ls.get('winBtnStrList') // Liste des fonctions des boutons - chaîne JSON
      if (btnStrList) {
        for (let i = 0; i < btnStrList.length; i++) {
          if (btnStrList[i].btnStr) {
            this.quickBtn.retailBack =
              btnStrList[i].url === '/bill/retail_back' ? btnStrList[i].btnStr : this.quickBtn.retailBack
            this.quickBtn.purchaseOrder =
              btnStrList[i].url === '/bill/purchase_order' ? btnStrList[i].btnStr : this.quickBtn.purchaseOrder
            this.quickBtn.purchaseIn =
              btnStrList[i].url === '/bill/purchase_in' ? btnStrList[i].btnStr : this.quickBtn.purchaseIn
            this.quickBtn.purchaseBack =
              btnStrList[i].url === '/bill/purchase_back' ? btnStrList[i].btnStr : this.quickBtn.purchaseBack
            this.quickBtn.saleOut =
              btnStrList[i].url === '/bill/sale_out' ? btnStrList[i].btnStr : this.quickBtn.saleOut
            this.quickBtn.saleBack =
              btnStrList[i].url === '/bill/sale_back' ? btnStrList[i].btnStr : this.quickBtn.saleBack
          }
        }
      }
    },
    handleSearchSupplier(value) {
      let that = this
      if (this.setTimeFlag != null) {
        clearTimeout(this.setTimeFlag)
      }
      this.setTimeFlag = setTimeout(() => {
        findBySelectSup({ key: value, limit: 1 }).then((res) => {
          if (res) {
            that.supList = res
          }
        })
      }, 500)
    },
    handleSearchCustomer(value) {
      let that = this
      if (this.setTimeFlag != null) {
        clearTimeout(this.setTimeFlag)
      }
      this.setTimeFlag = setTimeout(() => {
        findBySelectCus({ key: value, limit: 1 }).then((res) => {
          if (res) {
            that.cusList = res
          }
        })
      }, 500)
    },
    handleSearchRetail(value) {
      let that = this
      if (this.setTimeFlag != null) {
        clearTimeout(this.setTimeFlag)
      }
      this.setTimeFlag = setTimeout(() => {
        findBySelectRetail({ key: value, limit: 1 }).then((res) => {
          if (res) {
            that.retailList = res
          }
        })
      }, 500)
    },
    getDepotByCurrentUser() {
      getAction('/depot/findDepotByCurrentUser').then((res) => {
        if (res.code === 200) {
          if (res.data.length === 1) {
            this.defaultDepotId = res.data[0].id + ''
          } else {
            for (let i = 0; i < res.data.length; i++) {
              if (res.data[i].isDefault) {
                this.defaultDepotId = res.data[i].id + ''
              }
            }
          }
        }
      })
    },
    // Passer à la page du document suivant
    transferBill(type, quickBtnStr) {
      if (this.selectedRowKeys.length <= 0) {
        this.$message.warning('Veuillez sélectionner un enregistrement !')
      } else if (this.selectedRowKeys.length > 1) {
        this.$message.warning('Un seul enregistrement peut être sélectionné !')
      } else {
        let info = this.selectionRows[0]
        if (info.status === '1' || info.status === '3') {
          let linkType = 'basic'
          if (type === '转采购订单-以销定购') {
            linkType = 'purchase'
          } else {
            linkType = 'basic'
          }
          let param = {
            headerId: info.id,
            mpList: '',
            linkType: linkType,
          }
          getAction('/depotItem/getDetailList', param).then((res) => {
            if (res.code === 200) {
              let deposit = info.changeAmount - info.finishDeposit
              let transferParam = {
                list: res.data.rows,
                number: info.number,
                organId: info.organId,
                discountMoney: info.discountMoney,
                deposit: deposit,
                remark: info.remark,
                accountId: info.accountId,
                salesMan: info.salesMan,
              }
              if (type === '转采购订单-以销定购') {
                this.$refs.transferPurchaseModalForm.action = 'add'
                this.$refs.transferPurchaseModalForm.transferParam = transferParam
                this.$refs.transferPurchaseModalForm.defaultDepotId = this.defaultDepotId
                this.$refs.transferPurchaseModalForm.add()
                this.$refs.transferPurchaseModalForm.title = type
                if (quickBtnStr.indexOf(2) === -1) {
                  this.$refs.transferPurchaseModalForm.isCanCheck = false
                }
              } else {
                this.$refs.transferModalForm.action = 'add'
                this.$refs.transferModalForm.transferParam = transferParam
                this.$refs.transferModalForm.defaultDepotId = this.defaultDepotId
                this.$refs.transferModalForm.add()
                this.$refs.transferModalForm.title = type
                if (quickBtnStr.indexOf(2) === -1) {
                  this.$refs.transferModalForm.isCanCheck = false
                }
              }
            }
          })
        } else {
          this.$message.warning('Cet état ne peut pas être ' + type + ' !')
        }
      }
    },
    // Événement de modification des paramètres de colonnes
    onColChange(checkedValues) {
      this.columns = this.defColumns.filter((item) => {
        return checkedValues.includes(item.dataIndex)
      })
      let columnsStr = checkedValues.join()
      Vue.ls.set(this.prefixNo, columnsStr)
    },
    // Restaurer les valeurs par défaut
    handleRestDefault() {
      Vue.ls.remove(this.prefixNo)
      this.initColumnsSetting()
    },
    // Exporter le document
    handleExport() {
      let search = this.getQueryParams().search
      this.$refs.billExcelIframe.show(this.model, this.billExcelUrl + '?search=' + search + '&type=1', 150)
      this.$refs.billExcelIframe.title = "Confirmer l'export"
    },
    // Développer/Replier les lignes
    onExpand(expanded, record) {
      if (expanded) {
        this.expandedRowKeys = [...new Set([...this.expandedRowKeys, record.id])]
        let showType = 'basic'
        if (
          record.subType === '采购' ||
          record.subType === '采购退货' ||
          record.subType === '销售' ||
          record.subType === '销售退货'
        ) {
          if (record.status === '3') {
            showType = 'other'
          }
        } else {
          if (record.status === '3') {
            showType = 'basic'
          } else if (record.purchaseStatus === '3') {
            showType = 'purchase'
          }
        }
        let params = {
          headerId: record.id,
          mpList: getMpListShort(Vue.ls.get('materialPropertyList')), // Attributs étendus
          linkType: showType,
          isReadOnly: '0',
        }
        let url = '/depotItem/getDetailList'
        this.requestSubTableData(record, url, params)
      } else {
        this.expandedRowKeys = this.expandedRowKeys.filter((key) => key !== record.id)
      }
    },
    requestSubTableData(record, url, params, success) {
      record.loading = true
      getAction(url, params)
        .then((res) => {
          if (res && res.code === 200) {
            record.childrens = res.data.rows
            this.initSetting(record, record.childrens)
            record.loading = false
            typeof success === 'function' ? success(res) : ''
          }
        })
        .finally(() => {
          record.loading = false
        })
    },
    initSetting(record, ds) {
      if (this.prefixNo === 'LSCK') {
        this.defDetailColumns = this.retailOutColumns
      } else if (this.prefixNo === 'LSTH') {
        this.defDetailColumns = this.retailBackColumns
      } else if (this.prefixNo === 'QGD') {
        this.defDetailColumns = this.purchaseApplyColumns
      } else if (this.prefixNo === 'CGDD') {
        this.defDetailColumns = this.purchaseOrderColumns
      } else if (this.prefixNo === 'CGRK') {
        this.defDetailColumns = this.purchaseInColumns
      } else if (this.prefixNo === 'CGTH') {
        this.defDetailColumns = this.purchaseBackColumns
      } else if (this.prefixNo === 'XSDD') {
        this.defDetailColumns = this.saleOrderColumns
      } else if (this.prefixNo === 'XSCK') {
        this.defDetailColumns = this.saleOutColumns
      } else if (this.prefixNo === 'XSTH') {
        this.defDetailColumns = this.saleBackColumns
      } else if (this.prefixNo === 'QTRK') {
        this.defDetailColumns = this.otherInColumns
      } else if (this.prefixNo === 'QTCK') {
        this.defDetailColumns = this.otherOutColumns
      } else if (this.prefixNo === 'DBCK') {
        this.defDetailColumns = this.allocationOutColumns
      } else if (this.prefixNo === 'ZZD') {
        this.defDetailColumns = this.assembleColumns
      } else if (this.prefixNo === 'CXD') {
        this.defDetailColumns = this.disassembleColumns
      } else if (this.prefixNo === 'PDFP') {
        this.defDetailColumns = this.stockCheckReplayColumns
      }
      // Remplacer dynamiquement les champs étendus
      this.handleChangeOtherField()
      // Vérifier si les numéros de série, numéros de lot, dates d'expiration, multi-attributs, poids, emplacements/étagères, extensions, remarques, etc. ont des valeurs
      let needAddkeywords = []
      for (let i = 0; i < ds.length; i++) {
        if (ds[i].snList) {
          needAddkeywords.push('snList')
        }
        if (ds[i].batchNumber) {
          needAddkeywords.push('batchNumber')
        }
        if (ds[i].expirationDate) {
          needAddkeywords.push('expirationDate')
        }
        if (ds[i].sku) {
          needAddkeywords.push('sku')
        }
        if (ds[i].weight) {
          needAddkeywords.push('weight')
        }
        if (ds[i].position) {
          needAddkeywords.push('position')
        }
        if (ds[i].brand) {
          needAddkeywords.push('brand')
        }
        if (ds[i].mfrs) {
          needAddkeywords.push('mfrs')
        }
        if (ds[i].otherField1) {
          needAddkeywords.push('otherField1')
        }
        if (ds[i].otherField2) {
          needAddkeywords.push('otherField2')
        }
        if (ds[i].otherField3) {
          needAddkeywords.push('otherField3')
        }
        if (ds[i].taxRate) {
          needAddkeywords.push('taxRate')
        }
        if (ds[i].remark) {
          needAddkeywords.push('remark')
        }
      }
      let currentCol = []
      if (record.status === '3') {
        // Afficher toutes les colonnes lors d'achat partiel | vente partielle
        for (let i = 0; i < this.defDetailColumns.length; i++) {
          currentCol.push(this.defDetailColumns[i])
        }
        this.detailColumns = currentCol
      } else if (record.purchaseStatus === '3') {
        // Convertir le titre "Déjà sorti" en "Déjà acheté", pour le scénario de conversion de commande de vente en commande d'achat
        for (let i = 0; i < this.defDetailColumns.length; i++) {
          let info = {}
          info.title = this.defDetailColumns[i].title
          info.dataIndex = this.defDetailColumns[i].dataIndex
          if (this.defDetailColumns[i].width) {
            info.width = this.defDetailColumns[i].width
          }
          if (this.defDetailColumns[i].dataIndex === 'finishNumber') {
            info.title = 'Déjà acheté'
          }
          if (this.defDetailColumns[i].dataIndex === 'barCode') {
            info.scopedSlots = { customRender: 'customBarCode' }
          }
          currentCol.push(info)
        }
        this.detailColumns = currentCol
      } else {
        for (let i = 0; i < this.defDetailColumns.length; i++) {
          // Supprimer la colonne
          let needRemoveKeywords = [
            'finishNumber',
            'snList',
            'batchNumber',
            'expirationDate',
            'sku',
            'weight',
            'position',
            'brand',
            'mfrs',
            'otherField1',
            'otherField2',
            'otherField3',
            'taxRate',
            'remark',
          ]
          if (needRemoveKeywords.indexOf(this.defDetailColumns[i].dataIndex) === -1) {
            let info = {}
            info.title = this.defDetailColumns[i].title
            info.dataIndex = this.defDetailColumns[i].dataIndex
            if (this.defDetailColumns[i].width) {
              info.width = this.defDetailColumns[i].width
            }
            if (this.defDetailColumns[i].dataIndex === 'barCode') {
              info.scopedSlots = { customRender: 'customBarCode' }
            }
            currentCol.push(info)
          }
          // Ajouter les colonnes avec des données
          if (needAddkeywords.indexOf(this.defDetailColumns[i].dataIndex) > -1) {
            let info = {}
            info.title = this.defDetailColumns[i].title
            info.dataIndex = this.defDetailColumns[i].dataIndex
            if (this.defDetailColumns[i].width) {
              info.width = this.defDetailColumns[i].width
            }
            currentCol.push(info)
          }
        }
        this.detailColumns = currentCol
      }
    },
    // Remplacer dynamiquement les champs étendus
    handleChangeOtherField() {
      let mpStr = getMpListShort(Vue.ls.get('materialPropertyList'))
      if (mpStr) {
        let mpArr = mpStr.split(',')
        if (mpArr.length === 3) {
          for (let i = 0; i < this.defDetailColumns.length; i++) {
            if (this.defDetailColumns[i].dataIndex === 'otherField1') {
              this.defDetailColumns[i].title = mpArr[0]
            }
            if (this.defDetailColumns[i].dataIndex === 'otherField2') {
              this.defDetailColumns[i].title = mpArr[1]
            }
            if (this.defDetailColumns[i].dataIndex === 'otherField3') {
              this.defDetailColumns[i].title = mpArr[2]
            }
          }
        }
      }
    },
  },
}
