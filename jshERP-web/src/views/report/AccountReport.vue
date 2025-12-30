<!-- from 7 5 2 7 1 8 9 2 0 -->
<template>
  <a-row :gutter="24">
    <a-col :md="24">
      <a-card :style="cardStyle" :bordered="false">
        <!-- Zone de recherche -->
        <div class="table-page-search-wrapper">
          <a-form layout="inline" @keyup.enter.native="searchQuery">
            <a-row :gutter="24">
              <a-col :md="6" :sm="24">
                <a-form-item label="Nom" :labelCol="labelCol" :wrapperCol="wrapperCol">
                  <a-input placeholder="Veuillez saisir le nom" v-model="queryParam.name"></a-input>
                </a-form-item>
              </a-col>
              <a-col :md="6" :sm="24">
                <a-form-item label="Numéro" :labelCol="labelCol" :wrapperCol="wrapperCol">
                  <a-input placeholder="Veuillez saisir le numéro" v-model="queryParam.serialNo"></a-input>
                </a-form-item>
              </a-col>
              <a-col :md="5" :sm="24">
                <span class="table-page-search-submitButtons">
                  <a-button type="primary" @click="searchQuery">Rechercher</a-button>
                  <a-button style="margin-left: 8px" v-print="'#reportPrint'" icon="printer">Imprimer</a-button>
                  <a-button style="margin-left: 8px" @click="exportExcel" icon="download">Exporter</a-button>
                </span>
              </a-col>
              <a-col :md="6" :sm="24">
                <a-form-item>
                  <span>Total du mois : {{allMonthAmount}}，Solde total actuel : {{allCurrentAmount}}</span>
                </a-form-item>
              </a-col>
            </a-row>
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
                              <j-ellipsis :value="item.title" :length="10"></j-ellipsis>
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
              <a @click="showAccountInOutList(record)">{{record.id?'Mouvements':''}}</a>
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
        <account-in-out-list ref="accountInOutList" @ok="modalFormOk"></account-in-out-list>
      </a-card>
    </a-col>
  </a-row>
</template>
<script>
  import AccountInOutList from './modules/AccountInOutList'
  import { JeecgListMixin } from '@/mixins/JeecgListMixin'
  import JEllipsis from '@/components/jeecg/JEllipsis'
  import {getAction} from '@/api/manage'
  export default {
    name: "AccountReport",
    mixins:[JeecgListMixin],
    components: {
      AccountInOutList,
      JEllipsis
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
          name:'',
          serialNo:''
        },
        ipagination:{
          pageSize: 11,
          pageSizeOptions: ['11', '21', '31', '101', '201']
        },
        allMonthAmount: '',
        allCurrentAmount: '',
        tabKey: "1",
        pageName: 'accountReport',
        // Index par défaut
        defDataIndex:['rowIndex','action','name','serialNo','initialAmount','thisMonthAmount','currentAmount'],
        // Colonnes par défaut
        defColumns: [
          {
            dataIndex: 'rowIndex', width:60, align:"center", slots: { title: 'customTitle' },
            customRender:function (t,r,index) {
              return (t !== 'Total') ? (parseInt(index) + 1) : t
            }
          },
          { title: 'Mouvements du compte', dataIndex: 'action', align:"center", width: 120,
            scopedSlots: { customRender: 'action' }
          },
          { title: 'Nom', dataIndex: 'name', width: 150},
          { title: 'Numéro', dataIndex: 'serialNo', width: 150},
          { title: 'Montant initial', dataIndex: 'initialAmount', sorter: (a, b) => a.initialAmount - b.initialAmount, width: 100},
          { title: 'Montant du mois', dataIndex: 'thisMonthAmount', sorter: (a, b) => a.thisMonthAmount - b.thisMonthAmount, width: 100},
          { title: 'Solde actuel', dataIndex: 'currentAmount', sorter: (a, b) => a.currentAmount - b.currentAmount, width: 100}
        ],
        url: {
          list: "/account/listWithBalance",
          getStatistics: "/account/getStatistics"
        }
      }
    },
    created () {
      this.getAccountStatistics()
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
      getAccountStatistics() {
        getAction(this.url.getStatistics, this.queryParam).then((res)=>{
          if(res && res.code === 200) {
            if(res.data){
              this.allMonthAmount = res.data.allMonthAmount
              this.allCurrentAmount = res.data.allCurrentAmount
            }
          }
        })
      },
      searchQuery() {
        this.loadData(1);
        this.getAccountStatistics();
      },
      showAccountInOutList(record) {
        this.$refs.accountInOutList.show(record);
        this.$refs.accountInOutList.title = "Voir les mouvements du compte - " + record.name;
        this.$refs.accountInOutList.disableSubmit = false;
      },
      exportExcel() {
        let list = []
        let head = 'Nom,Numéro,Montant initial,Montant du mois,Solde actuel'
        for (let i = 0; i < this.dataSource.length; i++) {
          let item = []
          let ds = this.dataSource[i]
          item.push(ds.name, ds.serialNo, ds.initialAmount, ds.thisMonthAmount, ds.currentAmount)
          list.push(item)
        }
        let tip = 'Recherche de statistiques de compte'
        this.handleExportXlsPost('Statistiques de compte', 'Statistiques de compte', head, tip, list)
      }
    }
  }
</script>
<style scoped>
  @import '~@assets/less/common.less'
</style>