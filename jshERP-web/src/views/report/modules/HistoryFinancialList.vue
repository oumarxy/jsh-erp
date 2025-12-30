<!-- by 7527 18920 -->
<template>
  <div ref="container">
    <a-modal
      :title="title"
      :width="1600"
      :visible="visible"
      :getContainer="() => $refs.container"
      :maskStyle="{ top: '93px', left: '154px' }"
      :wrapClassName="wrapClassNameInfo()"
      :mask="isDesktop()"
      :maskClosable="false"
      @cancel="handleCancel"
      cancelText="Fermer"
      style="top: 20px; height: 95%"
    >
      <template slot="footer">
        <a-button key="back" @click="handleCancel">Annuler</a-button>
      </template>
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
              <a-form-item label="Opérateur" :labelCol="labelCol" :wrapperCol="wrapperCol">
                <a-select
                  placeholder="Veuillez sélectionner l'opérateur"
                  showSearch
                  optionFilterProp="children"
                  v-model="queryParam.creator"
                >
                  <a-select-option v-for="(item, index) in userList" :key="index" :value="item.id">
                    {{ item.userName }}
                  </a-select-option>
                </a-select>
              </a-form-item>
            </a-col>
            <a-col :md="6" :sm="24">
              <a-form-item label="État du document" :labelCol="labelCol" :wrapperCol="wrapperCol">
                <a-select placeholder="Veuillez sélectionner l'état du document" v-model="queryParam.status">
                  <a-select-option value="0">Non vérifié</a-select-option>
                  <a-select-option value="1">Vérifié</a-select-option>
                </a-select>
              </a-form-item>
            </a-col>
            <span style="float: left; overflow: hidden" class="table-page-search-submitButtons">
              <a-col :md="6" :sm="24">
                <a-button type="primary" @click="searchQuery">Rechercher</a-button>
                <a-button style="margin-left: 8px" @click="searchReset">Réinitialiser</a-button>
                <a @click="handleToggleSearch" style="margin-left: 8px">
                  {{ toggleSearchStatus ? 'Masquer' : 'Développer' }}
                  <a-icon :type="toggleSearchStatus ? 'up' : 'down'" />
                </a>
              </a-col>
            </span>
            <template v-if="toggleSearchStatus">
              <a-col :md="6" :sm="24">
                <a-form-item label="Personnel financier" :labelCol="labelCol" :wrapperCol="wrapperCol">
                  <a-select
                    placeholder="Veuillez sélectionner le personnel financier"
                    showSearch
                    optionFilterProp="children"
                    v-model="queryParam.handsPersonId"
                  >
                    <a-select-option v-for="(item, index) in personList" :key="index" :value="item.id">
                      {{ item.name }}
                    </a-select-option>
                  </a-select>
                </a-form-item>
              </a-col>
              <a-col :md="6" :sm="24">
                <a-form-item label="Informations sur le compte" :labelCol="labelCol" :wrapperCol="wrapperCol">
                  <a-select
                    placeholder="Veuillez sélectionner les informations sur le compte"
                    showSearch
                    optionFilterProp="children"
                    v-model="queryParam.accountId"
                  >
                    <a-select-option v-for="(item, index) in accountList" :key="index" :value="item.id">
                      {{ item.name }}
                    </a-select-option>
                  </a-select>
                </a-form-item>
              </a-col>
              <a-col :md="6" :sm="24">
                <a-form-item label="Remarque du document" :labelCol="labelCol" :wrapperCol="wrapperCol">
                  <a-input placeholder="Veuillez saisir la remarque du document" v-model="queryParam.remark"></a-input>
                </a-form-item>
              </a-col>
              <a-col :md="6" :sm="24">
                <a-form-item label="Numéro de commande de vente" :labelCol="labelCol" :wrapperCol="wrapperCol">
                  <a-input
                    placeholder="Veuillez saisir le numéro de commande de vente"
                    v-model="queryParam.number"
                  ></a-input>
                </a-form-item>
              </a-col>
            </template>
          </a-row>
        </a-form>
      </div>
      <!-- Zone du tableau - début -->
      <a-table
        ref="table"
        size="middle"
        bordered
        rowKey="id"
        :columns="columns"
        :dataSource="dataSource"
        :components="handleDrag(columns)"
        :pagination="ipagination"
        :loading="loading"
        @change="handleTableChange"
      >
        <span slot="billNoCustomRender" slot-scope="text, record">
          <a @click="myHandleDetail(record, queryParam.type, prefixNo)">{{ text }}</a>
        </span>
        <template slot="customRenderStatus" slot-scope="status">
          <a-tag v-if="status == '0'" color="red">Non vérifié</a-tag>
          <a-tag v-if="status == '1'" color="green">Vérifié</a-tag>
          <a-tag v-if="status == '9'" color="orange">En cours de vérification</a-tag>
        </template>
      </a-table>
      <!-- Zone du tableau - fin -->
      <!-- Zone du formulaire -->
      <financial-detail ref="modalDetail" @ok="modalFormOk" @close="modalFormClose"></financial-detail>
    </a-modal>
  </div>
</template>
<script>
import FinancialDetail from '../../financial/dialog/FinancialDetail'
import { JeecgListMixin } from '@/mixins/JeecgListMixin'
import { FinancialListMixin } from '../../financial/mixins/FinancialListMixin'
import JDate from '@/components/jeecg/JDate'
import Vue from 'vue'
export default {
  name: 'HistoryFinancialList',
  mixins: [JeecgListMixin, FinancialListMixin],
  components: {
    FinancialDetail,
    JDate,
  },
  data() {
    return {
      title: '',
      visible: false,
      labelCol: {
        span: 5,
      },
      wrapperCol: {
        span: 18,
        offset: 1,
      },
      // Conditions de recherche
      queryParam: {
        billNo: '',
        beginTime: '',
        endTime: '',
        searchMaterial: '',
        type: '',
        organId: '',
        creator: '',
        handsPersonId: '',
        accountId: '',
        status: '',
        remark: '',
        number: '',
      },
      prefixNo: '',
      disableMixinCreated: true,
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
          title: 'Numéro de document',
          dataIndex: 'billNo',
          width: 120,
          scopedSlots: { customRender: 'billNoCustomRender' },
        },
        { title: 'Client', dataIndex: 'organName', width: 140, ellipsis: true },
        { title: 'Date du document ', dataIndex: 'billTimeStr', width: 140 },
        { title: 'Opérateur', dataIndex: 'userName', width: 100, ellipsis: true },
        { title: 'Personnel financier', dataIndex: 'handsPersonName', width: 100 },
        { title: 'Total des recouvrements', dataIndex: 'totalPrice', width: 80 },
        { title: 'Montant de remise', dataIndex: 'discountMoney', width: 80 },
        { title: 'Recouvrement réel', dataIndex: 'changeAmount', width: 80 },
        { title: 'Remarque', dataIndex: 'remark', width: 160 },
        {
          title: 'État',
          dataIndex: 'status',
          width: 80,
          align: 'center',
          scopedSlots: { customRender: 'customRenderStatus' },
        },
      ],
      url: {
        list: '/accountHead/list',
      },
    }
  },
  computed: {},
  created() {
    this.initSystemConfig()
    this.initUser()
    this.initPerson()
    this.initAccount()
  },
  methods: {
    show() {
      if (this.queryParam.type === '付款') {
        this.columns[2].title = 'Fournisseur'
        this.columns[6].title = 'Total des paiements'
        this.columns[8].title = 'Paiement réel'
        this.prefixNo = 'FK'
      } else if (this.queryParam.type === '收款') {
        this.columns[2].title = 'Client'
        this.columns[6].title = 'Total des recouvrements'
        this.columns[8].title = 'Recouvrement réel'
        this.prefixNo = 'SK'
      }
      this.loadData(1)
    },
    close() {
      this.$emit('close')
      this.visible = false
    },
    handleCancel() {
      this.close()
    },
    searchReset() {
      this.queryParam = {
        organId: this.queryParam.organId,
        beginTime: this.queryParam.beginTime,
        endTime: this.queryParam.endTime,
        type: this.queryParam.type,
      }
      this.loadData(1)
    },
  },
}
</script>
<style scoped>
@import '~@assets/less/common.less';
</style>
