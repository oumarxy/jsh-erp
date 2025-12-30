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
      style="top: 15%; height: 60%"
    >
      <template slot="footer">
        <a-button key="back" v-if="isReadOnly" @click="handleCancel"> Annuler </a-button>
      </template>
      <a-spin :spinning="confirmLoading">
        <a-form :form="form" id="roleModal">
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Nom du rôle">
            <a-input placeholder="Veuillez saisir le nom du rôle" v-decorator.trim="['name', validatorRules.name]" />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Type de données">
            <a-select
              placeholder="Veuillez sélectionner le type de données"
              v-decorator="['type', validatorRules.type]"
              style="width: 94%"
            >
              <a-select-option value="全部数据">Toutes les données</a-select-option>
              <a-select-option value="本机构数据">Données de l'organisation</a-select-option>
              <a-select-option value="个人数据">Données personnelles</a-select-option>
            </a-select>
            <a-tooltip
              title="1、Toutes les données - Les utilisateurs de ce rôle peuvent voir tous les documents；2、Données de l'organisation - Les utilisateurs de ce rôle peuvent voir tous les documents de leur organisation；
                3、Données personnelles - Les utilisateurs de ce rôle ne peuvent voir que leurs propres documents. Les documents incluent les entrées d'achat, les sorties de vente, etc."
            >
              <a-icon type="question-circle" style="width: 6%; padding-left: 5px; font-size: 18px" />
            </a-tooltip>
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Masquage des prix">
            <j-select-multiple
              style="width: 94%"
              placeholder="Veuillez sélectionner le masquage des prix"
              v-model="priceLimitList.value"
              :options="priceLimitList.options"
            />
            <a-tooltip
              title="Le masquage des prix supporte la sélection multiple, principalement utilisé pour contrôler le masquage des prix sur l'interface d'accueil et les matériaux"
            >
              <a-icon type="question-circle" style="width: 6%; padding-left: 5px; font-size: 18px" />
            </a-tooltip>
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Remarque">
            <a-textarea
              :rows="1"
              placeholder="Veuillez saisir une remarque"
              v-decorator="['description', validatorRules.description]"
            />
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
import JSelectMultiple from '@/components/jeecg/JSelectMultiple'
import { addRole, editRole, checkRole } from '@/api/api'
import { autoJumpNextInput } from '@/utils/util'
import { mixinDevice } from '@/utils/mixin'
export default {
  name: 'RoleModal',
  mixins: [mixinDevice],
  components: {
    JSelectMultiple,
  },
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
      priceLimitList: {
        options: [
          { value: '1', text: "Masquer le prix d'achat de la page d'accueil" },
          { value: '2', text: "Masquer le prix de détail de la page d'accueil" },
          { value: '3', text: "Masquer le prix de vente de la page d'accueil" },
          { value: '4', text: "Masquer le prix d'achat des documents" },
          { value: '5', text: 'Masquer le prix de détail des documents' },
          { value: '6', text: 'Masquer le prix de vente des documents' },
        ],
        value: '',
      },
      confirmLoading: false,
      form: this.$form.createForm(this),
      validatorRules: {
        name: {
          rules: [
            { required: true, message: 'Veuillez saisir le nom du rôle!' },
            { min: 2, max: 30, message: 'La longueur doit être entre 2 et 30 caractères', trigger: 'blur' },
            { validator: this.validateRoleName },
          ],
        },
        type: {
          rules: [{ required: true, message: 'Veuillez sélectionner le type de données!' }],
        },
        description: {
          rules: [{ min: 0, max: 126, message: 'La longueur ne doit pas dépasser 126 caractères', trigger: 'blur' }],
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
      this.priceLimitList.value = this.model.priceLimit
      this.visible = true
      this.$nextTick(() => {
        this.form.setFieldsValue(pick(this.model, 'name', 'type', 'sort', 'description'))
        autoJumpNextInput('roleModal')
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
          formData.priceLimit = this.priceLimitList.value
          let obj
          if (!this.model.id) {
            obj = addRole(formData)
          } else {
            obj = editRole(formData)
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
    validateRoleName(rule, value, callback) {
      let params = {
        name: value,
        id: this.model.id ? this.model.id : 0,
      }
      checkRole(params).then((res) => {
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
