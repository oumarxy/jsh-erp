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
                <a-form-item label="Nom" :labelCol="labelCol" :wrapperCol="wrapperCol">
                  <a-input placeholder="Veuillez saisir le nom pour rechercher" v-model="queryParam.name"></a-input>
                </a-form-item>
              </a-col>
              <span style="float: left; overflow: hidden" class="table-page-search-submitButtons">
                <a-col :md="6" :sm="24">
                  <a-button type="primary" @click="searchQuery">Rechercher</a-button>
                  <a-button style="margin-left: 8px" @click="searchReset">Réinitialiser</a-button>
                  <a-button type="primary" style="margin-left: 8px" @click="writeCode"
                    >Saisir le code d'activation du plugin</a-button
                  >
                  <a-button type="primary" style="margin-left: 8px" @click="writeAppCode"
                    >Saisir le code d'activation mobile</a-button
                  >
                </a-col>
              </span>
            </a-row>
          </a-form>
        </div>
        <!-- Zone des boutons d'action -->
        <div class="table-operator" style="margin-top: 5px">
          <a-upload
            name="file"
            :showUploadList="false"
            :multiple="false"
            :headers="tokenHeader"
            :action="importUrl"
            @change="handleImportJar"
          >
            <a-popover title="Points d'attention pour l'importation">
              <template slot="content">
                <p>Veuillez sélectionner le fichier jar du plugin à importer</p>
              </template>
              <a-button type="primary" icon="import">Télécharger le package du plugin</a-button>
            </a-popover>
          </a-upload>
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
            @change="handleTableChange"
          >
            <span slot="action" slot-scope="text, record">
              <a @click="uploadTemplate(record)">Télécharger la page</a>
              <a-divider type="vertical" />
              <a-popconfirm
                title="Êtes-vous sûr de vouloir démarrer ce plugin ?"
                @confirm="() => startPlugin(record.pluginDescriptor.pluginId)"
              >
                <a>Démarrer</a>
              </a-popconfirm>
              <a-divider type="vertical" />
              <a-popconfirm
                title="Êtes-vous sûr de vouloir arrêter ce plugin ?"
                @confirm="() => stopPlugin(record.pluginDescriptor.pluginId)"
              >
                <a>Arrêter</a>
              </a-popconfirm>
              <a-divider type="vertical" />
              <a-popconfirm
                title="Êtes-vous sûr de vouloir désinstaller ce plugin ?"
                @confirm="() => uninstallPlugin(record.pluginDescriptor.pluginId)"
              >
                <a>Désinstaller</a>
              </a-popconfirm>
            </span>
            <span slot="linkInfo" slot-scope="text, record">
              <a :href="linkUrl(record)" target="_blank" :title="linkUrl(record)">{{ linkUrl(record) }}</a>
            </span>
            <template slot="customRenderFlag" slot-scope="pluginState">
              <a-tag v-if="pluginState == 'STARTED'" color="green">Activé</a-tag>
              <a-tag v-if="pluginState == 'STOPPED'" color="orange">Arrêté</a-tag>
            </template>
          </a-table>
        </div>
        <!-- Zone du tableau - fin -->
        <!-- Zone du formulaire -->
        <plugin-modal ref="modalForm" @ok="modalFormOk"></plugin-modal>
        <plugin-app-modal ref="appModalForm" @ok="appModalFormOk"></plugin-app-modal>
      </a-card>
    </a-col>
  </a-row>
</template>
<!-- f r o m 7 5  2 7 1  8 9 2 0 -->
<script>
import PluginModal from './modules/PluginModal'
import PluginAppModal from './modules/PluginAppModal'
import { JeecgListMixin } from '@/mixins/JeecgListMixin'
import { postAction } from '@/api/manage'
import JDate from '@/components/jeecg/JDate'
import { filterObj } from '@/utils/util'
export default {
  name: 'PluginList',
  mixins: [JeecgListMixin],
  components: {
    PluginModal,
    PluginAppModal,
    JDate,
  },
  data() {
    return {
      labelCol: {
        span: 5,
      },
      wrapperCol: {
        span: 18,
        offset: 1,
      },
      // Conditions de recherche
      queryParam: { name: '' },
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
          title: 'Opération',
          dataIndex: 'action',
          width: 200,
          align: 'center',
          scopedSlots: { customRender: 'action' },
        },
        {
          title: 'Nom',
          dataIndex: '',
          width: 120,
          customRender: function (t, r, index) {
            if (r) {
              var desc = r.pluginDescriptor.pluginDescription
              if (desc.indexOf('|')) {
                var arr = desc.split('|')
                return arr[0]
              }
            }
          },
        },
        {
          title: 'Identifiant',
          dataIndex: '',
          width: 180,
          customRender: function (t, r, index) {
            if (r) {
              return r.pluginDescriptor.pluginId
            }
          },
        },
        {
          title: 'Version',
          dataIndex: '',
          width: 120,
          customRender: function (t, r, index) {
            if (r) {
              return r.pluginDescriptor.version
            }
          },
        },
        {
          title: 'Auteur',
          dataIndex: '',
          width: 100,
          customRender: function (t, r, index) {
            if (r) {
              return r.pluginDescriptor.provider
            }
          },
        },
        {
          title: 'Lien de la page',
          dataIndex: '',
          width: 250,
          ellipsis: true,
          scopedSlots: { customRender: 'linkInfo' },
        },
        {
          title: 'État',
          dataIndex: 'pluginState',
          width: 60,
          align: 'center',
          scopedSlots: { customRender: 'customRenderFlag' },
        },
      ],
      url: {
        list: '/plugin/list',
        delete: '/plugin/delete',
        deleteBatch: '/plugin/deleteBatch',
        importJarUrl: '/plugin/uploadInstallPluginJar',
      },
    }
  },
  computed: {
    importUrl: function () {
      return `${window._CONFIG['domianURL']}${this.url.importJarUrl}`
    },
  },
  methods: {
    getQueryParams() {
      // Obtenir les conditions de recherche
      let sqp = {}
      if (this.superQueryParams) {
        sqp['superQueryParams'] = encodeURI(this.superQueryParams)
        sqp['superQueryMatchType'] = this.superQueryMatchType
      }
      let param = {}
      param.name = this.queryParam.name
      param.currentPage = this.ipagination.current
      param.pageSize = this.ipagination.pageSize
      return filterObj(param)
    },
    writeCode() {
      this.$refs.modalForm.edit()
      this.$refs.modalForm.title = "Saisir le code d'activation du plugin"
      this.$refs.modalForm.disableSubmit = false
    },
    writeAppCode() {
      this.$refs.appModalForm.edit()
      this.$refs.appModalForm.title = "Saisir le code d'activation mobile"
      this.$refs.appModalForm.disableSubmit = false
    },
    linkUrl(record) {
      let desc = record.pluginDescriptor.pluginDescription
      if (desc.indexOf('|')) {
        let arr = desc.split('|')
        return arr[1]
      } else {
        return ''
      }
    },
    uploadTemplate(record) {
      var rootPath = record.path.substring(0, record.path.indexOf('plugins'))
      this.$message.info(
        'Veuillez télécharger la page vers le répertoire du serveur : ' + ' /répertoire racine frontend/plugins/'
      )
    },
    startPlugin(pluginId) {
      postAction('/plugin/start/' + pluginId).then((res) => {
        if (res && res.code == 200) {
          this.loadData()
        }
      })
    },
    stopPlugin(pluginId) {
      postAction('/plugin/stop/' + pluginId).then((res) => {
        if (res && res.code == 200) {
          this.loadData()
        }
      })
    },
    uninstallPlugin(pluginId) {
      postAction('/plugin/uninstall/' + pluginId).then((res) => {
        if (res && res.code == 200) {
          this.loadData()
        }
      })
    },
    handleImportJar(info) {
      if (info.file.status !== 'uploading') {
        console.log(info.file, info.fileList)
      }
      if (info.file.status === 'done') {
        if (info.file.response) {
          if (info.file.response.code === 200) {
            this.$message.success(info.file.response.data)
            this.loadData()
          } else {
            this.$message.error(info.file.response.data)
          }
        } else {
          this.$message.error(info.file.response.data)
        }
      } else if (info.file.status === 'error') {
        this.$message.error(`文件上传失败: ${info.file.msg} `)
      }
    },
  },
}
</script>
<style scoped>
@import '~@assets/less/common.less';
</style>
