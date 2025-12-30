<template>
  <a-row :gutter="24">
    <a-col :md="24">
      <a-card :style="cardStyle" :bordered="false">
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
            @change="handleTableChange"
          >
            <span slot="action" slot-scope="text, record">
              <a @click="handleEdit(record)">Modifier</a>
            </span>
          </a-table>
        </div>
        <!-- Zone du tableau - fin -->
        <!-- Zone du formulaire -->
        <platform-config-modal ref="modalForm" @ok="modalFormOk"></platform-config-modal>
      </a-card>
    </a-col>
  </a-row>
</template>
<!-- f r o m 7 5  2 7 1  8 9 2 0 -->
<script>
import PlatformConfigModal from './modules/PlatformConfigModal'
import { JeecgListMixin } from '@/mixins/JeecgListMixin'
export default {
  name: 'PlatformConfigList',
  mixins: [JeecgListMixin],
  components: {
    PlatformConfigModal,
  },
  data() {
    return {
      currentRoleId: '',
      labelCol: {
        span: 5,
      },
      wrapperCol: {
        span: 18,
        offset: 1,
      },
      // Conditions de recherche
      queryParam: { platformKey: '' },
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
          width: 100,
          scopedSlots: { customRender: 'action' },
        },
        {
          title: 'Nom de configuration',
          dataIndex: 'platformKeyInfo',
          width: 100,
        },
        {
          title: 'Valeur de configuration',
          dataIndex: 'platformValue',
          width: 500,
        },
      ],
      url: {
        list: '/platformConfig/list',
        delete: '/platformConfig/delete',
        deleteBatch: '/platformConfig/deleteBatch',
      },
    }
  },
  methods: {
    handleEdit: function (record) {
      this.$refs.modalForm.edit(record)
      this.$refs.modalForm.title = 'Modifier'
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
