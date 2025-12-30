<template>
  <div ref="container">
    <a-modal
      :title="title"
      :width="800"
      :visible="visible"
      :getContainer="() => $refs.container"
      :maskStyle="{ top: '93px', left: '154px' }"
      :wrapClassName="wrapClassNameInfo()"
      :mask="isDesktop()"
      :maskClosable="false"
      @cancel="handleCancel"
      cancelText="Fermer"
      style="top: 100px; height: 80%"
    >
      <template slot="footer">
        <a-button key="back" @click="handleCancel">Annuler (ESC)</a-button>
      </template>
      <!-- Zone du tableau - début -->
      <a-table
        bordered
        ref="table"
        size="middle"
        rowKey="id"
        :columns="columns"
        :dataSource="dataSource"
        :components="handleDrag(columns)"
        :pagination="ipagination"
        :loading="loading"
        @change="handleTableChange"
      >
      </a-table>
      <!-- Zone du tableau - fin -->
    </a-modal>
  </div>
</template>
<script>
import { JeecgListMixin } from '@/mixins/JeecgListMixin'
import JEllipsis from '@/components/jeecg/JEllipsis'
import { mixinDevice } from '@/utils/mixin'

export default {
  name: "MaterialDepotStockList",
  mixins:[JeecgListMixin, mixinDevice],
  components: {
    JEllipsis
  },
  data () {
    return {
      title:"Opération",
      visible: false,
      disableMixinCreated: true,
      toFromType: '',
      currentMaterialId: '',
      // Conditions de recherche
      queryParam: {
        depotIds: '',
        materialId:'',
      },
      ipagination:{
        pageSizeOptions: ['10', '20', '30', '100', '200']
      },
      tabKey: "1",
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
        { title: "Nom de l'entrepôt", dataIndex: 'depotName', width: 200},
        { title: 'Quantité en stock', dataIndex: 'currentNumber', width: 100},
        { title: 'Prix de revient', dataIndex: 'unitPrice', width: 100},
        { title: 'Montant du stock', dataIndex: 'allPrice', width: 100}
      ],
      labelCol: {
        xs: { span: 1 },
        sm: { span: 2 },
      },
      wrapperCol: {
        xs: { span: 10 },
        sm: { span: 16 },
      },
      url: {
        list: "/material/getMaterialDepotStock"
      }
    }
  },
  created() {
  },
  methods: {
    getQueryParams() {
      let param = Object.assign({}, this.queryParam, this.isorter)
      param.field = this.getQueryField()
      param.materialId = this.currentMaterialId
      param.currentPage = this.ipagination.current
      param.pageSize = this.ipagination.pageSize
      return param
    },
    show(record, depotIds) {
      this.model = Object.assign({}, record);
      this.currentMaterialId = record.id
      this.visible = true;
      this.queryParam.depotIds = depotIds
      this.queryParam.materialId = record.id
      this.loadData(1)
    },
    close () {
      this.$emit('close');
      this.visible = false;
    },
    handleCancel () {
      this.close()
    },
    onDateOk(value) {
      console.log(value);
    }
  }
}
</script>
<style scoped>
@import '~@assets/less/common.less';
</style>
