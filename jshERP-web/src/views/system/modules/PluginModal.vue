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
      <a-spin :spinning="confirmLoading">
        <a-form :form="form">
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Code machine">
            <a-input v-decorator.trim="['platformKey']" :readOnly="true" />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Code d'activation du plugin">
            <a-textarea
              :rows="2"
              placeholder="Veuillez saisir le code d'activation du plugin"
              v-decorator="['platformValue']"
            />
          </a-form-item>
        </a-form>
      </a-spin>
    </a-modal>
  </div>
</template>
<script>
import pick from 'lodash.pick'
import { getPlatformConfigByKey } from '@/api/api'
import { mixinDevice } from '@/utils/mixin'
import { getAction, postAction } from '../../../api/manage'
export default {
  name: 'PluginModal',
  mixins: [mixinDevice],
  data() {
    return {
      title: 'Opération',
      visible: false,
      model: {},
      machineCode: '',
      activationCode: '',
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
    }
  },
  created() {},
  methods: {
    edit() {
      this.form.resetFields()
      this.model = Object.assign({}, {})
      getAction('/plugin/getMacWithSecret').then((res) => {
        if (res && res.code == 200) {
          this.model.platformKey = res.data
          getPlatformConfigByKey({ platformKey: 'activation_code' }).then((res) => {
            if (res && res.code == 200) {
              this.model.platformValue = res.data.platformValue
              this.visible = true
              this.$nextTick(() => {
                this.form.setFieldsValue(pick(this.model, 'platformKey', 'platformValue'))
              })
            }
          })
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
          formData.platformKey = 'activation_code'
          postAction('/platformConfig/updatePlatformConfigByKey', formData)
            .then((res) => {
              if (res.code === 200) {
                that.$message.info('Enregistrement réussi !')
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
  },
}
</script>
<style scoped></style>
