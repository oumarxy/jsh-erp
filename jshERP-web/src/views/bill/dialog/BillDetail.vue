<template>
  <j-modal
    :title="title"
    :width="width"
    :visible="visible"
    :maskClosable="false"
    :forceRender="true"
    :style="modalStyle"
    fullscreen
    switchFullscreen
    @cancel="handleCancel"
    wrapClassName="ant-modal-cust-warp"
  >
    <template slot="footer">
      <!-- Impression -->
      <a-button key="back" @click="handleCancel">Annuler (ESC)</a-button>
      <template v-if="isShowPrintBtn">
        <a-button v-if="billPrintFlag" @click="handlePrintPro"
          >Impression en trois exemplaires - Nouvelle version</a-button
        >
        <a-button v-if="billPrintFlag" @click="handlePrint">Impression en trois exemplaires</a-button>
        <!-- Ici pour résoudre le problème de cache -->
        <a-button v-if="billType === '零售出库'" v-print="'#retailOutPrint'">Impression normale</a-button>
        <a-button v-if="billType === '零售退货入库'" v-print="'#retailBackPrint'">Impression normale</a-button>
        <a-button v-if="billType === '请购单'" v-print="'#purchaseApplyPrint'">Impression normale</a-button>
        <a-button v-if="billType === '采购订单'" v-print="'#purchaseOrderPrint'">Impression normale</a-button>
        <a-button v-if="billType === '采购入库'" v-print="'#purchaseInPrint'">Impression normale</a-button>
        <a-button v-if="billType === '采购退货出库'" v-print="'#purchaseBackPrint'">Impression normale</a-button>
        <a-button v-if="billType === '销售订单'" v-print="'#saleOrderPrint'">Impression normale</a-button>
        <a-button v-if="billType === '销售出库'" v-print="'#saleOutPrint'">Impression normale</a-button>
        <a-button v-if="billType === '销售退货入库'" v-print="'#saleBackPrint'">Impression normale</a-button>
        <a-button v-if="billType === '其它入库'" v-print="'#otherInPrint'">Impression normale</a-button>
        <a-button v-if="billType === '其它出库'" v-print="'#otherOutPrint'">Impression normale</a-button>
        <a-button v-if="billType === '调拨出库'" v-print="'#allocationOutPrint'">Impression normale</a-button>
        <a-button v-if="billType === '组装单'" v-print="'#assemblePrint'">Impression normale</a-button>
        <a-button v-if="billType === '拆卸单'" v-print="'#disassemblePrint'">Impression normale</a-button>
        <a-button v-if="billType === '盘点复盘'" v-print="'#stockCheckReplayPrint'">Impression normale</a-button>
      </template>
      <!-- Exporter Excel -->
      <a-button v-if="billType === '零售出库' || billType === '零售退货入库'" @click="retailExportExcel()"
        >Exporter</a-button
      >
      <a-button v-if="billType === '请购单'" @click="applyExportExcel()">Exporter</a-button>
      <a-button v-if="billType === '采购订单' || billType === '销售订单'" @click="orderExportExcel()"
        >Exporter</a-button
      >
      <a-button
        v-if="
          billType === '采购入库' ||
          billType === '采购退货出库' ||
          billType === '销售出库' ||
          billType === '销售退货入库'
        "
        @click="purchaseSaleExportExcel()"
        >Exporter</a-button
      >
      <a-button v-if="billType === '其它入库' || billType === '其它出库'" @click="otherExportExcel()"
        >Exporter</a-button
      >
      <a-button v-if="billType === '调拨出库'" @click="allocationOutExportExcel()">Exporter</a-button>
      <a-button v-if="billType === '组装单' || billType === '拆卸单'" @click="assembleExportExcel()">Exporter</a-button>
      <a-button v-if="billType === '盘点复盘'" @click="stockCheckReplayExportExcel()">Exporter</a-button>
      <!-- Désauditer -->
      <a-button v-if="checkFlag && isCanBackCheck && model.status === '1'" @click="handleBackCheck()"
        >Désauditer</a-button
      >
    </template>
    <a-form :form="form">
      <!-- Sortie de vente au détail -->
      <template v-if="billType === '零售出库'">
        <section ref="print" id="retailOutPrint">
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de carte membre">
                <a-input v-decorator="['id']" hidden />
                {{ model.organName }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Date du document">
                {{ model.operTimeStr }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de document">
                {{ model.number }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Type de paiement">
                {{ model.payType }}
              </a-form-item>
            </a-col>
          </a-row>
          <a-row class="form-row" :gutter="24">
            <a-col :lg="18" :md="12" :sm="24">
              <div :style="tableWidthRetail">
                <a-table
                  ref="table"
                  size="middle"
                  bordered
                  rowKey="id"
                  :pagination="false"
                  :loading="loading"
                  :columns="columns"
                  :dataSource="dataSource"
                >
                  <template slot="customBarCode" slot-scope="text, record">
                    <div :style="record.imgName ? 'float:left;line-height:30px' : 'float:left;'">
                      {{ record.barCode }}
                    </div>
                    <a-popover placement="right" trigger="click">
                      <template slot="content"
                        ><img :src="getImgUrl(record.imgName, record.imgLarge)" width="500px"
                      /></template>
                      <div class="item-info" v-if="record.imgName">
                        <img
                          v-if="record.imgName"
                          :src="getImgUrl(record.imgName, record.imgSmall)"
                          class="item-img"
                          title="Voir l'image en grand"
                        />
                      </div>
                    </a-popover>
                  </template>
                </a-table>
              </div>
            </a-col>
            <a-col :span="6">
              <a-row class="form-row" :gutter="24">
                <a-col :lg="24" :md="6" :sm="6">
                  <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Montant du document">
                    {{ model.changeAmount }}
                  </a-form-item>
                </a-col>
                <a-col :lg="24" :md="6" :sm="6">
                  <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Montant reçu">
                    {{ model.getAmount }}
                  </a-form-item>
                </a-col>
                <a-col :lg="24" :md="6" :sm="6">
                  <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Monnaie rendue">
                    {{ model.backAmount }}
                  </a-form-item>
                </a-col>
                <a-col :lg="24" :md="6" :sm="6">
                  <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Compte de recouvrement">
                    {{ model.accountName }}
                  </a-form-item>
                </a-col>
                <a-col v-if="model.hasBackFlag" :lg="24" :md="6" :sm="6">
                  <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de retour">
                    <template v-for="(item, index) in linkNumberList">
                      <a @click="myHandleDetail(item.number)">{{ item.number }}</a
                      ><br />
                    </template>
                  </a-form-item>
                </a-col>
              </a-row>
            </a-col>
          </a-row>
          <a-row class="form-row" :gutter="24">
            <a-col :lg="24" :md="24" :sm="24">
              <a-form-item
                :labelCol="labelCol"
                :wrapperCol="{ xs: { span: 24 }, sm: { span: 24 } }"
                label=""
                style="padding: 20px 10px"
              >
                {{ model.remark }}
              </a-form-item>
            </a-col>
          </a-row>
        </section>
      </template>
      <!-- Retour de vente au détail -->
      <template v-else-if="billType === '零售退货入库'">
        <section ref="print" id="retailBackPrint">
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de carte membre">
                <a-input v-decorator="['id']" hidden />
                {{ model.organName }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Date du document">
                {{ model.operTimeStr }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de document">
                {{ model.number }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Document associé">
                <a @click="myHandleDetail(model.linkNumber)">{{ model.linkNumber }}</a>
              </a-form-item>
            </a-col>
          </a-row>
          <a-row class="form-row" :gutter="24">
            <a-col :lg="18" :md="12" :sm="24">
              <div :style="tableWidthRetail">
                <a-table
                  ref="table"
                  size="middle"
                  bordered
                  rowKey="id"
                  :pagination="false"
                  :loading="loading"
                  :columns="columns"
                  :dataSource="dataSource"
                >
                  <template slot="customBarCode" slot-scope="text, record">
                    <div :style="record.imgName ? 'float:left;line-height:30px' : 'float:left;'">
                      {{ record.barCode }}
                    </div>
                    <a-popover placement="right" trigger="click">
                      <template slot="content"
                        ><img :src="getImgUrl(record.imgName, record.imgLarge)" width="500px"
                      /></template>
                      <div class="item-info" v-if="record.imgName">
                        <img
                          v-if="record.imgName"
                          :src="getImgUrl(record.imgName, record.imgSmall)"
                          class="item-img"
                          title="Voir l'image en grand"
                        />
                      </div>
                    </a-popover>
                  </template>
                </a-table>
              </div>
            </a-col>
            <a-col :span="6">
              <a-row class="form-row" :gutter="24">
                <a-col :lg="24" :md="6" :sm="6">
                  <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Montant du document">
                    {{ model.changeAmount }}
                  </a-form-item>
                </a-col>
                <a-col :lg="24" :md="6" :sm="6">
                  <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Montant payé">
                    {{ model.getAmount }}
                  </a-form-item>
                </a-col>
                <a-col :lg="24" :md="6" :sm="6">
                  <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Monnaie rendue">
                    {{ model.backAmount }}
                  </a-form-item>
                </a-col>
                <a-col :lg="24" :md="6" :sm="6">
                  <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Compte de paiement">
                    {{ model.accountName }}
                  </a-form-item>
                </a-col>
              </a-row>
            </a-col>
          </a-row>
          <a-row class="form-row" :gutter="24">
            <a-col :lg="24" :md="24" :sm="24">
              <a-form-item
                :labelCol="labelCol"
                :wrapperCol="{ xs: { span: 24 }, sm: { span: 24 } }"
                label=""
                style="padding: 20px 10px"
              >
                {{ model.remark }}
              </a-form-item>
            </a-col>
          </a-row>
        </section>
      </template>
      <!-- Demande d'achat -->
      <template v-else-if="billType === '请购单'">
        <section ref="print" id="purchaseApplyPrint">
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Date du document">
                {{ model.operTimeStr }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de document">
                {{ model.number }}
              </a-form-item>
            </a-col>
            <a-col :span="6"> </a-col>
            <a-col :span="6"> </a-col>
          </a-row>
          <div :style="tableWidth">
            <a-table
              ref="table"
              size="middle"
              bordered
              rowKey="id"
              :pagination="false"
              :loading="loading"
              :columns="columns"
              :dataSource="dataSource"
            >
              <template slot="customBarCode" slot-scope="text, record">
                <div :style="record.imgName ? 'float:left;line-height:30px' : 'float:left;'">{{ record.barCode }}</div>
                <a-popover placement="right" trigger="click">
                  <template slot="content"
                    ><img :src="getImgUrl(record.imgName, record.imgLarge)" width="500px"
                  /></template>
                  <div class="item-info" v-if="record.imgName">
                    <img
                      v-if="record.imgName"
                      :src="getImgUrl(record.imgName, record.imgSmall)"
                      class="item-img"
                      title="Voir l'image en grand"
                    />
                  </div>
                </a-popover>
              </template>
            </a-table>
          </div>
          <a-row class="form-row" :gutter="24">
            <a-col :lg="24" :md="24" :sm="24">
              <a-form-item
                :labelCol="labelCol"
                :wrapperCol="{ xs: { span: 24 }, sm: { span: 24 } }"
                label=""
                style="padding: 20px 10px"
              >
                {{ model.remark }}
              </a-form-item>
            </a-col>
          </a-row>
        </section>
      </template>
      <!-- Commande d'achat -->
      <template v-else-if="billType === '采购订单'">
        <section ref="print" id="purchaseOrderPrint">
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Fournisseur">
                <a-input v-decorator="['id']" hidden />
                {{ model.organName }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Date du document">
                {{ model.operTimeStr }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de document">
                {{ model.number }}
              </a-form-item>
            </a-col>
            <a-col :span="6" v-if="model.linkApply">
              <a-form-item
                :labelCol="{ xs: { span: 24 }, sm: { span: 6 } }"
                :wrapperCol="wrapperCol"
                label="Demande d'achat associée"
              >
                <a @click="myHandleDetail(model.linkApply)">{{ model.linkApply }}</a>
              </a-form-item>
            </a-col>
            <a-col :span="6" v-if="model.linkNumber">
              <a-form-item
                v-if="purchaseBySaleFlag"
                :labelCol="labelCol"
                :wrapperCol="wrapperCol"
                label="Commande associée"
              >
                {{ model.linkNumber }}
              </a-form-item>
            </a-col>
          </a-row>
          <div :style="tableWidth">
            <a-table
              ref="table"
              size="middle"
              bordered
              rowKey="id"
              :pagination="false"
              :loading="loading"
              :columns="columns"
              :dataSource="dataSource"
            >
              <template slot="customBarCode" slot-scope="text, record">
                <div :style="record.imgName ? 'float:left;line-height:30px' : 'float:left;'">{{ record.barCode }}</div>
                <a-popover placement="right" trigger="click">
                  <template slot="content"
                    ><img :src="getImgUrl(record.imgName, record.imgLarge)" width="500px"
                  /></template>
                  <div class="item-info" v-if="record.imgName">
                    <img
                      v-if="record.imgName"
                      :src="getImgUrl(record.imgName, record.imgSmall)"
                      class="item-img"
                      title="Voir l'image en grand"
                    />
                  </div>
                </a-popover>
              </template>
            </a-table>
          </div>
          <a-row class="form-row" :gutter="24">
            <a-col :lg="24" :md="24" :sm="24">
              <a-form-item
                :labelCol="labelCol"
                :wrapperCol="{ xs: { span: 24 }, sm: { span: 24 } }"
                label=""
                style="padding: 20px 10px"
              >
                {{ model.remark }}
              </a-form-item>
            </a-col>
          </a-row>
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Taux de remise">
                {{ model.discount }}%
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Remise de paiement">
                {{ model.discountMoney }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item
                :labelCol="{ xs: { span: 24 }, sm: { span: 6 } }"
                :wrapperCol="wrapperCol"
                label="Montant après remise"
              >
                {{ model.discountLastMoney }}
              </a-form-item>
            </a-col>
            <a-col :span="6"></a-col>
          </a-row>
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Compte de règlement">
                {{ model.accountName }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Acompte payé">
                {{ model.changeAmount }}
              </a-form-item>
            </a-col>
            <a-col :span="6"></a-col>
            <a-col :span="6"></a-col>
          </a-row>
        </section>
      </template>
      <!-- Entrée d'achat -->
      <template v-else-if="billType === '采购入库'">
        <section ref="print" id="purchaseInPrint">
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Fournisseur">
                <a-input v-decorator="['id']" hidden />
                {{ model.organName }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Date du document">
                {{ model.operTimeStr }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de document">
                {{ model.number }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Commande associée">
                <a @click="myHandleDetail(model.linkNumber)">{{ model.linkNumber }}</a>
              </a-form-item>
            </a-col>
          </a-row>
          <div :style="tableWidth">
            <a-table
              ref="table"
              size="middle"
              bordered
              rowKey="id"
              :pagination="false"
              :loading="loading"
              :columns="columns"
              :dataSource="dataSource"
            >
              <template slot="customBarCode" slot-scope="text, record">
                <div :style="record.imgName ? 'float:left;line-height:30px' : 'float:left;'">{{ record.barCode }}</div>
                <a-popover placement="right" trigger="click">
                  <template slot="content"
                    ><img :src="getImgUrl(record.imgName, record.imgLarge)" width="500px"
                  /></template>
                  <div class="item-info" v-if="record.imgName">
                    <img
                      v-if="record.imgName"
                      :src="getImgUrl(record.imgName, record.imgSmall)"
                      class="item-img"
                      title="Voir l'image en grand"
                    />
                  </div>
                </a-popover>
              </template>
            </a-table>
          </div>
          <a-row class="form-row" :gutter="24">
            <a-col :lg="24" :md="24" :sm="24">
              <a-form-item
                :labelCol="labelCol"
                :wrapperCol="{ xs: { span: 24 }, sm: { span: 24 } }"
                label=""
                style="padding: 20px 10px"
              >
                {{ model.remark }}
              </a-form-item>
            </a-col>
          </a-row>
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Taux de remise">
                {{ model.discount }}%
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Remise de paiement">
                {{ model.discountMoney }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item
                :labelCol="{ xs: { span: 24 }, sm: { span: 6 } }"
                :wrapperCol="wrapperCol"
                label="Montant après remise"
              >
                {{ model.discountLastMoney }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Autres frais">
                {{ model.otherMoney }}
              </a-form-item>
            </a-col>
          </a-row>
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Compte de règlement">
                {{ model.accountName }}
              </a-form-item>
            </a-col>
            <a-col v-if="model.deposit" :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Acompte déduit">
                {{ model.deposit }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Paiement actuel">
                {{ model.changeAmount }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Dette actuelle">
                {{ model.debt }}
              </a-form-item>
            </a-col>
            <a-col v-if="model.hasBackFlag" :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de retour">
                <template v-for="(item, index) in linkNumberList">
                  <a @click="myHandleDetail(item.number)">{{ item.number }}</a
                  ><br />
                </template>
              </a-form-item>
            </a-col>
          </a-row>
          <a-row class="form-row" :gutter="24">
            <a-col v-if="financialBillNoList.length" :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de paiement">
                <template v-for="(item, index) in financialBillNoList">
                  <a @click="myHandleFinancialDetail(item.billNo)">{{ item.billNo }}</a
                  ><br />
                </template>
              </a-form-item>
            </a-col>
          </a-row>
        </section>
      </template>
      <!-- Retour d'achat -->
      <template v-else-if="billType === '采购退货出库'">
        <section ref="print" id="purchaseBackPrint">
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Fournisseur">
                <a-input v-decorator="['id']" hidden />
                {{ model.organName }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Date du document">
                {{ model.operTimeStr }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de document">
                {{ model.number }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Document associé">
                <a @click="myHandleDetail(model.linkNumber)">{{ model.linkNumber }}</a>
              </a-form-item>
            </a-col>
          </a-row>
          <div :style="tableWidth">
            <a-table
              ref="table"
              size="middle"
              bordered
              rowKey="id"
              :pagination="false"
              :loading="loading"
              :columns="columns"
              :dataSource="dataSource"
            >
              <template slot="customBarCode" slot-scope="text, record">
                <div :style="record.imgName ? 'float:left;line-height:30px' : 'float:left;'">{{ record.barCode }}</div>
                <a-popover placement="right" trigger="click">
                  <template slot="content"
                    ><img :src="getImgUrl(record.imgName, record.imgLarge)" width="500px"
                  /></template>
                  <div class="item-info" v-if="record.imgName">
                    <img
                      v-if="record.imgName"
                      :src="getImgUrl(record.imgName, record.imgSmall)"
                      class="item-img"
                      title="Voir l'image en grand"
                    />
                  </div>
                </a-popover>
              </template>
            </a-table>
          </div>
          <a-row class="form-row" :gutter="24">
            <a-col :lg="24" :md="24" :sm="24">
              <a-form-item
                :labelCol="labelCol"
                :wrapperCol="{ xs: { span: 24 }, sm: { span: 24 } }"
                label=""
                style="padding: 20px 10px"
              >
                {{ model.remark }}
              </a-form-item>
            </a-col>
          </a-row>
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Taux de remise">
                {{ model.discount }}%
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Remise de remboursement">
                {{ model.discountMoney }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item
                :labelCol="{ xs: { span: 24 }, sm: { span: 6 } }"
                :wrapperCol="wrapperCol"
                label="Montant après remise"
              >
                {{ model.discountLastMoney }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Autres frais">
                {{ model.otherMoney }}
              </a-form-item>
            </a-col>
          </a-row>
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Compte de règlement">
                {{ model.accountName }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Remboursement actuel">
                {{ model.changeAmount }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Dette actuelle">
                {{ model.debt }}
              </a-form-item>
            </a-col>
            <a-col :span="6"> </a-col>
          </a-row>
        </section>
      </template>
      <!-- Commande de vente -->
      <template v-else-if="billType === '销售订单'">
        <section ref="print" id="saleOrderPrint">
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Client">
                <a-input v-decorator="['id']" hidden />
                {{ model.organName }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Date du document">
                {{ model.operTimeStr }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de document">
                {{ model.number }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Vendeur">
                {{ model.salesManStr }}
              </a-form-item>
            </a-col>
          </a-row>
          <div :style="tableWidth">
            <a-table
              ref="table"
              size="middle"
              bordered
              rowKey="id"
              :pagination="false"
              :loading="loading"
              :columns="columns"
              :dataSource="dataSource"
            >
              <template slot="customBarCode" slot-scope="text, record">
                <div :style="record.imgName ? 'float:left;line-height:30px' : 'float:left;'">{{ record.barCode }}</div>
                <a-popover placement="right" trigger="click">
                  <template slot="content"
                    ><img :src="getImgUrl(record.imgName, record.imgLarge)" width="500px"
                  /></template>
                  <div class="item-info" v-if="record.imgName">
                    <img
                      v-if="record.imgName"
                      :src="getImgUrl(record.imgName, record.imgSmall)"
                      class="item-img"
                      title="Voir l'image en grand"
                    />
                  </div>
                </a-popover>
              </template>
            </a-table>
          </div>
          <a-row class="form-row" :gutter="24">
            <a-col :lg="24" :md="24" :sm="24">
              <a-form-item
                :labelCol="labelCol"
                :wrapperCol="{ xs: { span: 24 }, sm: { span: 24 } }"
                label=""
                style="padding: 20px 10px"
              >
                {{ model.remark }}
              </a-form-item>
            </a-col>
          </a-row>
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Taux de remise">
                {{ model.discount }}%
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Remise de recouvrement">
                {{ model.discountMoney }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item
                :labelCol="{ xs: { span: 24 }, sm: { span: 6 } }"
                :wrapperCol="wrapperCol"
                label="Montant après remise"
              >
                {{ model.discountLastMoney }}
              </a-form-item>
            </a-col>
            <a-col :span="6"></a-col>
          </a-row>
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Compte de règlement">
                {{ model.accountName }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Acompte perçu">
                {{ model.changeAmount }}
              </a-form-item>
            </a-col>
            <a-col :span="6"></a-col>
            <a-col :span="6"></a-col>
          </a-row>
        </section>
      </template>
      <!-- Sortie de vente -->
      <template v-else-if="billType === '销售出库'">
        <section ref="print" id="saleOutPrint">
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Client">
                <a-input v-decorator="['id']" hidden />
                {{ model.organName }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Date du document">
                {{ model.operTimeStr }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de document">
                {{ model.number }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Commande associée">
                <a @click="myHandleDetail(model.linkNumber)">{{ model.linkNumber }}</a>
              </a-form-item>
            </a-col>
          </a-row>
          <div :style="tableWidth">
            <a-table
              ref="table"
              size="middle"
              bordered
              rowKey="id"
              :pagination="false"
              :loading="loading"
              :columns="columns"
              :dataSource="dataSource"
            >
              <template slot="customBarCode" slot-scope="text, record">
                <div :style="record.imgName ? 'float:left;line-height:30px' : 'float:left;'">{{ record.barCode }}</div>
                <a-popover placement="right" trigger="click">
                  <template slot="content"
                    ><img :src="getImgUrl(record.imgName, record.imgLarge)" width="500px"
                  /></template>
                  <div class="item-info" v-if="record.imgName">
                    <img
                      v-if="record.imgName"
                      :src="getImgUrl(record.imgName, record.imgSmall)"
                      class="item-img"
                      title="Voir l'image en grand"
                    />
                  </div>
                </a-popover>
              </template>
            </a-table>
          </div>
          <a-row class="form-row" :gutter="24">
            <a-col :lg="24" :md="24" :sm="24">
              <a-form-item
                :labelCol="labelCol"
                :wrapperCol="{ xs: { span: 24 }, sm: { span: 24 } }"
                label=""
                style="padding: 20px 10px"
              >
                {{ model.remark }}
              </a-form-item>
            </a-col>
          </a-row>
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Taux de remise">
                {{ model.discount }}%
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Remise de recouvrement">
                {{ model.discountMoney }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item
                :labelCol="{ xs: { span: 24 }, sm: { span: 6 } }"
                :wrapperCol="wrapperCol"
                label="Montant après remise"
              >
                {{ model.discountLastMoney }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Autres frais">
                {{ model.otherMoney }}
              </a-form-item>
            </a-col>
          </a-row>
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Compte de règlement">
                {{ model.accountName }}
              </a-form-item>
            </a-col>
            <a-col v-if="model.deposit" :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Acompte déduit">
                {{ model.deposit }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Recouvrement actuel">
                {{ model.changeAmount }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Dette actuelle">
                {{ model.debt }}
              </a-form-item>
            </a-col>
            <a-col v-if="model.hasBackFlag" :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de retour">
                <template v-for="(item, index) in linkNumberList">
                  <a @click="myHandleDetail(item.number)">{{ item.number }}</a
                  ><br />
                </template>
              </a-form-item>
            </a-col>
          </a-row>
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Vendeur">
                {{ model.salesManStr }}
              </a-form-item>
            </a-col>
            <a-col v-if="financialBillNoList.length" :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de recouvrement">
                <template v-for="(item, index) in financialBillNoList">
                  <a @click="myHandleFinancialDetail(item.billNo)">{{ item.billNo }}</a
                  ><br />
                </template>
              </a-form-item>
            </a-col>
          </a-row>
        </section>
      </template>
      <!-- Retour de vente -->
      <template v-else-if="billType === '销售退货入库'">
        <section ref="print" id="saleBackPrint">
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Client">
                <a-input v-decorator="['id']" hidden />
                {{ model.organName }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Date du document">
                {{ model.operTimeStr }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de document">
                {{ model.number }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Document associé">
                <a @click="myHandleDetail(model.linkNumber)">{{ model.linkNumber }}</a>
              </a-form-item>
            </a-col>
          </a-row>
          <div :style="tableWidth">
            <a-table
              ref="table"
              size="middle"
              bordered
              rowKey="id"
              :pagination="false"
              :loading="loading"
              :columns="columns"
              :dataSource="dataSource"
            >
              <template slot="customBarCode" slot-scope="text, record">
                <div :style="record.imgName ? 'float:left;line-height:30px' : 'float:left;'">{{ record.barCode }}</div>
                <a-popover placement="right" trigger="click">
                  <template slot="content"
                    ><img :src="getImgUrl(record.imgName, record.imgLarge)" width="500px"
                  /></template>
                  <div class="item-info" v-if="record.imgName">
                    <img
                      v-if="record.imgName"
                      :src="getImgUrl(record.imgName, record.imgSmall)"
                      class="item-img"
                      title="Voir l'image en grand"
                    />
                  </div>
                </a-popover>
              </template>
            </a-table>
          </div>
          <a-row class="form-row" :gutter="24">
            <a-col :lg="24" :md="24" :sm="24">
              <a-form-item
                :labelCol="labelCol"
                :wrapperCol="{ xs: { span: 24 }, sm: { span: 24 } }"
                label=""
                style="padding: 20px 10px"
              >
                {{ model.remark }}
              </a-form-item>
            </a-col>
          </a-row>
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Taux de remise">
                {{ model.discount }}%
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Remise de remboursement">
                {{ model.discountMoney }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item
                :labelCol="{ xs: { span: 24 }, sm: { span: 6 } }"
                :wrapperCol="wrapperCol"
                label="Montant après remise"
              >
                {{ model.discountLastMoney }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Autres frais">
                {{ model.otherMoney }}
              </a-form-item>
            </a-col>
          </a-row>
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Compte de règlement">
                {{ model.accountName }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Remboursement actuel">
                {{ model.changeAmount }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Dette actuelle">
                {{ model.debt }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Vendeur">
                {{ model.salesManStr }}
              </a-form-item>
            </a-col>
          </a-row>
        </section>
      </template>
      <!-- Autre entrée -->
      <template v-else-if="billType === '其它入库'">
        <section ref="print" id="otherInPrint">
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Fournisseur">
                <a-input v-decorator="['id']" hidden />
                {{ model.organName }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Date du document">
                {{ model.operTimeStr }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de document">
                {{ model.number }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item v-if="model.billType" :labelCol="labelCol" :wrapperCol="wrapperCol" label="Document associé">
                {{ model.linkNumber }} {{ model.billType }}
              </a-form-item>
              <a-form-item
                v-if="!model.billType"
                :labelCol="labelCol"
                :wrapperCol="wrapperCol"
                label="Document associé"
              >
                <a @click="myHandleDetail(model.linkNumber)">{{ model.linkNumber }}</a>
              </a-form-item>
            </a-col>
          </a-row>
          <div :style="tableWidth">
            <a-table
              ref="table"
              size="middle"
              bordered
              rowKey="id"
              :pagination="false"
              :loading="loading"
              :columns="columns"
              :dataSource="dataSource"
            >
              <template slot="customBarCode" slot-scope="text, record">
                <div :style="record.imgName ? 'float:left;line-height:30px' : 'float:left;'">{{ record.barCode }}</div>
                <a-popover placement="right" trigger="click">
                  <template slot="content"
                    ><img :src="getImgUrl(record.imgName, record.imgLarge)" width="500px"
                  /></template>
                  <div class="item-info" v-if="record.imgName">
                    <img
                      v-if="record.imgName"
                      :src="getImgUrl(record.imgName, record.imgSmall)"
                      class="item-img"
                      title="Voir l'image en grand"
                    />
                  </div>
                </a-popover>
              </template>
            </a-table>
          </div>
          <a-row class="form-row" :gutter="24">
            <a-col :lg="24" :md="24" :sm="24">
              <a-form-item
                :labelCol="labelCol"
                :wrapperCol="{ xs: { span: 24 }, sm: { span: 24 } }"
                label=""
                style="padding: 20px 10px"
              >
                {{ model.remark }}
              </a-form-item>
            </a-col>
          </a-row>
        </section>
      </template>
      <!-- Autre sortie -->
      <template v-else-if="billType === '其它出库'">
        <section ref="print" id="otherOutPrint">
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Client">
                <a-input v-decorator="['id']" hidden />
                {{ model.organName }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Date du document">
                {{ model.operTimeStr }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de document">
                {{ model.number }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item v-if="model.billType" :labelCol="labelCol" :wrapperCol="wrapperCol" label="Document associé">
                {{ model.linkNumber }} {{ model.billType }}
              </a-form-item>
              <a-form-item
                v-if="!model.billType"
                :labelCol="labelCol"
                :wrapperCol="wrapperCol"
                label="Document associé"
              >
                <a @click="myHandleDetail(model.linkNumber)">{{ model.linkNumber }}</a>
              </a-form-item>
            </a-col>
          </a-row>
          <div :style="tableWidth">
            <a-table
              ref="table"
              size="middle"
              bordered
              rowKey="id"
              :pagination="false"
              :loading="loading"
              :columns="columns"
              :dataSource="dataSource"
            >
              <template slot="customBarCode" slot-scope="text, record">
                <div :style="record.imgName ? 'float:left;line-height:30px' : 'float:left;'">{{ record.barCode }}</div>
                <a-popover placement="right" trigger="click">
                  <template slot="content"
                    ><img :src="getImgUrl(record.imgName, record.imgLarge)" width="500px"
                  /></template>
                  <div class="item-info" v-if="record.imgName">
                    <img
                      v-if="record.imgName"
                      :src="getImgUrl(record.imgName, record.imgSmall)"
                      class="item-img"
                      title="Voir l'image en grand"
                    />
                  </div>
                </a-popover>
              </template>
            </a-table>
          </div>
          <a-row class="form-row" :gutter="24">
            <a-col :lg="24" :md="24" :sm="24">
              <a-form-item
                :labelCol="labelCol"
                :wrapperCol="{ xs: { span: 24 }, sm: { span: 24 } }"
                label=""
                style="padding: 20px 10px"
              >
                {{ model.remark }}
              </a-form-item>
            </a-col>
          </a-row>
        </section>
      </template>
      <!-- Transfert de sortie -->
      <template v-else-if="billType === '调拨出库'">
        <section ref="print" id="allocationOutPrint">
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Date du document">
                {{ model.operTimeStr }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de document">
                {{ model.number }}
              </a-form-item>
            </a-col>
            <a-col :span="6"></a-col>
            <a-col :span="6"></a-col>
          </a-row>
          <div :style="tableWidth">
            <a-table
              ref="table"
              size="middle"
              bordered
              rowKey="id"
              :pagination="false"
              :loading="loading"
              :columns="columns"
              :dataSource="dataSource"
            >
              <template slot="customBarCode" slot-scope="text, record">
                <div :style="record.imgName ? 'float:left;line-height:30px' : 'float:left;'">{{ record.barCode }}</div>
                <a-popover placement="right" trigger="click">
                  <template slot="content"
                    ><img :src="getImgUrl(record.imgName, record.imgLarge)" width="500px"
                  /></template>
                  <div class="item-info" v-if="record.imgName">
                    <img
                      v-if="record.imgName"
                      :src="getImgUrl(record.imgName, record.imgSmall)"
                      class="item-img"
                      title="Voir l'image en grand"
                    />
                  </div>
                </a-popover>
              </template>
            </a-table>
          </div>
          <a-row class="form-row" :gutter="24">
            <a-col :lg="24" :md="24" :sm="24">
              <a-form-item
                :labelCol="labelCol"
                :wrapperCol="{ xs: { span: 24 }, sm: { span: 24 } }"
                label=""
                style="padding: 20px 10px"
              >
                {{ model.remark }}
              </a-form-item>
            </a-col>
          </a-row>
        </section>
      </template>
      <!-- Bon d'assemblage -->
      <template v-else-if="billType === '组装单'">
        <section ref="print" id="assemblePrint">
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Date du document">
                {{ model.operTimeStr }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de document">
                {{ model.number }}
              </a-form-item>
            </a-col>
            <a-col :span="6"></a-col>
            <a-col :span="6"></a-col>
          </a-row>
          <div :style="tableWidth">
            <a-table
              ref="table"
              size="middle"
              bordered
              rowKey="id"
              :pagination="false"
              :loading="loading"
              :columns="columns"
              :dataSource="dataSource"
            >
              <template slot="customBarCode" slot-scope="text, record">
                <div :style="record.imgName ? 'float:left;line-height:30px' : 'float:left;'">{{ record.barCode }}</div>
                <a-popover placement="right" trigger="click">
                  <template slot="content"
                    ><img :src="getImgUrl(record.imgName, record.imgLarge)" width="500px"
                  /></template>
                  <div class="item-info" v-if="record.imgName">
                    <img
                      v-if="record.imgName"
                      :src="getImgUrl(record.imgName, record.imgSmall)"
                      class="item-img"
                      title="Voir l'image en grand"
                    />
                  </div>
                </a-popover>
              </template>
            </a-table>
          </div>
          <a-row class="form-row" :gutter="24">
            <a-col :lg="24" :md="24" :sm="24">
              <a-form-item
                :labelCol="labelCol"
                :wrapperCol="{ xs: { span: 24 }, sm: { span: 24 } }"
                label=""
                style="padding: 20px 10px"
              >
                {{ model.remark }}
              </a-form-item>
            </a-col>
          </a-row>
        </section>
      </template>
      <!-- Bon de démontage -->
      <template v-else-if="billType === '拆卸单'">
        <section ref="print" id="disassemblePrint">
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Date du document">
                {{ model.operTimeStr }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de document">
                {{ model.number }}
              </a-form-item>
            </a-col>
            <a-col :span="6"></a-col>
            <a-col :span="6"></a-col>
          </a-row>
          <div :style="tableWidth">
            <a-table
              ref="table"
              size="middle"
              bordered
              rowKey="id"
              :pagination="false"
              :loading="loading"
              :columns="columns"
              :dataSource="dataSource"
            >
              <template slot="customBarCode" slot-scope="text, record">
                <div :style="record.imgName ? 'float:left;line-height:30px' : 'float:left;'">{{ record.barCode }}</div>
                <a-popover placement="right" trigger="click">
                  <template slot="content"
                    ><img :src="getImgUrl(record.imgName, record.imgLarge)" width="500px"
                  /></template>
                  <div class="item-info" v-if="record.imgName">
                    <img
                      v-if="record.imgName"
                      :src="getImgUrl(record.imgName, record.imgSmall)"
                      class="item-img"
                      title="Voir l'image en grand"
                    />
                  </div>
                </a-popover>
              </template>
            </a-table>
          </div>
          <a-row class="form-row" :gutter="24">
            <a-col :lg="24" :md="24" :sm="24">
              <a-form-item
                :labelCol="labelCol"
                :wrapperCol="{ xs: { span: 24 }, sm: { span: 24 } }"
                label=""
                style="padding: 20px 10px"
              >
                {{ model.remark }}
              </a-form-item>
            </a-col>
          </a-row>
        </section>
      </template>
      <!-- Révision d'inventaire -->
      <template v-else-if="billType === '盘点复盘'">
        <section ref="print" id="stockCheckReplayPrint">
          <a-row class="form-row" :gutter="24">
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Date du document">
                {{ model.operTimeStr }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Numéro de document">
                {{ model.number }}
              </a-form-item>
            </a-col>
            <a-col :span="6">
              <a-form-item :labelCol="labelCol" :wrapperCol="wrapperCol" label="Document associé">
                {{ model.linkNumber }}
              </a-form-item>
            </a-col>
            <a-col :span="6"></a-col>
          </a-row>
          <div :style="tableWidth">
            <a-table
              ref="table"
              size="middle"
              bordered
              rowKey="id"
              :pagination="false"
              :loading="loading"
              :columns="columns"
              :dataSource="dataSource"
            >
              <template slot="customBarCode" slot-scope="text, record">
                <div :style="record.imgName ? 'float:left;line-height:30px' : 'float:left;'">{{ record.barCode }}</div>
                <a-popover placement="right" trigger="click">
                  <template slot="content"
                    ><img :src="getImgUrl(record.imgName, record.imgLarge)" width="500px"
                  /></template>
                  <div class="item-info" v-if="record.imgName">
                    <img
                      v-if="record.imgName"
                      :src="getImgUrl(record.imgName, record.imgSmall)"
                      class="item-img"
                      title="Voir l'image en grand"
                    />
                  </div>
                </a-popover>
              </template>
            </a-table>
          </div>
          <a-row class="form-row" :gutter="24">
            <a-col :lg="24" :md="24" :sm="24">
              <a-form-item
                :labelCol="labelCol"
                :wrapperCol="{ xs: { span: 24 }, sm: { span: 24 } }"
                label=""
                style="padding: 20px 10px"
              >
                {{ model.remark }}
              </a-form-item>
            </a-col>
          </a-row>
        </section>
      </template>
      <template v-if="fileList && fileList.length > 0">
        <a-row class="form-row" :gutter="24">
          <a-col :span="10">
            <a-form-item
              :labelCol="{ xs: { span: 24 }, sm: { span: 3 } }"
              :wrapperCol="{ xs: { span: 24 }, sm: { span: 21 } }"
              label="Pièce jointe"
            >
              <j-upload v-model="fileList" bizPath="bill" :disabled="true" :buttonVisible="false"></j-upload>
            </a-form-item>
          </a-col>
          <a-col :span="14"></a-col>
        </a-row>
      </template>
    </a-form>
    <bill-print-iframe ref="modalDetail"></bill-print-iframe>
    <bill-print-pro-iframe ref="modalProDetail"></bill-print-pro-iframe>
    <financial-detail ref="financialDetailModal"></financial-detail>
  </j-modal>
</template>

<script>
import pick from 'lodash.pick'
import { getAction, postAction, getFileAccessHttpUrl } from '@/api/manage'
import {
  findBillDetailByNumber,
  findFinancialDetailByNumber,
  getPlatformConfigByKey,
  getCurrentSystemConfig,
} from '@/api/api'
import { getMpListShort, getCheckFlag, exportXlsPost } from '@/utils/util'
import BillPrintIframe from './BillPrintIframe'
import BillPrintProIframe from './BillPrintProIframe'
import FinancialDetail from '../../financial/dialog/FinancialDetail'
import JUpload from '@/components/jeecg/JUpload'
import Vue from 'vue'
export default {
  name: 'BillDetail',
  components: {
    BillPrintIframe,
    BillPrintProIframe,
    FinancialDetail,
    JUpload,
  },
  data() {
    return {
      title: 'Détails',
      width: '1600px',
      visible: false,
      modalStyle: '',
      model: {},
      isCanBackCheck: true,
      billType: '',
      billPrintFlag: false,
      fileList: [],
      purchaseBySaleFlag: false,
      linkNumberList: [],
      financialBillNoList: [],
      /* Vérifier si l'audit original est activé */
      checkFlag: true,
      /* Afficher ou non le bouton d'impression */
      isShowPrintBtn: true,
      tableWidth: {
        width: '1700px',
      },
      tableWidthRetail: {
        width: '1200px',
      },
      labelCol: {
        xs: { span: 24 },
        sm: { span: 5 },
      },
      wrapperCol: {
        xs: { span: 24 },
        sm: { span: 16 },
      },
      form: this.$form.createForm(this),
      loading: false,
      dataSource: [],
      url: {
        detailList: '/depotItem/getDetailList',
        batchSetStatusUrl: '/depotHead/batchSetStatus',
      },
      // Titre des informations étendues
      otherFieldTitle: '',
      // En-têtes de colonnes
      columns: [],
      // Définition des colonnes
      defColumns: [],
      retailOutColumns: [
        { title: "Nom de l'entrepôt", dataIndex: 'depotName' },
        { title: 'Code-barres', dataIndex: 'barCode' },
        { title: 'Nom', dataIndex: 'name' },
        { title: 'Spécification', dataIndex: 'standard' },
        { title: 'Modèle', dataIndex: 'model' },
        { title: 'Couleur', dataIndex: 'color' },
        { title: 'Marque', dataIndex: 'brand' },
        { title: 'Fabricant', dataIndex: 'mfrs' },
        { title: 'Extension 1', dataIndex: 'otherField1' },
        { title: 'Extension 2', dataIndex: 'otherField2' },
        { title: 'Extension 3', dataIndex: 'otherField3' },
        { title: 'Stock', dataIndex: 'stock' },
        { title: 'Unité', dataIndex: 'unit' },
        { title: 'Numéro de série', dataIndex: 'snList', width: 300 },
        { title: 'Numéro de lot', dataIndex: 'batchNumber' },
        { title: "Date d'expiration", dataIndex: 'expirationDate' },
        { title: 'Multi-attributs', dataIndex: 'sku' },
        { title: 'Quantité', dataIndex: 'operNumber' },
        { title: 'Prix unitaire', dataIndex: 'unitPrice' },
        { title: 'Montant', dataIndex: 'allPrice' },
        { title: 'Poids', dataIndex: 'weight' },
        { title: 'Emplacement/Étagère', dataIndex: 'position' },
        { title: 'Remarque', dataIndex: 'remark' },
      ],
      retailBackColumns: [
        { title: "Nom de l'entrepôt", dataIndex: 'depotName' },
        { title: 'Code-barres', dataIndex: 'barCode' },
        { title: 'Nom', dataIndex: 'name' },
        { title: 'Spécification', dataIndex: 'standard' },
        { title: 'Modèle', dataIndex: 'model' },
        { title: 'Couleur', dataIndex: 'color' },
        { title: 'Marque', dataIndex: 'brand' },
        { title: 'Fabricant', dataIndex: 'mfrs' },
        { title: 'Extension 1', dataIndex: 'otherField1' },
        { title: 'Extension 2', dataIndex: 'otherField2' },
        { title: 'Extension 3', dataIndex: 'otherField3' },
        { title: 'Stock', dataIndex: 'stock' },
        { title: 'Unité', dataIndex: 'unit' },
        { title: 'Numéro de série', dataIndex: 'snList', width: 300 },
        { title: 'Numéro de lot', dataIndex: 'batchNumber' },
        { title: "Date d'expiration", dataIndex: 'expirationDate' },
        { title: 'Multi-attributs', dataIndex: 'sku' },
        { title: 'Quantité', dataIndex: 'operNumber' },
        { title: 'Prix unitaire', dataIndex: 'unitPrice' },
        { title: 'Montant', dataIndex: 'allPrice' },
        { title: 'Poids', dataIndex: 'weight' },
        { title: 'Emplacement/Étagère', dataIndex: 'position' },
        { title: 'Remarque', dataIndex: 'remark' },
      ],
      purchaseApplyColumns: [
        { title: 'Code-barres', dataIndex: 'barCode' },
        { title: 'Nom', dataIndex: 'name' },
        { title: 'Spécification', dataIndex: 'standard' },
        { title: 'Modèle', dataIndex: 'model' },
        { title: 'Couleur', dataIndex: 'color' },
        { title: 'Marque', dataIndex: 'brand' },
        { title: 'Fabricant', dataIndex: 'mfrs' },
        { title: 'Extension 1', dataIndex: 'otherField1' },
        { title: 'Extension 2', dataIndex: 'otherField2' },
        { title: 'Extension 3', dataIndex: 'otherField3' },
        { title: 'Unité', dataIndex: 'unit' },
        { title: 'Multi-attributs', dataIndex: 'sku' },
        { title: 'Quantité', dataIndex: 'operNumber' },
        { title: 'Déjà acheté', dataIndex: 'finishNumber' },
        { title: 'Remarque', dataIndex: 'remark' },
      ],
      purchaseOrderColumns: [
        { title: 'Code-barres', dataIndex: 'barCode' },
        { title: 'Nom', dataIndex: 'name' },
        { title: 'Spécification', dataIndex: 'standard' },
        { title: 'Modèle', dataIndex: 'model' },
        { title: 'Couleur', dataIndex: 'color' },
        { title: 'Marque', dataIndex: 'brand' },
        { title: 'Fabricant', dataIndex: 'mfrs' },
        { title: 'Extension 1', dataIndex: 'otherField1' },
        { title: 'Extension 2', dataIndex: 'otherField2' },
        { title: 'Extension 3', dataIndex: 'otherField3' },
        { title: 'Stock', dataIndex: 'stock' },
        { title: 'Unité', dataIndex: 'unit' },
        { title: 'Multi-attributs', dataIndex: 'sku' },
        { title: 'Quantité', dataIndex: 'operNumber' },
        { title: 'Déjà acheté', dataIndex: 'finishNumber' },
        { title: 'Prix unitaire', dataIndex: 'unitPrice' },
        { title: 'Montant', dataIndex: 'allPrice' },
        { title: 'Taux de taxe (%)', dataIndex: 'taxRate' },
        { title: 'Montant de la taxe', dataIndex: 'taxMoney' },
        { title: 'Total TTC', dataIndex: 'taxLastMoney' },
        { title: 'Remarque', dataIndex: 'remark' },
      ],
      purchaseInColumns: [
        { title: "Nom de l'entrepôt", dataIndex: 'depotName' },
        { title: 'Code-barres', dataIndex: 'barCode' },
        { title: 'Nom', dataIndex: 'name' },
        { title: 'Spécification', dataIndex: 'standard' },
        { title: 'Modèle', dataIndex: 'model' },
        { title: 'Couleur', dataIndex: 'color' },
        { title: 'Marque', dataIndex: 'brand' },
        { title: 'Fabricant', dataIndex: 'mfrs' },
        { title: 'Extension 1', dataIndex: 'otherField1' },
        { title: 'Extension 2', dataIndex: 'otherField2' },
        { title: 'Extension 3', dataIndex: 'otherField3' },
        { title: 'Stock', dataIndex: 'stock' },
        { title: 'Unité', dataIndex: 'unit' },
        { title: 'Numéro de série', dataIndex: 'snList', width: 300 },
        { title: 'Numéro de lot', dataIndex: 'batchNumber' },
        { title: "Date d'expiration", dataIndex: 'expirationDate' },
        { title: 'Multi-attributs', dataIndex: 'sku' },
        { title: 'Quantité', dataIndex: 'operNumber' },
        { title: 'Déjà entré', dataIndex: 'finishNumber' },
        { title: 'Prix unitaire', dataIndex: 'unitPrice' },
        { title: 'Montant', dataIndex: 'allPrice' },
        { title: 'Taux de taxe (%)', dataIndex: 'taxRate' },
        { title: 'Montant de la taxe', dataIndex: 'taxMoney' },
        { title: 'Total TTC', dataIndex: 'taxLastMoney' },
        { title: 'Poids', dataIndex: 'weight' },
        { title: 'Emplacement/Étagère', dataIndex: 'position' },
        { title: 'Remarque', dataIndex: 'remark' },
      ],
      purchaseBackColumns: [
        { title: "Nom de l'entrepôt", dataIndex: 'depotName' },
        { title: 'Code-barres', dataIndex: 'barCode' },
        { title: 'Nom', dataIndex: 'name' },
        { title: 'Spécification', dataIndex: 'standard' },
        { title: 'Modèle', dataIndex: 'model' },
        { title: 'Couleur', dataIndex: 'color' },
        { title: 'Marque', dataIndex: 'brand' },
        { title: 'Fabricant', dataIndex: 'mfrs' },
        { title: 'Extension 1', dataIndex: 'otherField1' },
        { title: 'Extension 2', dataIndex: 'otherField2' },
        { title: 'Extension 3', dataIndex: 'otherField3' },
        { title: 'Stock', dataIndex: 'stock' },
        { title: 'Unité', dataIndex: 'unit' },
        { title: 'Numéro de série', dataIndex: 'snList', width: 300 },
        { title: 'Numéro de lot', dataIndex: 'batchNumber' },
        { title: "Date d'expiration", dataIndex: 'expirationDate' },
        { title: 'Multi-attributs', dataIndex: 'sku' },
        { title: 'Quantité', dataIndex: 'operNumber' },
        { title: 'Déjà sorti', dataIndex: 'finishNumber' },
        { title: 'Prix unitaire', dataIndex: 'unitPrice' },
        { title: 'Montant', dataIndex: 'allPrice' },
        { title: 'Taux de taxe (%)', dataIndex: 'taxRate' },
        { title: 'Montant de la taxe', dataIndex: 'taxMoney' },
        { title: 'Total TTC', dataIndex: 'taxLastMoney' },
        { title: 'Poids', dataIndex: 'weight' },
        { title: 'Emplacement/Étagère', dataIndex: 'position' },
        { title: 'Remarque', dataIndex: 'remark' },
      ],
      saleOrderColumns: [
        { title: 'Code-barres', dataIndex: 'barCode' },
        { title: 'Nom', dataIndex: 'name' },
        { title: 'Spécification', dataIndex: 'standard' },
        { title: 'Modèle', dataIndex: 'model' },
        { title: 'Couleur', dataIndex: 'color' },
        { title: 'Marque', dataIndex: 'brand' },
        { title: 'Fabricant', dataIndex: 'mfrs' },
        { title: 'Extension 1', dataIndex: 'otherField1' },
        { title: 'Extension 2', dataIndex: 'otherField2' },
        { title: 'Extension 3', dataIndex: 'otherField3' },
        { title: 'Stock', dataIndex: 'stock' },
        { title: 'Unité', dataIndex: 'unit' },
        { title: 'Multi-attributs', dataIndex: 'sku' },
        { title: 'Quantité', dataIndex: 'operNumber' },
        { title: 'Déjà vendu', dataIndex: 'finishNumber' },
        { title: 'Prix unitaire', dataIndex: 'unitPrice' },
        { title: 'Montant', dataIndex: 'allPrice' },
        { title: 'Taux de taxe (%)', dataIndex: 'taxRate' },
        { title: 'Montant de la taxe', dataIndex: 'taxMoney' },
        { title: 'Total TTC', dataIndex: 'taxLastMoney' },
        { title: 'Remarque', dataIndex: 'remark' },
      ],
      saleOutColumns: [
        { title: "Nom de l'entrepôt", dataIndex: 'depotName' },
        { title: 'Code-barres', dataIndex: 'barCode' },
        { title: 'Nom', dataIndex: 'name' },
        { title: 'Spécification', dataIndex: 'standard' },
        { title: 'Modèle', dataIndex: 'model' },
        { title: 'Couleur', dataIndex: 'color' },
        { title: 'Marque', dataIndex: 'brand' },
        { title: 'Fabricant', dataIndex: 'mfrs' },
        { title: 'Extension 1', dataIndex: 'otherField1' },
        { title: 'Extension 2', dataIndex: 'otherField2' },
        { title: 'Extension 3', dataIndex: 'otherField3' },
        { title: 'Stock', dataIndex: 'stock' },
        { title: 'Unité', dataIndex: 'unit' },
        { title: 'Numéro de série', dataIndex: 'snList', width: 300 },
        { title: 'Numéro de lot', dataIndex: 'batchNumber' },
        { title: "Date d'expiration", dataIndex: 'expirationDate' },
        { title: 'Multi-attributs', dataIndex: 'sku' },
        { title: 'Quantité', dataIndex: 'operNumber' },
        { title: 'Déjà sorti', dataIndex: 'finishNumber' },
        { title: 'Prix unitaire', dataIndex: 'unitPrice' },
        { title: 'Montant', dataIndex: 'allPrice' },
        { title: 'Taux de taxe (%)', dataIndex: 'taxRate' },
        { title: 'Montant de la taxe', dataIndex: 'taxMoney' },
        { title: 'Total TTC', dataIndex: 'taxLastMoney' },
        { title: 'Poids', dataIndex: 'weight' },
        { title: 'Emplacement/Étagère', dataIndex: 'position' },
        { title: 'Remarque', dataIndex: 'remark' },
      ],
      saleBackColumns: [
        { title: "Nom de l'entrepôt", dataIndex: 'depotName' },
        { title: 'Code-barres', dataIndex: 'barCode' },
        { title: 'Nom', dataIndex: 'name' },
        { title: 'Spécification', dataIndex: 'standard' },
        { title: 'Modèle', dataIndex: 'model' },
        { title: 'Couleur', dataIndex: 'color' },
        { title: 'Marque', dataIndex: 'brand' },
        { title: 'Fabricant', dataIndex: 'mfrs' },
        { title: 'Extension 1', dataIndex: 'otherField1' },
        { title: 'Extension 2', dataIndex: 'otherField2' },
        { title: 'Extension 3', dataIndex: 'otherField3' },
        { title: 'Stock', dataIndex: 'stock' },
        { title: 'Unité', dataIndex: 'unit' },
        { title: 'Numéro de série', dataIndex: 'snList', width: 300 },
        { title: 'Numéro de lot', dataIndex: 'batchNumber' },
        { title: "Date d'expiration", dataIndex: 'expirationDate' },
        { title: 'Multi-attributs', dataIndex: 'sku' },
        { title: 'Quantité', dataIndex: 'operNumber' },
        { title: 'Déjà entré', dataIndex: 'finishNumber' },
        { title: 'Prix unitaire', dataIndex: 'unitPrice' },
        { title: 'Montant', dataIndex: 'allPrice' },
        { title: 'Taux de taxe (%)', dataIndex: 'taxRate' },
        { title: 'Montant de la taxe', dataIndex: 'taxMoney' },
        { title: 'Total TTC', dataIndex: 'taxLastMoney' },
        { title: 'Poids', dataIndex: 'weight' },
        { title: 'Emplacement/Étagère', dataIndex: 'position' },
        { title: 'Remarque', dataIndex: 'remark' },
      ],
      otherInColumns: [
        { title: "Nom de l'entrepôt", dataIndex: 'depotName' },
        { title: 'Code-barres', dataIndex: 'barCode' },
        { title: 'Nom', dataIndex: 'name' },
        { title: 'Spécification', dataIndex: 'standard' },
        { title: 'Modèle', dataIndex: 'model' },
        { title: 'Couleur', dataIndex: 'color' },
        { title: 'Marque', dataIndex: 'brand' },
        { title: 'Fabricant', dataIndex: 'mfrs' },
        { title: 'Extension 1', dataIndex: 'otherField1' },
        { title: 'Extension 2', dataIndex: 'otherField2' },
        { title: 'Extension 3', dataIndex: 'otherField3' },
        { title: 'Stock', dataIndex: 'stock' },
        { title: 'Unité', dataIndex: 'unit' },
        { title: 'Numéro de série', dataIndex: 'snList', width: 300 },
        { title: 'Numéro de lot', dataIndex: 'batchNumber' },
        { title: "Date d'expiration", dataIndex: 'expirationDate' },
        { title: 'Multi-attributs', dataIndex: 'sku' },
        { title: 'Quantité', dataIndex: 'operNumber' },
        { title: 'Prix unitaire', dataIndex: 'unitPrice' },
        { title: 'Montant', dataIndex: 'allPrice' },
        { title: 'Poids', dataIndex: 'weight' },
        { title: 'Emplacement/Étagère', dataIndex: 'position' },
        { title: 'Remarque', dataIndex: 'remark' },
      ],
      otherOutColumns: [
        { title: "Nom de l'entrepôt", dataIndex: 'depotName' },
        { title: 'Code-barres', dataIndex: 'barCode' },
        { title: 'Nom', dataIndex: 'name' },
        { title: 'Spécification', dataIndex: 'standard' },
        { title: 'Modèle', dataIndex: 'model' },
        { title: 'Couleur', dataIndex: 'color' },
        { title: 'Marque', dataIndex: 'brand' },
        { title: 'Fabricant', dataIndex: 'mfrs' },
        { title: 'Extension 1', dataIndex: 'otherField1' },
        { title: 'Extension 2', dataIndex: 'otherField2' },
        { title: 'Extension 3', dataIndex: 'otherField3' },
        { title: 'Stock', dataIndex: 'stock' },
        { title: 'Unité', dataIndex: 'unit' },
        { title: 'Numéro de série', dataIndex: 'snList', width: 300 },
        { title: 'Numéro de lot', dataIndex: 'batchNumber' },
        { title: "Date d'expiration", dataIndex: 'expirationDate' },
        { title: 'Multi-attributs', dataIndex: 'sku' },
        { title: 'Quantité', dataIndex: 'operNumber' },
        { title: 'Prix unitaire', dataIndex: 'unitPrice' },
        { title: 'Montant', dataIndex: 'allPrice' },
        { title: 'Poids', dataIndex: 'weight' },
        { title: 'Emplacement/Étagère', dataIndex: 'position' },
        { title: 'Remarque', dataIndex: 'remark' },
      ],
      allocationOutColumns: [
        { title: "Nom de l'entrepôt", dataIndex: 'depotName' },
        { title: 'Code-barres', dataIndex: 'barCode' },
        { title: 'Nom', dataIndex: 'name' },
        { title: 'Spécification', dataIndex: 'standard' },
        { title: 'Modèle', dataIndex: 'model' },
        { title: 'Couleur', dataIndex: 'color' },
        { title: 'Marque', dataIndex: 'brand' },
        { title: 'Fabricant', dataIndex: 'mfrs' },
        { title: 'Extension 1', dataIndex: 'otherField1' },
        { title: 'Extension 2', dataIndex: 'otherField2' },
        { title: 'Extension 3', dataIndex: 'otherField3' },
        { title: 'Stock', dataIndex: 'stock' },
        { title: 'Entrepôt de destination', dataIndex: 'anotherDepotName' },
        { title: 'Unité', dataIndex: 'unit' },
        { title: 'Multi-attributs', dataIndex: 'sku' },
        { title: 'Quantité', dataIndex: 'operNumber' },
        { title: 'Prix unitaire', dataIndex: 'unitPrice' },
        { title: 'Montant', dataIndex: 'allPrice' },
        { title: 'Poids', dataIndex: 'weight' },
        { title: 'Emplacement/Étagère', dataIndex: 'position' },
        { title: 'Remarque', dataIndex: 'remark' },
      ],
      assembleColumns: [
        { title: 'Type de produit', dataIndex: 'mType' },
        { title: "Nom de l'entrepôt", dataIndex: 'depotName' },
        { title: 'Code-barres', dataIndex: 'barCode' },
        { title: 'Nom', dataIndex: 'name' },
        { title: 'Spécification', dataIndex: 'standard' },
        { title: 'Modèle', dataIndex: 'model' },
        { title: 'Couleur', dataIndex: 'color' },
        { title: 'Marque', dataIndex: 'brand' },
        { title: 'Fabricant', dataIndex: 'mfrs' },
        { title: 'Extension 1', dataIndex: 'otherField1' },
        { title: 'Extension 2', dataIndex: 'otherField2' },
        { title: 'Extension 3', dataIndex: 'otherField3' },
        { title: 'Stock', dataIndex: 'stock' },
        { title: 'Unité', dataIndex: 'unit' },
        { title: 'Multi-attributs', dataIndex: 'sku' },
        { title: 'Quantité', dataIndex: 'operNumber' },
        { title: 'Prix unitaire', dataIndex: 'unitPrice' },
        { title: 'Montant', dataIndex: 'allPrice' },
        { title: 'Remarque', dataIndex: 'remark' },
      ],
      disassembleColumns: [
        { title: 'Type de produit', dataIndex: 'mType' },
        { title: "Nom de l'entrepôt", dataIndex: 'depotName' },
        { title: 'Code-barres', dataIndex: 'barCode' },
        { title: 'Nom', dataIndex: 'name' },
        { title: 'Spécification', dataIndex: 'standard' },
        { title: 'Modèle', dataIndex: 'model' },
        { title: 'Couleur', dataIndex: 'color' },
        { title: 'Marque', dataIndex: 'brand' },
        { title: 'Fabricant', dataIndex: 'mfrs' },
        { title: 'Extension 1', dataIndex: 'otherField1' },
        { title: 'Extension 2', dataIndex: 'otherField2' },
        { title: 'Extension 3', dataIndex: 'otherField3' },
        { title: 'Stock', dataIndex: 'stock' },
        { title: 'Unité', dataIndex: 'unit' },
        { title: 'Multi-attributs', dataIndex: 'sku' },
        { title: 'Quantité', dataIndex: 'operNumber' },
        { title: 'Prix unitaire', dataIndex: 'unitPrice' },
        { title: 'Montant', dataIndex: 'allPrice' },
        { title: 'Remarque', dataIndex: 'remark' },
      ],
      stockCheckReplayColumns: [
        { title: "Nom de l'entrepôt", dataIndex: 'depotName' },
        { title: 'Code-barres', dataIndex: 'barCode' },
        { title: 'Nom', dataIndex: 'name' },
        { title: 'Spécification', dataIndex: 'standard' },
        { title: 'Modèle', dataIndex: 'model' },
        { title: 'Marque', dataIndex: 'brand' },
        { title: 'Fabricant', dataIndex: 'mfrs' },
        { title: 'Extension 1', dataIndex: 'otherField1' },
        { title: 'Extension 2', dataIndex: 'otherField2' },
        { title: 'Extension 3', dataIndex: 'otherField3' },
        { title: 'Stock', dataIndex: 'stock' },
        { title: 'Unité', dataIndex: 'unit' },
        { title: 'Multi-attributs', dataIndex: 'sku' },
        { title: 'Quantité', dataIndex: 'operNumber' },
        { title: 'Prix unitaire', dataIndex: 'unitPrice' },
        { title: 'Montant', dataIndex: 'allPrice' },
        { title: 'Remarque', dataIndex: 'remark' },
      ],
    }
  },
  created() {
    let realScreenWidth = window.screen.width
    this.width = realScreenWidth < 1500 ? '1200px' : '1600px'
    this.tableWidth = {
      width: '100%',
    }
    this.tableWidthRetail = {
      width: '100%',
    }
  },
  methods: {
    initSetting(record, type, ds) {
      if (type === '零售出库') {
        this.defColumns = this.retailOutColumns
      } else if (type === '零售退货入库') {
        this.defColumns = this.retailBackColumns
      } else if (type === '请购单') {
        this.defColumns = this.purchaseApplyColumns
      } else if (type === '采购订单') {
        this.defColumns = this.purchaseOrderColumns
      } else if (type === '采购入库') {
        this.defColumns = this.purchaseInColumns
      } else if (type === '采购退货出库') {
        this.defColumns = this.purchaseBackColumns
      } else if (type === '销售订单') {
        this.defColumns = this.saleOrderColumns
      } else if (type === '销售出库') {
        this.defColumns = this.saleOutColumns
      } else if (type === '销售退货入库') {
        this.defColumns = this.saleBackColumns
      } else if (type === '其它入库') {
        this.defColumns = this.otherInColumns
      } else if (type === '其它出库') {
        this.defColumns = this.otherOutColumns
      } else if (type === '调拨出库') {
        this.defColumns = this.allocationOutColumns
      } else if (type === '组装单') {
        this.defColumns = this.assembleColumns
      } else if (type === '拆卸单') {
        this.defColumns = this.disassembleColumns
      } else if (type === '盘点复盘') {
        this.defColumns = this.stockCheckReplayColumns
      }
      // Remplacer dynamiquement les champs étendus
      this.handleChangeOtherField()
      // Vérifier si les numéros de série, numéros de lot, dates d'expiration, multi-attributs, poids, emplacements/étagères, extensions, remarques, etc. ont des valeurs
      let needAddkeywords = []
      for (let i = 0; i < ds.length; i++) {
        if (ds[i].snList) {
          needAddkeywords.push('snList')
        }
        if (ds[i].batchNumber) {
          needAddkeywords.push('batchNumber')
        }
        if (ds[i].expirationDate) {
          needAddkeywords.push('expirationDate')
        }
        if (ds[i].sku) {
          needAddkeywords.push('sku')
        }
        if (ds[i].weight) {
          needAddkeywords.push('weight')
        }
        if (ds[i].position) {
          needAddkeywords.push('position')
        }
        if (ds[i].brand) {
          needAddkeywords.push('brand')
        }
        if (ds[i].mfrs) {
          needAddkeywords.push('mfrs')
        }
        if (ds[i].otherField1) {
          needAddkeywords.push('otherField1')
        }
        if (ds[i].otherField2) {
          needAddkeywords.push('otherField2')
        }
        if (ds[i].otherField3) {
          needAddkeywords.push('otherField3')
        }
        if (ds[i].taxRate) {
          needAddkeywords.push('taxRate')
        }
        if (ds[i].remark) {
          needAddkeywords.push('remark')
        }
        if (record.status === '3' || record.purchaseStatus === '3') {
          // Scénario d'achat partiel | vente partielle | conversion de commande de vente en commande d'achat
          needAddkeywords.push('finishNumber')
        }
      }
      let currentCol = [
        {
          title: '#',
          dataIndex: '',
          align: 'center',
          customRender: function (t, r, index) {
            if (r.mType) {
              // Afficher le numéro de séquence pour toutes les lignes d'assemblage et de démontage
              return index === ds.length ? '' : parseInt(index) + 1
            } else {
              return index === ds.length - 1 ? '' : parseInt(index) + 1
            }
          },
        },
      ]
      for (let i = 0; i < this.defColumns.length; i++) {
        // Supprimer la colonne
        let needRemoveKeywords = [
          'finishNumber',
          'snList',
          'batchNumber',
          'expirationDate',
          'sku',
          'weight',
          'position',
          'brand',
          'mfrs',
          'otherField1',
          'otherField2',
          'otherField3',
          'taxRate',
          'remark',
        ]
        if (needRemoveKeywords.indexOf(this.defColumns[i].dataIndex) === -1) {
          let info = {}
          info.title = this.defColumns[i].title
          info.dataIndex = this.defColumns[i].dataIndex
          if (this.defColumns[i].width) {
            info.width = this.defColumns[i].width
          }
          if (this.defColumns[i].dataIndex === 'barCode') {
            info.scopedSlots = { customRender: 'customBarCode' }
          }
          currentCol.push(info)
        }
        // Ajouter les colonnes avec des données
        if (needAddkeywords.indexOf(this.defColumns[i].dataIndex) > -1) {
          let info = {}
          info.title = this.defColumns[i].title
          info.dataIndex = this.defColumns[i].dataIndex
          if (this.defColumns[i].width) {
            info.width = this.defColumns[i].width
          }
          if (record.purchaseStatus === '3') {
            // Convertir le titre "Déjà sorti" en "Déjà acheté", pour le scénario de conversion de commande de vente en commande d'achat
            if (this.defColumns[i].dataIndex === 'finishNumber') {
              info.title = 'Déjà acheté'
            }
          }
          currentCol.push(info)
        }
      }
      this.columns = currentCol
    },
    // Remplacer dynamiquement les champs étendus
    handleChangeOtherField() {
      let mpStr = getMpListShort(Vue.ls.get('materialPropertyList'))
      if (mpStr) {
        let mpArr = mpStr.split(',')
        if (mpArr.length === 3) {
          this.otherFieldTitle = mpStr
          for (let i = 0; i < this.defColumns.length; i++) {
            if (this.defColumns[i].dataIndex === 'otherField1') {
              this.defColumns[i].title = mpArr[0]
            }
            if (this.defColumns[i].dataIndex === 'otherField2') {
              this.defColumns[i].title = mpArr[1]
            }
            if (this.defColumns[i].dataIndex === 'otherField3') {
              this.defColumns[i].title = mpArr[2]
            }
          }
        }
      }
    },
    initPlatform() {
      getPlatformConfigByKey({ platformKey: 'bill_print_flag' }).then((res) => {
        if (res && res.code === 200) {
          if (
            this.billType === '零售出库' ||
            this.billType === '零售退货入库' ||
            this.billType === '请购单' ||
            this.billType === '采购订单' ||
            this.billType === '采购入库' ||
            this.billType === '采购退货出库' ||
            this.billType === '销售订单' ||
            this.billType === '销售出库' ||
            this.billType === '销售退货入库' ||
            this.billType === '其它入库' ||
            this.billType === '其它出库' ||
            this.billType === '调拨出库' ||
            this.billType === '组装单' ||
            this.billType === '拆卸单'
          ) {
            this.billPrintFlag = res.data.platformValue === '1' ? true : false
          }
        }
      })
    },
    getSystemConfig() {
      getCurrentSystemConfig().then((res) => {
        if (res.code === 200 && res.data) {
          this.purchaseBySaleFlag = res.data.purchaseBySaleFlag === '1' ? true : false
          let multiBillType = res.data.multiBillType
          let multiLevelApprovalFlag = res.data.multiLevelApprovalFlag
          this.checkFlag = getCheckFlag(multiBillType, multiLevelApprovalFlag, this.prefixNo)
          if (res.data.auditPrintFlag === '1') {
            if (this.model.status === '0' || this.model.status === '9') {
              this.isShowPrintBtn = false
            } else {
              this.isShowPrintBtn = true
            }
          } else {
            this.isShowPrintBtn = true
          }
        }
      })
    },
    getBillListByLinkNumber(number) {
      getAction('/depotHead/getBillListByLinkNumber', { number: number }).then((res) => {
        if (res && res.code === 200) {
          this.linkNumberList = res.data
        }
      })
    },
    getFinancialBillNoByBillId(billId) {
      getAction('/accountHead/getFinancialBillNoByBillId', { billId: billId }).then((res) => {
        if (res && res.code === 200) {
          this.financialBillNoList = res.data
        }
      })
    },
    show(record, type, prefixNo) {
      // Rechercher les informations d'un document unique
      findBillDetailByNumber({ number: record.number }).then((res) => {
        if (res && res.code === 200) {
          let item = res.data
          this.billType = type
          this.prefixNo = prefixNo
          // Téléchargement de pièces jointes
          this.fileList = item.fileName
          this.visible = true
          this.modalStyle = 'top:20px;height: 95%;'
          this.model = Object.assign({}, item)
          if (this.model.backAmount) {
            this.model.getAmount = (this.model.changeAmount + this.model.backAmount).toFixed(2)
          } else {
            this.model.getAmount = this.model.changeAmount
          }
          this.model.debt = (
            this.model.discountLastMoney +
            this.model.otherMoney -
            (this.model.deposit + this.model.changeAmount)
          ).toFixed(2)
          this.$nextTick(() => {
            this.form.setFieldsValue(pick(this.model, 'id'))
          })
          let showType = 'basic'
          if (
            item.subType === '采购' ||
            item.subType === '采购退货' ||
            item.subType === '销售' ||
            item.subType === '销售退货'
          ) {
            if (item.status === '3') {
              showType = 'other'
            }
          } else {
            if (item.status === '3') {
              showType = 'basic'
            } else if (item.purchaseStatus === '3') {
              showType = 'purchase'
            }
          }
          let isReadOnly = '1'
          if (item.subType === '组装单' || item.subType === '拆卸单') {
            isReadOnly = '0'
          }
          let params = {
            headerId: this.model.id,
            mpList: getMpListShort(Vue.ls.get('materialPropertyList')), // Attributs étendus
            linkType: showType,
            isReadOnly: isReadOnly,
          }
          let url = this.readOnly ? this.url.detailList : this.url.detailList
          this.requestSubTableData(item, type, url, params)
          this.initPlatform()
          this.getSystemConfig()
          this.getBillListByLinkNumber(this.model.number)
          this.getFinancialBillNoByBillId(this.model.id)
        }
      })
    },
    requestSubTableData(record, type, url, params, success) {
      this.loading = true
      getAction(url, params)
        .then((res) => {
          if (res && res.code === 200) {
            this.dataSource = res.data.rows
            this.initSetting(record, type, this.dataSource)
            typeof success === 'function' ? success(res) : ''
          }
        })
        .finally(() => {
          this.loading = false
        })
    },
    handleBackCheck() {
      let that = this
      this.$confirm({
        title: "Confirmer l'opération",
        content: 'Voulez-vous désauditer ce document ?',
        onOk: function () {
          that.loading = true
          postAction(that.url.batchSetStatusUrl, { status: '0', ids: that.model.id })
            .then((res) => {
              if (res.code === 200) {
                that.$emit('ok')
                that.loading = false
                that.close()
              } else {
                that.$message.warning(res.data.message)
                that.loading = false
              }
            })
            .finally(() => {})
        },
      })
    },
    handleCancel() {
      this.close()
    },
    close() {
      this.$emit('close')
      this.visible = false
      this.modalStyle = ''
    },
    myHandleDetail(billNumber) {
      findBillDetailByNumber({ number: billNumber }).then((res) => {
        if (res && res.code === 200) {
          let type = res.data.type === '其它' ? '' : res.data.type
          this.show(res.data, res.data.subType + type)
          this.title = res.data.subType + type + ' - Détails'
        }
      })
    },
    myHandleFinancialDetail(billNo) {
      let that = this
      findFinancialDetailByNumber({ billNo: billNo }).then((res) => {
        if (res && res.code === 200) {
          if (that.$refs.financialDetailModal) {
            that.$refs.financialDetailModal.show(res.data, res.data.type)
            that.$refs.financialDetailModal.title = res.data.type + ' - Détails'
          }
        }
      })
    },
    getImgUrl(imgName, type) {
      if (imgName && imgName.split(',')) {
        type = type ? type + '/' : ''
        return getFileAccessHttpUrl('systemConfig/static/' + type + imgName.split(',')[0])
      } else {
        return ''
      }
    },
    // Impression en trois exemplaires - Nouvelle version
    handlePrintPro() {
      getPlatformConfigByKey({ platformKey: 'bill_print_pro_url' }).then((res) => {
        if (res && res.code === 200) {
          let billPrintUrl = res.data.platformValue + '&no=' + this.model.number
          let billPrintHeight = document.documentElement.clientHeight - 260
          this.$refs.modalProDetail.show(this.model, billPrintUrl, billPrintHeight)
          this.$refs.modalProDetail.title = this.billType + ' - Impression en trois exemplaires - Nouvelle version'
        }
      })
    },
    // Impression en trois exemplaires
    handlePrint() {
      getPlatformConfigByKey({ platformKey: 'bill_print_url' }).then((res) => {
        if (res && res.code === 200) {
          let billPrintUrl = res.data.platformValue + '&no=' + this.model.number
          let billPrintHeight = this.dataSource.length * 50 + 600
          this.$refs.modalDetail.show(this.model, billPrintUrl, billPrintHeight)
          this.$refs.modalDetail.title = this.billType + ' - Impression en trois exemplaires'
        }
      })
    },
    // Sortie de vente au détail | Retour de vente au détail
    retailExportExcel() {
      let list = []
      let head =
        "Nom de l'entrepôt,Code-barres,Nom,Spécification,Modèle,Couleur," +
        this.otherFieldTitle +
        ",Stock,Unité,Numéro de série,Numéro de lot,Date d'expiration,Multi-attributs,Quantité,Prix unitaire,Montant,Remarque"
      for (let i = 0; i < this.dataSource.length; i++) {
        let item = []
        let ds = this.dataSource[i]
        item.push(
          ds.depotName,
          ds.barCode,
          ds.name,
          ds.standard,
          ds.model,
          ds.color,
          ds.otherField1,
          ds.otherField2,
          ds.otherField3,
          ds.stock,
          ds.unit,
          ds.snList,
          ds.batchNumber,
          ds.expirationDate,
          ds.sku,
          ds.operNumber,
          ds.unitPrice,
          ds.allPrice,
          ds.remark
        )
        list.push(item)
      }
      let organName = this.model.organName ? 'Numéro de carte membre : ' + this.model.organName : ''
      let tip =
        organName +
        ' ' +
        'Date du document : ' +
        this.model.operTimeStr +
        ' ' +
        'Numéro de document : ' +
        this.model.number
      exportXlsPost(this.billType + '_' + this.model.number, 'Export de document', head, tip, list)
    },
    // Demande d'achat
    applyExportExcel() {
      let list = []
      let head =
        'Code-barres,Nom,Spécification,Modèle,Couleur,' +
        this.otherFieldTitle +
        ",Unité,Multi-attributs,Quantité d'origine,Déjà acheté,Quantité,Remarque"
      for (let i = 0; i < this.dataSource.length; i++) {
        let item = []
        let ds = this.dataSource[i]
        item.push(
          ds.barCode,
          ds.name,
          ds.standard,
          ds.model,
          ds.color,
          ds.otherField1,
          ds.otherField2,
          ds.otherField3,
          ds.unit,
          ds.sku,
          ds.preNumber,
          ds.finishNumber,
          ds.operNumber,
          ds.remark
        )
        list.push(item)
      }
      let tip = 'Date du document : ' + this.model.operTimeStr + ' ' + 'Numéro de document : ' + this.model.number
      exportXlsPost(this.billType + '_' + this.model.number, 'Export de document', head, tip, list)
    },
    // Commande d'achat | Commande de vente
    orderExportExcel() {
      let list = []
      let finishType = ''
      let organType = ''
      if (this.billType === '采购订单') {
        finishType = 'Déjà entré'
        organType = 'Fournisseur : '
      } else if (this.billType === '销售订单') {
        finishType = 'Déjà sorti'
        organType = 'Client : '
      }
      let head =
        'Code-barres,Nom,Spécification,Modèle,Couleur,' +
        this.otherFieldTitle +
        ',Stock,Unité,Multi-attributs,Quantité,' +
        finishType +
        ',Prix unitaire,Montant,Taux de taxe (%),Montant de la taxe,Total TTC,Remarque'
      for (let i = 0; i < this.dataSource.length; i++) {
        let item = []
        let ds = this.dataSource[i]
        item.push(
          ds.barCode,
          ds.name,
          ds.standard,
          ds.model,
          ds.color,
          ds.otherField1,
          ds.otherField2,
          ds.otherField3,
          ds.stock,
          ds.unit,
          ds.sku,
          ds.operNumber,
          ds.finishNumber,
          ds.unitPrice,
          ds.allPrice,
          ds.taxRate,
          ds.taxMoney,
          ds.taxLastMoney,
          ds.remark
        )
        list.push(item)
      }
      let organName = this.model.organName ? this.model.organName : ''
      let tip =
        organType +
        organName +
        ' ' +
        'Date du document : ' +
        this.model.operTimeStr +
        ' ' +
        'Numéro de document : ' +
        this.model.number
      exportXlsPost(this.billType + '_' + this.model.number, 'Export de document', head, tip, list)
    },
    // Entrée d'achat | Retour d'achat | Sortie de vente | Retour de vente
    purchaseSaleExportExcel() {
      let list = []
      let organType = ''
      if (this.billType === '采购入库' || this.billType === '采购退货出库') {
        organType = 'Fournisseur : '
      } else if (this.billType === '销售出库' || this.billType === '销售退货入库') {
        organType = 'Client : '
      }
      let head =
        "Nom de l'entrepôt,Code-barres,Nom,Spécification,Modèle,Couleur," +
        this.otherFieldTitle +
        ",Stock,Unité,Numéro de série,Numéro de lot,Date d'expiration,Multi-attributs,Quantité,Prix unitaire,Montant,Taux de taxe (%),Montant de la taxe,Total TTC,Poids,Remarque"
      for (let i = 0; i < this.dataSource.length; i++) {
        let item = []
        let ds = this.dataSource[i]
        item.push(
          ds.depotName,
          ds.barCode,
          ds.name,
          ds.standard,
          ds.model,
          ds.color,
          ds.otherField1,
          ds.otherField2,
          ds.otherField3,
          ds.stock,
          ds.unit,
          ds.snList,
          ds.batchNumber,
          ds.expirationDate,
          ds.sku,
          ds.operNumber,
          ds.unitPrice,
          ds.allPrice,
          ds.taxRate,
          ds.taxMoney,
          ds.taxLastMoney,
          ds.weight,
          ds.remark
        )
        list.push(item)
      }
      let organName = this.model.organName ? this.model.organName : ''
      let linkNumber = this.model.linkNumber ? this.model.linkNumber : ''
      let tip =
        organType +
        organName +
        ' ' +
        'Date du document : ' +
        this.model.operTimeStr +
        ' ' +
        'Numéro de document : ' +
        this.model.number +
        ' ' +
        'Numéro de document associé : ' +
        linkNumber
      exportXlsPost(this.billType + '_' + this.model.number, 'Export de document', head, tip, list)
    },
    // Autre entrée | Autre sortie
    otherExportExcel() {
      let list = []
      let organType = ''
      if (this.billType === '其它入库') {
        organType = 'Fournisseur : '
      } else if (this.billType === '其它出库') {
        organType = 'Client : '
      }
      let head =
        "Nom de l'entrepôt,Code-barres,Nom,Spécification,Modèle,Couleur," +
        this.otherFieldTitle +
        ",Stock,Unité,Numéro de série,Numéro de lot,Date d'expiration,Multi-attributs,Quantité,Prix unitaire,Montant,Remarque"
      for (let i = 0; i < this.dataSource.length; i++) {
        let item = []
        let ds = this.dataSource[i]
        item.push(
          ds.depotName,
          ds.barCode,
          ds.name,
          ds.standard,
          ds.model,
          ds.color,
          ds.otherField1,
          ds.otherField2,
          ds.otherField3,
          ds.stock,
          ds.unit,
          ds.snList,
          ds.batchNumber,
          ds.expirationDate,
          ds.sku,
          ds.operNumber,
          ds.unitPrice,
          ds.allPrice,
          ds.remark
        )
        list.push(item)
      }
      let organName = this.model.organName ? this.model.organName : ''
      let tip =
        organType +
        organName +
        ' ' +
        'Date du document : ' +
        this.model.operTimeStr +
        ' ' +
        'Numéro de document : ' +
        this.model.number
      exportXlsPost(this.billType + '_' + this.model.number, 'Export de document', head, tip, list)
    },
    // Transfert de sortie
    allocationOutExportExcel() {
      let list = []
      let head =
        "Nom de l'entrepôt,Code-barres,Nom,Spécification,Modèle,Couleur," +
        this.otherFieldTitle +
        ',Stock,Entrepôt de destination,Unité,Multi-attributs,Quantité,Prix unitaire,Montant,Remarque'
      for (let i = 0; i < this.dataSource.length; i++) {
        let item = []
        let ds = this.dataSource[i]
        item.push(
          ds.depotName,
          ds.barCode,
          ds.name,
          ds.standard,
          ds.model,
          ds.color,
          ds.otherField1,
          ds.otherField2,
          ds.otherField3,
          ds.stock,
          ds.anotherDepotName,
          ds.unit,
          ds.sku,
          ds.operNumber,
          ds.unitPrice,
          ds.allPrice,
          ds.remark
        )
        list.push(item)
      }
      let tip = 'Date du document : ' + this.model.operTimeStr + ' ' + 'Numéro de document : ' + this.model.number
      exportXlsPost(this.billType + '_' + this.model.number, 'Export de document', head, tip, list)
    },
    // Bon d'assemblage | Bon de démontage
    assembleExportExcel() {
      let list = []
      let head = [
        "Type de produit,Nom de l'entrepôt,Code-barres,Nom,Spécification,Modèle,Couleur," +
          this.otherFieldTitle +
          ',Stock,Unité,Multi-attributs,Quantité,Prix unitaire,Montant,Remarque',
      ]
      for (let i = 0; i < this.dataSource.length; i++) {
        let item = []
        let ds = this.dataSource[i]
        item.push(
          ds.mType,
          ds.depotName,
          ds.barCode,
          ds.name,
          ds.standard,
          ds.model,
          ds.color,
          ds.otherField1,
          ds.otherField2,
          ds.otherField3,
          ds.stock,
          ds.unit,
          ds.sku,
          ds.operNumber,
          ds.unitPrice,
          ds.allPrice,
          ds.remark
        )
        list.push(item)
      }
      let tip = 'Date du document : ' + this.model.operTimeStr + ' ' + 'Numéro de document : ' + this.model.number
      exportXlsPost(this.billType + '_' + this.model.number, 'Export de document', head, tip, list)
    },
    // Révision d'inventaire
    stockCheckReplayExportExcel() {
      let list = []
      let head =
        "Nom de l'entrepôt,Code-barres,Nom,Spécification,Modèle," +
        this.otherFieldTitle +
        ',Stock,Unité,Multi-attributs,Quantité,Prix unitaire,Montant,Remarque'
      for (let i = 0; i < this.dataSource.length; i++) {
        let item = []
        let ds = this.dataSource[i]
        item.push(
          ds.depotName,
          ds.barCode,
          ds.name,
          ds.standard,
          ds.model,
          ds.otherField1,
          ds.otherField2,
          ds.otherField3,
          ds.stock,
          ds.unit,
          ds.sku,
          ds.operNumber,
          ds.unitPrice,
          ds.allPrice,
          ds.remark
        )
        list.push(item)
      }
      let linkNumber = this.model.linkNumber ? this.model.linkNumber : ''
      let tip =
        'Date du document : ' +
        this.model.operTimeStr +
        ' ' +
        'Numéro de document : ' +
        this.model.number +
        ' ' +
        'Numéro de document associé : ' +
        linkNumber
      exportXlsPost(this.billType + '_' + this.model.number, 'Export de document', head, tip, list)
    },
  },
}
</script>

<style scoped>
.item-info {
  float: left;
  width: 30px;
  height: 30px;
  margin-left: 8px;
}
.item-img {
  cursor: pointer;
  position: static;
  display: block;
  width: 100%;
  height: 100%;
  object-fit: cover;
}
</style>

