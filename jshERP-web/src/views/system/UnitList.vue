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
                <a-form-item label="Nom de l'unité" :labelCol="labelCol" :wrapperCol="wrapperCol">
                  <a-input
                    placeholder="Veuillez saisir le nom de l'unité pour rechercher"
                    v-model="queryParam.name"
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
            <template slot="customRenderFlag" slot-scope="enabled">
              <a-tag v-if="enabled" color="green">Activé</a-tag>
              <a-tag v-if="!enabled" color="orange">Désactivé</a-tag>
            </template>
          </a-table>
        </div>
        <!-- Zone du tableau - fin -->
        <!-- Zone du formulaire -->
        <unit-modal ref="modalForm" @ok="modalFormOk"></unit-modal>
      </a-card>
    </a-col>
  </a-row>
</template>
<!-- b y 7 5 2 7  1 8 9 2 0 -->
<script>
import UnitModal from './modules/UnitModal'
import { JeecgListMixin } from '@/mixins/JeecgListMixin'
import JDate from '@/components/jeecg/JDate'
export default {
  name: "UnitList",
  mixins:[JeecgListMixin],
  components: {
    UnitModal,
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
      queryParam: {name:'',type:''},
      urlPath: '/system/unit',
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
          width:100,
          align:"center",
          scopedSlots: { customRender: 'action' },
        },
        { title: "Nom de l'unité", align:"left", dataIndex: 'name', width:200 },
        { title: 'Unité de base', align:"left", dataIndex: 'basicUnit', width:80 },
        { title: 'Unité secondaire', align:"left", dataIndex: 'otherUnit', width:100,
          customRender:function (t,r,index) {
            if (r) {
              return r.otherUnit + '=' + r.ratio + r.basicUnit;
            }
          }
        },
        { title: 'Unité secondaire 2', align:"left", dataIndex: 'otherUnitTwo', width:100,
          customRender:function (t,r,index) {
            if (r) {
              if(r.otherUnitTwo) {
                return r.otherUnitTwo + '=' + r.ratioTwo + r.basicUnit;
              }
            }
          }
        },
        { title: 'Unité secondaire 3', align:"left", dataIndex: 'otherUnitThree', width:100,
          customRender:function (t,r,index) {
            if (r) {
              if(r.otherUnitThree) {
                return r.otherUnitThree + '=' + r.ratioThree + r.basicUnit;
              }
            }
          }
        },
        { title: 'État',dataIndex: 'enabled',width:60,align:"center",
          scopedSlots: { customRender: 'customRenderFlag' }
        }
      ],
      url: {
        list: "/unit/list",
        delete: "/unit/delete",
        deleteBatch: "/unit/deleteBatch",
        batchSetStatusUrl: "/unit/batchSetStatus"
      }
    }
  },
  computed: {

  },
  methods: {
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
