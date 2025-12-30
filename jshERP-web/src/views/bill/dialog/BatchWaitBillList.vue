<template>
  <div ref="container">
    <a-modal
      :title="title"
      :width="1300"
      :visible="visible"
      :getContainer="() => $refs.container"
      :maskStyle="{'top':'93px','left':'154px'}"
      :wrapClassName="wrapClassNameInfo()"
      :mask="isDesktop()"
      :maskClosable="false"
      @cancel="handleCancel"
      style="top:20px;height: 95%;">
      <template slot="footer">
        <a-button key="back" @click="handleCancel">Annuler</a-button>
      </template>
      <!-- Zone de recherche -->
      <div class="table-page-search-wrapper">
        <!-- Zone de recherche -->
        <a-form layout="inline" @keyup.enter.native="searchQuery">
          <a-row :gutter="24">
            <a-col :md="6" :sm="24">
              <a-form-item label="Numéro de document" :labelCol="{span: 5}" :wrapperCol="{span: 18, offset: 1}">
                <a-input placeholder="Veuillez saisir le numéro de document pour rechercher" v-model="queryParam.number"></a-input>
              </a-form-item>
            </a-col>
            <a-col :md="6" :sm="24">
              <a-form-item label="Informations produit" :labelCol="{span: 5}" :wrapperCol="{span: 18, offset: 1}">
                <a-input placeholder="Code-barres|Nom|Spécification|Modèle" v-model="queryParam.materialParam"></a-input>
              </a-form-item>
            </a-col>
            <a-col :md="6" :sm="24">
              <a-form-item label="Date du document" :labelCol="labelCol" :wrapperCol="wrapperCol">
                <a-range-picker
                  style="width: 100%"
                  v-model="queryParam.createTimeRange"
                  format="YYYY-MM-DD"
                  :placeholder="['Heure de début', 'Heure de fin']"
                  @change="onDateChange"
                  @ok="onDateOk"
                />
              </a-form-item>
            </a-col>
            <span style="float: left;overflow: hidden;" class="table-page-search-submitButtons">
              <a-col :md="6" :sm="24">
                <a-button type="primary" @click="searchQuery">Rechercher</a-button>
                <a-button style="margin-left: 8px" @click="searchReset">Réinitialiser</a-button>
              </a-col>
            </span>
          </a-row>
        </a-form>
      </div>
      <!-- Zone des boutons d'action -->
      <div class="table-operator"  style="margin-top: 5px">
        <a-button @click="handleBatchInOut" type="primary" icon="plus">Lot {{queryParam.type}}</a-button>
        <span style="padding-left:10px">Attention : Les produits contenant des numéros de série, des numéros de lot ou avec un état d'entrée partielle ne peuvent pas être traités en lot {{queryParam.type}}, il faut associer les documents dans l'interface d'ajout</span>
      </div>
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
        :rowSelection="{selectedRowKeys: selectedRowKeys, onChange: onSelectChange}"
        @change="handleTableChange">
        <span slot="numberCustomRender" slot-scope="text, record">
          <a v-if="!queryParam.purchaseStatus" @click="myHandleDetail(record)">{{record.number}}</a>
          <span v-if="queryParam.purchaseStatus">{{record.number}}</span>
        </span>
        <template slot="customRenderStatus" slot-scope="text, record">
          <template>
            <a-tag v-if="record.status === '1'" color="green">Audité</a-tag>
            <a-tag v-if="record.status === '3' && queryParam.type === '入库'" color="blue">Entrée partielle</a-tag>
            <a-tag v-if="record.status === '3' && queryParam.type === '出库'" color="blue">Sortie partielle</a-tag>
          </template>
        </template>
      </a-table>
      <!-- Zone du tableau - fin -->
      <!-- Zone du formulaire -->
      <bill-detail ref="billDetail"></bill-detail>
    </a-modal>
  </div>
</template>

<script>
  import BillDetail from './BillDetail'
  import { JeecgListMixin } from '@/mixins/JeecgListMixin'
  import {mixinDevice} from '@/utils/mixin'
  import { findBillDetailByNumber, batchAddDepotHeadAndDetail } from '@/api/api'
  export default {
    name: 'BatchWaitBillList',
    mixins:[JeecgListMixin, mixinDevice],
    components: {
      BillDetail
    },
    data () {
      return {
        title: "Opération",
        visible: false,
        disableMixinCreated: true,
        selectedRowKeys: [],
        linkNumber: '',
        organId: '',
        remark: '',
        queryParam: {
          number: "",
          materialParam: "",
          type: "",
          subType: "",
          status: ""
        },
        labelCol: {
          xs: { span: 24 },
          sm: { span: 8 },
        },
        wrapperCol: {
          xs: { span: 24 },
          sm: { span: 16 },
        },
        // En-têtes de colonnes
        columns: [
          { title: '', dataIndex: 'organName',width:120, ellipsis:true},
          { title: 'Numéro de document', dataIndex: 'number',width:130,
            scopedSlots: { customRender: 'numberCustomRender' },
          },
          { title: 'Informations produit', dataIndex: 'materialsList',width:280, ellipsis:true,
            customRender:function (text,record,index) {
              if(text) {
                return text.replace(",","，");
              }
            }
          },
          { title: 'Date du document', dataIndex: 'operTimeStr',width:145},
          { title: 'Opérateur', dataIndex: 'userName',width:70},
          { title: 'Quantité', dataIndex: 'materialCount',width:60},
          { title: 'État', dataIndex: 'status', width: 70, align: "center",
            scopedSlots: { customRender: 'customRenderStatus' }
          }
        ],
        dataSource:[],
        url: {
          list: "/depotHead/waitBillList"
        }
      }
    },
    created() {
    },
    methods: {
      show(type, subType, status) {
        this.queryParam.type = type
        this.queryParam.subType = subType
        this.queryParam.status = status
        this.columns[0].title = 'Fournisseur ou client'
        this.model = Object.assign({}, {});
        this.visible = true;
        this.loadData(1)
      },
      myHandleDetail(record) {
        findBillDetailByNumber({ number: record.number }).then((res) => {
          if (res && res.code === 200) {
            let type = res.data.depotHeadType
            type = type.replace('其它','')
            this.$refs.billDetail.show(res.data, type)
            this.$refs.billDetail.title=type+"- Détails"
          }
        })
      },
      close () {
        this.$emit('close');
        this.visible = false;
      },
      handleCancel () {
        this.close()
      },
      onSelectChange(selectedRowKeys) {
        this.selectedRowKeys = selectedRowKeys;
      },
      onDateChange: function (value, dateString) {
        this.queryParam.beginTime=dateString[0];
        this.queryParam.endTime=dateString[1];
      },
      onDateOk(value) {
        console.log(value);
      },
      searchReset() {
        this.queryParam = {
          type: this.queryParam.type,
          subType: this.queryParam.subType,
          status: "1,3"
        }
        this.loadData(1);
      },
      handleBatchInOut() {
        const that = this
        if (this.selectedRowKeys.length <= 0) {
          this.$message.warning('Veuillez sélectionner au moins un enregistrement !')
        } else {
          this.$confirm({
            title: "Confirmer l'opération par lot",
            content: "Voulez-vous effectuer une opération par lot sur les documents sélectionnés ?",
            onOk: function () {
              let ids = "";
              for (let i = 0; i < that.selectedRowKeys.length; i++) {
                ids += that.selectedRowKeys[i] + ",";
              }
              that.confirmLoading = true
              batchAddDepotHeadAndDetail({ 'ids': ids }).then((res) => {
                if (res.code === 200) {
                  that.$emit('ok')
                  that.selectedRowKeys = []
                  that.confirmLoading = false
                  that.close()
                } else {
                  that.$message.warning(res.data.message)
                  that.confirmLoading = false
                }
              })
            }
          })
        }
      }
    }
  }
</script>

<style scoped>

</style>