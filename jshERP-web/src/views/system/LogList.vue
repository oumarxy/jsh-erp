<template>
  <a-row :gutter="24">
    <a-col :md="24">
      <a-card :style="cardStyle" :bordered="false">
        <!-- Zone de recherche -->
        <div class="table-page-search-wrapper">
          <a-form layout="inline" @keyup.enter.native="searchQuery">
            <a-row :gutter="24">
              <a-col :md="6" :sm="24">
                <a-form-item label="Module d'opération" :labelCol="labelCol" :wrapperCol="wrapperCol">
                  <a-input placeholder="Veuillez saisir le module d'opération" v-model="queryParam.operation"></a-input>
                </a-form-item>
              </a-col>
              <a-col :md="6" :sm="24">
                <a-form-item label="Détails de l'opération" :labelCol="labelCol" :wrapperCol="wrapperCol">
                  <a-input
                    placeholder="Veuillez saisir les détails de l'opération"
                    v-model="queryParam.content"
                  ></a-input>
                </a-form-item>
              </a-col>
              <a-col :md="6" :sm="24">
                <a-form-item label="Date de création" :labelCol="labelCol" :wrapperCol="wrapperCol">
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
                  <a-form-item label="Opérateur" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-input
                      placeholder="Veuillez saisir le compte ou le nom de l'opérateur"
                      v-model="queryParam.userInfo"
                    ></a-input>
                  </a-form-item>
                </a-col>
                <a-col :md="6" :sm="24">
                  <a-form-item label="IP d'opération" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-input placeholder="Veuillez saisir l'IP d'opération" v-model="queryParam.clientIp"></a-input>
                  </a-form-item>
                </a-col>
                <a-col :md="6" :sm="24" v-if="isManage">
                  <a-form-item label="Compte du locataire" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-input
                      placeholder="Veuillez saisir le compte du locataire"
                      v-model="queryParam.tenantLoginName"
                    ></a-input>
                  </a-form-item>
                </a-col>
                <a-col :md="6" :sm="24" v-if="isManage">
                  <a-form-item label="Type de locataire" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-select v-model="queryParam.tenantType" placeholder="Veuillez sélectionner le type de locataire">
                      <a-select-option value="">Veuillez sélectionner</a-select-option>
                      <a-select-option value="0">Locataire d'essai</a-select-option>
                      <a-select-option value="1">Locataire payant</a-select-option>
                    </a-select>
                  </a-form-item>
                </a-col>
              </a-row>
            </template>
          </a-form>
        </div>
        <!-- Zone du tableau - début -->
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
          @change="handleTableChange"
        >
          <!-- Affichage avec points de suspension pour les chaînes trop longues -->
          <span slot="content" slot-scope="text, record">
            <j-ellipsis :value="text" :length="40" />
          </span>
        </a-table>
        <!-- Zone du tableau - fin -->
      </a-card>
    </a-col>
  </a-row>
</template>
<!-- f r o m 7 5  2 7 1  8 9 2 0 -->
<script>
import { JeecgListMixin } from '@/mixins/JeecgListMixin'
import JEllipsis from '@/components/jeecg/JEllipsis'
import { getFormatDate, getPrevMonthFormatDate } from '@/utils/util'
import { getAction } from '@/api/manage'
import moment from 'moment'

export default {
  name: 'LogList',
  mixins: [JeecgListMixin],
  components: {
    JEllipsis,
  },
  data() {
    return {
      // Conditions de recherche
      queryParam: {
        operation: '',
        content: '',
        userInfo: '',
        clientIp: '',
        tenantLoginName: '',
        tenantType: '',
        beginTime: getPrevMonthFormatDate(1),
        endTime: getFormatDate(),
        createTimeRange: [moment(getPrevMonthFormatDate(1)), moment(getFormatDate())],
      },
      tabKey: '1',
      isManage: false,
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
        { title: "Module d'opération", dataIndex: 'operation', width: 120, align: 'left' },
        {
          title: "Détails de l'opération",
          dataIndex: 'content',
          scopedSlots: { customRender: 'content' },
          width: 360,
          align: 'left',
        },
        { title: "Compte de l'opérateur", dataIndex: 'loginName', width: 80, align: 'left' },
        { title: "Nom de l'opérateur", dataIndex: 'userName', width: 80, align: 'left' },
        { title: "IP d'opération", dataIndex: 'clientIp', width: 100, align: 'left' },
        { title: "Heure de l'opération", dataIndex: 'createTimeStr', width: 110, align: 'left' },
      ],
      operateColumn: {
        title: "Type d'opération",
        dataIndex: 'operateType_dictText',
        align: 'center',
      },
      labelCol: {
        span: 5,
      },
      wrapperCol: {
        span: 18,
        offset: 1,
      },
      url: {
        list: '/log/list',
      },
    }
  },
  created() {
    this.initUserInfo()
  },
  methods: {
    onDateChange: function (value, dateString) {
      this.queryParam.beginTime = dateString[0]
      this.queryParam.endTime = dateString[1]
      if (dateString[0] && dateString[1]) {
        this.queryParam.createTimeRange = [moment(dateString[0]), moment(dateString[1])]
      }
    },
    onDateOk(value) {
      console.log(value)
    },
    searchReset() {
      this.queryParam = {
        operation: '',
        content: '',
        userInfo: '',
        clientIp: '',
        tenantLoginName: '',
        tenantType: '',
        beginTime: getPrevMonthFormatDate(1),
        endTime: getFormatDate(),
        createTimeRange: [moment(getPrevMonthFormatDate(1)), moment(getFormatDate())],
      }
      this.loadData(1)
    },
    initUserInfo() {
      getAction('/user/getUserSession').then((res) => {
        if (res.code === 200) {
          let user = res.data.user
          if (user.tenantId === 0) {
            this.isManage = true
          }
        } else {
          this.$message.warning(res.data)
        }
      })
    },
  },
}
</script>
<style scoped>
@import '~@assets/less/common.less';
</style>
