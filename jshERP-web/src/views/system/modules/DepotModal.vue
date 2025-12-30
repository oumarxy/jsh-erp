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
      style="top: 10%; height: 70%"
    >
      <template slot="footer">
        <a-button key="back" v-if="isReadOnly" @click="handleCancel"> Annuler </a-button>
      </template>
      <a-spin :spinning="confirmLoading">
        <a-form :form="form" id="depotModal">
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Nom de l'entrepôt">
            <a-input
              placeholder="Veuillez saisir le nom de l'entrepôt"
              v-decorator.trim="['name', validatorRules.name]"
            />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Adresse de l'entrepôt">
            <a-input placeholder="Veuillez saisir l'adresse de l'entrepôt" v-decorator.trim="['address']" />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Frais de stockage">
            <a-input
              placeholder="Veuillez saisir les frais de stockage"
              v-decorator.trim="['warehousing']"
              suffix="€/jour/KG"
            />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Frais de manutention">
            <a-input
              placeholder="Veuillez saisir les frais de manutention"
              v-decorator.trim="['truckage']"
              suffix="€"
            />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Responsable">
            <a-select
              placeholder="Sélectionner le responsable"
              v-decorator="['principal']"
              :dropdownMatchSelectWidth="false"
            >
              <a-select-option v-for="(item, index) in userList" :key="index" :value="item.id">
                {{ item.userName }}
              </a-select-option>
            </a-select>
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Tri">
            <a-input placeholder="Veuillez saisir le tri" v-decorator.trim="['sort']" />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Remarque">
            <a-textarea :rows="2" placeholder="Veuillez saisir une remarque" v-decorator.trim="['remark']" />
          </a-form-item>
        </a-form>
      </a-spin>
    </a-modal>
  </div>
</template>
<script>
import pick from 'lodash.pick'
import { addDepot, editDepot, checkDepot, getUserList } from '@/api/api'
import { autoJumpNextInput } from '@/utils/util'
import { mixinDevice } from '@/utils/mixin'
export default {
  name: 'DepotModal',
  mixins: [mixinDevice],
  data() {
    return {
      title: 'Opération',
      visible: false,
      model: {},
      maskStyle: '',
      userList: [],
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
            { required: true, message: "Veuillez saisir le nom de l'entrepôt!" },
            { min: 2, max: 30, message: 'La longueur doit être entre 2 et 30 caractères', trigger: 'blur' },
            { validator: this.validateDepotName },
          ],
        },
      },
    }
  },
  created() {
    this.initUser()
  },
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
          pick(this.model, 'name', 'address', 'warehousing', 'truckage', 'principal', 'sort', 'remark')
        )
        autoJumpNextInput('depotModal')
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
            obj = addDepot(formData)
          } else {
            obj = editDepot(formData)
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
    validateDepotName(rule, value, callback) {
      let params = {
        name: value,
        id: this.model.id ? this.model.id : 0,
      }
      checkDepot(params).then((res) => {
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
    initUser() {
      getUserList({}).then((res) => {
        if (res) {
          this.userList = res
        }
      })
    },
  },
}
</script>
<style scoped></style>
