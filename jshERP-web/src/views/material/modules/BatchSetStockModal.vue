<template>
  <div ref="container">
    <a-modal
      :title="title"
      :width="500"
      :visible="visible"
      :confirm-loading="confirmLoading"
      :getContainer="() => $refs.container"
      :maskStyle="{ top: '93px', left: '154px' }"
      :wrapClassName="wrapClassNameInfo()"
      :mask="isDesktop()"
      :maskClosable="false"
      @ok="handleOk"
      @cancel="handleCancel"
      cancelText="Annuler"
      okText="Enregistrer"
      style="top: 30%; height: 30%"
    >
      <template slot="footer">
        <a-button key="back" v-if="isReadOnly" @click="handleCancel"> Annuler </a-button>
      </template>
      <a-spin :spinning="confirmLoading">
        <a-form :form="form">
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Veuillez saisir la quantité">
            <a-input placeholder="Veuillez saisir la quantité" v-decorator.trim="['number', validatorRules.number]" />
          </a-form-item>
        </a-form>
      </a-spin>
    </a-modal>
  </div>
</template>

<script>
import { mixinDevice } from '@/utils/mixin'
export default {
  name: 'BatchSetStockModal',
  mixins: [mixinDevice],
  data() {
    return {
      title: 'Paramétrage en lot',
      visible: false,
      isReadOnly: false,
      batchType: '',
      model: {},
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
        number: {
          rules: [{ required: true, message: 'Veuillez saisir la quantité !' }],
        },
      },
    }
  },
  created() {},
  methods: {
    add(type) {
      this.batchType = type
      if (type === 'initStock') {
        this.title = 'Stock initial - Paramétrage en lot'
      } else if (type === 'lowSafeStock') {
        this.title = 'Stock de sécurité minimum - Paramétrage en lot'
      } else if (type === 'highSafeStock') {
        this.title = 'Stock de sécurité maximum - Paramétrage en lot'
      }
      this.edit({})
    },
    edit(record) {
      this.form.resetFields()
      this.model = Object.assign({}, record)
      this.visible = true
    },
    close() {
      this.$emit('close')
      this.visible = false
    },
    handleOk() {
      let number = this.form.getFieldValue('number')
      this.$emit('ok', number, this.batchType)
      this.visible = false
    },
    handleCancel() {
      this.close()
    },
  },
}
</script>

<style scoped></style>
