<!-- by 7527_18920 -->
<template>
  <a-row :gutter="24">
    <a-col :md="24">
      <a-card :style="cardStyle" :bordered="false">
        <!-- Zone de recherche -->
        <div class="table-page-search-wrapper">
          <!-- Zone de recherche -->
          <a-form layout="inline" @keyup.enter.native="searchQuery">
            <a-row :gutter="24">
              <a-col :md="6" :sm="8">
                <a-form-item label="Nom de l'attribut" :labelCol="{ span: 5 }" :wrapperCol="{ span: 18, offset: 1 }">
                  <a-input
                    placeholder="Veuillez saisir le nom de l'attribut pour rechercher"
                    v-model="queryParam.attributeName"
                  ></a-input>
                </a-form-item>
              </a-col>
              <a-col :md="6" :sm="8">
                <a-form-item label="Valeur de l'attribut" :labelCol="{ span: 5 }" :wrapperCol="{ span: 18, offset: 1 }">
                  <a-input
                    placeholder="Veuillez saisir la valeur de l'attribut pour rechercher"
                    v-model="queryParam.attributeValue"
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
            :loading="loading"
            :rowSelection="{ selectedRowKeys: selectedRowKeys, onChange: onSelectChange }"
            @change="handleTableChange"
          >
            <span slot="action" slot-scope="text, record">
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
            <template slot="customRenderAttributeValue" slot-scope="attributeValue">
              <a-tag v-for="(item, index) in getTagArr(attributeValue)" color="blue">{{ item }}</a-tag>
            </template>
          </a-table>
        </div>
        <!-- Zone du tableau - fin -->
        <!-- Zone du formulaire -->
        <material-attribute-modal ref="modalForm" @ok="modalFormOk"></material-attribute-modal>
      </a-card>
    </a-col>
  </a-row>
</template>
<script>
import MaterialAttributeModal from './modules/MaterialAttributeModal'
import { JeecgListMixin } from '@/mixins/JeecgListMixin'
import JDate from '@/components/jeecg/JDate'
export default {
  name: "MaterialAttributeList",
  mixins:[JeecgListMixin],
  components: {
    MaterialAttributeModal,
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
      queryParam: {
        attributeName:'',
        attributeValue:''
      },
      urlPath: '/material/material_attribute',
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
          width: 100,
          align:"center",
          scopedSlots: { customRender: 'action' },
        },
        {title: "Nom de l'attribut", dataIndex: 'attributeName', width: 150},
        {title: "Valeur de l'attribut", dataIndex: 'attributeValue', width: 750,
          scopedSlots: { customRender: 'customRenderAttributeValue' }
        }
      ],
      url: {
        list: "/materialAttribute/list",
        delete: "/materialAttribute/delete",
        deleteBatch: "/materialAttribute/deleteBatch"
      }
    }
  },
  computed: {

  },
  methods: {
    getTagArr(attributeValue) {
      return attributeValue.split('|')
    },
    handleEdit: function (record) {
      this.$refs.modalForm.edit(record);
      this.$refs.modalForm.title = "Modifier";
      this.$refs.modalForm.disableSubmit = false;
      if(this.btnEnableList.indexOf(1)===-1) {
        this.$refs.modalForm.isReadOnly = true
      }
    }
  }
}
</script>
<style scoped>
@import '~@assets/less/common.less';
</style>
