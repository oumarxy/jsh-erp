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
      style="top: 20%; height: 45%"
    >
      <template slot="footer">
        <a-button key="back" v-if="isReadOnly" @click="handleCancel"> Annuler </a-button>
      </template>
      <a-spin :spinning="confirmLoading">
        <a-form :form="form" id="personModal">
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Nom">
            <a-input placeholder="Veuillez saisir le nom" v-decorator.trim="['name', validatorRules.name]" />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Type">
            <a-select placeholder="Veuillez sélectionner le type" v-decorator="['type', validatorRules.type]">
              <a-select-option value="销售员">Vendeur</a-select-option>
              <a-select-option value="财务员">Comptable</a-select-option>
            </a-select>
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Tri">
            <a-input placeholder="Veuillez saisir le tri" v-decorator.trim="['sort']" />
          </a-form-item>
        </a-form>
      </a-spin>
    </a-modal>
  </div>
</template>
<script>
import pick from 'lodash.pick'
import { addPerson, editPerson, checkPerson } from '@/api/api'
import { autoJumpNextInput } from '@/utils/util'
import { mixinDevice } from '@/utils/mixin'
export default {
  name: 'PersonModal',
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
            { validator: this.validatePersonName },
          ],
        },
        type: {
          rules: [{ required: true, message: 'Veuillez sélectionner le type!' }],
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
        this.form.setFieldsValue(pick(this.model, 'name', 'type', 'sort'))
        autoJumpNextInput('personModal')
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
            obj = addPerson(formData)
          } else {
            obj = editPerson(formData)
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
    validatePersonName(rule, value, callback) {
      let params = {
        name: value,
        id: this.model.id ? this.model.id : 0,
      }
      checkPerson(params).then((res) => {
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
