<template>
  <a-modal
    :title="title"
    :width="modalWidth"
    :visible="visible"
    :confirmLoading="confirmLoading"
    @cancel="handleCancel"
    cancelText="Fermer"
    style="top: 15%; height: 70%; overflow-y: hidden"
  >
    <template slot="footer">
      <a-button key="back" @click="handleCancel"> Fermer </a-button>
    </template>
    <!-- Zone de recherche -->
    <div class="table-page-search-wrapper">
      <a-form layout="inline" @keyup.enter.native="searchQuery">
        <a-row :gutter="24">
          <a-col :span="12">
            <a-form-item label="Titre">
              <a-input placeholder="Veuillez saisir le titre" v-model="queryParam.name"></a-input>
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <span style="float: left; overflow: hidden" class="table-page-search-submitButtons">
              <a-button type="primary" @click="searchQuery">Rechercher</a-button>
              <a-button @click="searchReset" style="margin-left: 8px">Réinitialiser</a-button>
              <a-button type="primary" @click="readAll" style="margin-left: 8px" icon="book"
                >Tout marquer comme lu</a-button
              >
            </span>
          </a-col>
        </a-row>
      </a-form>
    </div>
    <div style="margin-top: 5px">
      <a-table
        ref="table"
        size="default"
        bordered
        rowKey="id"
        :columns="columns"
        :dataSource="dataSource"
        :pagination="ipagination"
        :loading="loading"
        @change="handleTableChange"
      >
        <template slot="customRenderTitle" slot-scope="text, record">
          <span v-if="record.status == '1'" style="font-weight: bold">{{ text }}</span>
          <span v-if="record.status == '2'">{{ text }}</span>
        </template>
        <span slot="action" slot-scope="text, record">
          <a @click="showAnnouncement(record)">Voir</a>
        </span>
      </a-table>
    </div>
    <show-announcement ref="ShowAnnouncement"></show-announcement>
    <dynamic-notice ref="showDynamNotice" :path="openPath" :formData="formData" />
  </a-modal>
</template>

<script>
import { postAction } from '@/api/manage'
import ShowAnnouncement from '@/components/tools/ShowAnnouncement'
import { JeecgListMixin } from '@/mixins/JeecgListMixin'
import DynamicNotice from '../../components/tools/DynamicNotice'

export default {
  name: 'MsgList',
  mixins: [JeecgListMixin],
  components: {
    DynamicNotice,
    ShowAnnouncement,
  },
  data() {
    return {
      title: 'Notification',
      modalWidth: 800,
      visible: false,
      confirmLoading: false,
      queryParam: {
        name: '',
      },
      ipagination: {
        pageSize: 5,
        pageSizeOptions: ['5', '10', '20', '30'],
      },
      columns: [
        {
          title: 'Titre',
          dataIndex: 'msgTitle',
          scopedSlots: { customRender: 'customRenderTitle' },
          width: 200,
        },
        {
          title: 'Type de message',
          dataIndex: 'type',
          width: 80,
        },
        {
          title: 'Date de notification',
          dataIndex: 'createTimeStr',
          width: 90,
        },
        {
          title: 'Opération',
          dataIndex: 'action',
          align: 'center',
          scopedSlots: { customRender: 'action' },
          width: 50,
        },
      ],
      url: {
        list: '/msg/list',
        batchUpdateStatus: '/msg/batchUpdateStatus',
        readAllMsg: '/msg/readAllMsg',
      },
      loading: false,
      openPath: '',
      formData: '',
    }
  },
  methods: {
    handleDetail: function () {
      this.visible = true
    },
    showAnnouncement(record) {
      postAction(this.url.batchUpdateStatus, { ids: record.id, status: '2' }).then((res) => {
        if (res && res.code === 200) {
          this.loadData()
        }
      })
      if (record.openType === 'component') {
        this.openPath = record.openPage
        this.formData = { id: record.busId }
        this.$refs.showDynamNotice.detail()
      } else {
        this.$refs.ShowAnnouncement.detail(record)
      }
    },
    readAll() {
      let that = this
      that.$confirm({
        title: "Confirmer l'opération",
        content: 'Voulez-vous tout marquer comme lu ?',
        onOk: function () {
          postAction(that.url.readAllMsg).then((res) => {
            if (res && res.code === 200) {
              that.$message.success(res.data)
              that.loadData()
            }
          })
        },
      })
    },
    close() {
      this.$emit('close')
      this.visible = false
    },
    handleCancel() {
      this.close()
    },
  },
}
</script>
<style scoped>
.ant-card-body .table-operator {
  margin-bottom: 18px;
}
.anty-row-operator button {
  margin: 0 5px;
}
.ant-btn-danger {
  background-color: #ffffff;
}
z .ant-modal-cust-warp {
  height: 100%;
}
.ant-modal-cust-warp .ant-modal-body {
  height: calc(100% - 110px) !important;
  overflow-y: auto;
}
.ant-modal-cust-warp .ant-modal-content {
  height: 90% !important;
  overflow-y: hidden;
}
</style>
