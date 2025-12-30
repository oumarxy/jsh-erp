import { FormTypes, getListData } from '@/utils/JEditableTableUtil'
import {
  findBySelectCus,
  findBySelectRetail,
  findBySelectSup,
  findStockByDepotAndBarCode,
  getAccount,
  getBatchNumberList,
  getCurrentSystemConfig,
  getMaterialByBarCode,
  getPersonByNumType,
  getPlatformConfigByKey,
} from '@/api/api'
import { getAction } from '@/api/manage'
import { getCheckFlag, getMpListShort, getNowFormatDateTime } from '@/utils/util'
import { USER_INFO } from '@/store/mutation-types'
import Vue from 'vue'

export const BillModalMixin = {
  data() {
    return {
      action: '',
      manyAccountBtnStatus: false,
      supList: [],
      cusList: [],
      retailList: [],
      personList: {
        options: [],
        value: '',
      },
      currentSelectDepotId: '',
      transferParam: {},
      defaultDepotId: '',
      depotList: [],
      accountList: [],
      accountIdList: [],
      accountMoneyList: [],
      billUnitPirce: '',
      scanBarCode: '',
      scanStatus: true,
      billStatus: '0',
      minWidth: 1100,
      isCanCheck: true,
      quickBtn: {
        vendor: false,
        customer: false,
        member: false,
        account: false,
        depot: false,
      },
      billPrintFlag: false,
      /* Afficher ou non le bouton d'impression */
      isShowPrintBtn: true,
      /* Vérifier si l'audit original est activé */
      checkFlag: true,
      // Interrupteur de scénario de paiement/reçu zéro
      zeroChangeAmountFlag: false,
      setTimeFlag: null,
      validatorRules: {
        price: {
          rules: [
            {
              pattern: /^(([0-9][0-9]*)|([0]\.\d{0,4}|[0-9][0-9]*\.\d{0,4}))$/,
              message: 'Format du montant incorrect !',
            },
          ],
        },
      },
      spans: {
        labelCol1: { span: 2 },
        wrapperCol1: { span: 22 },
        //1_5: Divisé en 1.5 colonnes (équivaut à 2/3)
        labelCol1_5: { span: 3 },
        wrapperCol1_5: { span: 21 },
        labelCol2: { span: 4 },
        wrapperCol2: { span: 20 },
        labelCol3: { span: 6 },
        wrapperCol3: { span: 18 },
        labelCol6: { span: 12 },
        wrapperCol6: { span: 12 },
      },
    }
  },
  created() {
    let realScreenWidth = window.screen.width
    this.width = realScreenWidth < 1500 ? '1200px' : '1550px'
    this.minWidth = realScreenWidth < 1500 ? 1150 : 1500
  },
  mounted() {
    document.getElementById(this.prefixNo).addEventListener('keydown', this.handleOkKey)
  },
  beforeDestroy() {
    document.getElementById(this.prefixNo).removeEventListener('keydown', this.handleOkKey)
  },
  computed: {
    readOnly: function () {
      return this.action !== 'add' && this.action !== 'edit'
    },
  },
  methods: {
    // Raccourci clavier
    handleOkKey(e) {
      const key = window.event.keyCode ? window.event.keyCode : window.event.which
      if (key === 83 && e.ctrlKey) {
        // Enregistrer CTRL+S
        this.handleOk()
        e.preventDefault()
      }
    },
    addInit(amountNum) {
      getAction('/sequence/buildNumber').then((res) => {
        if (res && res.code === 200) {
          this.model.defaultNumber = amountNum + res.data.defaultNumber
          this.form.setFieldsValue({ number: amountNum + res.data.defaultNumber })
        }
      })
      this.$nextTick(() => {
        this.form.setFieldsValue({
          operTime: getNowFormatDateTime(),
          discount: 0,
          discountMoney: 0,
          discountLastMoney: 0,
          otherMoney: 0,
          changeAmount: 0,
          debt: 0,
        })
      })
      this.$nextTick(() => {
        getAccount({}).then((res) => {
          if (res && res.code === 200) {
            for (const item of res.data.accountList) {
              if (item.isDefault) {
                this.form.setFieldsValue({ accountId: item.id })
              }
            }
            // Données transmises depuis la page précédente
            if (this.transferParam && this.transferParam.accountId) {
              this.form.setFieldsValue({ accountId: this.transferParam.accountId })
            }
          }
        })
      })
      this.accountIdList = []
      this.accountMoneyList = []
      this.manyAccountBtnStatus = false
    },
    copyAddInit(amountNum) {
      getAction('/sequence/buildNumber').then((res) => {
        if (res && res.code === 200) {
          this.form.setFieldsValue({ number: amountNum + res.data.defaultNumber })
        }
      })
      this.$nextTick(() => {
        this.form.setFieldsValue({ operTime: getNowFormatDateTime() })
      })
    },
    /** Interroger les données d'un onglet */
    requestSubTableData(url, params, tab, success) {
      tab.loading = true
      getAction(url, params)
        .then((res) => {
          if (res && res.code === 200) {
            tab.dataSource = res.data.rows
            for (let i = 0; i < tab.dataSource.length; i++) {
              let info = tab.dataSource[i]
              info.isEdit = this.model.id ? 1 : 0
              this.changeColumnShow(info)
            }
            typeof success === 'function' ? success(res) : ''
          }
        })
        .finally(() => {
          tab.loading = false
        })
    },
    // Modifier l'état du champ, 1- afficher 0- masquer
    changeFormTypes(columns, key, type) {
      for (let i = 0; i < columns.length; i++) {
        if (columns[i].key === key) {
          if (type) {
            if (key === 'snList' || key === 'batchNumber') {
              if (
                this.prefixNo === 'LSCK' ||
                this.prefixNo === 'CGTH' ||
                this.prefixNo === 'XSCK' ||
                this.prefixNo === 'QTCK' ||
                this.prefixNo === 'DBCK'
              ) {
                columns[i].type = FormTypes.popupJsh // Afficher
              } else {
                if (key === 'snList') {
                  columns[i].type = FormTypes.popupJsh // Afficher
                } else {
                  columns[i].type = FormTypes.input // Afficher
                }
              }
            } else if (key === 'expirationDate') {
              if (
                this.prefixNo === 'LSTH' ||
                this.prefixNo === 'CGRK' ||
                this.prefixNo === 'XSTH' ||
                this.prefixNo === 'QTRK'
              ) {
                columns[i].type = FormTypes.date // Afficher
              } else {
                columns[i].type = FormTypes.input // Afficher
              }
            } else {
              columns[i].type = FormTypes.normal // Afficher
            }
          } else {
            columns[i].type = FormTypes.hidden // Masquer
          }
        }
      }
    },
    initSystemConfig() {
      getCurrentSystemConfig().then((res) => {
        if (res.code === 200 && res.data) {
          let multiBillType = res.data.multiBillType
          let multiLevelApprovalFlag = res.data.multiLevelApprovalFlag
          this.checkFlag = getCheckFlag(multiBillType, multiLevelApprovalFlag, this.prefixNo)
          this.purchaseBySaleFlag = res.data.purchaseBySaleFlag === '1' ? true : false
          this.inOutManageFlag = res.data.inOutManageFlag === '1' ? true : false
          this.zeroChangeAmountFlag = res.data.zeroChangeAmountFlag === '1' ? true : false
          if (res.data.auditPrintFlag === '1') {
            if (this.model.status === '0' || this.model.status === '9') {
              this.isShowPrintBtn = false
            } else {
              this.isShowPrintBtn = true
            }
          } else {
            this.isShowPrintBtn = true
          }
        }
      })
    },
    initSupplier(isChecked) {
      let that = this
      findBySelectSup({ organId: this.model.organId, limit: 1 }).then((res) => {
        if (res) {
          that.supList = res
          if (isChecked && res.length > 0) {
            that.form.setFieldsValue({ organId: res[0].id })
          }
        }
      })
    },
    initCustomer(isChecked) {
      let that = this
      findBySelectCus({ organId: this.model.organId, limit: 1 }).then((res) => {
        if (res) {
          that.cusList = res
          if (isChecked && res.length > 0) {
            that.form.setFieldsValue({ organId: res[0].id })
          }
        }
      })
    },
    initRetail(isChecked) {
      let that = this
      findBySelectRetail({ organId: this.model.organId, limit: 1 }).then((res) => {
        if (res) {
          that.retailList = res
          if (isChecked && res.length > 0) {
            that.form.setFieldsValue({ organId: res[0].id })
          }
        }
      })
    },
    initSalesman() {
      let that = this
      getPersonByNumType({ type: 1 }).then((res) => {
        if (res) {
          that.personList.options = res
        }
      })
    },
    initDepot() {
      let that = this
      getAction('/depot/findDepotByCurrentUser').then((res) => {
        if (res.code === 200) {
          let arr = res.data
          for (let item of that.materialTable.columns) {
            if (item.key == 'depotId' || item.key == 'anotherDepotId') {
              item.options = []
              for (let i = 0; i < arr.length; i++) {
                let depotInfo = {}
                depotInfo.value = arr[i].id + '' // Note - la valeur doit être au format chaîne ici
                depotInfo.text = arr[i].depotName
                depotInfo.title = arr[i].depotName
                item.options.push(depotInfo)
              }
            }
          }
        }
      })
    },
    initAccount(isChecked) {
      let that = this
      getAccount({}).then((res) => {
        if (res && res.code === 200) {
          let list = res.data.accountList
          let lastId = list.length > 0 ? list[0].id : ''
          getCurrentSystemConfig().then((res) => {
            if (res.code === 200 && res.data) {
              let multiAccountFlag = res.data.multiAccountFlag
              if (multiAccountFlag === '1') {
                list.splice(0, 0, { id: 0, name: 'Multi-comptes' })
              }
            }
            that.accountList = list
            if (isChecked) {
              that.form.setFieldsValue({ accountId: lastId })
            }
          })
        }
      })
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
    handleManyAccount() {
      this.selectAccount(0)
    },
    selectAccount(value) {
      if (value === 0) {
        // Multi-comptes
        this.$refs.manyAccountModalForm.edit(this.accountIdList, this.accountMoneyList)
        this.$refs.manyAccountModalForm.title = 'Règlement multi-comptes'
        this.manyAccountBtnStatus = true
      } else {
        this.accountIdList = []
        this.accountMoneyList = []
        this.manyAccountBtnStatus = false
      }
    },
    manyAccountModalFormOk(idList, moneyList, allPrice) {
      this.accountIdList = idList
      this.accountMoneyList = moneyList
      let discountLastMoney = this.form.getFieldValue('discountLastMoney') - 0
      let otherMoney = this.form.getFieldValue('otherMoney') ? this.form.getFieldValue('otherMoney') - 0 : 0
      let debt = (discountLastMoney + otherMoney - allPrice).toFixed(2)
      this.$nextTick(() => {
        this.form.setFieldsValue({ changeAmount: allPrice, debt: debt })
      })
    },
    addSupplier() {
      this.$refs.vendorModalForm.add()
      this.$refs.vendorModalForm.title = 'Ajouter un fournisseur'
      this.$refs.vendorModalForm.disableSubmit = false
    },
    addCustomer() {
      this.$refs.customerModalForm.add()
      this.$refs.customerModalForm.title =
        'Ajouter un client (Rappel : si vous ne trouvez pas le client nouvellement ajouté, allez dans la gestion des utilisateurs pour vérifier si les permissions de ce client ont été attribuées)'
      this.$refs.customerModalForm.disableSubmit = false
    },
    addMember() {
      this.$refs.memberModalForm.add()
      this.$refs.memberModalForm.title = 'Ajouter un membre'
      this.$refs.memberModalForm.disableSubmit = false
    },
    handleBatchSetDepot() {
      this.$refs.batchSetDepotModalForm.add()
      this.$refs.batchSetDepotModalForm.title = "Changer d'entrepôt en lot"
      this.$refs.batchSetDepotModalForm.disableSubmit = false
    },
    addDepot() {
      this.$refs.depotModalForm.add()
      this.$refs.depotModalForm.title = 'Ajouter un entrepôt'
      this.$refs.depotModalForm.disableSubmit = false
    },
    addAccount() {
      this.$refs.accountModalForm.add()
      this.$refs.accountModalForm.title = 'Ajouter un compte de règlement'
      this.$refs.accountModalForm.disableSubmit = false
    },
    vendorModalFormOk() {
      this.initSupplier(1)
    },
    customerModalFormOk() {
      this.initCustomer(1)
    },
    memberModalFormOk() {
      this.initRetail(1)
    },
    batchSetDepotModalFormOk(depotId) {
      this.getAllTable()
        .then((tables) => {
          return getListData(this.form, tables)
        })
        .then((allValues) => {
          // Obtenir les informations de la liste des détails du document
          let detailArr = allValues.tablesValue[0].values
          let barCodes = ''
          for (let detail of detailArr) {
            barCodes += detail.barCode + ','
          }
          if (barCodes) {
            barCodes = barCodes.substring(0, barCodes.length - 1)
          }
          let param = {
            barCode: barCodes,
            organId: this.form.getFieldValue('organId'),
            depotId: depotId,
            mpList: getMpListShort(Vue.ls.get('materialPropertyList')), // Attributs étendus
            prefixNo: this.prefixNo,
          }
          getMaterialByBarCode(param).then((res) => {
            if (res && res.code === 200) {
              let mList = res.data
              // Construire un nouveau tableau de liste pour stocker les informations de détail du document
              let newDetailArr = []
              if (mList && mList.length) {
                for (let i = 0; i < detailArr.length; i++) {
                  let item = detailArr[i]
                  item.depotId = depotId
                  for (let j = 0; j < mList.length; j++) {
                    if (mList[j].mBarCode === item.barCode) {
                      item.stock = mList[j].stock
                    }
                  }
                  newDetailArr.push(item)
                }
              } else {
                for (let i = 0; i < detailArr.length; i++) {
                  let item = detailArr[i]
                  item.depotId = depotId
                  newDetailArr.push(item)
                }
              }
              this.materialTable.dataSource = newDetailArr
            }
          })
        })
    },
    depotModalFormOk() {
      this.initDepot()
    },
    accountModalFormOk() {
      this.initAccount(1)
    },
    workflowModalFormOk() {
      this.close()
    },
    onAdded(event) {
      let that = this
      const { row, target } = event
      target.setValues([{ rowKey: row.id, values: { operNumber: 0 } }])
      // Défiler automatiquement jusqu'à la dernière ligne
      setTimeout(function () {
        that.$refs.materialDataTable.resetScrollTop((target.rows.length + 1) * that.$refs.materialDataTable.rowHeight)
      }, 1000)
      if (this.currentSelectDepotId) {
        // Si un entrepôt a été sélectionné dans le document, charger directement depuis l'entrepôt sélectionné
        target.setValues([{ rowKey: row.id, values: { depotId: this.currentSelectDepotId } }])
      } else {
        getAction('/depot/findDepotByCurrentUser').then((res) => {
          if (res.code === 200) {
            let arr = res.data
            if (arr.length === 1) {
              target.setValues([{ rowKey: row.id, values: { depotId: arr[0].id + '' } }])
            } else {
              for (let i = 0; i < arr.length; i++) {
                if (arr[i].isDefault) {
                  target.setValues([{ rowKey: row.id, values: { depotId: arr[i].id + '' } }])
                }
              }
            }
          }
        })
      }
    },
    // Déclenché une fois par changement d'un caractère dans la valeur de la cellule
    onValueChange(event) {
      let that = this
      const { type, row, column, value, target } = event
      let param, snList, batchNumber, operNumber, unitPrice, allPrice, taxRate, taxMoney, taxLastMoney
      switch (column.key) {
        case 'depotId':
          that.currentSelectDepotId = row.depotId
          if (row.barCode) {
            that.getStockByDepotBarCode(row, target)
          }
          break
        case 'barCode':
          param = {
            barCode: value,
            organId: this.form.getFieldValue('organId'),
            mpList: getMpListShort(Vue.ls.get('materialPropertyList')), // Attributs étendus
            prefixNo: this.prefixNo,
          }
          getMaterialByBarCode(param).then((res) => {
            if (res && res.code === 200) {
              let mList = res.data
              if (value.indexOf(',') > -1) {
                // Plusieurs codes-barres
                this.$refs.materialDataTable.getValues((error, values) => {
                  values.pop() // Supprimer la dernière ligne de données
                  let mArr = values
                  for (let i = 0; i < mList.length; i++) {
                    let mInfo = mList[i]
                    this.changeColumnShow(mInfo)
                    let mObj = this.parseInfoToObj(mInfo)
                    mObj.depotId = mInfo.depotId
                    mObj.stock = mInfo.stock
                    mObj.snList = ''
                    mObj.batchNumber = ''
                    mObj.expirationDate = ''
                    mArr.push(mObj)
                  }
                  let allPriceTotal = 0
                  let taxLastMoneyTotal = 0
                  for (let j = 0; j < mArr.length; j++) {
                    allPriceTotal += mArr[j].allPrice - 0
                    taxLastMoneyTotal += mArr[j].taxLastMoney - 0
                    // Réaffecter le type de produit pour les documents d'assemblage et de démontage
                    if (j === 0) {
                      mArr[0].mType = 'Composant combiné'
                    } else {
                      mArr[j].mType = 'Composant standard'
                    }
                  }
                  this.materialTable.dataSource = mArr
                  if (this.prefixNo === 'LSCK' || this.prefixNo === 'LSTH') {
                    target.statisticsColumns.allPrice = allPriceTotal
                  } else {
                    target.statisticsColumns.taxLastMoney = taxLastMoneyTotal
                  }
                  that.autoChangePrice(target)
                  // Forcer le rendu
                  target.$forceUpdate()
                })
              } else {
                // Code-barres unique
                let depotIdSelected = this.prefixNo !== 'CGDD' && this.prefixNo !== 'XSDD' ? row.depotId : ''
                findStockByDepotAndBarCode({ depotId: depotIdSelected, barCode: row.barCode }).then((res) => {
                  if (res && res.code === 200) {
                    let mArr = []
                    let mInfo = mList[0]
                    this.changeColumnShow(mInfo)
                    let mInfoEx = this.parseInfoToObj(mInfo)
                    mInfoEx.stock = res.data.stock
                    mInfoEx.snList = ''
                    mInfoEx.batchNumber = ''
                    mInfoEx.expirationDate = ''
                    let mObj = {
                      rowKey: row.id,
                      values: mInfoEx,
                    }
                    mArr.push(mObj)
                    target.setValues(mArr)
                    target.recalcAllStatisticsColumns()
                    that.autoChangePrice(target)
                    target.autoSelectBySpecialKey('operNumber', row.orderNum)
                    // Forcer le rendu
                    target.$forceUpdate()
                  }
                })
              }
            }
          })
          break
        case 'snList':
          snList = value
          if (snList) {
            snList = snList.replaceAll('，', ',')
            let snArr = snList.split(',')
            operNumber = snArr.length
            taxRate = row.taxRate - 0 // Taux de taxe
            unitPrice = row.unitPrice - 0 // Prix unitaire
            allPrice = (unitPrice * operNumber).toFixed(2) - 0
            taxMoney = (taxRate * 0.01 * allPrice).toFixed(2) - 0
            taxLastMoney = (allPrice + taxMoney).toFixed(2) - 0
            target.setValues([
              {
                rowKey: row.id,
                values: { operNumber: operNumber, allPrice: allPrice, taxMoney: taxMoney, taxLastMoney: taxLastMoney },
              },
            ])
            target.recalcAllStatisticsColumns()
            that.autoChangePrice(target)
          }
          break
        case 'batchNumber':
          // Uniquement pour les sorties de vente au détail, sorties de vente, retours d'achat, autres sorties
          if (
            this.prefixNo === 'LSCK' ||
            this.prefixNo === 'XSCK' ||
            this.prefixNo === 'CGTH' ||
            this.prefixNo === 'QTCK'
          ) {
            batchNumber = value
            let depotItemId = ''
            if (this.model.id) {
              // Obtenir l'ID du détail uniquement dans la page d'édition après l'enregistrement
              let rowId = row.id
              if (rowId.length <= 19) {
                depotItemId = rowId - 0
              }
            }
            getBatchNumberList({
              name: '',
              depotItemId: depotItemId,
              depotId: row.depotId,
              barCode: row.barCode,
              batchNumber: batchNumber,
            }).then((res) => {
              if (res && res.code === 200) {
                if (res.data && res.data.rows) {
                  let info = res.data.rows[0]
                  let preNumber = row.preNumber - 0 // Quantité d'origine
                  let finishNumber = row.finishNumber - 0 // Sorti du stock
                  let totalNum = info.totalNum - 0 // Quantité du lot
                  if (preNumber > 0) {
                    if (totalNum > preNumber - finishNumber) {
                      operNumber = preNumber - finishNumber
                    } else {
                      operNumber = totalNum
                    }
                  } else {
                    operNumber = totalNum
                  }
                  taxRate = row.taxRate - 0 // Taux de taxe
                  unitPrice = row.unitPrice - 0 // Prix unitaire
                  allPrice = (unitPrice * operNumber).toFixed(2) - 0
                  taxMoney = (taxRate * 0.01 * allPrice).toFixed(2) - 0
                  taxLastMoney = (allPrice + taxMoney).toFixed(2) - 0
                  target.setValues([
                    {
                      rowKey: row.id,
                      values: {
                        expirationDate: info.expirationDateStr,
                        operNumber: operNumber,
                        allPrice: allPrice,
                        taxMoney: taxMoney,
                        taxLastMoney: taxLastMoney,
                      },
                    },
                  ])
                  target.recalcAllStatisticsColumns()
                  that.autoChangePrice(target)
                }
              }
            })
          }
          break
        case 'operNumber':
          operNumber = value - 0
          taxRate = row.taxRate - 0 // Taux de taxe
          unitPrice = row.unitPrice - 0 // Prix unitaire
          allPrice = (unitPrice * operNumber).toFixed(2) - 0
          taxMoney = (taxRate * 0.01 * allPrice).toFixed(2) - 0
          taxLastMoney = (allPrice + taxMoney).toFixed(2) - 0
          target.setValues([
            { rowKey: row.id, values: { allPrice: allPrice, taxMoney: taxMoney, taxLastMoney: taxLastMoney } },
          ])
          target.recalcAllStatisticsColumns()
          that.autoChangePrice(target)
          break
        case 'unitPrice':
          operNumber = row.operNumber - 0 // Quantité
          unitPrice = value - 0 // Prix unitaire
          taxRate = row.taxRate - 0 // Taux de taxe
          allPrice = (unitPrice * operNumber).toFixed(2) - 0
          taxMoney = (taxRate * 0.01 * allPrice).toFixed(2) - 0
          taxLastMoney = (allPrice + taxMoney).toFixed(2) - 0
          target.setValues([
            { rowKey: row.id, values: { allPrice: allPrice, taxMoney: taxMoney, taxLastMoney: taxLastMoney } },
          ])
          target.recalcAllStatisticsColumns()
          that.autoChangePrice(target)
          break
        case 'allPrice':
          operNumber = row.operNumber - 0 // Quantité
          taxRate = row.taxRate - 0 // Taux de taxe
          allPrice = value - 0
          unitPrice = (allPrice / operNumber).toFixed(4) - 0 // Prix unitaire
          taxMoney = (taxRate * 0.01 * allPrice).toFixed(2) - 0
          taxLastMoney = (allPrice + taxMoney).toFixed(2) - 0
          target.setValues([
            { rowKey: row.id, values: { unitPrice: unitPrice, taxMoney: taxMoney, taxLastMoney: taxLastMoney } },
          ])
          target.recalcAllStatisticsColumns()
          that.autoChangePrice(target)
          break
        case 'taxRate':
          operNumber = row.operNumber - 0 // Quantité
          allPrice = row.allPrice - 0
          unitPrice = row.unitPrice - 0
          taxRate = value - 0 // Taux de taxe
          taxMoney = (taxRate * 0.01 * allPrice).toFixed(2) - 0
          taxLastMoney = (allPrice + taxMoney).toFixed(2) - 0
          target.setValues([{ rowKey: row.id, values: { taxMoney: taxMoney, taxLastMoney: taxLastMoney } }])
          target.recalcAllStatisticsColumns()
          that.autoChangePrice(target)
          break
        case 'taxLastMoney':
          operNumber = row.operNumber - 0 // Quantité
          taxLastMoney = value - 0
          taxRate = row.taxRate - 0 // Taux de taxe
          if (taxRate) {
            unitPrice = (taxLastMoney / operNumber / (1 + taxRate * 0.01)).toFixed(4) - 0
            allPrice = (unitPrice * operNumber).toFixed(2) - 0
            taxMoney = (taxLastMoney - allPrice).toFixed(2) - 0
          } else {
            // Cas où le taux de taxe est 0, traitement spécial
            allPrice = taxLastMoney
            unitPrice = (allPrice / operNumber).toFixed(4) - 0 // Prix unitaire
            taxMoney = 0
          }
          target.setValues([
            { rowKey: row.id, values: { unitPrice: unitPrice, allPrice: allPrice, taxMoney: taxMoney } },
          ])
          target.recalcAllStatisticsColumns()
          that.autoChangePrice(target)
          break
      }
    },
    // Convertir en objet produit
    parseInfoToObj(mInfo) {
      return {
        barCode: mInfo.mBarCode,
        name: mInfo.name,
        standard: mInfo.standard,
        model: mInfo.model,
        color: mInfo.color,
        brand: mInfo.brand,
        mfrs: mInfo.mfrs,
        otherField1: mInfo.otherField1,
        otherField2: mInfo.otherField2,
        otherField3: mInfo.otherField3,
        unit: mInfo.commodityUnit,
        sku: mInfo.sku,
        operNumber: 1,
        unitPrice: mInfo.billPrice,
        allPrice: mInfo.billPrice,
        taxRate: 0,
        taxMoney: 0,
        taxLastMoney: mInfo.billPrice,
      }
    },
    // Masquer le modèle, la couleur, les informations étendues, sku, etc.
    changeColumnHide() {
      this.changeFormTypes(this.materialTable.columns, 'model', 0)
      this.changeFormTypes(this.materialTable.columns, 'color', 0)
      this.changeFormTypes(this.materialTable.columns, 'brand', 0)
      this.changeFormTypes(this.materialTable.columns, 'mfrs', 0)
      this.changeFormTypes(this.materialTable.columns, 'otherField1', 0)
      this.changeFormTypes(this.materialTable.columns, 'otherField2', 0)
      this.changeFormTypes(this.materialTable.columns, 'otherField3', 0)
      this.changeFormTypes(this.materialTable.columns, 'sku', 0)
    },
    // Afficher sku, numéro de série, numéro de lot, date d'expiration, etc.
    changeColumnShow(info) {
      if (info.model) {
        this.changeFormTypes(this.materialTable.columns, 'model', 1)
      }
      if (info.color) {
        this.changeFormTypes(this.materialTable.columns, 'color', 1)
      }
      if (info.brand) {
        this.changeFormTypes(this.materialTable.columns, 'brand', 1)
      }
      if (info.mfrs) {
        this.changeFormTypes(this.materialTable.columns, 'mfrs', 1)
      }
      if (info.otherField1) {
        this.changeFormTypes(this.materialTable.columns, 'otherField1', 1)
      }
      if (info.otherField2) {
        this.changeFormTypes(this.materialTable.columns, 'otherField2', 1)
      }
      if (info.otherField3) {
        this.changeFormTypes(this.materialTable.columns, 'otherField3', 1)
      }
      if (info.sku) {
        this.changeFormTypes(this.materialTable.columns, 'sku', 1)
      }
      if (info.enableSerialNumber === '1') {
        // Si la gestion des entrées/sorties est activée et que le type est achat, retour d'achat, vente, retour de vente, alors ignorer
        if (
          this.inOutManageFlag &&
          (this.prefixNo === 'CGRK' || this.prefixNo === 'CGTH' || this.prefixNo === 'XSCK' || this.prefixNo === 'XSTH')
        ) {
          // Ignorer
        } else {
          this.changeFormTypes(this.materialTable.columns, 'snList', 1)
        }
      }
      if (info.enableBatchNumber === '1') {
        // Si la gestion des entrées/sorties est activée et que le type est achat, retour d'achat, vente, retour de vente, alors ignorer
        if (
          this.inOutManageFlag &&
          (this.prefixNo === 'CGRK' || this.prefixNo === 'CGTH' || this.prefixNo === 'XSCK' || this.prefixNo === 'XSTH')
        ) {
          // Ignorer
        } else {
          this.changeFormTypes(this.materialTable.columns, 'batchNumber', 1)
          this.changeFormTypes(this.materialTable.columns, 'expirationDate', 1)
        }
      }
    },
    // Déclenché lors de la suppression d'une ou plusieurs lignes
    onDeleted(ids, target) {
      target.recalcAllStatisticsColumns()
      this.autoChangePrice(target)
    },
    // Interroger le stock selon l'entrepôt et le code-barres
    getStockByDepotBarCode(row, target) {
      findStockByDepotAndBarCode({ depotId: row.depotId, barCode: row.barCode }).then((res) => {
        if (res && res.code === 200) {
          target.setValues([{ rowKey: row.id, values: { stock: res.data.stock } }])
          target.recalcAllStatisticsColumns()
        }
      })
    },
    // Changer les valeurs de remise, paiement actuel, dette
    autoChangePrice(target) {
      let allTaxLastMoney = target.statisticsColumns.taxLastMoney - 0
      let discount = this.form.getFieldValue('discount') - 0
      let otherMoney = this.form.getFieldValue('otherMoney') ? this.form.getFieldValue('otherMoney') - 0 : 0
      let deposit = this.form.getFieldValue('deposit')
      let discountMoney = (discount * 0.01 * allTaxLastMoney).toFixed(2) - 0
      let discountLastMoney = (allTaxLastMoney - discountMoney).toFixed(2) - 0
      let changeAmountNew = (discountLastMoney + otherMoney).toFixed(2) - 0
      if (deposit) {
        changeAmountNew = (changeAmountNew - deposit).toFixed(2) - 0
      }
      this.$nextTick(() => {
        changeAmountNew = this.prefixNo === 'CGDD' || this.prefixNo === 'XSDD' ? 0 : changeAmountNew
        this.form.setFieldsValue({
          discount: discount,
          discountMoney: discountMoney,
          discountLastMoney: discountLastMoney,
          changeAmount: changeAmountNew,
          debt: 0,
        })
        this.setZeroChangeAmount()
      })
    },
    // Changer le taux de remise
    onChangeDiscount(e) {
      const value = e.target.value - 0
      let otherMoney = this.form.getFieldValue('otherMoney') ? this.form.getFieldValue('otherMoney') - 0 : 0
      let deposit = this.form.getFieldValue('deposit')
      let allTaxLastMoney = this.$refs.materialDataTable.statisticsColumns.taxLastMoney - 0
      let discountMoneyNew = (allTaxLastMoney * value * 0.01).toFixed(2) - 0
      let discountLastMoneyNew = (allTaxLastMoney - discountMoneyNew).toFixed(2) - 0
      let changeAmountNew = (discountLastMoneyNew + otherMoney).toFixed(2) - 0
      if (deposit) {
        changeAmountNew = (changeAmountNew - deposit).toFixed(2) - 0
      }
      this.$nextTick(() => {
        changeAmountNew = this.prefixNo === 'CGDD' || this.prefixNo === 'XSDD' ? 0 : changeAmountNew
        this.form.setFieldsValue({
          discountMoney: discountMoneyNew,
          discountLastMoney: discountLastMoneyNew,
          changeAmount: changeAmountNew,
          debt: 0,
        })
        this.setZeroChangeAmount()
      })
    },
    // Changer la remise de paiement
    onChangeDiscountMoney(e) {
      const value = e.target.value - 0
      let otherMoney = this.form.getFieldValue('otherMoney') ? this.form.getFieldValue('otherMoney') - 0 : 0
      let deposit = this.form.getFieldValue('deposit')
      let allTaxLastMoney = this.$refs.materialDataTable.statisticsColumns.taxLastMoney - 0
      let discountNew = ((value / allTaxLastMoney) * 100).toFixed(2) - 0
      let discountLastMoneyNew = (allTaxLastMoney - value).toFixed(2) - 0
      let changeAmountNew = (discountLastMoneyNew + otherMoney).toFixed(2) - 0
      if (deposit) {
        changeAmountNew = (changeAmountNew - deposit).toFixed(2) - 0
      }
      this.$nextTick(() => {
        changeAmountNew = this.prefixNo === 'CGDD' || this.prefixNo === 'XSDD' ? 0 : changeAmountNew
        this.form.setFieldsValue({
          discount: discountNew,
          discountLastMoney: discountLastMoneyNew,
          changeAmount: changeAmountNew,
          debt: 0,
        })
        this.setZeroChangeAmount()
      })
    },
    // Autres frais
    onChangeOtherMoney(e) {
      const value = e.target.value - 0
      let discountLastMoney = this.form.getFieldValue('discountLastMoney') - 0
      let deposit = this.form.getFieldValue('deposit')
      let changeAmountNew = (discountLastMoney + value).toFixed(2) - 0
      if (deposit) {
        changeAmountNew = (changeAmountNew - deposit).toFixed(2) - 0
      }
      this.$nextTick(() => {
        this.form.setFieldsValue({ changeAmount: changeAmountNew, debt: 0 })
        this.setZeroChangeAmount()
      })
    },
    // Changer la déduction de l'acompte
    onChangeDeposit(e) {
      const value = e.target.value - 0
      let discountLastMoney = this.form.getFieldValue('discountLastMoney') - 0
      let otherMoney = this.form.getFieldValue('otherMoney') ? this.form.getFieldValue('otherMoney') - 0 : 0
      let changeAmountNew = (discountLastMoney + otherMoney).toFixed(2) - 0
      if (value) {
        changeAmountNew = (changeAmountNew - value).toFixed(2) - 0
      }
      this.$nextTick(() => {
        this.form.setFieldsValue({ changeAmount: changeAmountNew, debt: 0 })
        this.setZeroChangeAmount()
      })
    },
    // Changer le paiement actuel
    onChangeChangeAmount(e) {
      const value = e.target.value - 0
      let discountLastMoney = this.form.getFieldValue('discountLastMoney') - 0
      let otherMoney = this.form.getFieldValue('otherMoney') ? this.form.getFieldValue('otherMoney') - 0 : 0
      let deposit = this.form.getFieldValue('deposit')
      let debtNew = (discountLastMoney + otherMoney - value).toFixed(2) - 0
      if (deposit) {
        debtNew = (debtNew - deposit).toFixed(2) - 0
      }
      this.$nextTick(() => {
        this.form.setFieldsValue({ debt: debtNew })
      })
    },
    // Changer le prix unitaire du produit en changeant les informations du client
    handleOrganChange(value) {
      let organId = value
      this.getAllTable()
        .then((tables) => {
          return getListData(this.form, tables)
        })
        .then((allValues) => {
          let detailArr = allValues.tablesValue[0].values
          let barCodeStr = ''
          for (let detail of detailArr) {
            if (detail.barCode) {
              barCodeStr += detail.barCode + ','
            }
          }
          if (barCodeStr) {
            let param = {
              barCode: barCodeStr,
              organId: organId,
              mpList: getMpListShort(Vue.ls.get('materialPropertyList')), // Attributs étendus
              prefixNo: this.prefixNo,
            }
            getMaterialByBarCode(param).then((res) => {
              if (res && res.code === 200) {
                let allLastMoney = 0
                let allTaxLastMoney = 0
                // Obtenir les informations de la liste des détails du document
                let detailArr = allValues.tablesValue[0].values
                // Construire un nouveau tableau de liste pour stocker les informations de détail du document
                let newDetailArr = []
                for (let detail of detailArr) {
                  if (detail.barCode) {
                    // Si le code-barres est dupliqué, ajouter 1 à la quantité d'origine
                    let mList = res.data
                    for (let i = 0; i < mList.length; i++) {
                      if (detail.barCode === mList[i].mBarCode) {
                        // Comme le prix unitaire du produit a changé, il faut mettre à jour simultanément le montant associé et le total TTC
                        let taxRate = detail.taxRate - 0 // Taux de taxe
                        detail.unitPrice = mList[i].billPrice - 0 // Prix unitaire
                        detail.allPrice = (detail.unitPrice * detail.operNumber).toFixed(2) - 0
                        detail.taxMoney = (taxRate * 0.01 * detail.allPrice).toFixed(2) - 0
                        detail.taxLastMoney = (detail.allPrice + detail.taxMoney).toFixed(2) - 0
                      }
                    }
                    newDetailArr.push(detail)
                  }
                }
                this.materialTable.dataSource = newDetailArr
                // Mettre à jour le montant après remise, le paiement actuel, etc.
                for (let newDetail of newDetailArr) {
                  allLastMoney = allLastMoney + (newDetail.allPrice - 0)
                  allTaxLastMoney = allTaxLastMoney + (newDetail.taxLastMoney - 0)
                }
                let discount = this.form.getFieldValue('discount') - 0
                let otherMoney = this.form.getFieldValue('otherMoney') ? this.form.getFieldValue('otherMoney') - 0 : 0
                let deposit = this.form.getFieldValue('deposit')
                let discountMoney = (discount * 0.01 * allTaxLastMoney).toFixed(2) - 0
                let discountLastMoney = (allTaxLastMoney - discountMoney).toFixed(2) - 0
                let changeAmountNew = (discountLastMoney + otherMoney).toFixed(2) - 0
                if (deposit) {
                  changeAmountNew = (changeAmountNew - deposit).toFixed(2) - 0
                }
                this.$nextTick(() => {
                  changeAmountNew = this.prefixNo === 'XSDD' ? 0 : changeAmountNew
                  this.form.setFieldsValue({
                    discount: discount,
                    discountMoney: discountMoney,
                    discountLastMoney: discountLastMoney,
                    changeAmount: changeAmountNew,
                    debt: 0,
                  })
                  this.setZeroChangeAmount()
                })
              }
            })
          }
        })
    },
    // Changer le montant de paiement/reçu à 0
    setZeroChangeAmount() {
      if (
        this.prefixNo === 'CGRK' ||
        this.prefixNo === 'CGTH' ||
        this.prefixNo === 'XSCK' ||
        this.prefixNo === 'XSTH'
      ) {
        if (this.zeroChangeAmountFlag) {
          let oldChangeAmount = this.form.getFieldValue('changeAmount') - 0
          this.form.setFieldsValue({ changeAmount: 0, debt: oldChangeAmount })
        }
      }
    },
    scanEnter() {
      this.scanStatus = false
      this.$nextTick(() => {
        this.$refs.scanBarCode.focus()
      })
    },
    // Appuyer sur Entrée après le scan
    scanPressEnter() {
      let that = this
      if (this.scanBarCode) {
        this.getAllTable()
          .then((tables) => {
            return getListData(this.form, tables)
          })
          .then((allValues) => {
            let param = {
              barCode: this.scanBarCode.trim(),
              organId: this.form.getFieldValue('organId'),
              mpList: getMpListShort(Vue.ls.get('materialPropertyList')), // Attributs étendus
              prefixNo: this.prefixNo,
            }
            getMaterialByBarCode(param).then((res) => {
              if (res && res.code === 200) {
                let hasFinished = false
                let allLastMoney = 0
                let allTaxLastMoney = 0
                // Obtenir les informations de la liste des détails du document
                let detailArr = allValues.tablesValue[0].values
                // Construire un nouveau tableau de liste pour stocker les informations de détail du document
                let newDetailArr = []
                let hasAdd = false
                for (let detail of detailArr) {
                  if (detail.barCode) {
                    // Si le résultat du scan et le code-barres sont dupliqués, ajouter 1 à la quantité d'origine
                    if (detail.barCode === this.scanBarCode.trim() && !hasAdd) {
                      detail.operNumber = detail.operNumber - 0 + 1
                      // Comme la quantité du produit a changé, il faut mettre à jour simultanément le montant associé et le total TTC
                      let taxRate = detail.taxRate - 0 // Taux de taxe
                      let unitPrice = detail.unitPrice - 0 // Prix unitaire
                      detail.allPrice = (unitPrice * detail.operNumber).toFixed(2) - 0
                      detail.taxMoney = (taxRate * 0.01 * detail.allPrice).toFixed(2) - 0
                      detail.taxLastMoney = (detail.allPrice + detail.taxMoney).toFixed(2) - 0
                      hasFinished = true
                      hasAdd = true
                    }
                    // Si le résultat du scan et le numéro de série sont dupliqués, ignorer directement
                    if (detail.snList === this.scanBarCode.trim()) {
                      this.$message.warning('Désolé, ce numéro de série a déjà été scanné !')
                      hasFinished = true
                    }
                    newDetailArr.push(detail)
                  }
                }
                if (!hasFinished) {
                  // Ajouter le produit correspondant au code-barres scanné à la liste
                  let item = {}
                  let mList = res.data
                  if (mList && mList.length > 0) {
                    let mInfo = mList[0]
                    this.changeColumnShow(mInfo)
                    item.depotId = mInfo.depotId
                    item.barCode = mInfo.mBarCode
                    item.name = mInfo.name
                    item.standard = mInfo.standard
                    item.model = mInfo.model
                    item.color = mInfo.color
                    item.materialOther = mInfo.materialOther
                    item.stock = mInfo.stock
                    item.unit = mInfo.commodityUnit
                    item.sku = mInfo.sku
                    if (mInfo.mBarCode !== this.scanBarCode.trim()) {
                      if (
                        this.prefixNo === 'LSCK' ||
                        this.prefixNo === 'CGTH' ||
                        this.prefixNo === 'XSCK' ||
                        this.prefixNo === 'QTCK'
                      ) {
                        // Assigner le numéro de série à ce moment
                        item.snList = this.scanBarCode.trim()
                      }
                    }
                    item.operNumber = 1
                    item.unitPrice = mInfo.billPrice
                    item.allPrice = mInfo.billPrice
                    item.taxRate = 0
                    item.taxMoney = 0
                    item.taxLastMoney = mInfo.billPrice
                    newDetailArr.push(item)
                  } else {
                    this.$message.warning("Désolé, ce code-barres n'existe pas dans les informations produit !")
                  }
                }
                // Réaffecter le type de produit pour les documents d'assemblage et de démontage
                for (let i = 0; i < newDetailArr.length; i++) {
                  if (i === 0) {
                    newDetailArr[0].mType = 'Composant combiné'
                  } else {
                    newDetailArr[i].mType = 'Composant standard'
                  }
                }
                this.materialTable.dataSource = newDetailArr
                // Mettre à jour le montant après remise, le paiement actuel, etc.
                for (let newDetail of newDetailArr) {
                  allLastMoney = allLastMoney + (newDetail.allPrice - 0)
                  allTaxLastMoney = allTaxLastMoney + (newDetail.taxLastMoney - 0)
                }
                let discount = this.form.getFieldValue('discount') - 0
                let otherMoney = this.form.getFieldValue('otherMoney') ? this.form.getFieldValue('otherMoney') - 0 : 0
                let deposit = this.form.getFieldValue('deposit')
                let discountMoney = (discount * 0.01 * allTaxLastMoney).toFixed(2) - 0
                let discountLastMoney = (allTaxLastMoney - discountMoney).toFixed(2) - 0
                let changeAmountNew = (discountLastMoney + otherMoney).toFixed(2) - 0
                if (deposit) {
                  changeAmountNew = (changeAmountNew - deposit).toFixed(2) - 0
                }
                if (this.prefixNo === 'LSCK' || this.prefixNo === 'LSTH') {
                  this.$nextTick(() => {
                    this.form.setFieldsValue({ changeAmount: allLastMoney, getAmount: allLastMoney, backAmount: 0 })
                  })
                } else {
                  this.$nextTick(() => {
                    changeAmountNew = this.prefixNo === 'CGDD' || this.prefixNo === 'XSDD' ? 0 : changeAmountNew
                    this.form.setFieldsValue({
                      discount: discount,
                      discountMoney: discountMoney,
                      discountLastMoney: discountLastMoney,
                      changeAmount: changeAmountNew,
                      debt: 0,
                    })
                  })
                }
                // Vider le contenu du scan
                this.scanBarCode = ''
                this.$refs.scanBarCode.focus()
                // Défiler automatiquement jusqu'à la dernière ligne
                setTimeout(function () {
                  that.$refs.materialDataTable.resetScrollTop(
                    (newDetailArr.length + 1) * that.$refs.materialDataTable.rowHeight
                  )
                }, 1000)
              }
            })
          })
      }
    },
    stopScan() {
      this.scanStatus = true
      this.scanBarCode = ''
    },
    onImport(prefixNo) {
      this.$refs.importItemModalForm.add(prefixNo)
    },
    importItemModalFormOk(data) {
      this.materialTable.dataSource = data
      this.$nextTick(() => {
        let discountLastMoney = 0
        for (let i = 0; i < data.length; i++) {
          discountLastMoney += data[i].taxLastMoney
          this.changeColumnShow(data[i])
        }
        this.form.setFieldsValue({ discountLastMoney: discountLastMoney })
      })
    },
    // Enregistrer et auditer
    handleOkAndCheck() {
      this.billStatus = '1'
      this.handleOk()
    },
    // Lancer le processus
    handleWorkflow() {
      if (this.model && this.model.number) {
        getPlatformConfigByKey({ platformKey: 'send_workflow_url' }).then((res) => {
          if (res && res.code === 200) {
            let sendWorkflowUrl = res.data.platformValue + '&no=' + this.model.number + '&type=1'
            this.$refs.modalWorkflow.show(this.model, sendWorkflowUrl, this.model.number, 1, 320)
            this.$refs.modalWorkflow.title = 'Lancer le processus'
          }
        })
      } else {
        this.$message.warning("Veuillez d'abord enregistrer le document avant de soumettre le processus !")
      }
    },
    // Impression en trois exemplaires - nouvelle version
    handlePrintPro(billType) {
      if (this.model.id) {
        getPlatformConfigByKey({ platformKey: 'bill_print_pro_url' }).then((res) => {
          if (res && res.code === 200) {
            let billPrintUrl = res.data.platformValue + '&no=' + this.model.number
            let billPrintHeight = document.documentElement.clientHeight - 260
            this.$refs.modalPrintPro.show(this.model, billPrintUrl, billPrintHeight)
            this.$refs.modalPrintPro.title = billType + '- Impression en trois exemplaires - Nouvelle version'
          }
        })
      } else {
        this.$message.warning("Veuillez d'abord enregistrer le document avant d'imprimer !")
      }
    },
    // Impression en trois exemplaires
    handlePrint(billType) {
      if (this.model.id) {
        getPlatformConfigByKey({ platformKey: 'bill_print_url' }).then((res) => {
          if (res && res.code === 200) {
            let billPrintUrl = res.data.platformValue + '&no=' + this.model.number
            let billPrintHeight = this.materialTable.dataSource.length * 50 + 600
            this.$refs.modalPrint.show(this.model, billPrintUrl, billPrintHeight)
            this.$refs.modalPrint.title = billType + '- Impression en trois exemplaires'
          }
        })
      } else {
        this.$message.warning("Veuillez d'abord enregistrer le document avant d'imprimer !")
      }
    },
    // Charger les informations de configuration de la plateforme
    initPlatform() {
      getPlatformConfigByKey({ platformKey: 'bill_print_flag' }).then((res) => {
        if (res && res.code === 200) {
          this.billPrintFlag = res.data.platformValue === '1' ? true : false
        }
      })
    },
    // Charger les boutons rapides : fournisseur, client, membre, compte de règlement, entrepôt
    initQuickBtn() {
      let btnStrList = Vue.ls.get('winBtnStrList') // Liste des fonctions des boutons - chaîne JSON
      if (btnStrList) {
        for (let i = 0; i < btnStrList.length; i++) {
          if (btnStrList[i].btnStr) {
            this.quickBtn.vendor =
              btnStrList[i].url === '/system/vendor' ? btnStrList[i].btnStr.indexOf(1) > -1 : this.quickBtn.vendor
            this.quickBtn.customer =
              btnStrList[i].url === '/system/customer' ? btnStrList[i].btnStr.indexOf(1) > -1 : this.quickBtn.customer
            this.quickBtn.member =
              btnStrList[i].url === '/system/member' ? btnStrList[i].btnStr.indexOf(1) > -1 : this.quickBtn.member
            this.quickBtn.account =
              btnStrList[i].url === '/system/account' ? btnStrList[i].btnStr.indexOf(1) > -1 : this.quickBtn.account
            this.quickBtn.depot =
              btnStrList[i].url === '/system/depot' ? btnStrList[i].btnStr.indexOf(1) > -1 : this.quickBtn.depot
          }
        }
      }
    },
    // Remplacer dynamiquement les champs étendus
    handleChangeOtherField() {
      let mpStr = getMpListShort(Vue.ls.get('materialPropertyList'))
      if (mpStr) {
        let mpArr = mpStr.split(',')
        if (mpArr.length === 3) {
          for (let i = 0; i < this.materialTable.columns.length; i++) {
            if (this.materialTable.columns[i].key === 'otherField1') {
              this.materialTable.columns[i].title = mpArr[0]
            }
            if (this.materialTable.columns[i].key === 'otherField2') {
              this.materialTable.columns[i].title = mpArr[1]
            }
            if (this.materialTable.columns[i].key === 'otherField3') {
              this.materialTable.columns[i].title = mpArr[2]
            }
          }
        }
      }
    },
  },
}
