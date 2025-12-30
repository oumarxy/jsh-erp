<template>
  <j-modal
    :title="title"
    :width="width"
    :visible="visible"
    :confirmLoading="confirmLoading"
    v-bind:prefixNo="prefixNo"
    fullscreen
    switchHelp
    switchFullscreen
    @cancel="handleCancel"
    :id="prefixNo"
    :style="modalStyle"
  >
    <template slot="footer">
      <a-button key="back" @click="handleCancel">Annuler</a-button>
      <a-button type="primary" v-if="showOkFlag" :loading="confirmLoading" @click="handleOk"
        >Enregistrer (Ctrl+S)</a-button
      >
    </template>
    <a-spin :spinning="confirmLoading">
      <a-form :form="form">
        <a-tabs v-model:activeKey="activeKey" size="small">
          <a-tab-pane key="1" tab="Informations de base" id="materialHeadModal" forceRender>
            <a-row class="form-row" :gutter="24">
              <a-col :md="6" :sm="24">
                <a-form-item
                  :labelCol="labelCol"
                  :wrapperCol="wrapperCol"
                  label="Nom"
                  data-step="1"
                  data-title="Nom"
                  data-intro="Le nom est obligatoire et peut être répété"
                >
                  <a-input
                    placeholder="Veuillez saisir le nom"
                    v-decorator.trim="['name', validatorRules.name]"
                    @change="handleNameChange"
                  />
                </a-form-item>
              </a-col>
              <a-col :md="6" :sm="24">
                <a-form-item
                  :labelCol="labelCol"
                  :wrapperCol="wrapperCol"
                  label="Spécifications"
                  data-step="2"
                  data-title="Spécifications"
                  data-intro="Les spécifications ne sont pas obligatoires, par exemple : 10g"
                >
                  <a-input
                    placeholder="Veuillez saisir les spécifications"
                    v-decorator.trim="['standard', validatorRules.standard]"
                  />
                </a-form-item>
              </a-col>
              <a-col :md="6" :sm="24">
                <a-form-item
                  :labelCol="labelCol"
                  :wrapperCol="wrapperCol"
                  label="Modèle"
                  data-step="3"
                  data-title="Modèle"
                  data-intro="Le modèle est un attribut plus petit que les spécifications, par exemple : RX-01"
                >
                  <a-input placeholder="Veuillez saisir le modèle" v-decorator.trim="['model', validatorRules.model]" />
                </a-form-item>
              </a-col>
              <a-col :md="6" :sm="24">
                <a-form-item
                  :labelCol="labelCol"
                  :wrapperCol="wrapperCol"
                  label="Unité"
                  data-step="4"
                  data-title="Unité"
                  data-intro="Ici, les unités simples et multiples sont prises en charge. Cochez l'unité multiple pour passer à la liste déroulante des unités multiples. Les unités multiples doivent d'abord être saisies sur la page [Unités multiples].
                  Par exemple, le lait a deux unités : bouteille et caisse, 12 bouteilles = 1 caisse, ce qui constitue une unité multiple, avec un ratio de conversion dans les unités multiples"
                >
                  <a-row class="form-row" :gutter="24">
                    <a-col :lg="15" :md="15" :sm="24" style="padding: 0px 0px 0px 12px">
                      <a-input
                        placeholder="Saisir l'unité"
                        v-if="!unitChecked"
                        v-decorator.trim="['unit', validatorRules.unit]"
                        @change="onlyUnitOnChange"
                      />
                      <a-select
                        :value="unitList"
                        placeholder="Sélectionner une unité multiple"
                        v-decorator="['unitId', validatorRules.unitId]"
                        @change="manyUnitOnChange"
                        showSearch
                        optionFilterProp="children"
                        v-if="unitChecked"
                        :dropdownMatchSelectWidth="false"
                      >
                        <div slot="dropdownRender" slot-scope="menu">
                          <v-nodes :vnodes="menu" />
                          <a-divider style="margin: 4px 0" />
                          <div
                            style="padding: 4px 8px; cursor: pointer"
                            @mousedown="(e) => e.preventDefault()"
                            @click="addUnit"
                          >
                            <a-icon type="plus" /> Ajouter une unité multiple
                          </div>
                        </div>
                        <a-select-option v-for="(item, index) in unitList" :key="index" :value="item.id">
                          {{ item.name }}
                        </a-select-option>
                      </a-select>
                    </a-col>
                    <a-col :lg="9" :md="9" :sm="24" style="padding: 0px; text-align: center">
                      <a-checkbox :checked="unitChecked" @change="unitOnChange">Unité multiple</a-checkbox>
                    </a-col>
                  </a-row>
                </a-form-item>
              </a-col>
            </a-row>
            <a-row class="form-row" :gutter="24">
              <a-col :md="6" :sm="24">
                <a-form-item
                  :labelCol="labelCol"
                  :wrapperCol="wrapperCol"
                  label="Couleur"
                  data-step="5"
                  data-title="Couleur"
                  data-intro="Veuillez remplir la couleur du produit. Si c'est un produit multi-attributs, vous pouvez ne pas le remplir (il y a un interrupteur multi-attributs ci-dessous)"
                >
                  <a-input placeholder="Veuillez saisir la couleur" v-decorator.trim="['color']" />
                </a-form-item>
              </a-col>
              <a-col :md="6" :sm="24">
                <a-form-item
                  :labelCol="labelCol"
                  :wrapperCol="wrapperCol"
                  label="Marque"
                  data-step="6"
                  data-title="Marque"
                  data-intro="Veuillez remplir la marque du produit pour faciliter la distinction entre les produits de différentes marques"
                >
                  <a-input placeholder="Veuillez saisir la marque" v-decorator.trim="['brand']" />
                </a-form-item>
              </a-col>
              <a-col :md="6" :sm="24">
                <a-form-item
                  :labelCol="labelCol"
                  :wrapperCol="wrapperCol"
                  label="Code mnémonique"
                  data-step="7"
                  data-title="Code mnémonique"
                  data-intro="Le code mnémonique est généré automatiquement. C'est l'acronyme des premières lettres du nom du produit"
                >
                  <a-input placeholder="" v-decorator.trim="['mnemonic']" :readOnly="true" />
                </a-form-item>
              </a-col>
              <a-col :md="6" :sm="24">
                <a-form-item
                  :labelCol="labelCol"
                  :wrapperCol="wrapperCol"
                  label="Catégorie"
                  data-step="8"
                  data-title="Catégorie"
                  data-intro="La catégorie doit être saisie sur la page [Catégories de produits], puis appelée ici"
                >
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
            </a-row>
            <a-row class="form-row" :gutter="24">
              <a-col :md="6" :sm="24">
                <a-form-item
                  :labelCol="labelCol"
                  :wrapperCol="wrapperCol"
                  label="Poids de base"
                  data-step="9"
                  data-title="Poids de base"
                  data-intro="Veuillez remplir le poids correspondant à l'unité de base, utilisé pour calculer le coût réparti de chaque ligne de produit dans le document lors du calcul de la répartition des coûts par poids"
                >
                  <a-input-number
                    style="width: 100%"
                    placeholder="Veuillez saisir le poids de base (kg)"
                    v-decorator.trim="['weight']"
                  />
                </a-form-item>
              </a-col>
              <a-col :md="6" :sm="24">
                <a-form-item
                  :labelCol="labelCol"
                  :wrapperCol="wrapperCol"
                  label="Durée de conservation"
                  data-step="10"
                  data-title="Durée de conservation"
                  data-intro="La durée de conservation fait référence à la durée de conservation du produit (jours), principalement pour les produits avec date de production, ces produits ont généralement un numéro de lot"
                >
                  <a-input-number
                    style="width: 100%"
                    placeholder="Veuillez saisir la durée de conservation (jours)"
                    v-decorator.trim="['expiryNum']"
                  />
                </a-form-item>
              </a-col>
              <a-col :md="6" :sm="24">
                <a-form-item
                  :labelCol="labelCol"
                  :wrapperCol="wrapperCol"
                  label="Emplacement/Étagère"
                  data-step="11"
                  data-title="Emplacement/Étagère"
                  data-intro="L'emplacement/étagère fait référence à l'emplacement et au numéro d'étagère dans l'entrepôt, principalement applicable aux entrepôts plus grands, pour faciliter la recherche de l'emplacement exact du produit"
                >
                  <a-input
                    style="width: 100%"
                    placeholder="Veuillez saisir l'emplacement/étagère"
                    v-decorator.trim="['position']"
                  />
                </a-form-item>
              </a-col>
              <a-col :md="6" :sm="24">
                <a-form-item
                  :labelCol="labelCol"
                  :wrapperCol="wrapperCol"
                  label="Fabricant"
                  data-step="12"
                  data-title="Fabricant"
                  data-intro="Veuillez remplir le fabricant du produit, généralement applicable à l'industrie manufacturière"
                >
                  <a-input placeholder="Veuillez saisir le fabricant" v-decorator.trim="['mfrs']" />
                </a-form-item>
              </a-col>
            </a-row>
            <a-row class="form-row" :gutter="24">
              <a-col :lg="6" :md="6" :sm="6">
                <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" :label="mpShort.otherField1.name">
                  <a-input
                    :placeholder="'Veuillez saisir ' + mpShort.otherField1.name"
                    v-decorator.trim="['otherField1']"
                  />
                </a-form-item>
              </a-col>
              <a-col :lg="6" :md="6" :sm="6">
                <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" :label="mpShort.otherField2.name">
                  <a-input
                    :placeholder="'Veuillez saisir ' + mpShort.otherField2.name"
                    v-decorator.trim="['otherField2']"
                  />
                </a-form-item>
              </a-col>
              <a-col :lg="6" :md="6" :sm="6">
                <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" :label="mpShort.otherField3.name">
                  <a-input
                    :placeholder="'Veuillez saisir ' + mpShort.otherField3.name"
                    v-decorator.trim="['otherField3']"
                  />
                </a-form-item>
              </a-col>
            </a-row>
            <a-row class="form-row" :gutter="24">
              <a-col :md="6" :sm="24">
                <a-form-item
                  :labelCol="labelCol"
                  :wrapperCol="wrapperCol"
                  label="Numéro de série"
                  data-step="13"
                  data-title="Numéro de série"
                  data-intro="Il s'agit de l'interrupteur du numéro de série du produit. Si vous choisissez « Oui », vous devrez saisir le numéro de série du produit dans le document d'entrée d'achat, et sélectionner le numéro de série du produit dans le document de sortie de vente pour la sortie"
                >
                  <a-tooltip
                    title="Si vous choisissez « Oui », vous devrez saisir le numéro de série du produit dans le document d'entrée d'achat"
                  >
                    <a-select placeholder="Avec ou sans numéro de série" v-decorator="['enableSerialNumber']">
                      <a-select-option value="1">Oui</a-select-option>
                      <a-select-option value="0">Non</a-select-option>
                    </a-select>
                  </a-tooltip>
                </a-form-item>
              </a-col>
              <a-col :md="6" :sm="24">
                <a-form-item
                  :labelCol="labelCol"
                  :wrapperCol="wrapperCol"
                  label="Numéro de lot"
                  data-step="14"
                  data-title="Numéro de lot"
                  data-intro="Il s'agit de l'interrupteur du numéro de lot du produit. Si vous choisissez « Oui », vous devrez saisir le numéro de lot et la date d'expiration du produit dans le document d'entrée d'achat, et sélectionner le numéro de lot du produit dans le document de sortie de vente pour la sortie"
                >
                  <a-tooltip
                    title="Si vous choisissez « Oui », vous devrez saisir le numéro de lot et la date d'expiration du produit dans le document d'entrée d'achat"
                  >
                    <a-select placeholder="Avec ou sans numéro de lot" v-decorator="['enableBatchNumber']">
                      <a-select-option value="1">Oui</a-select-option>
                      <a-select-option value="0">Non</a-select-option>
                    </a-select>
                  </a-tooltip>
                </a-form-item>
              </a-col>
              <a-col :md="6" :sm="24">
                <a-form-item
                  :labelCol="labelCol"
                  :wrapperCol="wrapperCol"
                  label="Multi-attributs"
                  data-step="15"
                  data-title="Multi-attributs"
                  data-intro="Les multi-attributs concernent les produits SKU (par exemple, l'industrie de l'habillement, des chaussures et du textile). Si cet interrupteur est activé, vous pouvez configurer plusieurs SKU ci-dessous, configurer des combinaisons spécifiques de couleurs, tailles, etc."
                >
                  <a-tooltip
                    title="Les multi-attributs concernent les industries de l'habillement, des chaussures et du textile (note : ne cochez pas l'unité multiple, car les produits multi-attributs ne supportent pas les unités multiples, seulement une seule unité)"
                  >
                    <a-select
                      mode="multiple"
                      v-decorator="['manySku']"
                      showSearch
                      optionFilterProp="children"
                      placeholder="Veuillez sélectionner les multi-attributs (sélection multiple possible)"
                      @change="onManySkuChange"
                      :disabled="attributeStatus"
                    >
                      <div slot="dropdownRender" slot-scope="menu">
                        <v-nodes :vnodes="menu" />
                        <a-divider style="margin: 4px 0" />
                        <div
                          style="padding: 4px 8px; cursor: pointer"
                          @mousedown="(e) => e.preventDefault()"
                          @click="initMaterialAttribute"
                        >
                          Introuvable ? Cliquez ici pour actualiser la liste <a-icon type="reload" />
                        </div>
                      </div>
                      <a-select-option
                        v-for="(item, index) in materialAttributeList"
                        :key="index"
                        :value="item.value"
                        :disabled="item.disabled"
                      >
                        {{ item.name }}
                      </a-select-option>
                    </a-select>
                  </a-tooltip>
                </a-form-item>
              </a-col>
            </a-row>
            <a-row class="form-row" :gutter="24">
              <a-col :md="12" :sm="24" v-if="manySkuSelected >= 1">
                <a-form-item
                  :labelCol="{ xs: { span: 24 }, sm: { span: 4 } }"
                  :wrapperCol="{ xs: { span: 24 }, sm: { span: 20 } }"
                  :label="skuOneTitle"
                >
                  <a-select
                    mode="multiple"
                    v-decorator="['skuOne']"
                    showSearch
                    optionFilterProp="children"
                    placeholder="Veuillez sélectionner (sélection multiple possible)"
                    @select="onSkuChange"
                    @deselect="onSkuOneDeSelect"
                  >
                    <a-select-option v-for="(item, index) in skuOneList" :key="index" :value="item.value">
                      {{ item.name }}
                    </a-select-option>
                  </a-select>
                </a-form-item>
              </a-col>
              <a-col :md="12" :sm="24" v-if="manySkuSelected >= 2">
                <a-form-item
                  :labelCol="{ xs: { span: 24 }, sm: { span: 4 } }"
                  :wrapperCol="{ xs: { span: 24 }, sm: { span: 20 } }"
                  :label="skuTwoTitle"
                >
                  <a-select
                    mode="multiple"
                    v-decorator="['skuTwo']"
                    showSearch
                    optionFilterProp="children"
                    placeholder="Veuillez sélectionner (sélection multiple possible)"
                    @select="onSkuChange"
                    @deselect="onSkuTwoDeSelect"
                  >
                    <a-select-option v-for="(item, index) in skuTwoList" :key="index" :value="item.value">
                      {{ item.name }}
                    </a-select-option>
                  </a-select>
                </a-form-item>
              </a-col>
              <a-col :md="12" :sm="24" v-if="manySkuSelected >= 3">
                <a-form-item
                  :labelCol="{ xs: { span: 24 }, sm: { span: 4 } }"
                  :wrapperCol="{ xs: { span: 24 }, sm: { span: 20 } }"
                  :label="skuThreeTitle"
                >
                  <a-select
                    mode="multiple"
                    v-decorator="['skuThree']"
                    showSearch
                    optionFilterProp="children"
                    placeholder="Veuillez sélectionner (sélection multiple possible)"
                    @select="onSkuChange"
                    @deselect="onSkuThreeDeSelect"
                  >
                    <a-select-option v-for="(item, index) in skuThreeList" :key="index" :value="item.value">
                      {{ item.name }}
                    </a-select-option>
                  </a-select>
                </a-form-item>
              </a-col>
            </a-row>
            <div style="margin-top: 8px" id="materialDetailModal">
              <j-editable-table
                ref="editableMeTable"
                :loading="meTable.loading"
                :columns="meTable.columns"
                :dataSource="meTable.dataSource"
                :height="300"
                :minWidth="1000"
                :maxHeight="300"
                :rowNumber="true"
                :rowSelection="true"
                :actionButton="true"
                @valueChange="onValueChange"
                @added="onAdded"
                @deleted="onDeleted"
              >
                <template #buttonAfter>
                  <a-button @click="batchSetPrice('purchase')">Prix d'achat - Lot</a-button>
                  <a-button style="margin-left: 8px" @click="batchSetPrice('commodity')">Prix de détail - Lot</a-button>
                  <a-button style="margin-left: 8px" @click="batchSetPrice('wholesale')">Prix de vente - Lot</a-button>
                  <a-button style="margin-left: 8px" @click="batchSetPrice('low')"
                    >Prix de vente minimum - Lot</a-button
                  >
                </template>
              </j-editable-table>
              <!-- Zone du formulaire -->
              <batch-set-price-modal ref="priceModalForm" @ok="batchSetPriceModalFormOk"></batch-set-price-modal>
            </div>
            <a-row class="form-row" :gutter="24">
              <a-col :lg="24" :md="24" :sm="24">
                <a-form-item :labelCol="labelCol" :wrapperCol="{ xs: { span: 24 }, sm: { span: 24 } }" label="">
                  <a-textarea
                    :rows="1"
                    placeholder="Veuillez saisir la remarque"
                    v-decorator="['remark']"
                    style="margin-top: 8px"
                  />
                </a-form-item>
              </a-col>
            </a-row>
          </a-tab-pane>
          <a-tab-pane key="2" tab="Quantité de stock" forceRender>
            <j-editable-table
              ref="editableDepotTable"
              :loading="depotTable.loading"
              :columns="depotTable.columns"
              :dataSource="depotTable.dataSource"
              :minWidth="1000"
              :maxHeight="300"
              :rowNumber="true"
              :rowSelection="false"
              :actionButton="false"
            >
              <template #buttonAfter>
                <a-button style="margin: 0px 0px 8px 0px" @click="batchSetStock('initStock')"
                  >Stock initial - Lot</a-button
                >
                <a-button style="margin-left: 8px" @click="batchSetStock('lowSafeStock')"
                  >Stock de sécurité minimum - Lot</a-button
                >
                <a-button style="margin-left: 8px" @click="batchSetStock('highSafeStock')"
                  >Stock de sécurité maximum - Lot</a-button
                >
              </template>
            </j-editable-table>
            <!-- Zone du formulaire -->
            <batch-set-stock-modal ref="stockModalForm" @ok="batchSetStockModalFormOk"></batch-set-stock-modal>
          </a-tab-pane>
          <a-tab-pane key="3" tab="Informations sur les images" forceRender>
            <a-row class="form-row" :gutter="24" style="padding-top: 20px">
              <a-col :lg="18" :md="18" :sm="24">
                <a-form-item
                  :labelCol="{ xs: { span: 24 }, sm: { span: 3 } }"
                  :wrapperCol="{ xs: { span: 24 }, sm: { span: 20 } }"
                  label="Informations sur les images"
                >
                  <j-image-upload v-model="fileList" bizPath="material" text="Télécharger" isMultiple></j-image-upload>
                </a-form-item>
              </a-col>
              <a-col :lg="6" :md="6" :sm="24"></a-col>
            </a-row>
            <a-row class="form-row" :gutter="24">
              <a-col :lg="18" :md="18" :sm="24">
                <a-form-item
                  :labelCol="{ xs: { span: 24 }, sm: { span: 3 } }"
                  :wrapperCol="{ xs: { span: 24 }, sm: { span: 20 } }"
                  label="Conseil de téléchargement"
                >
                  Maximum 4 images, et chaque image ne doit pas dépasser 1 Mo
                </a-form-item>
              </a-col>
              <a-col :lg="6" :md="6" :sm="24"></a-col>
            </a-row>
          </a-tab-pane>
        </a-tabs>
      </a-form>
    </a-spin>
    <unit-modal ref="unitModalForm" @ok="unitModalFormOk"></unit-modal>
  </j-modal>
</template>
<script>
import pick from 'lodash.pick'
import BatchSetPriceModal from './BatchSetPriceModal'
import BatchSetStockModal from './BatchSetStockModal'
import UnitModal from '../../system/modules/UnitModal'
import JEditableTable from '@/components/jeecg/JEditableTable'
import { FormTypes, getRefPromise, VALIDATE_NO_PASSED, validateFormAndTables } from '@/utils/JEditableTableUtil'
import {
  changeNameToPinYin,
  checkMaterial,
  checkMaterialBarCode,
  getMaterialAttributeNameList,
  getMaterialAttributeValueListById,
  getMaxBarCode,
  queryMaterialCategoryTreeList,
} from '@/api/api'
import { autoJumpNextInput, handleIntroJs, removeByVal } from '@/utils/util'
import { getAction, httpAction } from '@/api/manage'
import JImageUpload from '@/components/jeecg/JImageUpload'
import JDate from '@/components/jeecg/JDate'
import Vue from 'vue'

export default {
  name: 'MaterialModal',
  components: {
    BatchSetPriceModal,
    BatchSetStockModal,
    UnitModal,
    JImageUpload,
    JDate,
    JEditableTable,
    VNodes: {
      functional: true,
      render: (h, ctx) => ctx.props.vnodes,
    },
  },
  data() {
    return {
      title: 'Opération',
      width: '1300px',
      visible: false,
      modalStyle: '',
      action: '',
      activeKey: '1',
      categoryTree: [],
      unitList: [],
      depotList: [],
      fileList: [],
      unitStatus: false,
      manyUnitStatus: true,
      unitChecked: false,
      switchDisabled: false, // État d'activation de l'interrupteur
      barCodeSwitch: false, // Interrupteur de génération de code-barres
      maxBarCodeInfo: '', // Code-barres maximum
      meDeleteIdList: [], // Tableau d'ID des informations de code-barres à supprimer
      prefixNo: 'material',
      attributeStatus: false,
      materialAttributeList: [],
      skuOneTitle: 'Attribut 1',
      skuTwoTitle: 'Attribut 2',
      skuThreeTitle: 'Attribut 3',
      skuOneList: [],
      skuTwoList: [],
      skuThreeList: [],
      meOldDataSource: [],
      manySkuSelected: 0,
      model: {},
      showOkFlag: true,
      setTimeFlag: null,
      labelCol: {
        xs: { span: 24 },
        sm: { span: 8 },
      },
      wrapperCol: {
        xs: { span: 24 },
        sm: { span: 16 },
      },
      mpShort: {
        mfrs: {},
        otherField1: { name: 'Extension 1' },
        otherField2: { name: 'Extension 2' },
        otherField3: { name: 'Extension 3' },
      },
      meTable: {
        loading: false,
        dataSource: [],
        columns: [
          {
            title: 'Code-barres',
            key: 'barCode',
            width: '15%',
            type: FormTypes.input,
            defaultValue: '',
            placeholder: 'Veuillez saisir ${title}',
            validateRules: [
              { required: true, message: '${title} ne peut pas être vide' },
              { pattern: /^.{4,40}$/, message: 'La longueur doit être entre 4 et 40 caractères' },
              { handler: this.validateBarCode },
            ],
          },
          {
            title: 'Unité',
            key: 'commodityUnit',
            width: '8%',
            type: FormTypes.input,
            defaultValue: '',
            placeholder: 'Veuillez saisir ${title}',
            validateRules: [{ required: true, message: '${title} ne peut pas être vide' }],
          },
          {
            title: 'Multi-attributs',
            key: 'sku',
            width: '25%',
            type: FormTypes.input,
            defaultValue: '',
            readonly: true,
            placeholder: 'Veuillez saisir ${title}',
          },
          {
            title: "Prix d'achat",
            key: 'purchaseDecimal',
            width: '9%',
            type: FormTypes.inputNumber,
            defaultValue: '',
            placeholder: 'Veuillez saisir ${title}',
          },
          {
            title: 'Prix de détail',
            key: 'commodityDecimal',
            width: '9%',
            type: FormTypes.inputNumber,
            defaultValue: '',
            placeholder: 'Veuillez saisir ${title}',
          },
          {
            title: 'Prix de vente',
            key: 'wholesaleDecimal',
            width: '9%',
            type: FormTypes.inputNumber,
            defaultValue: '',
            placeholder: 'Veuillez saisir ${title}',
          },
          {
            title: 'Prix de vente minimum',
            key: 'lowDecimal',
            width: '9%',
            type: FormTypes.inputNumber,
            defaultValue: '',
            placeholder: 'Veuillez saisir ${title}',
          },
        ],
      },
      depotTable: {
        loading: false,
        dataSource: [],
        columns: [
          {
            title: 'Entrepôt',
            key: 'name',
            width: '15%',
            type: FormTypes.normal,
          },
          {
            title: 'Quantité de stock initial',
            key: 'initStock',
            width: '15%',
            type: FormTypes.inputNumber,
            defaultValue: '',
            placeholder: 'Veuillez saisir ${title}',
          },
          {
            title: 'Quantité de stock de sécurité minimum',
            key: 'lowSafeStock',
            width: '15%',
            type: FormTypes.inputNumber,
            defaultValue: '',
            placeholder: 'Veuillez saisir ${title}',
          },
          {
            title: 'Quantité de stock de sécurité maximum',
            key: 'highSafeStock',
            width: '15%',
            type: FormTypes.inputNumber,
            defaultValue: '',
            placeholder: 'Veuillez saisir ${title}',
          },
        ],
      },
      confirmLoading: false,
      form: this.$form.createForm(this),
      validatorRules: {
        name: {
          rules: [
            { required: true, message: 'Veuillez saisir le nom !' },
            { max: 100, message: 'La longueur doit être inférieure à 100 caractères', trigger: 'blur' },
          ],
        },
        standard: {
          rules: [{ max: 100, message: 'La longueur doit être inférieure à 100 caractères', trigger: 'blur' }],
        },
        model: {
          rules: [{ max: 100, message: 'La longueur doit être inférieure à 100 caractères', trigger: 'blur' }],
        },
        unit: {
          rules: [{ required: true, message: "Veuillez saisir l'unité !" }],
        },
        unitId: {
          rules: [{ required: true, message: 'Veuillez sélectionner une unité multiple !' }],
        },
      },
      url: {
        add: '/material/add',
        edit: '/material/update',
        materialsExtendList: '/materialsExtend/getDetailList',
        depotWithStock: '/depot/getAllListWithStock',
      },
    }
  },
  created() {
    this.loadParseMaterialProperty()
    let realScreenWidth = window.screen.width
    this.width = realScreenWidth < 1500 ? '1200px' : '1400px'
  },
  mounted() {
    document.getElementById(this.prefixNo).addEventListener('keydown', this.handleOkKey)
  },
  beforeDestroy() {
    document.getElementById(this.prefixNo).removeEventListener('keydown', this.handleOkKey)
  },
  methods: {
    // Raccourci clavier
    handleOkKey(e) {
      const key = window.event.keyCode ? window.event.keyCode : window.event.which
      if (key === 83 && e.ctrlKey) {
        // Enregistrer CTRL+S
        this.handleOk()
        e.preventDefault()
      }
    },
    // Obtenir toutes les instances d'editableTable
    getAllTable() {
      return Promise.all([getRefPromise(this, 'editableMeTable'), getRefPromise(this, 'editableDepotTable')])
    },
    add() {
      // Masquer les multi-attributs
      this.meTable.columns[2].type = FormTypes.hidden
      // Ajouter une ligne de données par défaut
      this.getAllTable().then((editableTables) => {
        editableTables[0].add()
      })
      this.edit({})
      this.$nextTick(() => {
        handleIntroJs('material', 11)
      })
    },
    edit(record) {
      let that = this
      this.form.resetFields()
      this.model = Object.assign({}, record)
      let attribute = record.attribute
      if (attribute) {
        // Construire les multi-attributs
        let attrObj = JSON.parse(attribute)
        this.model.manySku = attrObj.manySku
        this.model.skuOne = attrObj.skuOne
        this.model.skuTwo = attrObj.skuTwo
        this.model.skuThree = attrObj.skuThree
      }
      this.activeKey = '1'
      this.manySkuSelected = 0
      this.barCodeSwitch = false
      this.maxBarCodeInfo = ''
      this.visible = true
      this.meDeleteIdList = []
      this.modalStyle = 'top:20px;height: 95%;'
      if (JSON.stringify(record) === '{}') {
        this.fileList = []
      } else {
        if (this.action === 'edit') {
          setTimeout(() => {
            this.fileList = record.imgName
          }, 5)
        }
      }
      this.$nextTick(() => {
        this.form.setFieldsValue(
          pick(
            this.model,
            'name',
            'standard',
            'unit',
            'unitId',
            'model',
            'color',
            'brand',
            'mnemonic',
            'categoryId',
            'enableSerialNumber',
            'enableBatchNumber',
            'position',
            'expiryNum',
            'weight',
            'remark',
            'mfrs',
            'otherField1',
            'otherField2',
            'otherField3',
            'manySku',
            'skuOne',
            'skuTwo',
            'skuThree'
          )
        )
        autoJumpNextInput('materialHeadModal')
        autoJumpNextInput('materialDetailModal')
      })
      this.initMaterialAttribute()
      this.loadTreeData()
      this.loadUnitListData()
      // Charger les données des sous-tableaux
      if (this.model.id) {
        // Désactiver l'interrupteur multi-attributs
        this.switchDisabled = true
        // Déterminer s'il s'agit d'une unité multiple
        if (this.model.unit) {
          this.unitChecked = false
          this.unitStatus = false
          this.manyUnitStatus = true
        } else {
          this.unitChecked = true
          this.unitStatus = true
          this.manyUnitStatus = false
        }
        // En mode édition, s'il y a des multi-attributs, la modification n'est pas autorisée
        if (this.model.manySku) {
          this.attributeStatus = true
          // Charger la liste déroulante de chaque multi-attribut
          setTimeout(function () {
            that.loadSkuList(that.model.manySku)
          }, 1000)
        } else {
          this.attributeStatus = false
        }
        let params = { materialId: this.model.id }
        this.requestMeTableData(this.url.materialsExtendList, params, this.meTable)
        this.requestDepotTableData(this.url.depotWithStock, { mId: this.model.id }, this.depotTable)
      } else {
        this.attributeStatus = false
        this.switchDisabled = false
        this.meTable.columns[2].readonly = true
        this.requestDepotTableData(this.url.depotWithStock, { mId: 0 }, this.depotTable)
      }
    },
    /** Rechercher les données de l'onglet code-barres */
    requestMeTableData(url, params, tab) {
      tab.loading = true
      getAction(url, params)
        .then((res) => {
          for (let i = 0; i < res.data.rows.length; i++) {
            if (res.data.rows[i].sku) {
              this.meTable.columns[2].type = FormTypes.input
            } else {
              this.meTable.columns[2].type = FormTypes.hidden
            }
          }
          tab.dataSource = res.data.rows || []
          this.meOldDataSource = res.data.rows || []
          // Copier et ajouter un produit - Initialiser les informations de code-barres
          if (this.action === 'copyAdd') {
            getMaxBarCode({}).then((res) => {
              if (res && res.code === 200) {
                let maxBarCode = res.data.barCode - 0
                let meTableData = []
                for (let i = 0; i < tab.dataSource.length; i++) {
                  let meInfo = tab.dataSource[i]
                  meInfo.barCode = maxBarCode + i + 1
                  meTableData.push(meInfo)
                }
                tab.dataSource = meTableData
              }
            })
          }
        })
        .finally(() => {
          tab.loading = false
        })
    },
    /** Rechercher les données de l'onglet entrepôt */
    requestDepotTableData(url, params, tab) {
      tab.loading = true
      getAction(url, params)
        .then((res) => {
          tab.dataSource = res.data || []
        })
        .finally(() => {
          tab.loading = false
        })
    },
    close() {
      this.$emit('close')
      this.visible = false
      this.modalStyle = ''
      this.unitStatus = false
      this.manyUnitStatus = true
      this.unitChecked = false
      this.getAllTable().then((editableTables) => {
        editableTables[0].initialize()
        editableTables[1].initialize()
      })
    },
    handleOk() {
      this.validateFields()
    },
    handleCancel() {
      this.close()
    },
    /** Déclencher la validation du formulaire */
    validateFields() {
      this.getAllTable()
        .then((tables) => {
          /** Valider le tableau principal et tous les sous-tableaux en une seule fois */
          return validateFormAndTables(this.form, tables)
        })
        .then((allValues) => {
          let formData = this.classifyIntoFormData(allValues)
          formData.sortList = []
          if (formData.unit === undefined) {
            formData.unit = ''
          }
          if (formData.unitId === undefined) {
            formData.unitId = ''
          }
          if (this.unitChecked) {
            formData.unit = ''
          } else {
            formData.unitId = ''
          }
          // Lancer la requête
          return this.requestAddOrEdit(formData)
        })
        .catch((e) => {
          if (e.error === VALIDATE_NO_PASSED) {
            // S'il y a un sous-tableau qui n'a pas passé la validation du formulaire, passer automatiquement à son onglet
            this.activeKey = e.index == null ? this.activeKey : (e.index + 1).toString()
          } else {
            console.error(e)
          }
        })
    },
    /** Organiser en formData */
    classifyIntoFormData(allValues) {
      let materialMain = Object.assign(this.model, allValues.formValue)
      return {
        ...materialMain, // Développer
        meList: allValues.tablesValue[0].values,
        stock: allValues.tablesValue[1].values,
      }
    },
    /** Lancer la requête d'ajout ou de modification */
    requestAddOrEdit(formData) {
      // Copier et ajouter un produit - Initialiser l'ID et l'ID du locataire
      if (this.action === 'copyAdd') {
        this.model.id = ''
        this.model.tenantId = ''
        formData.id = ''
        formData.tenantId = ''
      }
      if (formData.meList.length === 0) {
        this.$message.warning('Désolé, veuillez saisir les informations de code-barres !')
        return
      }
      if (formData.enableSerialNumber === '1' && formData.enableBatchNumber === '1') {
        this.$message.warning('Désolé, vous ne pouvez choisir qu\'une seule option entre le numéro de série et le numéro de lot !')
        return
      }
      if (formData.manySku && formData.unitId) {
        this.$message.warning('Désolé, les produits multi-attributs ne peuvent pas utiliser d\'unités multiples, veuillez passer à une seule unité !')
        return
      }
      // Vérifier si le produit existe, en vérifiant le nom, le modèle, les spécifications, la couleur, l'unité, le fabricant, etc. du produit
      let param = {
        id: this.model.id ? this.model.id : 0,
        name: this.model.name,
        model: this.parseParam(this.model.model),
        color: this.parseParam(this.model.color),
        standard: this.parseParam(this.model.standard),
        mfrs: this.parseParam(this.model.mfrs),
        otherField1: this.parseParam(this.model.otherField1),
        otherField2: this.parseParam(this.model.otherField2),
        otherField3: this.parseParam(this.model.otherField3),
        unit: this.parseParam(this.model.unit),
        unitId: this.parseParam(this.model.unitId),
      }
      checkMaterial(param).then((res) => {
        if (res && res.code === 200) {
          if (res.data.status) {
            this.$message.warning('Désolé, ce produit existe déjà !')
            return
          } else {
            // Valider davantage l'unité
            let basicUnit = '',
              otherUnit = '',
              otherUnitTwo = '',
              otherUnitThree = ''
            if (formData.unitId) {
              let unitArr = this.unitList
              for (let i = 0; i < unitArr.length; i++) {
                if (unitArr[i].id == formData.unitId) {
                  basicUnit = unitArr[i].basicUnit
                  otherUnit = unitArr[i].otherUnit
                  if (unitArr[i].otherUnitTwo) {
                    otherUnitTwo = unitArr[i].otherUnitTwo
                  }
                  if (unitArr[i].otherUnitThree) {
                    otherUnitThree = unitArr[i].otherUnitThree
                  }
                }
              }
            }
            if (!formData.unit) {
              // À ce moment, c'est une unité multiple
              if (formData.meList.length < 2) {
                this.$message.warning('Les produits à unités multiples doivent avoir au moins deux lignes de code-barres, veuillez ajouter une ligne de code-barres !')
                return
              }
              if (formData.meList[0].commodityUnit != basicUnit) {
                this.$message.warning(
                  'L\'unité après le code-barres est incorrecte, l\'unité [' +
                    formData.meList[0].commodityUnit +
                    '] doit être modifiée en [' +
                    basicUnit +
                    '] !'
                )
                return
              }
              if (formData.meList[1].commodityUnit != otherUnit) {
                this.$message.warning(
                  'L\'unité après le code-barres est incorrecte, l\'unité [' +
                    formData.meList[1].commodityUnit +
                    '] doit être modifiée en [' +
                    otherUnit +
                    '] !'
                )
                return
              }
            }
            let skuCount = 0
            for (let i = 0; i < formData.meList.length; i++) {
              let commodityUnit = formData.meList[i].commodityUnit
              if (formData.unit) {
                if (commodityUnit != formData.unit) {
                  this.$message.warning(
                    'L\'unité après le code-barres est incorrecte, l\'unité [' + commodityUnit + '] doit être modifiée en [' + formData.unit + '] !'
                  )
                  return
                }
              } else if (formData.unitId) {
                if (
                  commodityUnit != basicUnit &&
                  commodityUnit != otherUnit &&
                  commodityUnit != otherUnitTwo &&
                  commodityUnit != otherUnitThree
                ) {
                  let warnInfo =
                    'L\'unité après le code-barres est incorrecte, l\'unité [' +
                    commodityUnit +
                    '] doit être modifiée en [' +
                    basicUnit +
                    '] ou [' +
                    otherUnit +
                    ']'
                  if (otherUnitTwo) {
                    warnInfo += ' ou [' + otherUnitTwo + ']'
                  }
                  if (otherUnitThree) {
                    warnInfo += ' ou [' + otherUnitThree + ']'
                  }
                  warnInfo += ' !'
                  this.$message.warning(warnInfo)
                  return
                }
              }
              if (formData.sku) {
                skuCount++
              }
            }
            // Valider le stock de sécurité minimum et maximum
            for (let i = 0; i < formData.stock.length; i++) {
              let depotStockObj = formData.stock[i]
              if (skuCount && depotStockObj.initStock && depotStockObj.initStock - 0) {
                this.$message.warning('Désolé, les produits multi-attributs ne peuvent pas avoir de stock initial, il est recommandé de faire une saisie d\'inventaire !')
                return
              }
              if (formData.enableSerialNumber === '1' && depotStockObj.initStock && depotStockObj.initStock - 0) {
                this.$message.warning('Désolé, les produits avec numéro de série ne peuvent pas avoir de stock initial, il est recommandé de faire une saisie via un document d\'entrée !')
                return
              }
              if (formData.enableBatchNumber === '1' && depotStockObj.initStock && depotStockObj.initStock - 0) {
                this.$message.warning('Désolé, les produits avec numéro de lot ne peuvent pas avoir de stock initial, il est recommandé de faire une saisie via un document d\'entrée !')
                return
              }
              if (depotStockObj.lowSafeStock && depotStockObj.highSafeStock) {
                if (depotStockObj.lowSafeStock - 0 > depotStockObj.highSafeStock - 0) {
                  this.$message.warning('Désolé, le stock de sécurité minimum de ' + depotStockObj.name + ' est supérieur au stock de sécurité maximum !')
                  return
                }
              }
            }
            // Validation des images
            if (this.fileList && this.fileList.length > 0) {
              formData.imgName = this.fileList
              let fileArr = this.fileList.split(',')
              if (fileArr.length > 4) {
                this.$message.warning('Désolé, les images de produits ne peuvent pas dépasser 4 !')
                return
              }
            } else {
              formData.imgName = ''
            }
            formData.meDeleteIdList = this.meDeleteIdList
            // Appel d'interface
            let url = this.url.add,
              method = 'post'
            if (this.model.id) {
              url = this.url.edit
              method = 'put'
            }
            const that = this
            this.confirmLoading = true
            httpAction(url, formData, method)
              .then((res) => {
                if (res.code === 200) {
                  that.$emit('ok')
                  that.confirmLoading = false
                  that.close()
                } else {
                  that.$message.warning(res.data.message)
                  that.confirmLoading = false
                }
              })
              .finally(() => {})
          }
        }
      })
    },
    parseParam(param) {
      return param ? param : ''
    },
    validateBarCode(type, value, row, column, callback, target) {
      let params = {
        barCode: value,
        id: row.id.length >= 20 ? 0 : row.id,
      }
      checkMaterialBarCode(params).then((res) => {
        if (res && res.code === 200) {
          if (!res.data.status) {
            callback(true)
          } else {
            callback(false, 'Ce code-barres existe déjà')
          }
        } else {
          callback(false, res.data)
        }
      })
    },
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
    loadUnitListData() {
      let that = this
      let params = {}
      params.currentPage = 1
      params.pageSize = 100
      getAction('/unit/getAllList', params).then((res) => {
        if (res) {
          that.unitList = res.data
        }
      })
    },
    onManySkuChange(value) {
      this.manySkuSelected = value.length
      // Contrôler l'état des éléments sélectionnés dans la liste déroulante multi-attributs
      if (value.length < 3) {
        this.materialAttributeList.forEach((item, index, array) => {
          array.indexOf(item.value) === -1 ? Vue.set(array[index], 'disabled', false) : ''
        })
      } else {
        this.materialAttributeList.forEach((item, index, array) => {
          value.indexOf(item.value) === -1 ? Vue.set(array[index], 'disabled', true) : ''
        })
      }
      // Mettre à jour les listes déroulantes des attributs 1, 2 et 3
      if (value.length <= 3) {
        let skuOneId = value[0]
        let skuTwoId = value[1]
        let skuThreeId = value[2]
        this.materialAttributeList.forEach((item) => {
          if (item.value === skuOneId) {
            this.skuOneTitle = item.name
          }
          if (item.value === skuTwoId) {
            this.skuTwoTitle = item.name
          }
          if (item.value === skuThreeId) {
            this.skuThreeTitle = item.name
          }
        })
        if (skuOneId) {
          getMaterialAttributeValueListById({ id: skuOneId }).then((res) => {
            this.skuOneList = res ? res : []
          })
        }
        if (skuTwoId) {
          getMaterialAttributeValueListById({ id: skuTwoId }).then((res) => {
            this.skuTwoList = res ? res : []
          })
        }
        if (skuThreeId) {
          getMaterialAttributeValueListById({ id: skuThreeId }).then((res) => {
            this.skuThreeList = res ? res : []
          })
        }
      }
      // Contrôler la colonne multi-attributs dans la liste des codes-barres
      if (value.length > 0) {
        this.meTable.columns[2].type = FormTypes.input
      } else {
        this.meTable.columns[2].type = FormTypes.hidden
      }
      this.barCodeSwitch = false
      this.meTable.dataSource = []
    },
    // Charger les SKU existants lors du chargement de la page d'édition
    loadSkuList(value) {
      this.manySkuSelected = value.length
      // Mettre à jour les listes déroulantes des attributs 1, 2 et 3
      if (value.length <= 3) {
        let skuOneId = value[0]
        let skuTwoId = value[1]
        let skuThreeId = value[2]
        this.materialAttributeList.forEach((item) => {
          if (item.value === skuOneId) {
            this.skuOneTitle = item.name
          }
          if (item.value === skuTwoId) {
            this.skuTwoTitle = item.name
          }
          if (item.value === skuThreeId) {
            this.skuThreeTitle = item.name
          }
        })
        if (skuOneId) {
          getMaterialAttributeValueListById({ id: skuOneId }).then((res) => {
            this.skuOneList = res ? res : []
            this.form.setFieldsValue(pick(this.model, 'skuOne'))
          })
        }
        if (skuTwoId) {
          getMaterialAttributeValueListById({ id: skuTwoId }).then((res) => {
            this.skuTwoList = res ? res : []
            this.form.setFieldsValue(pick(this.model, 'skuTwo'))
          })
        }
        if (skuThreeId) {
          getMaterialAttributeValueListById({ id: skuThreeId }).then((res) => {
            this.skuThreeList = res ? res : []
            this.form.setFieldsValue(pick(this.model, 'skuThree'))
          })
        }
      }
      this.barCodeSwitch = false
    },
    onSkuChange() {
      let skuOneData = this.form.getFieldValue('skuOne')
      let skuTwoData = this.form.getFieldValue('skuTwo')
      let skuThreeData = this.form.getFieldValue('skuThree')
      this.autoSkuList(skuOneData, skuTwoData, skuThreeData)
    },
    onSkuOneDeSelect(value) {
      let skuOneData = this.form.getFieldValue('skuOne')
      let skuTwoData = this.form.getFieldValue('skuTwo')
      let skuThreeData = this.form.getFieldValue('skuThree')
      removeByVal(skuOneData, value)
      this.autoSkuList(skuOneData, skuTwoData, skuThreeData)
    },
    onSkuTwoDeSelect(value) {
      let skuOneData = this.form.getFieldValue('skuOne')
      let skuTwoData = this.form.getFieldValue('skuTwo')
      let skuThreeData = this.form.getFieldValue('skuThree')
      removeByVal(skuTwoData, value)
      this.autoSkuList(skuOneData, skuTwoData, skuThreeData)
    },
    onSkuThreeDeSelect(value) {
      let skuOneData = this.form.getFieldValue('skuOne')
      let skuTwoData = this.form.getFieldValue('skuTwo')
      let skuThreeData = this.form.getFieldValue('skuThree')
      removeByVal(skuThreeData, value)
      this.autoSkuList(skuOneData, skuTwoData, skuThreeData)
    },
    autoSkuList(skuOneData, skuTwoData, skuThreeData) {
      let unit = this.form.getFieldValue('unit')
      if (unit) {
        // Calculer combien de multi-attributs ont été sélectionnés
        let skuArr = []
        if (this.getNumByField('skuOne')) {
          skuArr.push(skuOneData)
        }
        if (this.getNumByField('skuTwo')) {
          skuArr.push(skuTwoData)
        }
        if (this.getNumByField('skuThree')) {
          skuArr.push(skuThreeData)
        }
        let skuArrOne = skuArr[0]
        let skuArrTwo = skuArr[1]
        let skuArrThree = skuArr[2]
        let count = this.getNumByField('skuOne') + this.getNumByField('skuTwo') + this.getNumByField('skuThree')
        let barCodeSku = []
        if (count === 1) {
          let skuArrOnly = []
          if (this.getNumByField('skuOne')) {
            skuArrOnly = skuOneData
          } else if (this.getNumByField('skuTwo')) {
            skuArrOnly = skuTwoData
          } else if (this.getNumByField('skuThree')) {
            skuArrOnly = skuThreeData
          }
          for (let i = 0; i < skuArrOnly.length; i++) {
            barCodeSku.push(skuArrOnly[i])
          }
        } else if (count === 2) {
          for (let i = 0; i < skuArrOne.length; i++) {
            for (let j = 0; j < skuArrTwo.length; j++) {
              barCodeSku.push(skuArrOne[i] + '/' + skuArrTwo[j])
            }
          }
        } else if (count === 3) {
          for (let i = 0; i < skuArrOne.length; i++) {
            for (let j = 0; j < skuArrTwo.length; j++) {
              for (let k = 0; k < skuArrThree.length; k++) {
                barCodeSku.push(skuArrOne[i] + '/' + skuArrTwo[j] + '/' + skuArrThree[k])
              }
            }
          }
        }
        let meTableData = []
        getMaxBarCode({}).then((res) => {
          if (res && res.code === 200) {
            let k = 0
            let maxBarCode = res.data.barCode - 0
            for (let i = 0; i < barCodeSku.length; i++) {
              let currentBarCode = ''
              let currentId = ''
              let purchaseDecimal = ''
              let commodityDecimal = ''
              let wholesaleDecimal = ''
              let lowDecimal = ''
              for (let j = 0; j < this.meOldDataSource.length; j++) {
                if (barCodeSku[i] === this.meOldDataSource[j].sku) {
                  currentBarCode = this.meOldDataSource[j].barCode
                  currentId = this.meOldDataSource[j].id
                  purchaseDecimal = this.meOldDataSource[j].purchaseDecimal
                  commodityDecimal = this.meOldDataSource[j].commodityDecimal
                  wholesaleDecimal = this.meOldDataSource[j].wholesaleDecimal
                  lowDecimal = this.meOldDataSource[j].lowDecimal
                }
              }
              if (currentBarCode) {
                // À ce moment, cela signifie que ce SKU existait déjà
                meTableData.push({
                  id: currentId,
                  barCode: currentBarCode,
                  commodityUnit: unit,
                  sku: barCodeSku[i],
                  purchaseDecimal: purchaseDecimal,
                  commodityDecimal: commodityDecimal,
                  wholesaleDecimal: wholesaleDecimal,
                  lowDecimal: lowDecimal,
                })
              } else {
                k = k + 1
                currentBarCode = maxBarCode + k
                meTableData.push({ barCode: currentBarCode, commodityUnit: unit, sku: barCodeSku[i] })
              }
            }
            this.meTable.dataSource = meTableData
          }
        })
      } else {
        this.$message.warning('Veuillez remplir l\'unité (note : ne cochez pas l\'unité multiple, car les produits multi-attributs ne supportent pas les unités multiples)')
        this.barCodeSwitch = false
      }
    },
    getNumByField(field) {
      let num = 0
      if (this.form.getFieldValue(field)) {
        if (this.form.getFieldValue(field).length > 0) {
          num = 1
        }
      }
      return num
    },
    onAdded(event) {
      const { row, target } = event
      let unit = ''
      if (this.unitStatus == false) {
        unit = this.form.getFieldValue('unit')
      }
      if (this.maxBarCodeInfo === '') {
        getMaxBarCode({}).then((res) => {
          if (res && res.code === 200) {
            this.maxBarCodeInfo = res.data.barCode - 0
            this.maxBarCodeInfo = this.maxBarCodeInfo + 1
            target.setValues([
              { rowKey: row.id, values: { barCode: this.maxBarCodeInfo, commodityUnit: unit ? unit : '' } },
            ])
          }
        })
      } else {
        this.maxBarCodeInfo = this.maxBarCodeInfo + 1
        target.setValues([
          { rowKey: row.id, values: { barCode: this.maxBarCodeInfo, commodityUnit: unit ? unit : '' } },
        ])
      }
    },
    onDeleted(value) {
      this.meDeleteIdList = value
    },
    // Déclencher une fois chaque fois qu'un caractère de la valeur de l'unité change
    onValueChange(event) {
      const { type, row, column, value, target } = event
      switch (column.key) {
        case 'purchaseDecimal':
        case 'commodityDecimal':
        case 'wholesaleDecimal':
        case 'lowDecimal':
          this.changeDecimalByValue(row)
          break
      }
    },
    // Modifier le prix dans les détails du produit déclenche le calcul
    changeDecimalByValue(row) {
      let unitArr = this.unitList
      let basicUnit = '',
        otherUnit = '',
        ratio = 1,
        otherUnitTwo = '',
        ratioTwo = 1,
        otherUnitThree = '',
        ratioThree = 1
      for (let i = 0; i < unitArr.length; i++) {
        if (unitArr[i].id === this.form.getFieldValue('unitId')) {
          basicUnit = unitArr[i].basicUnit
          otherUnit = unitArr[i].otherUnit
          ratio = unitArr[i].ratio
          if (unitArr[i].otherUnitTwo) {
            otherUnitTwo = unitArr[i].otherUnitTwo
            ratioTwo = unitArr[i].ratioTwo
          }
          if (unitArr[i].otherUnitThree) {
            otherUnitThree = unitArr[i].otherUnitThree
            ratioThree = unitArr[i].ratioThree
          }
        }
      }
      if (row.commodityUnit === basicUnit) {
        this.$refs.editableMeTable.getValues((error, values) => {
          let mArr = values,
            basicPurchaseDecimal = '',
            basicCommodityDecimal = '',
            basicWholesaleDecimal = '',
            basicLowDecimal = ''
          for (let i = 0; i < mArr.length; i++) {
            let mInfo = mArr[i]
            if (i === 0) {
              basicPurchaseDecimal = mInfo.purchaseDecimal
              basicCommodityDecimal = mInfo.commodityDecimal
              basicWholesaleDecimal = mInfo.wholesaleDecimal
              basicLowDecimal = mInfo.lowDecimal
            } else {
              // Conversion de l'unité secondaire
              if (basicPurchaseDecimal) {
                mInfo.purchaseDecimal = (basicPurchaseDecimal * ratio).toFixed(2)
              }
              if (basicCommodityDecimal) {
                mInfo.commodityDecimal = (basicCommodityDecimal * ratio).toFixed(2)
              }
              if (basicWholesaleDecimal) {
                mInfo.wholesaleDecimal = (basicWholesaleDecimal * ratio).toFixed(2)
              }
              if (basicLowDecimal) {
                mInfo.lowDecimal = (basicLowDecimal * ratio).toFixed(2)
              }
              if (otherUnitTwo && i === 2) {
                if (basicPurchaseDecimal) {
                  mInfo.purchaseDecimal = (basicPurchaseDecimal * ratioTwo).toFixed(2)
                }
                if (basicCommodityDecimal) {
                  mInfo.commodityDecimal = (basicCommodityDecimal * ratioTwo).toFixed(2)
                }
                if (basicWholesaleDecimal) {
                  mInfo.wholesaleDecimal = (basicWholesaleDecimal * ratioTwo).toFixed(2)
                }
                if (basicLowDecimal) {
                  mInfo.lowDecimal = (basicLowDecimal * ratioTwo).toFixed(2)
                }
              }
              if (otherUnitThree && i === 3) {
                if (basicPurchaseDecimal) {
                  mInfo.purchaseDecimal = (basicPurchaseDecimal * ratioThree).toFixed(2)
                }
                if (basicCommodityDecimal) {
                  mInfo.commodityDecimal = (basicCommodityDecimal * ratioThree).toFixed(2)
                }
                if (basicWholesaleDecimal) {
                  mInfo.wholesaleDecimal = (basicWholesaleDecimal * ratioThree).toFixed(2)
                }
                if (basicLowDecimal) {
                  mInfo.lowDecimal = (basicLowDecimal * ratioThree).toFixed(2)
                }
              }
            }
          }
          this.meTable.dataSource = mArr
        })
      }
    },
    batchSetPrice(type) {
      if (this.manySkuSelected > 0 || this.model.id) {
        this.$refs.priceModalForm.add(type)
        this.$refs.priceModalForm.disableSubmit = false
      } else {
        this.$message.warning('Désolé, seuls les multi-attributs activés peuvent être traités en lot !')
      }
    },
    batchSetStock(type) {
      this.$refs.stockModalForm.add(type)
      this.$refs.stockModalForm.disableSubmit = false
    },
    batchSetPriceModalFormOk(price, batchType) {
      let arr = this.meTable.dataSource
      if (arr.length === 0) {
        this.$message.warning('Veuillez d\'abord saisir les informations de code-barres, unité, etc. !')
      } else {
        let meTableData = []
        for (let i = 0; i < arr.length; i++) {
          let meInfo = {
            barCode: arr[i].barCode,
            commodityUnit: arr[i].commodityUnit,
            sku: arr[i].sku,
            purchaseDecimal: arr[i].purchaseDecimal,
            commodityDecimal: arr[i].commodityDecimal,
            wholesaleDecimal: arr[i].wholesaleDecimal,
            lowDecimal: arr[i].lowDecimal,
          }
          if (batchType === 'purchase') {
            meInfo.purchaseDecimal = price - 0
          } else if (batchType === 'commodity') {
            meInfo.commodityDecimal = price - 0
          } else if (batchType === 'wholesale') {
            meInfo.wholesaleDecimal = price - 0
          } else if (batchType === 'low') {
            meInfo.lowDecimal = price - 0
          }
          if (arr[i].id) {
            meInfo.id = arr[i].id
          }
          meTableData.push(meInfo)
        }
        this.meTable.dataSource = meTableData
      }
    },
    batchSetStockModalFormOk(stock, batchType) {
      let arr = this.depotTable.dataSource
      let depotTableData = []
      for (let i = 0; i < arr.length; i++) {
        let depotInfo = {
          name: arr[i].name,
          initStock: arr[i].initStock,
          lowSafeStock: arr[i].lowSafeStock,
          highSafeStock: arr[i].highSafeStock,
        }
        if (batchType === 'initStock') {
          depotInfo.initStock = stock - 0
        } else if (batchType === 'lowSafeStock') {
          depotInfo.lowSafeStock = stock - 0
        } else if (batchType === 'highSafeStock') {
          depotInfo.highSafeStock = stock - 0
        }
        if (arr[i].id) {
          depotInfo.id = arr[i].id
        }
        depotTableData.push(depotInfo)
      }
      this.depotTable.dataSource = depotTableData
    },
    initMaterialAttribute() {
      getMaterialAttributeNameList().then((res) => {
        if (res) {
          this.materialAttributeList = res
        }
      })
    },
    loadParseMaterialProperty() {
      let mpList = Vue.ls.get('materialPropertyList')
      for (let i = 0; i < mpList.length; i++) {
        if (mpList[i].nativeName === 'Extension 1') {
          this.mpShort.otherField1.name = mpList[i].anotherName
        }
        if (mpList[i].nativeName === 'Extension 2') {
          this.mpShort.otherField2.name = mpList[i].anotherName
        }
        if (mpList[i].nativeName === 'Extension 3') {
          this.mpShort.otherField3.name = mpList[i].anotherName
        }
      }
    },
    handleNameChange(e) {
      let that = this
      if (e.target.value) {
        if (this.setTimeFlag != null) {
          clearTimeout(this.setTimeFlag)
        }
        this.setTimeFlag = setTimeout(() => {
          changeNameToPinYin({ name: e.target.value }).then((res) => {
            if (res && res.code === 200) {
              that.form.setFieldsValue({ mnemonic: res.data })
            } else {
              that.$message.warning(res.data)
            }
          })
        }, 500)
      } else {
        that.form.setFieldsValue({ mnemonic: '' })
      }
    },
    onlyUnitOnChange(e) {
      this.$refs.editableMeTable.getValues((error, values) => {
        let mArr = values
        for (let i = 0; i < mArr.length; i++) {
          let mInfo = mArr[i]
          mInfo.commodityUnit = e.target.value
        }
        this.meTable.dataSource = mArr
      })
    },
    manyUnitOnChange(value) {
      let unitArr = this.unitList
      let basicUnit = '',
        otherUnit = '',
        ratio = 1,
        otherUnitTwo = '',
        ratioTwo = 1,
        otherUnitThree = '',
        ratioThree = 1
      for (let i = 0; i < unitArr.length; i++) {
        if (unitArr[i].id === value) {
          basicUnit = unitArr[i].basicUnit
          otherUnit = unitArr[i].otherUnit
          ratio = unitArr[i].ratio
          if (unitArr[i].otherUnitTwo) {
            otherUnitTwo = unitArr[i].otherUnitTwo
            ratioTwo = unitArr[i].ratioTwo
          }
          if (unitArr[i].otherUnitThree) {
            otherUnitThree = unitArr[i].otherUnitThree
            ratioThree = unitArr[i].ratioThree
          }
        }
      }
      this.$refs.editableMeTable.getValues((error, values) => {
        let mArr = values,
          basicPurchaseDecimal = '',
          basicCommodityDecimal = '',
          basicWholesaleDecimal = '',
          basicLowDecimal = ''
        for (let i = 0; i < mArr.length; i++) {
          let mInfo = mArr[i]
          if (i === 0) {
            mInfo.commodityUnit = basicUnit
            basicPurchaseDecimal = mInfo.purchaseDecimal
            basicCommodityDecimal = mInfo.commodityDecimal
            basicWholesaleDecimal = mInfo.wholesaleDecimal
            basicLowDecimal = mInfo.lowDecimal
          } else {
            // Conversion de l'unité secondaire
            mInfo.commodityUnit = otherUnit
            if (basicPurchaseDecimal) {
              mInfo.purchaseDecimal = (basicPurchaseDecimal * ratio).toFixed(2)
            }
            if (basicCommodityDecimal) {
              mInfo.commodityDecimal = (basicCommodityDecimal * ratio).toFixed(2)
            }
            if (basicWholesaleDecimal) {
              mInfo.wholesaleDecimal = (basicWholesaleDecimal * ratio).toFixed(2)
            }
            if (basicLowDecimal) {
              mInfo.lowDecimal = (basicLowDecimal * ratio).toFixed(2)
            }
            if (otherUnitTwo && i === 2) {
              mInfo.commodityUnit = otherUnitTwo
              if (basicPurchaseDecimal) {
                mInfo.purchaseDecimal = (basicPurchaseDecimal * ratioTwo).toFixed(2)
              }
              if (basicCommodityDecimal) {
                mInfo.commodityDecimal = (basicCommodityDecimal * ratioTwo).toFixed(2)
              }
              if (basicWholesaleDecimal) {
                mInfo.wholesaleDecimal = (basicWholesaleDecimal * ratioTwo).toFixed(2)
              }
              if (basicLowDecimal) {
                mInfo.lowDecimal = (basicLowDecimal * ratioTwo).toFixed(2)
              }
            }
            if (otherUnitThree && i === 3) {
              mInfo.commodityUnit = otherUnitThree
              if (basicPurchaseDecimal) {
                mInfo.purchaseDecimal = (basicPurchaseDecimal * ratioThree).toFixed(2)
              }
              if (basicCommodityDecimal) {
                mInfo.commodityDecimal = (basicCommodityDecimal * ratioThree).toFixed(2)
              }
              if (basicWholesaleDecimal) {
                mInfo.wholesaleDecimal = (basicWholesaleDecimal * ratioThree).toFixed(2)
              }
              if (basicLowDecimal) {
                mInfo.lowDecimal = (basicLowDecimal * ratioThree).toFixed(2)
              }
            }
          }
        }
        this.meTable.dataSource = mArr
      })
    },
    unitOnChange(e) {
      let isChecked = e.target.checked
      if (isChecked) {
        this.unitStatus = true
        this.manyUnitStatus = false
        this.unitChecked = true
      } else {
        this.unitStatus = false
        this.manyUnitStatus = true
        this.unitChecked = false
      }
    },
    addUnit() {
      this.$refs.unitModalForm.add()
      this.$refs.unitModalForm.title = 'Ajouter une unité multiple'
      this.$refs.unitModalForm.disableSubmit = false
    },
    unitModalFormOk() {
      this.loadUnitListData()
    },
  },
}
</script>
<style scoped>
.input-table {
  max-width: 100%;
  min-width: 1200px;
}
.tag-info {
  font-size: 14px;
  height: 32px;
  line-height: 32px;
  width: 100%;
  padding: 0px 11px;
  color: #bbb;
  background-color: #ffffff;
}
</style>
