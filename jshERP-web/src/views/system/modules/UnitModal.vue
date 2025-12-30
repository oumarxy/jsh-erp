<template>
  <div ref="container">
    <a-modal
      :title="title"
      :width="700"
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
      style="top: 100px; height: 55%"
    >
      <template slot="footer">
        <a-button key="back" v-if="isReadOnly" @click="handleCancel"> Annuler </a-button>
      </template>
      <a-spin :spinning="confirmLoading">
        <a-form :form="form" id="unitModal">
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Unité de base">
            <a-input
              placeholder="Veuillez saisir l'unité de base (petite unité)"
              v-decorator.trim="['basicUnit', validatorRules.basicUnit]"
            />
          </a-form-item>
        </a-form>
        <a-form :form="form">
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Unité secondaire">
            <a-input
              placeholder="Veuillez saisir l'unité secondaire (grande unité)"
              style="width: 48%"
              v-decorator.trim="['otherUnit']"
            />
            =
            <a-input
              suffix="Unité de base"
              placeholder="Veuillez saisir le ratio"
              style="width: 48%"
              v-decorator.trim="['ratio']"
            />
          </a-form-item>
        </a-form>
        <a-form :form="form">
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Unité secondaire 2">
            <a-input
              placeholder="Veuillez saisir l'unité secondaire 2 (grande unité)"
              style="width: 48%"
              v-decorator.trim="['otherUnitTwo']"
            />
            =
            <a-input
              suffix="Unité de base"
              placeholder="Veuillez saisir le ratio 2"
              style="width: 48%"
              v-decorator.trim="['ratioTwo']"
            />
          </a-form-item>
        </a-form>
        <a-form :form="form">
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Unité secondaire 3">
            <a-input
              placeholder="Veuillez saisir l'unité secondaire 3 (grande unité)"
              style="width: 48%"
              v-decorator.trim="['otherUnitThree']"
            />
            =
            <a-input
              suffix="Unité de base"
              placeholder="Veuillez saisir le ratio 3"
              style="width: 48%"
              v-decorator.trim="['ratioThree']"
            />
          </a-form-item>
        </a-form>
      </a-spin>
    </a-modal>
  </div>
</template>
<script>
import pick from 'lodash.pick'
import { addUnit, editUnit, checkUnit } from '@/api/api'
import { autoJumpNextInput } from '@/utils/util'
import { isDecimalThree } from '@/utils/validate'
import { mixinDevice } from '@/utils/mixin'
export default {
  name: 'UnitModal',
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
        basicUnit: {
          rules: [
            { required: true, message: "Veuillez saisir l'unité de base!" },
            { min: 1, max: 10, message: 'La longueur doit être entre 1 et 10 caractères', trigger: 'blur' },
          ],
        },
        otherUnit: {
          rules: [
            { required: true, message: "Veuillez saisir l'unité secondaire!" },
            { min: 1, max: 10, message: 'La longueur doit être entre 1 et 10 caractères', trigger: 'blur' },
          ],
        },
        ratio: {
          rules: [{ required: true, message: 'Veuillez saisir le ratio!' }, { validator: this.validateRatio }],
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
          pick(
            this.model,
            'basicUnit',
            'otherUnit',
            'ratio',
            'otherUnitTwo',
            'ratioTwo',
            'otherUnitThree',
            'ratioThree'
          )
        )
        autoJumpNextInput('unitModal')
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
          if (!formData.otherUnit) {
            that.$message.warning("Désolé, l'unité secondaire ne peut pas être vide !")
            that.confirmLoading = false
            return
          }
          if (formData.otherUnit) {
            if (!formData.ratio) {
              that.$message.warning('Désolé, le ratio ne peut pas être vide !')
              that.confirmLoading = false
              return
            }
            if (!isDecimalThree(formData.ratio)) {
              that.$message.warning("Désolé, le ratio ne peut être qu'un nombre, avec au maximum trois décimales !")
              that.confirmLoading = false
              return
            }
          }
          if (formData.otherUnitTwo) {
            if (!formData.ratioTwo) {
              that.$message.warning('Désolé, le ratio 2 ne peut pas être vide !')
              that.confirmLoading = false
              return
            }
            if (!isDecimalThree(formData.ratioTwo)) {
              that.$message.warning("Désolé, le ratio 2 ne peut être qu'un nombre, avec au maximum trois décimales !")
              that.confirmLoading = false
              return
            }
          }
          if (formData.otherUnitThree) {
            if (!formData.ratioThree) {
              that.$message.warning('Désolé, le ratio 3 ne peut pas être vide !')
              that.confirmLoading = false
              return
            }
            if (!isDecimalThree(formData.ratioThree)) {
              that.$message.warning("Désolé, le ratio 3 ne peut être qu'un nombre, avec au maximum trois décimales !")
              that.confirmLoading = false
              return
            }
          }
          if (!formData.otherUnitTwo && formData.otherUnitThree) {
            that.$message.warning("Désolé, vous devez d'abord saisir l'unité secondaire 2 avant l'unité secondaire 3 !")
            that.confirmLoading = false
            return
          }
          if (formData.basicUnit === formData.otherUnit) {
            that.$message.warning("Désolé, l'unité de base et l'unité secondaire ne peuvent pas être identiques !")
            that.confirmLoading = false
            return
          }
          if (formData.basicUnit === formData.otherUnitTwo) {
            that.$message.warning("Désolé, l'unité de base et l'unité secondaire 2 ne peuvent pas être identiques !")
            that.confirmLoading = false
            return
          }
          if (formData.basicUnit === formData.otherUnitThree) {
            that.$message.warning("Désolé, l'unité de base et l'unité secondaire 3 ne peuvent pas être identiques !")
            that.confirmLoading = false
            return
          }
          let obj
          if (!this.model.id) {
            obj = addUnit(formData)
          } else {
            obj = editUnit(formData)
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
    validateRatio(rule, value, callback) {
      if (value > 1) {
        callback()
      } else {
        callback('Le ratio doit être supérieur à 1')
      }
    },
  },
}
</script>
<style scoped></style>
