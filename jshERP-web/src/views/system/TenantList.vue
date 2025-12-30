<template>
  <a-row :gutter="24">
    <a-col :md="24">
      <a-card :style="cardStyle" :bordered="false">
        <!-- Zone de recherche -->
        <div class="table-page-search-wrapper">
          <a-form layout="inline" @keyup.enter.native="searchQuery">
            <a-row :gutter="24">
              <a-col :md="6" :sm="24">
                <a-form-item label="Nom de connexion" :labelCol="labelCol" :wrapperCol="wrapperCol">
                  <a-input
                    placeholder="Saisir le nom de connexion pour une recherche floue"
                    v-model="queryParam.loginName"
                  ></a-input>
                </a-form-item>
              </a-col>
              <a-col :md="6" :sm="24">
                <a-form-item label="Type de locataire" :labelCol="labelCol" :wrapperCol="wrapperCol">
                  <a-select v-model="queryParam.type" placeholder="Veuillez sélectionner le type de locataire">
                    <a-select-option value="0">Locataire d'essai</a-select-option>
                    <a-select-option value="1">Locataire payant</a-select-option>
                  </a-select>
                </a-form-item>
              </a-col>
              <a-col :md="6" :sm="24">
                <a-form-item label="État du locataire" :labelCol="labelCol" :wrapperCol="wrapperCol">
                  <a-select v-model="queryParam.enabled" placeholder="Veuillez sélectionner l'état">
                    <a-select-option value="1">Activé</a-select-option>
                    <a-select-option value="0">Désactivé</a-select-option>
                  </a-select>
                </a-form-item>
              </a-col>
              <a-col :md="6" :sm="24">
                <span style="float: left; overflow: hidden" class="table-page-search-submitButtons">
                  <a-button type="primary" @click="searchQuery">Rechercher</a-button>
                  <a-button style="margin-left: 8px" @click="searchReset">Réinitialiser</a-button>
                  <a @click="handleToggleSearch" style="margin-left: 8px">
                    {{ toggleSearchStatus ? 'Masquer' : 'Développer' }}
                    <a-icon :type="toggleSearchStatus ? 'up' : 'down'" />
                  </a>
                </span>
              </a-col>
            </a-row>
            <template v-if="toggleSearchStatus">
              <a-row :gutter="24">
                <a-col :md="6" :sm="24">
                  <a-form-item label="Remarque" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-input v-model="queryParam.remark" placeholder="Veuillez saisir la remarque"></a-input>
                  </a-form-item>
                </a-col>
              </a-row>
            </template>
          </a-form>
        </div>
        <!-- Zone des boutons d'action -->
        <div class="table-operator" style="border-top: 5px">
          <a-button @click="handleAdd" type="primary" icon="plus">Ajouter</a-button>
          <a-button @click="batchSetStatus(1)" icon="check-square">Activer</a-button>
          <a-button @click="batchSetStatus(0)" icon="close-square">Désactiver</a-button>
        </div>
        <!-- Zone du tableau - début -->
        <div>
          <a-table
            ref="table"
            bordered
            size="middle"
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
              <a @click="handleEdit(record)">Modifier</a>
            </span>
            <!-- Modèle de rendu d'état -->
            <template slot="customRenderType" slot-scope="type">
              <a-tag v-if="type == 0">Locataire d'essai</a-tag>
              <a-tag v-if="type == 1" color="green">Locataire payant</a-tag>
            </template>
            <template slot="customRenderEnabled" slot-scope="enabled">
              <a-tag v-if="enabled" color="green">Activé</a-tag>
              <a-tag v-if="!enabled" color="orange">Désactivé</a-tag>
            </template>
          </a-table>
        </div>
        <!-- Zone du tableau - fin -->
        <tenant-modal ref="modalForm" @ok="modalFormOk"></tenant-modal>
      </a-card>
    </a-col>
  </a-row>
</template>
<!-- b y 7 5 2 7  1 8 9 2 0 -->
<script>
import TenantModal from './modules/TenantModal'
import {JeecgListMixin} from '@/mixins/JeecgListMixin'
import JInput from '@/components/jeecg/JInput'
import { getTenantRoleList } from '@/api/api'
export default {
  name: "TenantList",
  mixins: [JeecgListMixin],
  components: {
    TenantModal,
    JInput
  },
  data() {
    return {
      labelCol: {
        span: 5
      },
      wrapperCol: {
        span: 18,
        offset: 1
      },
      queryParam: {
        loginName: '',
        roleId: '',
        type: '',
        enabled: '',
        remark: ''
      },
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
          scopedSlots: {customRender: 'action'},
          align: "center",
          width: 100
        },
        { title: 'Nom de connexion', dataIndex: 'loginName', width: 100, align: "center"},
        { title: "Nombre d'utilisateurs", dataIndex: 'userCount', width: 60, align: "center"},
        { title: "Limite du nombre d'utilisateurs", dataIndex: 'userNumLimit', width: 80, align: "center"},
        { title: 'Rôle du locataire', dataIndex: 'roleName', width: 80, align: "center"},
        { title: 'Type de locataire',dataIndex: 'type',width:60,align:"center",
          scopedSlots: { customRender: 'customRenderType' }
        },
        { title: 'État du locataire',dataIndex: 'enabled',width:60,align:"center",
          scopedSlots: { customRender: 'customRenderEnabled' }
        },
        { title: 'Date de création', dataIndex: 'createTimeStr', width: 100, align: "center"},
        { title: "Date d'expiration", dataIndex: 'expireTimeStr', width: 100, align: "center"},
        { title: 'Remarque', dataIndex: 'remark', width: 200, align: "center", ellipsis:true}
      ],
      url: {
        list: "/tenant/list",
        batchSetStatusUrl: "/tenant/batchSetStatus"
      },
    }
  },
  created () {
  },
  methods: {
  }
}
</script>
<style scoped>
@import '~@assets/less/common.less';
</style>
