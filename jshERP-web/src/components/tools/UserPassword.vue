<template>
  <div ref="container">
    <a-modal
      :title="title"
      :width="modalWidth"
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
      style="top: 20%; height: 50%"
    >
      <a-spin :spinning="confirmLoading">
        <a-form :form="form">
          <a-form-item label="Ancien mot de passe" :labelCol="labelCol" :wrapperCol="wrapperCol">
            <a-input-password
              type="password"
              placeholder="Veuillez saisir l'ancien mot de passe"
              v-decorator="['oldpassword', validatorRules.oldpassword]"
            />
          </a-form-item>
          <a-form-item label="Nouveau mot de passe" :labelCol="labelCol" :wrapperCol="wrapperCol">
            <a-input-password
              type="password"
              placeholder="Le nouveau mot de passe doit contenir au moins 6 caractères, sensible à la casse"
              v-decorator="['password', validatorRules.password]"
            />
          </a-form-item>
          <a-form-item label="Confirmer le nouveau mot de passe" :labelCol="labelCol" :wrapperCol="wrapperCol">
            <a-input-password
              type="password"
              placeholder="Veuillez confirmer le nouveau mot de passe"
              v-decorator="['confirmPassword', validatorRules.confirmPassword]"
            />
          </a-form-item>
        </a-form>
      </a-spin>
    </a-modal>
  </div>
</template>

<script>
import { putAction } from '@/api/manage'
import { mixinDevice } from '@/utils/mixin'
import md5 from 'md5'
export default {
  name: 'UserPassword',
  mixins: [mixinDevice],
  data() {
    return {
      title: 'Modifier le mot de passe',
      modalWidth: 800,
      visible: false,
      confirmLoading: false,
      validatorRules: {
        oldpassword: {
          rules: [
            {
              required: true,
              message: "Veuillez saisir l'ancien mot de passe !",
            },
          ],
        },
        password: {
          rules: [
            { required: true, message: 'Veuillez saisir le nouveau mot de passe !' },
            { validator: this.handlePassword },
          ],
          validateTrigger: ['change', 'blur'],
          validateFirst: true,
        },
        confirmPassword: {
          rules: [
            { required: true, message: 'Veuillez confirmer le nouveau mot de passe !' },
            { validator: this.handleConfirmPassword },
          ],
          validateTrigger: ['change', 'blur'],
          validateFirst: true,
        },
      },
      confirmDirty: false,
      labelCol: {
        xs: { span: 24 },
        sm: { span: 5 },
      },
      wrapperCol: {
        xs: { span: 24 },
        sm: { span: 16 },
      },
      form: this.$form.createForm(this),
      url: '/user/updatePwd',
      userId: '',
    }
  },
  methods: {
    show(userId) {
      if (!userId) {
        this.$message.warning('Aucun utilisateur connecté dans le système actuel !')
      } else {
        this.userId = userId
        this.form.resetFields()
        this.visible = true
      }
    },
    handleCancel() {
      this.close()
    },
    close() {
      this.$emit('close')
      this.visible = false
      this.disableSubmit = false
    },
    handleOk() {
      const that = this
      // 触发表单验证
      this.form.validateFields((err, values) => {
        if (!err) {
          that.confirmLoading = true
          values.oldpassword = md5(values.oldpassword)
          values.password = md5(values.password)
          let params = Object.assign({ userId: this.userId }, values)
          console.log('修改密码提交数据', params)
          putAction(this.url, params)
            .then((res) => {
              if (res.code === 200) {
                if (res.data.status === 2 || res.data.status === 3) {
                  that.$message.warning(res.data.message)
                } else {
                  that.$message.success(res.data.message)
                  that.close()
                }
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
    handlePassword(rule, value, callback) {
      let oldpassword = this.form.getFieldValue('oldpassword')
      if (oldpassword === value) {
        callback(new Error("Le nouveau mot de passe ne peut pas être identique à l'ancien !"))
      }
      let reg = /^(?=.*[a-z])(?=.*\d).{6,}$/
      if (!reg.test(value)) {
        callback(new Error('Le mot de passe doit être composé de 6 chiffres et lettres minuscules !'))
      }
      callback()
    },
    handleConfirmPassword(rule, value, callback) {
      let password = this.form.getFieldValue('password')
      if (value === undefined) {
        callback(new Error('Veuillez saisir le mot de passe !'))
      }
      if (value && password && value.trim() !== password.trim()) {
        callback(new Error('Les deux mots de passe ne correspondent pas !'))
      }
      callback()
    },
  },
}
</script>

<style scoped></style>
