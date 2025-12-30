<template>
  <div ref="container">
    <a-modal
      :title="title"
      :width="800"
      :ok="false"
      :visible="visible"
      :confirmLoading="confirmLoading"
      :okButtonProps="{ props: { disabled: disableSubmit } }"
      :getContainer="() => $refs.container"
      :maskStyle="{ top: '93px', left: '154px' }"
      :wrapClassName="wrapClassNameInfo()"
      :mask="isDesktop()"
      :maskClosable="false"
      @ok="handleOk"
      @cancel="handleCancel"
      style="top: 100px; height: 50%"
      cancelText="Annuler"
      okText="Enregistrer"
    >
      <a-spin :spinning="confirmLoading">
        <a-form :form="form">
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Nom">
            <a-input placeholder="Veuillez saisir le nom" v-decorator="['name', validatorRules.name]" />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro">
            <a-input placeholder="Veuillez saisir le numéro" v-decorator="['serialNo', validatorRules.serialNo]" />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Répertoire parent">
            <a-tree-select
              style="width: 100%"
              :dropdownStyle="{ maxHeight: '200px', overflow: 'auto' }"
              allow-clear
              :treeDefaultExpandAll="true"
              :treeData="categoryTree"
              v-decorator="['parentId']"
              placeholder="Veuillez sélectionner le répertoire parent"
            >
            </a-tree-select>
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Tri">
            <a-input v-decorator="['sort']" />
          </a-form-item>
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Remarque">
            <a-textarea placeholder="Veuillez saisir la remarque" :rows="2" v-decorator.trim="['remark']" />
          </a-form-item>
        </a-form>
      </a-spin>
    </a-modal>
  </div>
</template>

<script>
import { httpAction } from '@/api/manage'
import { mixinDevice } from '@/utils/mixin'
import { queryMaterialCategoryTreeList, checkMaterialCategory } from '@/api/api'
import pick from 'lodash.pick'
import ATextarea from 'ant-design-vue/es/input/TextArea'
export default {
  name: 'MaterialCategoryModal',
  mixins: [mixinDevice],
  components: { ATextarea },
  data() {
    return {
      categoryTree: [],
      orgTypeData: [],
      phoneWarning: '',
      departName: '',
      title: 'Opération',
      visible: false,
      disableSubmit: false,
      model: {},
      menuhidden: false,
      menuusing: true,
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
          rules: [{ required: true, message: 'Veuillez saisir le nom !' }, { validator: this.validateName }],
        },
        serialNo: { rules: [{ required: true, message: 'Veuillez saisir le numéro !' }] },
      },
      url: {
        add: '/materialCategory/add',
      },
    }
  },
  created() {},
  methods: {
    loadTreeData() {
      var that = this
      let params = {}
      params.id = ''
      queryMaterialCategoryTreeList(params).then((res) => {
        if (res) {
          that.categoryTree = []
          for (let i = 0; i < res.length; i++) {
            let temp = res[i]
            that.categoryTree.push(temp)
          }
        }
      })
    },
    add() {
      this.edit()
    },
    edit(record) {
      this.form.resetFields()
      this.model = Object.assign({}, {})
      this.visible = true
      this.loadTreeData()
      this.$nextTick(() => {
        this.form.setFieldsValue(pick(record, 'name', 'serialNo', 'parentId', 'sort', 'remark'))
      })
    },
    close() {
      this.$emit('close')
      this.disableSubmit = false
      this.visible = false
    },
    handleOk() {
      const that = this
      // Déclencher la validation du formulaire
      this.form.validateFields((err, values) => {
        if (!err) {
          that.confirmLoading = true
          let formData = Object.assign(this.model, values)
          // Formatage de la date
          console.log(formData)
          httpAction(this.url.add, formData, 'post')
            .then((res) => {
              if (res.code == 200) {
                that.$message.success(res.data.message)
                that.loadTreeData()
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
    validateName(rule, value, callback) {
      let params = {
        name: value,
        parentId: this.form.getFieldValue('parentId'),
        id: this.model.id ? this.model.id : 0,
      }
      checkMaterialCategory(params).then((res) => {
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
