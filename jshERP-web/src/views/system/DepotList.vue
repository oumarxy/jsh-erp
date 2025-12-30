<!-- f r o m 7 5  2 7 1  8 9 2 0 -->
<template>
  <a-row :gutter="24">
    <a-col :md="24">
      <a-card :style="cardStyle" :bordered="false">
        <!-- Zone de recherche -->
        <div class="table-page-search-wrapper">
          <!-- Zone de recherche -->
          <a-form layout="inline" @keyup.enter.native="searchQuery">
            <a-row :gutter="24">
              <a-col :md="6" :sm="24">
                <a-form-item label="Nom de l'entrepôt" :labelCol="labelCol" :wrapperCol="wrapperCol">
                  <a-input
                    placeholder="Veuillez saisir le nom de l'entrepôt pour rechercher"
                    v-model="queryParam.name"
                  ></a-input>
                </a-form-item>
              </a-col>
              <a-col :md="6" :sm="24">
                <a-form-item label="Remarque" :labelCol="labelCol" :wrapperCol="wrapperCol">
                  <a-input
                    placeholder="Veuillez saisir la remarque pour rechercher"
                    v-model="queryParam.remark"
                  ></a-input>
                </a-form-item>
              </a-col>
              <span style="float: left; overflow: hidden" class="table-page-search-submitButtons">
                <a-col :md="6" :sm="24">
                  <a-button type="primary" @click="searchQuery">Rechercher</a-button>
                  <a-button style="margin-left: 8px" @click="searchReset">Réinitialiser</a-button>
                </a-col>
              </span>
            </a-row>
          </a-form>
        </div>
        <!-- Zone des boutons d'action -->
        <div class="table-operator" style="margin-top: 5px">
          <a-button v-if="btnEnableList.indexOf(1) > -1" @click="handleAdd" type="primary" icon="plus"
            >Ajouter</a-button
          >
          <a-button v-if="btnEnableList.indexOf(1) > -1" @click="batchDel" icon="delete">Supprimer</a-button>
          <a-button v-if="btnEnableList.indexOf(1) > -1" @click="batchSetStatus(true)" icon="check-square"
            >Activer</a-button
          >
          <a-button v-if="btnEnableList.indexOf(1) > -1" @click="batchSetStatus(false)" icon="close-square"
            >Désactiver</a-button
          >
        </div>
        <!-- Zone du tableau - début -->
        <div>
          <a-table
            ref="table"
            size="middle"
            bordered
            rowKey="id"
            :columns="columns"
            :dataSource="dataSource"
            :pagination="ipagination"
            :scroll="scroll"
            :loading="loading"
            :rowSelection="{ selectedRowKeys: selectedRowKeys, onChange: onSelectChange }"
            @change="handleTableChange"
          >
            <span slot="action" slot-scope="text, record">
              <a
                v-if="btnEnableList.indexOf(1) > -1 && depotFlag === '1' && quickBtn.user.indexOf(1) > -1"
                @click="btnSetUser(record)"
                >Attribuer un utilisateur</a
              >
              <a-divider
                v-if="btnEnableList.indexOf(1) > -1 && depotFlag === '1' && quickBtn.user.indexOf(1) > -1"
                type="vertical"
              />
              <a-popconfirm
                v-if="btnEnableList.indexOf(1) > -1"
                title="Êtes-vous sûr de vouloir définir par défaut ?"
                @confirm="() => handleSetDefault(record.id)"
              >
                <a>Définir par défaut</a>
              </a-popconfirm>
              <a-divider v-if="btnEnableList.indexOf(1) > -1" type="vertical" />
              <a @click="handleEdit(record)">Modifier</a>
              <a-divider v-if="btnEnableList.indexOf(1) > -1" type="vertical" />
              <a-popconfirm
                v-if="btnEnableList.indexOf(1) > -1"
                title="Êtes-vous sûr de vouloir supprimer ?"
                @confirm="() => handleDelete(record.id)"
              >
                <a>Supprimer</a>
              </a-popconfirm>
            </span>
            <!-- Modèle de rendu d'état -->
            <template slot="customRenderEnabledFlag" slot-scope="enabled">
              <a-tag v-if="enabled" color="green">Activé</a-tag>
              <a-tag v-if="!enabled" color="orange">Désactivé</a-tag>
            </template>
            <template slot="customRenderFlag" slot-scope="isDefault">
              <a-tag v-if="isDefault" color="green">Oui</a-tag>
              <a-tag v-if="!isDefault" color="orange">Non</a-tag>
            </template>
          </a-table>
        </div>
        <!-- Zone du tableau - fin -->
        <!-- Zone du formulaire -->
        <depot-modal ref="modalForm" @ok="modalFormOk"></depot-modal>
        <depot-user-modal ref="depotUserModal"></depot-user-modal>
      </a-card>
    </a-col>
  </a-row>
</template>
<!-- BY cao_yu-li -->
<script>
import DepotModal from './modules/DepotModal'
import DepotUserModal from './modules/DepotUserModal'
import { JeecgListMixin } from '@/mixins/JeecgListMixin'
import JDate from '@/components/jeecg/JDate'
import { postAction } from '@api/manage'
import { getCurrentSystemConfig } from '@/api/api'
import Vue from 'vue'
export default {
  name: "DepotList",
  mixins:[JeecgListMixin],
  components: {
    DepotModal,
    DepotUserModal,
    JDate
  },
  data () {
    return {
      labelCol: {
        span: 5
      },
      wrapperCol: {
        span: 18,
        offset: 1
      },
      // Conditions de recherche
      queryParam: {name:'',remark:''},
      urlPath: '/system/depot',
      depotFlag: '0',
      quickBtn: {
        user: ''
      },
      // En-têtes de colonnes
      columns: [
        {
          title: '#',
          dataIndex: '',
          key:'rowIndex',
          width:40,
          align:"center",
          customRender:function (t,r,index) {
            return parseInt(index)+1;
          }
        },
        {
          title: 'Opération',
          dataIndex: 'action',
          align:"center",
          width: 200,
          scopedSlots: { customRender: 'action' },
        },
        {title: "Nom de l'entrepôt", dataIndex: 'name', width: 200},
        {title: "Adresse de l'entrepôt", dataIndex: 'address', width: 200},
        {title: "Frais d'entreposage", dataIndex: 'warehousing', width: 80},
        {title: 'Frais de manutention', dataIndex: 'truckage', width: 80},
        {title: 'Responsable', dataIndex: 'principalName', width: 80},
        {title: 'Remarque', dataIndex: 'remark', width: 120},
        {title: 'Tri', dataIndex: 'sort', width: 60},
        { title: 'État',dataIndex: 'enabled',width:60,align:"center",
          scopedSlots: { customRender: 'customRenderEnabledFlag' }
        },
        {title: 'Par défaut',dataIndex: 'isDefault',width:80,align:"center",
          scopedSlots: { customRender: 'customRenderFlag' }
        }
      ],
      url: {
        list: "/depot/list",
        delete: "/depot/delete",
        deleteBatch: "/depot/deleteBatch",
        setDefault: "/depot/updateIsDefault",
        batchSetStatusUrl: "/depot/batchSetStatus"
      }
    }
  },
  created() {
    this.getSystemConfig()
    this.initQuickBtn()
  },
  methods: {
    getSystemConfig() {
      getCurrentSystemConfig().then((res) => {
        if(res.code === 200 && res.data){
          this.depotFlag = res.data.depotFlag
        }
      })
    },
    // Charger les boutons rapides : Attribuer un utilisateur
    initQuickBtn() {
      let btnStrList = Vue.ls.get('winBtnStrList') // Liste des fonctions de boutons - Chaîne JSON
      if (btnStrList) {
        for (let i = 0; i < btnStrList.length; i++) {
          if (btnStrList[i].btnStr) {
            this.quickBtn.user = btnStrList[i].url === '/system/user'?btnStrList[i].btnStr:this.quickBtn.user
          }
        }
      }
    },
    handleSetDefault: function (id) {
      if(!this.url.setDefault){
        this.$message.error("Veuillez définir l'attribut url.delete !")
        return
      }
      let that = this;
      postAction(that.url.setDefault, {id: id}).then((res) => {
        if(res.code === 200){
          that.loadData();
        } else {
          that.$message.warning(res.data.message);
        }
      });
    },
    handleEdit: function (record) {
      this.$refs.modalForm.edit(record);
      this.$refs.modalForm.title = "Modifier";
      this.$refs.modalForm.disableSubmit = false;
      if(this.btnEnableList.indexOf(1)===-1) {
        this.$refs.modalForm.isReadOnly = true
      }
    },
    btnSetUser(record) {
      this.$refs.depotUserModal.edit(record)
      this.$refs.depotUserModal.title = "Attribuer un utilisateur à : " + record.name
      this.$refs.depotUserModal.disableSubmit = false
    }
  }
}
</script>
<style scoped>
@import '~@assets/less/common.less';
</style>
