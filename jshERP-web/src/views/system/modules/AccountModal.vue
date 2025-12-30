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
      style="top: 15%; height: 55%"
    >
      <template slot="footer">
        <a-button key="back" v-if="isReadOnly" @click="handleCancel"> Annuler </a-button>
      </template>
      <a-spin :spinning="confirmLoading">
        <a-form :form="form" id="accountModal">
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Nom">
            <a-input placeholder="Veuillez saisir le nom" v-decorator.trim="['name', validatorRules.name]" />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro">
            <a-input placeholder="Veuillez saisir le numéro" v-decorator.trim="['serialNo']" />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Montant initial">
            <a-input placeholder="Veuillez saisir le montant initial" v-decorator.trim="['initialAmount']" />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Tri">
            <a-input placeholder="Veuillez saisir le tri" v-decorator.trim="['sort']" />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Remarque">
            <a-textarea :rows="2" placeholder="Veuillez saisir une remarque" v-decorator="['remark']" />
          </a-form-item>
        </a-form>
      </a-spin>
    </a-modal>
  </div>
</template>
<script>
import pick from 'lodash.pick'
import { addAccount, editAccount, checkAccount } from '@/api/api'
import { autoJumpNextInput } from '@/utils/util'
import { mixinDevice } from '@/utils/mixin'
export default {
  name: 'AccountModal',
  mixins: [mixinDevice],
  data() {
    return {
      title: 'Opération',
      visible: false,
      model: {},
      isReadOnly: false,
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
        name: {
          rules: [
            { required: true, message: 'Veuillez saisir le nom!' },
            { min: 2, max: 30, message: 'La longueur doit être entre 2 et 30 caractères', trigger: 'blur' },
            { validator: this.validateAccountName },
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
      this.visible = true
      this.$nextTick(() => {
        this.form.setFieldsValue(pick(this.model, 'name', 'serialNo', 'initialAmount', 'sort', 'remark'))
        autoJumpNextInput('accountModal')
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
            obj = addAccount(formData)
          } else {
            obj = editAccount(formData)
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
    validateAccountName(rule, value, callback) {
      let params = {
        name: value,
        id: this.model.id ? this.model.id : 0,
      }
      checkAccount(params).then((res) => {
        if (res && res.code === 200) {
          if (!res.data.status) {
            callback()
          } else {
            callback('Le nom existe déjà')
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
