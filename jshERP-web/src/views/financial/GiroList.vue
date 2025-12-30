<!-- by j i sheng h u a -->
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
                <a-form-item label="Numéro de document" :labelCol="labelCol" :wrapperCol="wrapperCol">
                  <a-input placeholder="Veuillez saisir le numéro de document" v-model="queryParam.billNo"></a-input>
                </a-form-item>
              </a-col>
              <a-col :md="6" :sm="24">
                <a-form-item label="Date du document" :labelCol="labelCol" :wrapperCol="wrapperCol">
                  <a-range-picker
                    style="width:100%"
                    v-model="queryParam.createTimeRange"
                    format="YYYY-MM-DD"
                    :placeholder="['Heure de début', 'Heure de fin']"
                    @change="onDateChange"
                    @ok="onDateOk"
                  />
                </a-form-item>
              </a-col>
              <a-col :md="6" :sm="24">
                <a-form-item label="Opérateur" :labelCol="labelCol" :wrapperCol="wrapperCol">
                  <a-select placeholder="Veuillez sélectionner l'opérateur" showSearch allow-clear optionFilterProp="children" v-model="queryParam.creator">
                    <a-select-option v-for="(item,index) in userList" :key="index" :value="item.id">
                      {{ item.userName }}
                    </a-select-option>
                  </a-select>
                </a-form-item>
              </a-col>
              <span style="float: left;overflow: hidden;" class="table-page-search-submitButtons">
                <a-col :md="6" :sm="24">
                  <a-button type="primary" @click="searchQuery">Rechercher</a-button>
                  <a-button style="margin-left: 8px" @click="searchReset">Réinitialiser</a-button>
                  <a @click="handleToggleSearch" style="margin-left: 8px">
                    {{ toggleSearchStatus ? 'Masquer' : 'Développer' }}
                    <a-icon :type="toggleSearchStatus ? 'up' : 'down'"/>
                  </a>
                </a-col>
              </span>
            </a-row>
            <template v-if="toggleSearchStatus">
              <a-row :gutter="24">
                <a-col :md="6" :sm="24">
                  <a-form-item label="Personnel financier" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-select placeholder="Veuillez sélectionner le personnel financier" showSearch allow-clear optionFilterProp="children" v-model="queryParam.handsPersonId">
                      <a-select-option v-for="(item,index) in personList" :key="index" :value="item.id">
                        {{ item.name }}
                      </a-select-option>
                    </a-select>
                  </a-form-item>
                </a-col>
                <a-col :md="6" :sm="24">
                  <a-form-item label="Compte de paiement" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-select placeholder="Veuillez sélectionner le compte de paiement" showSearch allow-clear optionFilterProp="children" v-model="queryParam.accountId">
                      <a-select-option v-for="(item,index) in accountList" :key="index" :value="item.id">
                        {{ item.name }}
                      </a-select-option>
                    </a-select>
                  </a-form-item>
                </a-col>
                <a-col :md="6" :sm="24">
                  <a-form-item label="État du document" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-select placeholder="Veuillez sélectionner l'état du document" allow-clear v-model="queryParam.status">
                      <a-select-option value="0">Non audité</a-select-option>
                      <a-select-option value="9" v-if="!checkFlag">En cours d'audit</a-select-option>
                      <a-select-option value="1">Audité</a-select-option>
                    </a-select>
                  </a-form-item>
                </a-col>
                <a-col :md="6" :sm="24">
                  <a-form-item label="Remarque du document" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-input placeholder="Veuillez saisir la remarque du document" v-model="queryParam.remark"></a-input>
                  </a-form-item>
                </a-col>
              </a-row>
            </template>
          </a-form>
        </div>
        <!-- Zone des boutons d'action -->
        <div class="table-operator"  style="margin-top: 5px">
          <a-button v-if="btnEnableList.indexOf(1)>-1" @click="myHandleAdd" type="primary" icon="plus">Ajouter</a-button>
          <a-button v-if="btnEnableList.indexOf(1)>-1" icon="delete" @click="batchDel">Supprimer</a-button>
          <a-button v-if="checkFlag && btnEnableList.indexOf(2)>-1" icon="check" @click="batchSetStatus(1)">Auditer</a-button>
          <a-button v-if="checkFlag && btnEnableList.indexOf(7)>-1" icon="stop" @click="batchSetStatus(0)">Désauditer</a-button>
          <a-button v-if="isShowExcel && btnEnableList.indexOf(3)>-1" icon="download" @click="handleExport">Exporter</a-button>
          <a-tooltip placement="left" title="Virement : dans ce système, un virement fait référence au transfert d'un compte bancaire de dépôt vers un autre compte bancaire de dépôt." slot="action">
            <a-icon v-if="btnEnableList.indexOf(1)>-1" type="question-circle" style="font-size:20px;float:right;" />
          </a-tooltip>
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
            :components="handleDrag(columns)"
            :pagination="ipagination"
            :scroll="scroll"
            :loading="loading"
            :rowSelection="{selectedRowKeys: selectedRowKeys, onChange: onSelectChange}"
            @change="handleTableChange">
            <span slot="action" slot-scope="text, record">
              <a @click="myHandleDetail(record, '转账', prefixNo)">Voir</a>
              <a-divider v-if="btnEnableList.indexOf(1)>-1" type="vertical" />
              <a v-if="btnEnableList.indexOf(1)>-1" @click="myHandleEdit(record)">Modifier</a>
              <a-divider v-if="btnEnableList.indexOf(1)>-1" type="vertical" />
              <a-popconfirm v-if="btnEnableList.indexOf(1)>-1" title="Êtes-vous sûr de vouloir supprimer ?" @confirm="() => myHandleDelete(record)">
                <a>Supprimer</a>
              </a-popconfirm>
            </span>
            <template slot="customRenderStatus" slot-scope="status">
              <a-tag v-if="status == '0'" color="red">Non audité</a-tag>
              <a-tag v-if="status == '1'" color="green">Audité</a-tag>
              <a-tag v-if="status == '9'" color="orange">En cours d'audit</a-tag>
            </template>
          </a-table>
        </div>
        <!-- Zone du tableau - fin -->
        <!-- Zone du formulaire -->
        <giro-modal ref="modalForm" @ok="modalFormOk" @close="modalFormClose"></giro-modal>
        <financial-detail ref="modalDetail" @ok="modalFormOk" @close="modalFormClose"></financial-detail>
        <bill-excel-iframe ref="billExcelIframe" @ok="modalFormOk" @close="modalFormClose"></bill-excel-iframe>
      </a-card>
    </a-col>
  </a-row>
</template>
<script>
  import GiroModal from './modules/GiroModal'
  import FinancialDetail from './dialog/FinancialDetail'
  import BillExcelIframe from '@/components/tools/BillExcelIframe'
  import { JeecgListMixin } from '@/mixins/JeecgListMixin'
  import { FinancialListMixin } from './mixins/FinancialListMixin'
  import JDate from '@/components/jeecg/JDate'
  import Vue from 'vue'
  export default {
    name: "GiroList",
    mixins:[JeecgListMixin, FinancialListMixin],
    components: {
      GiroModal,
      FinancialDetail,
      BillExcelIframe,
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
          billNo: "",
          searchMaterial: "",
          type: "转账",
          creator: undefined,
          handsPersonId: undefined,
          accountId: undefined,
          status: undefined,
          remark: ""
        },
        prefixNo: 'ZZ',
        urlPath: '/financial/giro',
        // En-têtes de colonnes
        columns: [
          {
            title: 'Opération',
            dataIndex: 'action',
            width:200,
            align:"center",
            scopedSlots: { customRender: 'action' },
          },
          { title: 'Numéro de document', dataIndex: 'billNo',width:160},
          { title: 'Date du document', dataIndex: 'billTimeStr',width:160},
          { title: 'Opérateur', dataIndex: 'userName',width:100, ellipsis:true},
          { title: 'Personnel financier', dataIndex: 'handsPersonName',width:100},
          { title: 'Compte de paiement', dataIndex: 'accountName',width:100, ellipsis:true},
          { title: 'Montant réellement payé', dataIndex: 'changeAmount',width:80},
          { title: 'Remarque', dataIndex: 'remark',width:200},
          { title: 'État', dataIndex: 'status', width: 80, align: "center",
            scopedSlots: { customRender: 'customRenderStatus' }
          }
        ],
        url: {
          list: "/accountHead/list",
          delete: "/accountHead/delete",
          deleteBatch: "/accountHead/deleteBatch",
          batchSetStatusUrl: "/accountHead/batchSetStatus"
        }
      }
    },
    computed: {
    },
    created () {
      this.initSystemConfig()
      this.initUser()
      this.initPerson()
      this.initAccount()
    },
    methods: {
    }
  }
</script>
<style scoped>
  @import '~@assets/less/common.less'
</style>