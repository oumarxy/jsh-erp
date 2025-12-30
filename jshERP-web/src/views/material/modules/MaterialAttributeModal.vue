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
      style="top: 100px; height: 60%"
    >
      <template slot="footer">
        <a-button key="back" v-if="isReadOnly" @click="handleCancel"> Annuler </a-button>
      </template>
      <a-spin :spinning="confirmLoading">
        <a-form :form="form">
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Nom de l'attribut">
            <a-input
              placeholder="Veuillez saisir le nom de l'attribut"
              v-decorator.trim="['attributeName', validatorRules.attributeName]"
            />
          </a-form-item>
        </a-form>
        <a-form :form="form">
          <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Valeur de l'attribut">
            <a-tabs v-model:activeKey="activeKey" size="small">
              <a-tab-pane key="1" tab="Mode étiquettes" forceRender>
                <template v-for="(tag, index) in tags">
                  <a-tag
                    color="blue"
                    style="margin-bottom: 10px"
                    :key="tag"
                    :closable="true"
                    @close="() => handleClose(tag)"
                  >
                    {{ tag }}
                  </a-tag>
                </template>
                <a-input
                  v-if="inputVisible"
                  ref="input"
                  type="text"
                  size="small"
                  :style="{ width: '150px' }"
                  :value="inputValue"
                  @change="handleInputChange"
                  @blur="handleInputConfirm"
                  @keyup.enter="handleInputConfirm"
                />
                <a-tag v-else style="background: #fff; borderstyle: dashed" @click="showInput">
                  <a-icon type="plus" /> Veuillez saisir la valeur de l'attribut
                </a-tag>
              </a-tab-pane>
              <a-tab-pane key="2" tab="Mode texte" forceRender>
                <a-textarea
                  :rows="8"
                  placeholder="Veuillez saisir la valeur de l'attribut"
                  @change="handleValueChange"
                  v-decorator.trim="['attributeValue', validatorRules.attributeValue]"
                />
                Note : Veuillez séparer les valeurs d'attribut par une barre verticale, par exemple :
                Rouge|Orange|Jaune|Vert
              </a-tab-pane>
            </a-tabs>
          </a-form-item>
        </a-form>
      </a-spin>
    </a-modal>
  </div>
</template>
<script>
import pick from 'lodash.pick'
import { addMaterialAttribute, checkMaterialAttribute, editMaterialAttribute } from '@/api/api'
import { mixinDevice } from '@/utils/mixin'

export default {
  name: "MaterialAttributeModal",
  mixins: [mixinDevice],
  data () {
    return {
      title:"Opération",
      visible: false,
      model: {},
      isReadOnly: false,
      activeKey: '1',
      tags: [],
      inputVisible: false,
      inputValue: '',
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
      validatorRules:{
        attributeName:{
          rules: [
            { required: true, message: "Veuillez saisir le nom de l'attribut !" },
            { min: 1, max: 10, message: 'La longueur doit être entre 1 et 10 caractères', trigger: 'blur' },
            { validator: this.validateAttributeName}
          ]
        },
        attributeValue:{
          rules: [
            { required: true, message: "Veuillez saisir la valeur de l'attribut !" }
          ]
        }
      }
    }
  },
  created () {
  },
  methods: {
    add () {
      this.edit({});
    },
    edit (record) {
      this.form.resetFields();
      this.model = Object.assign({}, record);
      this.activeKey = '1'
      this.visible = true;
      if(this.model.attributeValue) {
        this.tags = this.model.attributeValue.split('|')
      } else {
        this.tags = []
      }
      this.$nextTick(() => {
        this.form.setFieldsValue(pick(this.model, 'attributeName', 'attributeValue'))
      });
    },
    close () {
      this.$emit('close');
      this.visible = false;
    },
    handleOk () {
      const that = this;
      // Déclencher la validation du formulaire
      this.form.validateFields((err, values) => {
        if (!err) {
          that.confirmLoading = true;
          let formData = Object.assign(this.model, values);
          let obj;
          if(!this.model.id){
            obj=addMaterialAttribute(formData);
          }else{
            obj=editMaterialAttribute(formData);
          }
          obj.then((res)=>{
            if(res.code === 200){
              that.$emit('ok');
            }else{
              that.$message.warning(res.data.message);
            }
          }).finally(() => {
            that.confirmLoading = false;
            that.close();
          })
        }
      })
    },
    handleCancel () {
      this.close()
    },
    validateAttributeName(rule, value, callback){
      if(value) {
        let params = {
          name: value,
          id: this.model.id?this.model.id:0
        }
        checkMaterialAttribute(params).then((res)=>{
          if(res && res.code===200) {
            if(!res.data.status){
              callback();
            } else {
              callback("Le nom existe déjà");
            }
          } else {
            callback(res.data);
          }
        })
      } else {
        callback()
      }
    },
    // Changement de la valeur de l'attribut
    handleValueChange(e) {
      let attributeValue = e.target.value
      if(attributeValue) {
        this.tags = attributeValue.split('|')
      } else {
        this.tags = []
      }
    },
    // Supprimer l'étiquette
    handleClose(removedTag) {
      this.tags = this.tags.filter(tag => tag !== removedTag)
      this.form.setFieldsValue({'attributeValue': this.tags.join('|')})
    },
    // Afficher la zone de saisie d'étiquette
    showInput() {
      this.inputVisible = true
      this.$nextTick(function() {
        this.$refs.input.focus()
      });
    },
    handleInputChange(e) {
      this.inputValue = e.target.value
    },
    handleInputConfirm() {
      const inputValue = this.inputValue
      let tags = this.tags
      if (inputValue && tags.indexOf(inputValue) === -1) {
        tags = [...tags, inputValue]
      }
      Object.assign(this, {
        tags,
        inputVisible: false,
        inputValue: '',
      })
      this.form.setFieldsValue({'attributeValue': this.tags.join('|')})
    }
  }
}
</script>
<style scoped></style>
