<!-- from 7 5 2 7 1 8 9 2 0 -->
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
        <material-property-modal ref="modalForm" @ok="modalFormOk"></material-property-modal>
      </a-card>
    </a-col>
  </a-row>
</template>
<script>
import MaterialPropertyModal from './modules/MaterialPropertyModal'
import { JeecgListMixin } from '@/mixins/JeecgListMixin'
import JDate from '@/components/jeecg/JDate'
import { getAction } from '@/api/manage'
import Vue from 'vue'
export default {
  name: 'MaterialPropertyList',
  mixins: [JeecgListMixin],
  components: {
    MaterialPropertyModal,
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
      urlPath: '/material/material_property',
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
          width: 100,
          align: 'center',
          scopedSlots: { customRender: 'action' },
        },
        { title: 'Nom', dataIndex: 'nativeName', width: 100 },
        { title: 'Alias', dataIndex: 'anotherName', width: 100 },
      ],
      url: {
        list: '/materialProperty/list',
        delete: '/materialProperty/delete',
        deleteBatch: '/materialProperty/deleteBatch',
      },
    }
  },
  computed: {},
  methods: {
    loadData(arg) {
      let params = this.getQueryParams() // Conditions de recherche
      this.loading = true
      getAction(this.url.list, params).then((res) => {
        if (res.code === 200) {
          this.dataSource = res.data.rows
          this.ipagination.total = res.data.total
          Vue.ls.set('materialPropertyList', res.data.rows, 7 * 24 * 60 * 60 * 1000)
        } else if (res.code === 510) {
          this.$message.warning(res.data)
        } else {
          this.$message.warning(res.data.message)
        }
        this.loading = false
        this.onClearSelected()
      })
    },
  },
}
</script>
<style scoped>
@import '~@assets/less/common.less';
</style>
