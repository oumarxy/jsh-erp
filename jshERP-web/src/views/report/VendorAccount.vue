<!-- f r o m 7 5  2 7 1  8 9 2 0 -->
<template>
  <a-row :gutter="24">
    <a-col :md="24">
      <a-card :style="cardStyle" :bordered="false">
        <!-- Zone de recherche -->
        <div class="table-page-search-wrapper">
          <a-form layout="inline" @keyup.enter.native="searchQuery">
            <a-row :gutter="24">
              <a-col :md="6" :sm="24">
                <a-form-item label="Fournisseur" :labelCol="labelCol" :wrapperCol="wrapperCol">
                  <a-select placeholder="Veuillez sélectionner le fournisseur" v-model="queryParam.organId"
                    :dropdownMatchSelectWidth="false" showSearch allow-clear optionFilterProp="children" @search="handleSearchSupplier">
                    <div slot="dropdownRender" slot-scope="menu">
                      <v-nodes :vnodes="menu" />
                      <a-divider style="margin: 4px 0;" />
                      <div class="dropdown-btn" @mousedown="e => e.preventDefault()" @click="initSupplier"><a-icon type="reload" /> Actualiser la liste</div>
                    </div>
                    <a-select-option v-for="(item,index) in supList" :key="index" :value="item.id">
                      {{ item.supplier }}
                    </a-select-option>
                  </a-select>
                </a-form-item>
              </a-col>
              <a-col :md="6" :sm="24">
                <a-form-item label="Période de facturation" :labelCol="labelCol" :wrapperCol="wrapperCol">
                  <a-range-picker
                    style="width: 100%"
                    v-model="queryParam.createTimeRange"
                    format="YYYY-MM-DD"
                    :placeholder="['Heure de début', 'Heure de fin']"
                    @change="onDateChange"
                  />
                </a-form-item>
              </a-col>
              <a-col :md="6" :sm="24">
                <span class="table-page-search-submitButtons">
                  <a-button type="primary" @click="searchQuery">Rechercher</a-button>
                  <a-button style="margin-left: 8px" v-print="'#reportPrint'" icon="printer">Imprimer</a-button>
                  <a-button style="margin-left: 8px" @click="exportExcel" icon="download">Exporter</a-button>
                  <a @click="handleToggleSearch" style="margin-left: 8px">
                    {{ toggleSearchStatus ? 'Masquer' : 'Développer' }}
                    <a-icon :type="toggleSearchStatus ? 'up' : 'down'"/>
                  </a>
                </span>
              </a-col>
              <a-col :md="6" :sm="24">
                <a-form-item>
                  {{firstTotal}} {{lastTotal}}
                </a-form-item>
              </a-col>
            </a-row>
            <template v-if="toggleSearchStatus">
              <a-row :gutter="24">
                <a-col :md="6" :sm="24">
                  <a-form-item label="Situation de la dette" :labelCol="labelCol" :wrapperCol="wrapperCol">
                    <a-select v-model="queryParam.hasDebt">
                      <a-select-option value="1">Avec dette</a-select-option>
                      <a-select-option value="0">Sans dette</a-select-option>
                    </a-select>
                  </a-form-item>
                </a-col>
              </a-row>
            </template>
          </a-form>
        </div>
        <!-- Zone du tableau - début -->
        <section ref="print" id="reportPrint">
          <a-table
            bordered
            ref="table"
            size="middle"
            rowKey="id"
            :columns="columns"
            :dataSource="dataSource"
            :components="handleDrag(columns)"
            :pagination="false"
            :scroll="scroll"
            :loading="loading"
            @change="handleTableChange">
            <span slot="customTitle">
              <a-popover trigger="click" placement="right">
                <template slot="content">
                  <a-checkbox-group @change="onColChange" v-model="settingDataIndex" :defaultValue="settingDataIndex">
                    <a-row style="width: 600px">
                      <template v-for="(item,index) in defColumns">
                        <template>
                          <a-col :span="6">
                            <a-checkbox :value="item.dataIndex" v-if="item.dataIndex==='rowIndex'" disabled></a-checkbox>
                            <a-checkbox :value="item.dataIndex" v-if="item.dataIndex!=='rowIndex'">
                              <j-ellipsis :value="item.title" v-if="item.dataIndex!=='allNeed'" :length="10"></j-ellipsis>
                              <j-ellipsis value="Dettes en fin de période" v-if="item.dataIndex==='allNeed'" :length="10"></j-ellipsis>
                            </a-checkbox>
                          </a-col>
                        </template>
                      </template>
                    </a-row>
                    <a-row style="padding-top: 10px;">
                      <a-col>
                        Restaurer la configuration de colonnes par défaut : <a-button @click="handleRestDefault" type="link" size="small">Restaurer par défaut</a-button>
                      </a-col>
                    </a-row>
                  </a-checkbox-group>
                </template>
                <a-icon type="setting" />
              </a-popover>
            </span>
            <span slot="action" slot-scope="text, record">
              <a @click="showDebtAccountList(record)">{{record.id?'Détails':''}}</a>
            </span>
            <span slot="allNeedTitle">
              Dettes en fin de période
              <a-tooltip title="Dettes en fin de période = Dettes en début de période + Dettes de la période - Paiements de la période">
                <a-icon type="question-circle" />
              </a-tooltip>
            </span>
          </a-table>
          <a-row :gutter="24" style="margin-top: 8px;text-align:right;">
            <a-col :md="24" :sm="24">
              <a-pagination @change="paginationChange" @showSizeChange="paginationShowSizeChange"
                size="small"
                show-size-changer
                :showQuickJumper="true"
                :current="ipagination.current"
                :page-size="ipagination.pageSize"
                :page-size-options="ipagination.pageSizeOptions"
                :total="ipagination.total"
                :show-total="(total, range) => `Total ${total-Math.ceil(total/ipagination.pageSize)} entrées`">
                <template slot="buildOptionText" slot-scope="props">
                  <span>{{ props.value-1 }} entrées/page</span>
                </template>
              </a-pagination>
            </a-col>
          </a-row>
        </section>
        <!-- Zone du tableau - fin -->
        <!-- Zone du formulaire -->
        <debt-account-list ref="debtAccountList"></debt-account-list>
      </a-card>
    </a-col>
  </a-row>
</template>
<script>
  import DebtAccountList from './modules/DebtAccountList'
  import { JeecgListMixin } from '@/mixins/JeecgListMixin'
  import { getFormatDate, getNowFormatYear, getPrevMonthFormatDate } from '@/utils/util'
  import { getAction } from '@/api/manage'
  import {findBySelectSup} from '@/api/api'
  import JEllipsis from '@/components/jeecg/JEllipsis'
  import moment from 'moment'
  export default {
    name: "VendorAccount",
    mixins:[JeecgListMixin],
    components: {
      DebtAccountList,
      JEllipsis,
      VNodes: {
        functional: true,
        render: (h, ctx) => ctx.props.vnodes,
      }
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
          supplierType: "供应商",
          organId: undefined,
          hasDebt: '1',
          beginTime: getPrevMonthFormatDate(3),
          endTime: getFormatDate(),
          createTimeRange: [moment(getPrevMonthFormatDate(3)), moment(getFormatDate())],
        },
        ipagination:{
          pageSize: 11,
          pageSizeOptions: ['11', '21', '31', '101', '201']
        },
        supList: [],
        firstTotal: '',
        lastTotal: '',
        setTimeFlag: null,
        tabKey: "1",
        pageName: 'vendorAccount',
        // Index par défaut
        defDataIndex:['rowIndex','action','supplier','contacts','telephone','phoneNum','email','preNeed','debtMoney','backMoney','allNeed'],
        // Colonnes par défaut
        defColumns: [
          {
            dataIndex: 'rowIndex', width:40, align:"center", slots: { title: 'customTitle' },
            customRender:function (t,r,index) {
              return (t !== 'Total') ? (parseInt(index) + 1) : t
            }
          },
          {title: 'Détails de la dette', dataIndex: 'action', align:"center", width: 80,
            scopedSlots: { customRender: 'action' }
          },
          {title: 'Fournisseur', dataIndex: 'supplier', width: 150, ellipsis:true},
          {title: 'Contact', dataIndex: 'contacts', width: 100, ellipsis:true},
          {title: 'Numéro de téléphone portable', dataIndex: 'telephone', width: 100},
          {title: 'Numéro de téléphone', dataIndex: 'phoneNum', width: 100},
          {title: 'Adresse e-mail', dataIndex: 'email', width: 100},
          {title: 'Dettes en début de période', dataIndex: 'preNeed', sorter: (a, b) => a.preNeed - b.preNeed, width: 80},
          {title: 'Dettes de la période', dataIndex: 'debtMoney', sorter: (a, b) => a.debtMoney - b.debtMoney, width: 80},
          {title: 'Paiements de la période', dataIndex: 'backMoney', sorter: (a, b) => a.backMoney - b.backMoney, width: 80},
          {dataIndex: 'allNeed', sorter: (a, b) => a.allNeed - b.allNeed, width: 80,
            slots: { title: 'allNeedTitle' }
          }
        ],
        url: {
          list: "/depotHead/getStatementAccount",
        }
      }
    },
    created () {
      this.initSupplier()
      this.initColumnsSetting()
    },
    methods: {
      getQueryParams() {
        let param = Object.assign({}, this.queryParam, this.isorter);
        param.field = this.getQueryField();
        param.currentPage = this.ipagination.current;
        param.pageSize = this.ipagination.pageSize-1;
        return param;
      },
      initSupplier() {
        let that = this;
        findBySelectSup({limit:1}).then((res)=>{
          if(res) {
            that.supList = res;
          }
        });
      },
      handleSearchSupplier(value) {
        let that = this
        if(this.setTimeFlag != null){
          clearTimeout(this.setTimeFlag);
        }
        this.setTimeFlag = setTimeout(()=>{
          findBySelectSup({key: value, limit:1}).then((res) => {
            if(res) {
              that.supList = res;
            }
          })
        },500)
      },
      onDateChange: function (value, dateString) {
        this.queryParam.beginTime=dateString[0]
        this.queryParam.endTime=dateString[1]
        if(dateString[0] && dateString[1]) {
          this.queryParam.createTimeRange = [moment(dateString[0]), moment(dateString[1])]
        }
      },
      loadData(arg) {
        // Charger les données - si le paramètre 1 est passé, charger le contenu de la première page
        if (arg === 1) {
          this.ipagination.current = 1;
        }
        let params = this.getQueryParams();// Conditions de recherche
        this.loading = true;
        getAction(this.url.list, params).then((res) => {
          if (res.code===200) {
            this.dataSource = res.data.rows;
            this.ipagination.total = res.data.total;
            this.tableAddTotalRow(this.columns, this.dataSource)
            this.firstTotal = 'Dettes en début de période : ' + res.data.firstMoney + "，"
            this.lastTotal = 'Dettes en fin de période : ' + res.data.lastMoney
          } else if(res.code===510){
            this.$message.warning(res.data)
          } else {
            this.$message.warning(res.data.message)
          }
          this.loading = false;
        })
      },
      searchQuery() {
        if(this.queryParam.beginTime === '' || this.queryParam.endTime === ''){
          this.$message.warning('Veuillez sélectionner la date du document !')
        } else {
          this.loadData(1);
        }
      },
      exportExcel() {
        let list = []
        let head = 'Fournisseur,Contact,Numéro de téléphone portable,Numéro de téléphone,Adresse e-mail,Dettes en début de période,Dettes de la période,Paiements de la période,Dettes en fin de période'
        for (let i = 0; i < this.dataSource.length; i++) {
          let item = []
          let ds = this.dataSource[i]
          item.push(ds.supplier, ds.contacts, ds.telephone, ds.phoneNum, ds.email, ds.preNeed, ds.debtMoney, ds.backMoney, ds.allNeed)
          list.push(item)
        }
        let tip = 'Date du document : ' + this.queryParam.beginTime + '~' + this.queryParam.endTime
        this.handleExportXlsPost('Réconciliation fournisseur', 'Réconciliation fournisseur', head, tip, list)
      },
      showDebtAccountList(record) {
        this.$refs.debtAccountList.show(record.id, '入库', '采购', '供应商', "", this.queryParam.beginTime, this.queryParam.endTime)
        this.$refs.debtAccountList.title = "Détails de la dette"
        this.$refs.debtAccountList.disableSubmit = false
      }
    }
  }
</script>
<style scoped>
  @import '~@assets/less/common.less'
</style>