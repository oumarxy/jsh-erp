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
                <a-form-item label="Nom" :labelCol="labelCol" :wrapperCol="wrapperCol">
                  <a-input placeholder="Veuillez saisir le nom pour rechercher" v-model="queryParam.name"></a-input>
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
          <a-button @click="handleAdd" type="primary" icon="plus">Ajouter</a-button>
          <a-button @click="batchDel" icon="delete">Supprimer</a-button>
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
              <a @click="handleEdit(record)">Modifier</a>
              <a-divider type="vertical" />
              <a-popconfirm title="Êtes-vous sûr de vouloir supprimer ?" @confirm="() => handleDelete(record.id)">
                <a>Supprimer</a>
              </a-popconfirm>
            </span>
            <!-- Modèle de rendu d'état -->
            <template slot="customRenderFlag" slot-scope="enabled">
              <a-tag v-if="enabled == 1" color="green">Activé</a-tag>
              <a-tag v-if="enabled == 0" color="orange">Désactivé</a-tag>
            </template>
          </a-table>
        </div>
        <!-- Zone du tableau - fin -->
        <!-- Zone du formulaire -->
        <function-modal ref="modalForm" @ok="modalFormOk"></function-modal>
      </a-card>
    </a-col>
  </a-row>
</template>
<script>
import FunctionModal from './modules/FunctionModal'
import { JeecgListMixin } from '@/mixins/JeecgListMixin'
import JDate from '@/components/jeecg/JDate'
export default {
  name: 'FunctionList',
  mixins: [JeecgListMixin],
  components: {
    FunctionModal,
    JDate,
  },
  data() {
    return {
      labelCol: {
        span: 5,
      },
      wrapperCol: {
        span: 18,
        offset: 1,
      },
      // Conditions de recherche
      queryParam: { name: '', type: '' },
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
          width: 150,
          align: 'center',
          scopedSlots: { customRender: 'action' },
        },
        { title: 'Numéro ', dataIndex: 'number', width: 80 },
        { title: 'Nom', dataIndex: 'name', width: 120, ellipsis: true },
        { title: 'Numéro parent', dataIndex: 'parentNumber', width: 80 },
        { title: 'Nom parent', dataIndex: 'parentName', width: 120, ellipsis: true },
        { title: 'Lien', dataIndex: 'url', width: 250, ellipsis: true },
        { title: 'Composant', dataIndex: 'component', width: 250, ellipsis: true },
        { title: 'Tri', dataIndex: 'sort', width: 60 },
        {
          title: 'Activé',
          dataIndex: 'enabled',
          width: 80,
          align: 'center',
          scopedSlots: { customRender: 'customRenderFlag' },
        },
        { title: 'Icône', dataIndex: 'icon', width: 120 },
      ],
      url: {
        list: '/function/list',
        delete: '/function/delete',
        deleteBatch: '/function/deleteBatch',
      },
    }
  },
  computed: {},
  methods: {},
}
</script>
<style scoped>
@import '~@assets/less/common.less';
</style>
