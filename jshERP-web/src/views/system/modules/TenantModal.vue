<template>
  <div ref="container">
    <a-modal
      :title="title"
      :width="600"
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
      style="top: 15%; height: 60%"
    >
      <a-spin :spinning="confirmLoading">
        <a-form :form="form">
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Nom de connexion">
            <a-input
              placeholder="Veuillez saisir le nom de connexion"
              v-decorator.trim="['loginName', validatorRules.loginName]"
              :readOnly="!!model.id"
              suffix="Mot de passe initial : 123456"
            />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Limite du nombre d'utilisateurs">
            <a-input-number
              style="width: 100%"
              placeholder="Veuillez saisir la limite du nombre d'utilisateurs"
              v-decorator.trim="['userNumLimit']"
            />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Rôle du locataire" v-if="model.id">
            <a-select
              style="width: 100%"
              placeholder="Veuillez sélectionner le rôle du locataire"
              v-decorator.trim="['roleId']"
            >
              <a-select-option v-for="(item, index) in tenantRoleList" :key="index" :value="item.id">
                {{ item.name }}
              </a-select-option>
            </a-select>
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Type de locataire" v-if="model.id">
            <a-select
              style="width: 100%"
              placeholder="Veuillez sélectionner le type de locataire"
              v-decorator.trim="['type']"
            >
              <a-select-option value="0">Locataire d'essai</a-select-option>
              <a-select-option value="1">Locataire payant</a-select-option>
            </a-select>
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Date d'expiration">
            <j-date
              style="width: 100%"
              placeholder="Veuillez sélectionner la date d'expiration"
              v-decorator.trim="['expireTime']"
              :show-time="true"
            />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Remarque">
            <a-textarea :rows="2" placeholder="Veuillez saisir une remarque (WeChat)" v-decorator.trim="['remark']" />
          </a-form-item>
        </a-form>
      </a-spin>
    </a-modal>
  </div>
</template>
<script>
import pick from 'lodash.pick'
import { mixinDevice } from '@/utils/mixin'
import { addTenant, editTenant, checkTenant, getTenantRoleList } from '@/api/api'
import JDate from '@/components/jeecg/JDate'
import md5 from 'md5'
export default {
  name: 'TenantModal',
  mixins: [mixinDevice],
  components: {
    JDate,
  },
  data() {
    return {
      title: 'Opération',
      visible: false,
      model: {},
      tenantRoleList: [], // Liste des rôles du locataire
      labelCol: {
        xs: { span: 24 },
        sm: { span: 5 },
      },
      wrapperCol: {
        xs: { span: 24 },
        sm: { span: 16 },
      },
      confirmLoading: false,
      form: this.$form.createForm(this),
      validatorRules: {
        loginName: {
          rules: [
            { required: true, message: 'Veuillez saisir le nom de connexion!' },
            { min: 2, max: 30, message: 'La longueur doit être entre 2 et 30 caractères', trigger: 'blur' },
            { validator: this.validateLoginName },
          ],
        },
      },
    }
  },
  created() {},
  methods: {
    add() {
      this.edit({})
    },
    edit(record) {
      this.form.resetFields()
      this.model = Object.assign({}, record)
      this.model.expireTime = this.model.expireTimeStr
      this.visible = true
      this.$nextTick(() => {
        this.form.setFieldsValue(
          pick(this.model, 'loginName', 'userNumLimit', 'type', 'roleId', 'expireTime', 'remark')
        )
      })
      this.getTenantRoleList()
    },
    getTenantRoleList() {
      getTenantRoleList().then((res) => {
        if (res) {
          this.tenantRoleList = res
        }
      })
    },
    close() {
      this.$emit('close')
      this.visible = false
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
            formData.password = md5('123456')
            obj = addTenant(formData)
          } else {
            obj = editTenant(formData)
          }
          obj
            .then((res) => {
              if (res.code === 200) {
                that.$emit('ok')
              } else {
                that.$message.warning(res.data.message)
              }
            })
            .finally(() => {
              that.confirmLoading = false
              that.close()
            })
        }
      })
    },
    handleCancel() {
      this.close()
    },
    validateLoginName(rule, value, callback) {
      let params = {
        name: value,
        id: this.model.id ? this.model.id : 0,
      }
      checkTenant(params).then((res) => {
        if (res && res.code === 200) {
          if (!res.data.status) {
            callback()
          } else {
            callback('Le nom de connexion existe déjà')
          }
        } else {
          callback(res.data)
        }
      })
    },
  },
}
</script>
<style scoped></style>
