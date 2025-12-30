import {findBySelectSup,findBySelectCus,findBySelectRetail,findBySelectOrgan,getPlatformConfigByKey,getAccount,
  getPersonByType,findInOutItemByParam,getCurrentSystemConfig} from '@/api/api'
import { getAction } from '@/api/manage'
import { getCheckFlag, getNowFormatDateTime } from "@/utils/util"
import { USER_INFO } from "@/store/mutation-types"
import Vue from 'vue'

export const FinancialModalMixin = {
  data() {
    return {
      action: '',
      actionWithOrgan: false,
      supList: [],
      cusList: [],
      retailList: [],
      organList: [],
      personList: [],
      accountList: [],
      billStatus: '0',
      isCanCheck: true,
      quickBtn: {
        vendor: false,
        customer: false,
        account: false,
        person: false,
        inOutItem: false
      },
      /* L'audit original est-il activé */
      checkFlag: true,
      setTimeFlag: null,
      spans: {
        labelCol1: {span: 2},
        wrapperCol1: {span: 22},
        //1_5: Divisé en 1,5 colonnes (équivaut à 2/3)
        labelCol1_5: { span: 3 },
        wrapperCol1_5: { span: 21 },
        labelCol2: {span: 4},
        wrapperCol2: {span: 20},
        labelCol3: {span: 6},
        wrapperCol3: {span: 18},
        labelCol6: {span: 12},
        wrapperCol6: {span: 12}
      },
    };
  },
  created () {
    let realScreenWidth = window.screen.width
    this.width = realScreenWidth<1500?'1200px':'1550px'
    this.minWidth = realScreenWidth<1500?1150:1500
  },
  mounted() {
    document.getElementById(this.prefixNo).addEventListener('keydown', this.handleOkKey)
  },
  beforeDestroy() {
    document.getElementById(this.prefixNo).removeEventListener('keydown', this.handleOkKey)
  },
  computed: {
    readOnly: function() {
      return this.action !== "add" && this.action !== "edit";
    }
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
          this.form.setFieldsValue({'billNo':amountNum + res.data.defaultNumber})
        }
      })
      this.$nextTick(() => {
        this.form.setFieldsValue({'billTime':getNowFormatDateTime(), 'totalPrice': 0, 'discountMoney': 0, 'changeAmount': 0})
      })
      this.$nextTick(() => {
        getAccount({}).then((res)=>{
          if(res && res.code === 200) {
            for (const item of res.data.accountList) {
              if(item.isDefault){
                this.form.setFieldsValue({'accountId': item.id})
              }
            }
          }
        })
      })
    },
    initSystemConfig() {
      getCurrentSystemConfig().then((res) => {
        if(res.code === 200 && res.data){
          let multiBillType = res.data.multiBillType
          let multiLevelApprovalFlag = res.data.multiLevelApprovalFlag
          this.checkFlag = getCheckFlag(multiBillType, multiLevelApprovalFlag, this.prefixNo)
        }
      })
    },
    initSupplier() {
      let that = this;
      findBySelectSup({organId: this.model.organId, limit:1}).then((res)=>{
        if(res) {
          that.supList = res;
        }
      });
    },
    initCustomer() {
      let that = this;
      findBySelectCus({organId: this.model.organId, limit:1}).then((res)=>{
        if(res) {
          that.cusList = res;
        }
      });
    },
    initOrgan() {
      let that = this;
      findBySelectOrgan({organId: this.model.organId, limit:1}).then((res)=>{
        if(res) {
          that.organList = res;
        }
      });
    },
    initRetail() {
      let that = this;
      findBySelectRetail({organId: this.model.organId, limit:1}).then((res)=>{
        if(res) {
          that.retailList = res;
        }
      });
    },
    initPerson() {
      let that = this;
      getPersonByType({type:'财务员'}).then((res)=>{
        if(res && res.code === 200) {
          that.personList = res.data.personList;
        }
      })
    },
    initInOutItem(type) {
      let that = this;
      findInOutItemByParam({type:type}).then((res)=>{
        if(res) {
          for(let item of that.accountTable.columns){
            if(item.key == 'inOutItemId') {
              item.options = []
              for(let i=0; i<res.length; i++) {
                let inOutItemInfo = {};
                inOutItemInfo.value = res[i].id + '' // Note - la valeur doit être au format chaîne ici
                inOutItemInfo.text = res[i].name
                inOutItemInfo.title = res[i].name
                item.options.push(inOutItemInfo)
              }
            }
          }
        }
      })
    },
    // Compte - pour le tableau principal
    initAccount(){
      let that = this;
      getAccount({}).then((res)=>{
        if(res && res.code === 200) {
          that.accountList = res.data.accountList;
        }
      })
    },
    // Compte - pour les détails
    initDetailAccount(){
      let that = this;
      getAccount({}).then((res)=>{
        if(res && res.code === 200) {
          let list = res.data.accountList;
          for(let item of that.accountTable.columns){
            if(item.key == 'accountId') {
              item.options = []
              for(let i=0; i<list.length; i++) {
                let accountInfo = {};
                accountInfo.value = list[i].id + '' // Note - la valeur doit être au format chaîne ici
                accountInfo.text = list[i].name
                accountInfo.title = list[i].name
                item.options.push(accountInfo)
              }
            }
          }
        }
      })
    },
    handleSearchSupplier(value) {
      let that = this
      if(this.setTimeFlag != null){
        clearTimeout(this.setTimeFlag);
      }
      this.setTimeFlag = setTimeout(()=>{
        findBySelectSup({key: value, limit:1}).then((res) => {
          if(res) {
            that.supList = res;
          }
        })
      },500)
    },
    handleSearchCustomer(value) {
      let that = this
      if(this.setTimeFlag != null){
        clearTimeout(this.setTimeFlag);
      }
      this.setTimeFlag = setTimeout(()=>{
        findBySelectCus({key: value, limit:1}).then((res) => {
          if(res) {
            that.cusList = res;
          }
        })
      },500)
    },
    handleSearchOrgan(value) {
      let that = this
      if(this.setTimeFlag != null){
        clearTimeout(this.setTimeFlag);
      }
      this.setTimeFlag = setTimeout(()=>{
        findBySelectOrgan({key: value, limit:1}).then((res) => {
          if(res) {
            that.organList = res;
          }
        })
      },500)
    },
    handleSearchRetail(value) {
      let that = this
      if(this.setTimeFlag != null){
        clearTimeout(this.setTimeFlag);
      }
      this.setTimeFlag = setTimeout(()=>{
        findBySelectRetail({key: value, limit:1}).then((res) => {
          if(res) {
            that.retailList = res;
          }
        })
      },500)
    },
    // Événement déclenché lors de la sélection d'un fournisseur ou d'un client
    onChangeOrgan(value) {
      this.accountTable.dataSource = []
    },
    addSupplier() {
      this.$refs.vendorModalForm.add();
      this.$refs.vendorModalForm.title = "Ajouter";
      this.$refs.vendorModalForm.disableSubmit = false;
    },
    addCustomer() {
      this.$refs.customerModalForm.add();
      this.$refs.customerModalForm.title = "Ajouter un client (Rappel : si vous ne trouvez pas le client nouvellement ajouté, veuillez vérifier dans la gestion des utilisateurs si les permissions pour ce client ont été attribuées)";
      this.$refs.customerModalForm.disableSubmit = false;
    },
    addAccount() {
      this.$refs.accountModalForm.add();
      this.$refs.accountModalForm.title = "Ajouter un compte de règlement";
      this.$refs.accountModalForm.disableSubmit = false;
    },
    addPerson() {
      this.$refs.personModalForm.add();
      this.$refs.personModalForm.title = "Ajouter un responsable";
      this.$refs.personModalForm.disableSubmit = false;
    },
    addInOutItem(type) {
      this.$refs.inOutItemModalForm.add(type);
      this.$refs.inOutItemModalForm.title = "Ajouter un projet de recettes/dépenses";
      this.$refs.inOutItemModalForm.disableSubmit = false;
    },
    vendorModalFormOk() {
      this.initSupplier()
    },
    customerModalFormOk() {
      this.initCustomer()
    },
    accountModalFormOk() {
      this.initAccount()
    },
    personModalFormOk() {
      this.initPerson()
    },
    inOutItemModalFormOk(type) {
      this.initInOutItem(type)
    },
    workflowModalFormOk() {
      this.close()
    },
    waitNeedListOk(organType, organId, selectBillRows) {
      if(organId) {
        this.form.setFieldsValue({'organId': organId})
        if(organType === '供应商') {
          findBySelectSup({organId: organId, limit:1}).then((res)=> {
            this.supList = res && Array.isArray(res) ? res : [];
          })
        } else if(organType === '客户') {
          findBySelectCus({organId: organId, limit:1}).then((res)=> {
            this.cusList = res && Array.isArray(res) ? res : [];
          })
        }
      }
      if (selectBillRows && selectBillRows.length > 0) {
        this.requestSubTableDataEx(selectBillRows, this.accountTable);
      } else {
        this.selectBeginNeed(organType)
      }
    },
    onAdded(event) {
      let that = this
      const { row, target } = event
      // Défilement automatique jusqu'à la dernière ligne
      setTimeout(function(){
        that.$refs.accountDataTable.resetScrollTop((target.rows.length+1)*that.$refs.accountDataTable.rowHeight)
      },1000)
    },
    // Déclenché lors de la suppression d'une ou plusieurs lignes
    onDeleted(ids, target) {
      target.recalcAllStatisticsColumns()
      this.autoChangeAmount(target)
    },
    // Déclenché à chaque changement d'un caractère dans la valeur de la cellule
    onValueChange(event) {
      let that = this
      const { type, row, column, value, target } = event
      switch(column.key) {
        case "eachAmount":
          target.recalcAllStatisticsColumns()
          that.autoChangeAmount(target)
          break;
      }
    },
    // Modifier la valeur de la dette actuelle
    autoChangeAmount(target) {
      let allEachAmount = target.statisticsColumns.eachAmount-0
      let discountMoney = this.form.getFieldValue('discountMoney')-0
      if(!discountMoney) {
        discountMoney = 0
      }
      let changeAmount = (allEachAmount-discountMoney).toFixed(2)
      this.$nextTick(() => {
        this.form.setFieldsValue({'totalPrice':allEachAmount, 'changeAmount':changeAmount})
      });
    },
    // Modifier le montant de remise
    onChangeDiscountMoney(e) {
      const value = e.target.value-0
      let totalPrice = this.form.getFieldValue('totalPrice')-0
      let changeAmount = (totalPrice-value).toFixed(2)
      this.$nextTick(() => {
        this.form.setFieldsValue({'changeAmount':changeAmount})
      });
    },
    // Sélectionner un document de dette
    debtBillListOk(selectBillRows) {
      if(selectBillRows && selectBillRows.length>0) {
        this.requestSubTableDataEx(selectBillRows, this.accountTable);
      }
    },
    /** Rechercher les données d'un onglet, attribuer des valeurs aux montants dans les détails */
    requestSubTableDataEx(selectBillRows, tab, success) {
      tab.loading = true
      let listEx = []
      let changeAmount = 0
      for(let i=0; i<selectBillRows.length; i++){
        let info = selectBillRows[i]
        info.billNumber = info.number
        info.needDebt = info.needDebt
        info.eachAmount = info.debt
        if(info.eachAmount != 0) {
          changeAmount += info.eachAmount-0
          listEx.push(info)
        }
      }
      tab.dataSource = listEx
      this.$nextTick(() => {
        this.form.setFieldsValue({'totalPrice':changeAmount.toFixed(2), 'changeAmount':changeAmount.toFixed(2)})
      });
      typeof success === 'function' ? success(res) : ''
      tab.loading = false
    },
    // Sélectionner le solde initial
    selectBeginNeed(type) {
      let that = this
      let info = type === '供应商'? '付款':'收款'
      let organId = this.form.getFieldValue('organId')
      if(organId){
        this.$confirm({
          title: "Confirmer l'opération",
          content: "Voulez-vous sélectionner le montant du solde initial et effectuer " + info + " sur le solde initial ?",
          onOk: function () {
            let listEx = []
            let info = {}
            info.billNumber = 'QiChu'
            getAction('/supplier/getBeginNeedByOrganId', {'organId': organId}).then((res)=>{
              if(res.code === 200){
                info.needDebt = res.data.needDebt?res.data.needDebt:0
                info.finishDebt = res.data.finishDebt
                info.eachAmount = res.data.eachAmount
                listEx.push(info)
                that.accountTable.dataSource = listEx
                let changeAmount = info.eachAmount
                if(changeAmount) {
                  changeAmount = changeAmount.toFixed(2)
                }
                that.$nextTick(() => {
                  that.form.setFieldsValue({'totalPrice':changeAmount, 'changeAmount':changeAmount})
                })
              }else{
                that.$message.info(res.data)
              }
            })
          }
        })
      } else {
        that.$message.warning('Veuillez sélectionner ' + type + ' !');
      }
    },
    // Sélectionner - en attente de recouvrement ou en attente de paiement
    handleWaitNeed(type) {
      this.$refs.waitNeedList.show(type)
    },
    // Enregistrer et auditer
    handleOkAndCheck() {
      this.billStatus = '1'
      this.handleOk()
    },
    // Lancer le processus
    handleWorkflow() {
      if(this.model && this.model.billNo) {
        getPlatformConfigByKey({ "platformKey": "send_workflow_url" }).then((res) => {
          if (res && res.code === 200) {
            let sendWorkflowUrl = res.data.platformValue + '&no=' + this.model.billNo + '&type=2'
            this.$refs.modalWorkflow.show(this.model, sendWorkflowUrl, this.model.billNo, 2, 320)
            this.$refs.modalWorkflow.title = "Lancer le processus"
          }
        })
      } else {
        this.$message.warning('Veuillez d'abord enregistrer le document avant de soumettre le processus !');
      }
    },
    // Charger les boutons rapides : fournisseur, client, compte de règlement, responsable
    initQuickBtn() {
      let btnStrList = Vue.ls.get('winBtnStrList') // Liste des fonctions des boutons - chaîne JSON
      if (btnStrList) {
        for (let i = 0; i < btnStrList.length; i++) {
          if (btnStrList[i].btnStr) {
            this.quickBtn.vendor = btnStrList[i].url === '/system/vendor'?btnStrList[i].btnStr.indexOf(1)>-1:this.quickBtn.vendor
            this.quickBtn.customer = btnStrList[i].url === '/system/customer'?btnStrList[i].btnStr.indexOf(1)>-1:this.quickBtn.customer
            this.quickBtn.account = btnStrList[i].url === '/system/account'?btnStrList[i].btnStr.indexOf(1)>-1:this.quickBtn.account
            this.quickBtn.person = btnStrList[i].url === '/system/person'?btnStrList[i].btnStr.indexOf(1)>-1:this.quickBtn.person
            this.quickBtn.inOutItem = btnStrList[i].url === '/system/in_out_item'?btnStrList[i].btnStr.indexOf(1)>-1:this.quickBtn.inOutItem
          }
        }
      }
    }
  }
}