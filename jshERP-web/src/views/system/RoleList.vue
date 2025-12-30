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
                <a-form-item label="Nom du rôle" :labelCol="labelCol" :wrapperCol="wrapperCol">
                  <a-input
                    placeholder="Veuillez saisir le nom du rôle pour rechercher"
                    v-model="queryParam.name"
                  ></a-input>
                </a-form-item>
              </a-col>
              <a-col :md="6" :sm="24">
                <a-form-item label="Remarque" :labelCol="labelCol" :wrapperCol="wrapperCol">
                  <a-input
                    placeholder="Veuillez saisir la remarque pour rechercher"
                    v-model="queryParam.description"
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
              <a @click="handleSetFunction(record)">Attribuer des fonctions</a>
              <a-divider type="vertical" />
              <a @click="handleSetPushBtn(record.id, record.name)">Attribuer des boutons</a>
              <a-divider type="vertical" />
              <a @click="handleEdit(record)">Modifier</a>
              <a-divider v-if="btnEnableList.indexOf(1) > -1" type="vertical" />
              <a-popconfirm
                v-if="btnEnableList.indexOf(1) > -1"
                title="Êtes-vous sûr de vouloir supprimer ?"
                @confirm="() => handleDelete(record.id)"
              >
                <a>Supprimer</a>
              </a-popconfirm>
              <a-modal v-model="roleModalVisible" title="Avertissement" @ok="handleRoleTip(record)">
                <p>
                  L'enregistrement du rôle a réussi ! Voulez-vous continuer avec <b>l'attribution de fonctions</b> ?
                </p>
              </a-modal>
            </span>
            <span slot="typeTitle">
              Type de données
              <a-tooltip
                title="1. Toutes les données - Les utilisateurs avec ce rôle peuvent voir tous les documents ; 2. Données de l'organisation - Les utilisateurs avec ce rôle peuvent voir tous les documents de leur organisation ; 3. Données personnelles - Les utilisateurs avec ce rôle ne peuvent voir que leurs propres documents. Les documents désignent les entrées d'achat, les sorties de vente, etc."
              >
                <a-icon type="question-circle" />
              </a-tooltip>
            </span>
            <span slot="priceLimitTitle">
              Masquage des prix
              <a-tooltip
                title="Le masquage des prix supporte la sélection multiple, principalement utilisé pour contrôler le masquage des prix sur la page d'accueil et les documents"
              >
                <a-icon type="question-circle" />
              </a-tooltip>
            </span>
            <!-- Modèle de rendu d'état -->
            <template slot="customRenderFlag" slot-scope="enabled">
              <a-tag v-if="enabled" color="green">Activé</a-tag>
              <a-tag v-if="!enabled" color="orange">Désactivé</a-tag>
            </template>
          </a-table>
        </div>
        <!-- Zone du tableau - fin -->
        <!-- Zone du formulaire -->
        <role-modal ref="modalForm" @ok="roleModalFormOk"></role-modal>
        <role-function-modal ref="roleFunctionModal" @ok="roleFunctionModalFormOk"></role-function-modal>
        <role-push-btn-modal ref="rolePushBtnModal" @ok="modalFormOk"></role-push-btn-modal>
        <a-modal v-model="roleFunctionModalVisible" title="Avertissement" @ok="handleRoleFunctionTip">
          <p>L'attribution de fonctions a réussi ! Voulez-vous continuer avec <b>l'attribution de boutons</b> ?</p>
        </a-modal>
      </a-card>
    </a-col>
  </a-row>
</template>
<!-- f r o m 7 5  2 7 1  8 9 2 0 -->
<script>
import RoleModal from './modules/RoleModal'
import RoleFunctionModal from './modules/RoleFunctionModal'
import RolePushBtnModal from './modules/RolePushBtnModal'
import { JeecgListMixin } from '@/mixins/JeecgListMixin'
import JDate from '@/components/jeecg/JDate'
export default {
  name: 'RoleList',
  mixins: [JeecgListMixin],
  components: {
    RoleModal,
    RoleFunctionModal,
    RolePushBtnModal,
    JDate,
  },
  data() {
    return {
      description: 'Page de gestion des rôles',
      roleModalVisible: false,
      roleFunctionModalVisible: false,
      currentRoleId: '',
      labelCol: {
        span: 5,
      },
      wrapperCol: {
        span: 18,
        offset: 1,
      },
      // Conditions de recherche
      queryParam: {
        name: '',
        description: '',
      },
      urlPath: '/system/role',
      // En-têtes de colonnes
      columns: [
        {
          title: '#',
          dataIndex: '',
          key: 'rowIndex',
          width: 40,
          align: 'center',
          customRender: function (t, r, index) {
            return parseInt(index) + 1
          },
        },
        {
          title: 'Opération',
          dataIndex: 'action',
          align: 'center',
          width: 180,
          scopedSlots: { customRender: 'action' },
        },
        {
          title: 'Nom du rôle',
          align: 'left',
          dataIndex: 'name',
          width: 120,
        },
        {
          align: 'left',
          dataIndex: 'type',
          width: 100,
          slots: { title: 'typeTitle' },
        },
        {
          align: 'left',
          dataIndex: 'priceLimitStr',
          width: 300,
          slots: { title: 'priceLimitTitle' },
        },
        {
          title: 'Remarque',
          align: 'left',
          dataIndex: 'description',
          width: 150,
        },
        { title: 'Tri', align: 'left', dataIndex: 'sort', width: 50 },
        {
          title: 'État',
          dataIndex: 'enabled',
          width: 60,
          align: 'center',
          scopedSlots: { customRender: 'customRenderFlag' },
        },
      ],
      url: {
        list: '/role/list',
        delete: '/role/delete',
        deleteBatch: '/role/deleteBatch',
        batchSetStatusUrl: '/role/batchSetStatus',
      },
    }
  },
  computed: {
    importExcelUrl: function () {
      return `${window._CONFIG['domianURL']}/${this.url.importExcelUrl}`
    },
  },
  methods: {
    handleSetFunction(record) {
      this.$refs.roleFunctionModal.edit(record)
      this.$refs.roleFunctionModal.title =
        'Attribuer des fonctions à : ' +
        record.name +
        " [Après attribution, veuillez continuer avec l'attribution de boutons]"
      this.$refs.roleFunctionModal.disableSubmit = false
    },
    handleSetPushBtn(roleId, roleName) {
      this.$refs.rolePushBtnModal.edit(roleId)
      this.$refs.rolePushBtnModal.title = 'Attribuer des boutons à : ' + roleName
      this.$refs.rolePushBtnModal.disableSubmit = false
    },
    roleModalFormOk() {
      // Recharger la liste
      this.loadData()
      this.roleModalVisible = true
    },
    roleFunctionModalFormOk(id) {
      // Recharger la liste
      this.loadData()
      this.roleFunctionModalVisible = true
      this.currentRoleId = id
    },
    handleRoleTip(record) {
      if (record) {
        this.roleModalVisible = false
        this.handleSetFunction(record)
      }
    },
    handleRoleFunctionTip() {
      if (this.currentRoleId) {
        this.roleFunctionModalVisible = false
        let roleName = ''
        for (let i = 0; i < this.dataSource.length; i++) {
          if (this.dataSource[i].id == this.currentRoleId) {
            roleName = this.dataSource[i].name
          }
        }
        this.handleSetPushBtn(this.currentRoleId, roleName)
      }
    },
    handleAdd: function () {
      this.$refs.modalForm.add()
      this.$refs.modalForm.title = "Ajouter [Après enregistrement, veuillez continuer avec l'attribution de fonctions]"
      this.$refs.modalForm.disableSubmit = false
    },
    handleEdit: function (record) {
      this.$refs.modalForm.edit(record)
      this.$refs.modalForm.title = "Modifier [Après enregistrement, veuillez continuer avec l'attribution de fonctions]"
      this.$refs.modalForm.disableSubmit = false
      if (this.btnEnableList.indexOf(1) === -1) {
        this.$refs.modalForm.isReadOnly = true
      }
    },
  },
}
</script>
<style scoped>
@import '~@assets/less/common.less';
</style>
