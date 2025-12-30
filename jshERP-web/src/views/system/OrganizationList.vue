<template xmlns:background-color="http://www.w3.org/1999/xhtml">
  <a-row :gutter="10">
    <a-col :md="12" :sm="24">
      <a-card :bordered="false">
        <!-- Zone des boutons d'action -->
        <a-row style="margin-left: 14px">
          <a-button v-if="btnEnableList.indexOf(1) > -1" @click="handleAdd()" type="primary"
            >Ajouter une organisation</a-button
          >
          <a-button
            v-if="btnEnableList.indexOf(1) > -1"
            title="Supprimer plusieurs données"
            @click="batchDel"
            type="default"
            >Supprimer en lot</a-button
          >
          <a-button @click="refresh" type="default" icon="reload">Actualiser</a-button>
          <a-button type="dashed"
            >Note : Les organisations peuvent enregistrer des départements d'entreprise ou des magasins</a-button
          >
        </a-row>
        <div style="background: #fff; padding-left: 16px; height: 100%; margin-top: 5px">
          <a-alert type="info" :showIcon="true">
            <div slot="message">
              Sélection actuelle : <span v-if="this.currSelected.title">{{ getCurrSelectedTitle() }}</span>
              <a v-if="this.currSelected.title" style="margin-left: 10px" @click="onClearSelected"
                >Annuler la sélection</a
              >
            </div>
          </a-alert>
          <!-- Arbre -->
          <a-col :md="10" :sm="24">
            <template>
              <a-dropdown :trigger="[this.dropTrigger]" @visibleChange="dropStatus">
                <span style="user-select: none">
                  <a-tree
                    checkable
                    multiple
                    @select="onSelect"
                    @check="onCheck"
                    @rightClick="rightHandle"
                    :selectedKeys="selectedKeys"
                    :checkedKeys="checkedKeys"
                    :treeData="departTree"
                    :checkStrictly="checkStrictly"
                    :expandedKeys="iExpandedKeys"
                    :autoExpandParent="true"
                    @expand="onExpand"
                  />
                </span>
              </a-dropdown>
            </template>
          </a-col>
        </div>
      </a-card>
      <!---- author:os_chengtgen -- date:20190827 --  for:Basculer le mode de sélection parent-enfant =======------>
      <div class="drawer-bootom-button">
        <a-dropdown :trigger="['click']" placement="topCenter">
          <a-menu slot="overlay">
            <a-menu-item key="1" @click="switchCheckStrictly(1)">Associer parent-enfant</a-menu-item>
            <a-menu-item key="2" @click="switchCheckStrictly(2)">Annuler l'association</a-menu-item>
            <a-menu-item key="3" @click="checkALL">Tout sélectionner</a-menu-item>
            <a-menu-item key="4" @click="cancelCheckALL">Tout désélectionner</a-menu-item>
            <a-menu-item key="5" @click="expandAll">Développer tout</a-menu-item>
            <a-menu-item key="6" @click="closeAll">Réduire tout</a-menu-item>
          </a-menu>
          <a-button> Opérations sur l'arbre <a-icon type="up" /> </a-button>
        </a-dropdown>
      </div>
      <!---- author:os_chengtgen -- date:20190827 --  for:Basculer le mode de sélection parent-enfant =======------>
    </a-col>
    <a-col :md="12" :sm="24">
      <a-card :bordered="false" v-if="selectedKeys.length > 0">
        <a-form :form="form">
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Nom">
            <a-input placeholder="Veuillez saisir le nom" v-decorator="['orgAbr', validatorRules.orgAbr]" />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro">
            <a-input placeholder="Veuillez saisir le numéro" v-decorator="['orgNo', validatorRules.orgNo]" />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Organisation parente">
            <a-tree-select
              style="width: 100%"
              :dropdownStyle="{ maxHeight: '200px', overflow: 'auto' }"
              allow-clear
              :treeDefaultExpandAll="true"
              :treeData="treeData"
              v-decorator="['parentId']"
              placeholder="Veuillez sélectionner l'organisation parente"
            >
            </a-tree-select>
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Tri">
            <a-input v-decorator="['sort']" />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Remarque">
            <a-textarea placeholder="Veuillez saisir la remarque" :rows="2" v-decorator.trim="['remark']" />
          </a-form-item>
        </a-form>
        <div class="anty-form-btn">
          <a-button @click="emptyCurrForm" type="default" htmlType="button" icon="sync">Réinitialiser</a-button>
          <a-button @click="submitCurrForm" type="primary" htmlType="button" icon="form">Enregistrer</a-button>
        </div>
      </a-card>
      <a-card v-else>
        <a-empty>
          <span slot="description"> Veuillez d'abord sélectionner une organisation ! </span>
        </a-empty>
      </a-card>
    </a-col>
    <organization-modal ref="organizationModal" @ok="loadTree"></organization-modal>
  </a-row>
</template>
<!-- f r o m 7 5  2 7 1  8 9 2 0 -->
<script>
import OrganizationModal from './modules/OrganizationModal'
import pick from 'lodash.pick'
import {queryOrganizationTreeList,queryOrganizationById, checkOrganization} from '@/api/api'
import {httpAction, deleteAction} from '@/api/manage'
import {JeecgListMixin} from '@/mixins/JeecgListMixin'
export default {
  name: 'OrganizationList',
  mixins: [JeecgListMixin],
  components: {
    OrganizationModal
  },
  data() {
    return {
      iExpandedKeys: [],
      loading: false,
      currFlowId: '',
      currFlowName: '',
      disable: true,
      treeData: [],
      visible: false,
      departTree: [],
      rightClickSelectedKey: '',
      rightClickSelectedOrgCode: '',
      hiding: true,
      model: {},
      dropTrigger: '',
      depart: {},
      disableSubmit: false,
      checkedKeys: [],
      selectedKeys: [],
      autoIncr: 1,
      currSelected: {},
      allTreeKeys:[],
      checkStrictly: true,
      form: this.$form.createForm(this),
      urlPath: '/system/organization',
      labelCol: {
        xs: {span: 24},
        sm: {span: 5}
      },
      wrapperCol: {
        xs: {span: 24},
        sm: {span: 16}
      },
      graphDatasource: {
        nodes: [],
        edges: []
      },
      validatorRules: {
        orgAbr: {
          rules: [
            { required: true, message: 'Veuillez saisir le nom !'},
            { validator: this.validateName}
          ]
        },
        orgNo: {rules: [{required: true, message: 'Veuillez saisir le code !'}]}
      },
      url: {
        delete: '/organization/delete',
        edit: '/organization/update',
        deleteBatch: '/organization/deleteBatch'
      },
      orgCategoryDisabled:false,
    }
  },
  computed: {
    importExcelUrl: function () {
      return `${window._CONFIG['domianURL']}/${this.url.importExcelUrl}`;
    }
  },
  methods: {
    loadData() {
      this.refresh();
    },
    loadTree() {
      let that = this
      that.treeData = []
      that.departTree = []
      let params = {};
      params.id='';
      queryOrganizationTreeList(params).then((res) => {
        if (res) {
          // Après avoir tout sélectionné dans l'organisation, puis ajouter une organisation, le nombre de sélections augmente
          this.allTreeKeys = [];
          for (let i = 0; i < res.length; i++) {
            let temp = res[i]
            that.departTree.push(temp)
            that.setThisExpandedKeys(temp)
            that.getAllKeys(temp);
          }
          this.loading = false
        }
      })
    },
    setThisExpandedKeys(node) {
      if (node.children && node.children.length > 0) {
        this.iExpandedKeys.push(node.key)
        for (let a = 0; a < node.children.length; a++) {
          this.setThisExpandedKeys(node.children[a])
        }
      }
    },
    refresh() {
      this.loading = true
      this.loadTree()
    },
    // Méthode de gestion du clic droit
    rightHandle(node) {
      this.dropTrigger = 'contextmenu'
      console.log(node.node.eventKey)
      this.rightClickSelectedKey = node.node.eventKey
      this.rightClickSelectedOrgCode = node.node.dataRef.orgCode
    },
    onExpand(expandedKeys) {
      console.log('onExpand', expandedKeys)
      // if not set autoExpandParent to false, if children expanded, parent can not collapse.
      // or, you can remove all expanded children keys.
      this.iExpandedKeys = expandedKeys
    },
    backFlowList() {
      this.$router.back(-1)
    },
    // Événement de changement du menu déroulant lors du clic droit
    dropStatus(visible) {
      if (visible == false) {
        this.dropTrigger = ''
      }
    },
    // Fermer le menu déroulant lors du clic droit
    closeDrop() {
      this.dropTrigger = ''
    },
    addRootNode() {
      this.$refs.nodeModal.add(this.currFlowId, '')
    },
    batchDel: function () {
      console.log(this.checkedKeys)
      if (this.checkedKeys.length <= 0) {
        this.$message.warning('Veuillez sélectionner au moins un enregistrement !')
      } else {
        var ids = ''
        for (var a = 0; a < this.checkedKeys.length; a++) {
          ids += this.checkedKeys[a] + ','
        }
        var that = this
        this.$confirm({
          title: 'Confirmer la suppression',
          content: 'Êtes-vous sûr de vouloir supprimer les ' + this.checkedKeys.length + ' données sélectionnées ?',
          onOk: function () {
            deleteAction(that.url.deleteBatch, {ids: ids}).then((res) => {
              if (res.code == 200) {
                that.$message.success(res.data.message)
                that.loadTree()
                that.onClearSelected()
              } else {
                that.$message.warning(res.data.message)
              }
            })
          }
        })
      }
    },
    nodeModalOk() {
      this.loadTree()
    },
    nodeModalClose() {
    },
    hide() {
      console.log(111)
      this.visible = false
    },
    onCheck(checkedKeys, info) {
      console.log('onCheck', checkedKeys, info)
      this.hiding = false
      //this.checkedKeys = checkedKeys.checked
      // <!---- author:os_chengtgen -- date:20190827 --  for:Basculer le mode de sélection parent-enfant =======------>
      if(this.checkStrictly){
        this.checkedKeys = checkedKeys.checked;
      }else{
        this.checkedKeys = checkedKeys
      }
      // <!---- author:os_chengtgen -- date:20190827 --  for:Basculer le mode de sélection parent-enfant =======------>
    },
    onSelect(selectedKeys, e) {
      console.log('selected', selectedKeys, e)
      this.hiding = false
      let record = e.node.dataRef
      let params = {};
      params.id=record.id;
      this.getTreeByParams(params)
      queryOrganizationById(params).then((res) => {
        if (res && res.code == 200) {
          if(res.data){
            record.orgAbr = res.data.orgAbr;
            record.orgNo = res.data.orgNo;
            record.parentId = res.data.parentId;
            record.sort = res.data.sort;
            record.remark = res.data.remark;
            console.log('onSelect-record', record)
            this.currSelected = Object.assign({}, record)
            this.model = this.currSelected
            this.selectedKeys = [record.key]
            this.model.parentId = record.parentId
            this.setValuesToForm(record)
          }
        }
      });
    },
    // Charger l'arbre d'organisations selon l'ID d'organisation
    getTreeByParams(params) {
      queryOrganizationTreeList(params).then((res) => {
        if (res) {
          this.treeData = []
          for (let i = 0; i < res.length; i++) {
            this.treeData.push(res[i])
          }
        }
      })
    },
    // Lors du déclenchement de l'événement onSelect, assigner des valeurs au formulaire à droite de l'arbre d'organisations
    setValuesToForm(record) {
      this.$nextTick(() => {
        this.form.setFieldsValue(pick(record, 'orgAbr', 'orgNo', 'parentId', 'sort', 'remark'))
      })
    },
    getCurrSelectedTitle() {
      return !this.currSelected.title ? '' : this.currSelected.title
    },
    onClearSelected() {
      this.hiding = true
      this.checkedKeys = []
      this.currSelected = {}
      this.form.resetFields()
      this.selectedKeys = []
      this.$refs.departAuth.departId = ''
    },
    handleNodeTypeChange(val) {
      this.currSelected.nodeType = val
    },
    notifyTriggerTypeChange(value) {
      this.currSelected.notifyTriggerType = value
    },
    receiptTriggerTypeChange(value) {
      this.currSelected.receiptTriggerType = value
    },
    submitCurrForm() {
      this.form.validateFields((err, values) => {
        if (!err) {
          if (!this.currSelected.id) {
            this.$message.warning("Veuillez cliquer pour sélectionner l'organisation à modifier !")
            return
          }
          let formData = Object.assign(this.currSelected, values)
          console.log('Received values of form: ', formData)
          httpAction(this.url.edit, formData, 'put').then((res) => {
            if (res.code == 200) {
              this.$message.success('Enregistrement réussi !')
              this.loadTree()
              let params = {}
              params.id = formData.id
              this.getTreeByParams(params)
            } else {
              this.$message.error(res.message)
            }
          })
        }
      })
    },
    emptyCurrForm() {
      this.form.resetFields()
    },
    nodeSettingFormSubmit() {
      this.form.validateFields((err, values) => {
        if (!err) {
          console.log('Received values of form: ', values)
        }
      })
    },
    openSelect() {
      this.$refs.sysDirectiveModal.show()
    },
    validateName(rule, value, callback){
      let params = {
        name: value,
        id: this.model.id?this.model.id:0
      };
      checkOrganization(params).then((res)=>{
        if(res && res.code===200) {
          if(!res.data.status){
            callback();
          } else {
            callback("Le nom existe déjà");
          }
        } else {
          callback(res.data);
        }
      });
    },
    handleAdd() {
      this.$refs.organizationModal.add()
      this.$refs.organizationModal.title = 'Ajouter'
    },
    selectDirectiveOk(record) {
      console.log('Données d\'instruction sélectionnées', record)
      this.nodeSettingForm.setFieldsValue({directiveCode: record.directiveCode})
      this.currSelected.sysCode = record.sysCode
    },
    getFlowGraphData(node) {
      this.graphDatasource.nodes.push({
        id: node.id,
        text: node.flowNodeName
      })
      if (node.children.length > 0) {
        for (let a = 0; a < node.children.length; a++) {
          let temp = node.children[a]
          this.graphDatasource.edges.push({
            source: node.id,
            target: temp.id
          })
          this.getFlowGraphData(temp)
        }
      }
    },
    // <!---- author:os_chengtgen -- date:20190827 --  for:Basculer le mode de sélection parent-enfant =======------>
    expandAll () {
      this.iExpandedKeys = this.allTreeKeys
    },
    closeAll () {
      this.iExpandedKeys = []
    },
    checkALL () {
      this.checkStriccheckStrictlytly = false
      this.checkedKeys = this.allTreeKeys
    },
    cancelCheckALL () {
      //this.checkedKeys = this.defaultCheckedKeys
      this.checkedKeys = []
    },
    switchCheckStrictly (v) {
      if(v==1){
        this.checkStrictly = false
      }else if(v==2){
        this.checkStrictly = true
      }
    },
    getAllKeys(node) {
      // console.log('node',node);
      this.allTreeKeys.push(node.key)
      if (node.children && node.children.length > 0) {
        for (let a = 0; a < node.children.length; a++) {
          this.getAllKeys(node.children[a])
        }
      }
    }
    // <!---- author:os_chengtgen -- date:20190827 --  for:Basculer le mode de sélection parent-enfant =======------>

  },
  created() {
    this.currFlowId = this.$route.params.id
    this.currFlowName = this.$route.params.name
    // this.loadTree()
  },

}
</script>
<style scoped>
.ant-card-body .table-operator {
  margin: 15px;
}

.anty-form-btn {
  width: 100%;
  text-align: center;
}

.anty-form-btn button {
  margin: 0 5px;
}

.anty-node-layout .ant-layout-header {
  padding-right: 0;
}

.header {
  padding: 0 8px;
}

.header button {
  margin: 0 3px;
}

.ant-modal-cust-warp {
  height: 100%;
}

.ant-modal-cust-warp .ant-modal-body {
  height: calc(100% - 110px) !important;
  overflow-y: auto;
}

.ant-modal-cust-warp .ant-modal-content {
  height: 90% !important;
  overflow-y: hidden;
}

#app .desktop {
  height: auto !important;
}

/** Espacement des boutons */
.ant-btn {
  margin-left: 3px;
}

.drawer-bootom-button {
  /*position: absolute;*/
  bottom: 0;
  width: 100%;
  border-top: 1px solid #e8e8e8;
  padding: 10px 16px;
  text-align: left;
  left: 0;
  background: #fff;
  border-radius: 0 0 2px 2px;
}
</style>
