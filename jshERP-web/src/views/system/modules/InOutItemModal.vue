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
      style="top: 20%; height: 50%"
    >
      <template slot="footer">
        <a-button key="back" v-if="isReadOnly" @click="handleCancel"> Annuler </a-button>
      </template>
      <a-spin :spinning="confirmLoading">
        <a-form :form="form" id="inOutItemModal">
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Nom">
            <a-input placeholder="Veuillez saisir le nom" v-decorator.trim="['name', validatorRules.name]" />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Type">
            <a-select
              placeholder="Veuillez sélectionner le type"
              v-decorator="['type', validatorRules.type]"
              :disabled="typeDisabled"
            >
              <a-select-option value="收入">Revenu</a-select-option>
              <a-select-option value="支出">Dépense</a-select-option>
            </a-select>
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
import { addInOutItem, editInOutItem, checkInOutItem } from '@/api/api'
import { autoJumpNextInput } from '@/utils/util'
import { mixinDevice } from '@/utils/mixin'
export default {
  name: 'InOutItemModal',
  mixins: [mixinDevice],
  data() {
    return {
      title: 'Opération',
      visible: false,
      model: {},
      typeParam: '',
      isReadOnly: false,
      typeDisabled: false,
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
    add(type) {
      this.typeParam = type
      this.edit({})
    },
    edit(record) {
      this.form.resetFields()
      this.model = Object.assign({}, record)
      if (this.typeParam) {
        this.typeDisabled = true
        if (this.typeParam === 'in') {
          this.model.type = '收入'
        } else if (this.typeParam === 'out') {
          this.model.type = '支出'
        }
      } else {
        this.typeDisabled = false
      }
      this.visible = true
      this.$nextTick(() => {
        this.form.setFieldsValue(pick(this.model, 'name', 'type', 'sort', 'remark'))
        autoJumpNextInput('inOutItemModal')
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
            obj = addInOutItem(formData)
          } else {
            obj = editInOutItem(formData)
          }
          obj
            .then((res) => {
              if (res.code === 200) {
                that.$emit('ok')
                that.confirmLoading = false
                that.close()
              } else {
                that.$message.warning(res.data.message)
                that.confirmLoading = false
              }
            })
            .finally(() => {})
        }
      })
    },
    handleCancel() {
      this.close()
    },
  },
}
</script>
<style scoped></style>
