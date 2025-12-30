<template>
  <div ref="container">
    <a-modal
      :title="title"
      :width="800"
      :visible="visible"
      :confirmLoading="confirmLoading"
      :getContainer="() => $refs.container"
      :maskStyle="{ top: '93px', left: '154px' }"
      :wrapClassName="wrapClassNameInfo()"
      :mask="isDesktop()"
      :maskClosable="false"
      @ok="handleOk"
      @cancel="handleCancel"
      cancelText="Annuler"
      okText="Enregistrer"
      style="top: 5%; height: 85%"
    >
      <template slot="footer">
        <a-button key="back" v-if="isReadOnly" @click="handleCancel"> Annuler </a-button>
      </template>
      <a-spin :spinning="confirmLoading">
        <a-form :form="form" id="userModal">
          <a-form-item label="Nom de connexion" :labelCol="labelCol" :wrapperCol="wrapperCol">
            <a-input
              placeholder="Veuillez saisir le nom de connexion"
              v-decorator.trim="['loginName', validatorRules.loginName]"
              :readOnly="!!model.id"
              suffix="Mot de passe initial : 123456"
            />
          </a-form-item>
          <a-form-item label="Nom d'utilisateur" :labelCol="labelCol" :wrapperCol="wrapperCol">
            <a-input
              placeholder="Veuillez saisir le nom d'utilisateur"
              v-decorator.trim="['username', validatorRules.username]"
            />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Rôle">
            <a-select
              v-if="!model.id || model.id !== model.tenantId"
              placeholder="Sélectionner un rôle"
              v-decorator="['roleId', validatorRules.roleId]"
              :dropdownMatchSelectWidth="false"
            >
              <a-select-option v-for="(item, index) in roleList" :key="index" :value="item.id">
                {{ item.name }}
              </a-select-option>
            </a-select>
            <a-col v-if="model.id === model.tenantId"
              ><a-row>{{ tenantRoleName }}</a-row></a-col
            >
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Organisation">
            <a-tree-select
              style="width: 100%"
              :dropdownStyle="{ maxHeight: '200px', overflow: 'auto' }"
              allow-clear
              :treeData="orgaTree"
              v-decorator="['orgaId']"
              placeholder="Veuillez sélectionner une organisation"
            >
            </a-tree-select>
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Poste">
            <a-input placeholder="Veuillez saisir le poste" v-decorator.trim="['position']" />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Est-ce un manager">
            <a-select placeholder="Veuillez sélectionner si c'est un manager" v-decorator="['leaderFlag']">
              <a-select-option value="1">Oui</a-select-option>
              <a-select-option value="0">Non</a-select-option>
            </a-select>
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de téléphone">
            <a-input placeholder="Veuillez saisir le numéro de téléphone" v-decorator.trim="['phonenum']" />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Adresse e-mail">
            <a-input placeholder="Veuillez saisir l'adresse e-mail" v-decorator.trim="['email']" />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Tri">
            <a-input placeholder="Veuillez saisir le tri" v-decorator.trim="['userBlngOrgaDsplSeq']" />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Remarque">
            <a-textarea :rows="2" placeholder="Veuillez saisir une remarque" v-decorator="['description']" />
          </a-form-item>
        </a-form>
      </a-spin>
    </a-modal>
  </div>
</template>
<script>
import pick from 'lodash.pick'
import Vue from 'vue'
import JSelectPosition from '@/components/jeecgbiz/JSelectPosition'
import { ACCESS_TOKEN } from '@/store/mutation-types'
import { getAction } from '@/api/manage'
import { addUser, editUser, queryOrganizationTreeList, roleAllList } from '@/api/api'
import { disabledAuthFilter } from '@/utils/authFilter'
import { autoJumpNextInput } from '@/utils/util'
import { mixinDevice } from '@/utils/mixin'
import JImageUpload from '../../../components/jeecg/JImageUpload'
export default {
  name: 'UserModal',
  mixins: [mixinDevice],
  components: {
    JImageUpload,
    JSelectPosition,
  },
  data() {
    return {
      title: 'Opération',
      visible: false,
      modalWidth: 800,
      drawerWidth: 700,
      orgaTree: [],
      roleList: [],
      userId: '', // Enregistrer l'ID utilisateur
      tenantRoleName: '', // Nom du rôle du locataire
      isReadOnly: false,
      disableSubmit: false,
      dateFormat: 'YYYY-MM-DD',
      validatorRules: {
        loginName: {
          rules: [
            {
              required: true,
              message: 'Veuillez saisir le nom de connexion!',
            },
          ],
        },
        username: {
          rules: [
            {
              required: true,
              message: "Veuillez saisir le nom d'utilisateur!",
            },
          ],
        },
        roleId: {
          rules: [
            {
              required: true,
              message: 'Veuillez sélectionner un rôle!',
            },
          ],
        },
      },
      model: {},
      labelCol: {
        xs: { span: 24 },
        sm: { span: 5 },
      },
      wrapperCol: {
        xs: { span: 24 },
        sm: { span: 16 },
      },
      uploadLoading: false,
      confirmLoading: false,
      headers: {},
      form: this.$form.createForm(this),
    }
  },
  created() {
    const token = Vue.ls.get(ACCESS_TOKEN)
    this.headers = { 'X-Access-Token': token }
  },
  methods: {
    add() {
      this.edit({})
    },
    edit(record) {
      this.loadOrgaData()
      this.loadRoleData()
      this.form.resetFields()
      this.userId = record.id
      this.visible = true
      this.model = Object.assign({}, record)
      this.$nextTick(() => {
        this.form.setFieldsValue(
          pick(
            this.model,
            'loginName',
            'username',
            'roleId',
            'orgaId',
            'position',
            'leaderFlag',
            'phonenum',
            'email',
            'userBlngOrgaDsplSeq',
            'description'
          )
        )
        this.tenantRoleName = this.model.roleName
        autoJumpNextInput('userModal')
      })
    },
    close() {
      this.$emit('close')
      this.visible = false
      this.disableSubmit = false
    },
    handleOk() {
      const that = this
      // Déclencher la validation du formulaire
      this.form.validateFields((err, values) => {
        if (!err) {
          that.confirmLoading = true
          let formData = Object.assign(this.model, values)
          let obj
          if (!this.model.id) {
            formData.id = this.userId
            obj = addUser(formData)
          } else {
            obj = editUser(formData)
          }
          obj
            .then((res) => {
              if (res.code === 200) {
                that.$emit('ok')
                that.close()
              } else {
                that.$message.warning(res.data.message)
              }
            })
            .finally(() => {
              that.confirmLoading = false
            })
        }
      })
    },
    handleCancel() {
      this.close()
    },
    loadOrgaData() {
      let that = this
      let params = {}
      params.id = ''
      queryOrganizationTreeList(params).then((res) => {
        if (res) {
          that.orgaTree = res
        }
      })
    },
    loadRoleData() {
      roleAllList({}).then((res) => {
        if (res) {
          this.roleList = res
        }
      })
    },
  },
}
</script>

<style scoped></style>
