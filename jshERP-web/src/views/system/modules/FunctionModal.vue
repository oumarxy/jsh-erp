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
      style="top: 5%; height: 90%"
    >
      <template slot="footer">
        <a-button key="back" v-if="isReadOnly" @click="handleCancel"> Annuler </a-button>
      </template>
      <a-spin :spinning="confirmLoading">
        <a-form :form="form" id="functionModal">
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro">
            <a-input placeholder="Veuillez saisir le numéro" v-decorator.trim="['number', validatorRules.number]" />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Nom">
            <a-input placeholder="Veuillez saisir le nom" v-decorator.trim="['name', validatorRules.name]" />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro parent">
            <a-input-search
              placeholder="Veuillez sélectionner le numéro parent"
              v-decorator.trim="['parentNumber', validatorRules.parentNumber]"
              @search="onSearchParentNumber"
              :readOnly="true"
            />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Nom parent">
            <a-input v-decorator.trim="['parentName']" :readOnly="true" />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Lien">
            <a-input placeholder="Veuillez saisir le lien" v-decorator.trim="['url', validatorRules.url]" />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Composant">
            <a-input
              placeholder="Veuillez saisir le composant"
              v-decorator.trim="['component', validatorRules.component]"
            />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Tri">
            <a-input placeholder="Veuillez saisir le tri" v-decorator.trim="['sort', validatorRules.sort]" />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Boutons de fonction">
            <j-select-multiple
              placeholder="Veuillez sélectionner les boutons de fonction"
              v-model="jselectMultiple.value"
              :options="jselectMultiple.options"
            />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Icône">
            <a-input placeholder="Veuillez saisir l'icône" v-decorator.trim="['icon', validatorRules.icon]" />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Activer">
            <a-switch
              checked-children="Activé"
              un-checked-children="Désactivé"
              v-model="enabledSwitch"
              @change="onChange"
            />
          </a-form-item>
        </a-form>
      </a-spin>
      <function-tree-modal ref="functionTreeModal" @ok="functionTreeModalOk"></function-tree-modal>
    </a-modal>
  </div>
</template>
<script>
import pick from 'lodash.pick'
import FunctionTreeModal from './FunctionTreeModal'
import { addFunction, editFunction, checkFunction, checkNumber } from '@/api/api'
import { autoJumpNextInput } from '@/utils/util'
import { mixinDevice } from '@/utils/mixin'
import JSelectMultiple from '@/components/jeecg/JSelectMultiple'
export default {
  name: 'FunctionModal',
  mixins: [mixinDevice],
  components: {
    FunctionTreeModal,
    JSelectMultiple,
  },
  data() {
    return {
      title: 'Opération',
      visible: false,
      model: {},
      enabledSwitch: true, // Activer ou non
      isReadOnly: false,
      jselectMultiple: {
        options: [
          { text: 'Édition', value: '1' },
          { text: 'Audit', value: '2' },
          { text: 'Désaudit', value: '7' },
          { text: 'Export', value: '3' },
          { text: 'Activer/Désactiver', value: '4' },
          { text: 'Imprimer', value: '5' },
          { text: 'Annuler', value: '6' },
        ],
        value: '',
      },
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
          rules: [
            { required: true, message: 'Veuillez saisir le numéro!' },
            { min: 2, max: 30, message: 'La longueur doit être entre 2 et 30 caractères', trigger: 'blur' },
            { validator: this.validateNumber },
          ],
        },
        name: {
          rules: [
            { required: true, message: 'Veuillez saisir le nom!' },
            { min: 2, max: 30, message: 'La longueur doit être entre 2 et 30 caractères', trigger: 'blur' },
            { validator: this.validateName },
          ],
        },
        parentNumber: {
          rules: [{ required: true, message: 'Veuillez saisir le numéro parent!' }],
        },
        url: {
          rules: [{ required: true, message: 'Veuillez saisir le lien!' }],
        },
        component: {
          rules: [{ required: true, message: 'Veuillez saisir le composant!' }],
        },
        sort: {
          rules: [{ required: true, message: 'Veuillez saisir le tri!' }],
        },
        icon: {
          rules: [{ required: true, message: "Veuillez saisir l'icône!" }],
        },
      },
    }
  },
  created() {},
  methods: {
    onChange(checked) {
      this.model.enabled = checked
    },
    add() {
      this.edit({})
      this.model.enabled = true
      this.enabledSwitch = true
    },
    edit(record) {
      this.form.resetFields()
      this.model = Object.assign({}, record)
      this.visible = true
      if (record.enabled != null) {
        this.enabledSwitch = record.enabled ? true : false
      }
      if (this.model.id) {
        this.jselectMultiple.value = record.pushBtn
      } else {
        this.jselectMultiple.value = ''
      }
      this.$nextTick(() => {
        this.form.setFieldsValue(
          pick(
            this.model,
            'number',
            'name',
            'parentNumber',
            'parentName',
            'url',
            'component',
            'sort',
            'pushBtn',
            'icon',
            'enabled'
          )
        )
        autoJumpNextInput('functionModal')
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
          formData.pushBtn = this.jselectMultiple.value
          let obj
          if (!this.model.id) {
            obj = addFunction(formData)
          } else {
            obj = editFunction(formData)
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
    validateNumber(rule, value, callback) {
      let params = {
        number: value,
        id: this.model.id ? this.model.id : 0,
      }
      checkNumber(params).then((res) => {
        if (res && res.code === 200) {
          if (!res.data.status) {
            callback()
          } else {
            callback('Le numéro existe déjà !')
          }
        } else {
          callback(res.data)
        }
      })
    },
    validateName(rule, value, callback) {
      let params = {
        name: value,
        id: this.model.id ? this.model.id : 0,
      }
      checkFunction(params).then((res) => {
        if (res && res.code === 200) {
          if (!res.data.status) {
            callback()
          } else {
            callback('Le nom existe déjà !')
          }
        } else {
          callback(res.data)
        }
      })
    },
    onSearchParentNumber() {
      this.$refs.functionTreeModal.edit(this.model.id)
      this.$refs.functionTreeModal.title = 'Sélectionner le numéro parent'
      this.$refs.functionTreeModal.disableSubmit = false
    },
    functionTreeModalOk(number, name) {
      this.form.setFieldsValue({ parentNumber: number, parentName: name })
    },
  },
}
</script>
<style scoped></style>
