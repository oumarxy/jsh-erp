<template>
  <div ref="container">
    <a-modal
      :title="title"
      :width="1000"
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
      style="top: 20%; height: 45%"
    >
      <a-spin :spinning="confirmLoading">
        <a-form :form="form">
          <a-row class="form-row" :gutter="24">
            <a-col :md="8" :sm="24">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Couleur">
                <a-input placeholder="Veuillez saisir la couleur" v-decorator.trim="['color']" />
              </a-form-item>
            </a-col>
            <a-col :md="8" :sm="24">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Poids de base">
                <a-input-number
                  style="width: 100%"
                  placeholder="Veuillez saisir le poids de base (kg)"
                  v-decorator.trim="['weight']"
                />
              </a-form-item>
            </a-col>
            <a-col :md="8" :sm="24">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Durée de conservation">
                <a-input-number
                  style="width: 100%"
                  placeholder="Veuillez saisir la durée de conservation (jours)"
                  v-decorator.trim="['expiryNum']"
                />
              </a-form-item>
            </a-col>
            <a-col :md="8" :sm="24">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Catégorie">
                <a-tree-select
                  style="width: 100%"
                  :dropdownStyle="{ maxHeight: '200px', overflow: 'auto' }"
                  allow-clear
                  :treeData="categoryTree"
                  v-decorator="['categoryId']"
                  placeholder="Veuillez sélectionner la catégorie"
                >
                </a-tree-select>
              </a-form-item>
            </a-col>
            <a-col :md="8" :sm="24">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de série">
                <a-select placeholder="Avec ou sans numéro de série" v-decorator="['enableSerialNumber']">
                  <a-select-option value="1">Oui</a-select-option>
                  <a-select-option value="0">Non</a-select-option>
                </a-select>
              </a-form-item>
            </a-col>
            <a-col :md="8" :sm="24">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de lot">
                <a-select placeholder="Avec ou sans numéro de lot" v-decorator="['enableBatchNumber']">
                  <a-select-option value="1">Oui</a-select-option>
                  <a-select-option value="0">Non</a-select-option>
                </a-select>
              </a-form-item>
            </a-col>
            <a-col :md="8" :sm="24">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Remarque">
                <a-textarea
                  :rows="1"
                  placeholder="Veuillez saisir la remarque"
                  v-decorator="['remark']"
                  style="margin-top: 8px"
                />
              </a-form-item>
            </a-col>
          </a-row>
        </a-form>
      </a-spin>
    </a-modal>
  </div>
</template>

<script>
import { queryMaterialCategoryTreeList, batchUpdateMaterial } from '@/api/api'
import { mixinDevice } from '@/utils/mixin'
export default {
  name: 'BatchSetInfoModal',
  mixins: [mixinDevice],
  data() {
    return {
      title: 'Modification en lot',
      visible: false,
      categoryTree: [],
      materialIds: '',
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
    }
  },
  created() {},
  methods: {
    loadTreeData() {
      let that = this
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
    edit(ids) {
      this.materialIds = ids
      this.form.resetFields()
      this.model = Object.assign({}, '')
      this.loadTreeData()
      this.visible = true
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
          let formData = Object.assign(this.model, values)
          if (JSON.stringify(formData) === '{}') {
            that.$message.warning('Désolé, veuillez saisir le contenu à modifier en lot !')
            return
          }
          if (formData.enableSerialNumber === '1' && formData.enableBatchNumber === '1') {
            that.$message.warning(
              "Désolé, vous ne pouvez choisir qu'une seule option entre le numéro de série et le numéro de lot !"
            )
            return
          }
          let idList = that.materialIds ? that.materialIds.split(',') : []
          that.$confirm({
            title: "Confirmer l'opération",
            content: 'Voulez-vous traiter les ' + idList.length + ' données sélectionnées ?',
            onOk: function () {
              that.confirmLoading = true
              let paramObj = {
                ids: that.materialIds,
                material: JSON.stringify(formData),
              }
              batchUpdateMaterial(paramObj)
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
            },
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
