<template>
  <div ref="container">
    <a-modal
      :title="title"
      :width="1200"
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
      <template slot="footer">
        <a-button key="back" v-if="isReadOnly" @click="handleCancel"> Annuler </a-button>
      </template>
      <a-spin :spinning="confirmLoading">
        <a-form :form="form" id="memberModal">
          <a-row class="form-row" :gutter="24">
            <a-col :span="24 / 2">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de carte membre">
                <a-input
                  placeholder="Veuillez saisir le numéro de carte membre"
                  v-decorator.trim="['supplier', validatorRules.supplier]"
                />
              </a-form-item>
            </a-col>
            <a-col :span="24 / 2">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Contact">
                <a-input placeholder="Veuillez saisir le contact" v-decorator.trim="['contacts']" />
              </a-form-item>
            </a-col>
          </a-row>
          <a-row class="form-row" :gutter="24">
            <a-col :span="24 / 2">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de téléphone portable">
                <a-input
                  placeholder="Veuillez saisir le numéro de téléphone portable"
                  v-decorator.trim="['telephone']"
                />
              </a-form-item>
            </a-col>
            <a-col :span="24 / 2">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de téléphone">
                <a-input placeholder="Veuillez saisir le numéro de téléphone" v-decorator.trim="['phoneNum']" />
              </a-form-item>
            </a-col>
            <a-col :span="24 / 2">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Adresse e-mail">
                <a-input placeholder="Veuillez saisir l'adresse e-mail" v-decorator.trim="['email']" />
              </a-form-item>
            </a-col>
            <a-col :span="24 / 2">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Tri">
                <a-input placeholder="Veuillez saisir le tri" v-decorator.trim="['sort']" />
              </a-form-item>
            </a-col>
            <a-col :span="24 / 2">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Remarque">
                <a-textarea :rows="2" placeholder="Veuillez saisir une remarque" v-decorator.trim="['description']" />
              </a-form-item>
            </a-col>
          </a-row>
        </a-form>
      </a-spin>
    </a-modal>
  </div>
</template>
<script>
import pick from 'lodash.pick'
import { addSupplier, editSupplier, checkSupplier } from '@/api/api'
import { autoJumpNextInput } from '@/utils/util'
import { mixinDevice } from '@/utils/mixin'
export default {
  name: 'MemberModal',
  mixins: [mixinDevice],
  data() {
    return {
      title: 'Opération',
      visible: false,
      model: {},
      isReadOnly: false,
      labelCol: {
        xs: { span: 24 },
        sm: { span: 4 },
      },
      wrapperCol: {
        xs: { span: 24 },
        sm: { span: 20 },
      },
      confirmLoading: false,
      form: this.$form.createForm(this),
      validatorRules: {
        supplier: {
          rules: [
            { required: true, message: 'Veuillez saisir le numéro de carte membre!' },
            { min: 2, max: 60, message: 'La longueur doit être entre 2 et 60 caractères', trigger: 'blur' },
            { validator: this.validateSupplierName },
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
        this.form.setFieldsValue(
          pick(this.model, 'supplier', 'contacts', 'telephone', 'email', 'phoneNum', 'sort', 'description')
        )
        autoJumpNextInput('memberModal')
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
          if (this.model.beginNeedGet && this.model.beginNeedPay) {
            that.$message.warn(
              'Les créances initiales et les dettes initiales ne peuvent pas être saisies simultanément'
            )
            that.confirmLoading = false
            return
          }
          formData.type = '会员'
          let obj
          if (!this.model.id) {
            obj = addSupplier(formData)
          } else {
            obj = editSupplier(formData)
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
    validateSupplierName(rule, value, callback) {
      let params = {
        name: value,
        type: '会员',
        id: this.model.id ? this.model.id : 0,
      }
      checkSupplier(params).then((res) => {
        if (res && res.code === 200) {
          if (!res.data.status) {
            callback()
          } else {
            callback('Le numéro de carte membre existe déjà')
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
