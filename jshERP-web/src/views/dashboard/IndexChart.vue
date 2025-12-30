<template>
  <div class="page-header-index-wide">
    <a-row :gutter="24">
      <a-col :sm="24" :md="12" :xl="4" :style="{ paddingRight: '0px', marginBottom: '12px' }">
        <chart-card
          :loading="loading"
          title="Ventes d'aujourd'hui"
          data-step="1"
          data-title="Ventes d'aujourd'hui"
          data-intro="Statistiques du montant total des documents de vente d'aujourd'hui"
        >
          <a-tooltip title="Statistiques du montant total des documents de vente d'aujourd'hui" slot="action">
            <a-icon type="info-circle-o" />
          </a-tooltip>
          <head-info :content="statistics.todaySale"></head-info>
        </chart-card>
      </a-col>
      <a-col :sm="24" :md="12" :xl="4" :style="{ paddingRight: '0px', marginBottom: '12px' }">
        <chart-card
          :loading="loading"
          title="Vente au détail d'aujourd'hui"
          data-step="2"
          data-title="Vente au détail d'aujourd'hui"
          data-intro="Statistiques du montant total des documents de vente au détail d'aujourd'hui"
        >
          <a-tooltip title="Statistiques du montant total des documents de vente au détail d'aujourd'hui" slot="action">
            <a-icon type="info-circle-o" />
          </a-tooltip>
          <head-info :content="statistics.todayRetailSale"></head-info>
        </chart-card>
      </a-col>
      <a-col :sm="24" :md="12" :xl="4" :style="{ paddingRight: '0px', marginBottom: '12px' }">
        <chart-card
          :loading="loading"
          title="Achats d'aujourd'hui"
          data-step="3"
          data-title="Achats d'aujourd'hui"
          data-intro="Statistiques du montant total des documents d'achat d'aujourd'hui"
        >
          <a-tooltip title="Statistiques du montant total des documents d'achat d'aujourd'hui" slot="action">
            <a-icon type="info-circle-o" />
          </a-tooltip>
          <head-info :content="statistics.todayBuy"></head-info>
        </chart-card>
      </a-col>
      <a-col :sm="24" :md="12" :xl="4" :style="{ paddingRight: '0px', marginBottom: '12px' }">
        <chart-card :loading="loading" title="Ventes cumulées du mois">
          <a-tooltip title="Statistiques du montant total des documents de vente du mois" slot="action">
            <a-icon type="info-circle-o" />
          </a-tooltip>
          <head-info :content="statistics.monthSale"></head-info>
        </chart-card>
      </a-col>
      <a-col :sm="24" :md="12" :xl="4" :style="{ paddingRight: '0px', marginBottom: '12px' }">
        <chart-card :loading="loading" title="Vente au détail cumulée du mois">
          <a-tooltip title="Statistiques du montant total des documents de vente au détail du mois" slot="action">
            <a-icon type="info-circle-o" />
          </a-tooltip>
          <head-info :content="statistics.monthRetailSale"></head-info>
        </chart-card>
      </a-col>
      <a-col :sm="24" :md="12" :xl="4" :style="{ paddingRight: '0px', marginBottom: '12px' }">
        <chart-card :loading="loading" title="Achats cumulés du mois">
          <a-tooltip placement="left" title="Statistiques du montant total des documents d'achat du mois" slot="action">
            <a-icon type="info-circle-o" />
          </a-tooltip>
          <head-info :content="statistics.monthBuy"></head-info>
        </chart-card>
      </a-col>
      <a-col :sm="24" :md="12" :xl="4" :style="{ paddingRight: '0px', marginBottom: '12px' }">
        <chart-card :loading="loading" title="Ventes d'hier">
          <a-tooltip title="Statistiques du montant total des documents de vente d'hier" slot="action">
            <a-icon type="info-circle-o" />
          </a-tooltip>
          <head-info :content="statistics.yesterdaySale"></head-info>
        </chart-card>
      </a-col>
      <a-col :sm="24" :md="12" :xl="4" :style="{ paddingRight: '0px', marginBottom: '12px' }">
        <chart-card :loading="loading" title="Vente au détail d'hier">
          <a-tooltip title="Statistiques du montant total des documents de vente au détail d'hier" slot="action">
            <a-icon type="info-circle-o" />
          </a-tooltip>
          <head-info :content="statistics.yesterdayRetailSale"></head-info>
        </chart-card>
      </a-col>
      <a-col :sm="24" :md="12" :xl="4" :style="{ paddingRight: '0px', marginBottom: '12px' }">
        <chart-card :loading="loading" title="Achats d'hier">
          <a-tooltip title="Statistiques du montant total des documents d'achat d'hier" slot="action">
            <a-icon type="info-circle-o" />
          </a-tooltip>
          <head-info :content="statistics.yesterdayBuy"></head-info>
        </chart-card>
      </a-col>
      <a-col :sm="24" :md="12" :xl="4" :style="{ paddingRight: '0px', marginBottom: '12px' }">
        <chart-card :loading="loading" title="Ventes cumulées de l'année">
          <a-tooltip title="Statistiques du montant total des documents de vente de l'année" slot="action">
            <a-icon type="info-circle-o" />
          </a-tooltip>
          <head-info :content="statistics.yearSale"></head-info>
        </chart-card>
      </a-col>
      <a-col :sm="24" :md="12" :xl="4" :style="{ paddingRight: '0px', marginBottom: '12px' }">
        <chart-card :loading="loading" title="Vente au détail cumulée de l'année">
          <a-tooltip title="Statistiques du montant total des documents de vente au détail de l'année" slot="action">
            <a-icon type="info-circle-o" />
          </a-tooltip>
          <head-info :content="statistics.yearRetailSale"></head-info>
        </chart-card>
      </a-col>
      <a-col :sm="24" :md="12" :xl="4" :style="{ paddingRight: '0px', marginBottom: '12px' }">
        <chart-card :loading="loading" title="Achats cumulés de l'année">
          <a-tooltip
            placement="left"
            title="Statistiques du montant total des documents d'achat de l'année"
            slot="action"
          >
            <a-icon type="info-circle-o" />
          </a-tooltip>
          <head-info :content="statistics.yearBuy"></head-info>
        </chart-card>
      </a-col>
    </a-row>
    <a-row :gutter="24">
      <a-col :sm="24" :md="12" :xl="8" :style="{ paddingRight: '0px', marginBottom: '12px' }">
        <a-card
          :loading="loading"
          :bordered="false"
          :body-style="{ paddingRight: '5' }"
          data-step="4"
          data-title="Statistiques de vente"
          data-intro="Statistiques du montant total des ventes pour les 6 derniers mois"
        >
          <bar title="Statistiques de vente" :height="barHeight" :yaxisText="yaxisText" :dataSource="salePriceData" />
        </a-card>
      </a-col>
      <a-col :sm="24" :md="12" :xl="8" :style="{ paddingRight: '0px', marginBottom: '12px' }">
        <a-card
          :loading="loading"
          :bordered="false"
          :body-style="{ paddingRight: '5' }"
          data-step="5"
          data-title="Statistiques de vente au détail"
          data-intro="Statistiques du montant total de la vente au détail pour les 6 derniers mois"
        >
          <bar
            title="Statistiques de vente au détail"
            :height="barHeight"
            :yaxisText="yaxisText"
            :dataSource="retailPriceData"
          />
        </a-card>
      </a-col>
      <a-col :sm="24" :md="12" :xl="8" :style="{ paddingRight: '0px', marginBottom: '12px' }">
        <a-card
          :loading="loading"
          :bordered="false"
          :body-style="{ paddingRight: '5' }"
          data-step="6"
          data-title="Statistiques d'achat"
          data-intro="Statistiques du montant total des achats pour les 6 derniers mois"
        >
          <bar title="Statistiques d'achat" :height="barHeight" :yaxisText="yaxisText" :dataSource="buyPriceData" />
        </a-card>
      </a-col>
    </a-row>
    <a-row :gutter="24">
      <a-col :sm="24" :md="24" :xl="24" :style="{ paddingRight: '0px', marginBottom: '6px' }">
        <a-card
          :bordered="false"
          :body-style="{ padding: '5' }"
          data-step="7"
          data-title="Service et droits d'auteur"
          data-intro="Affiche la date d'expiration du service (un lien de renouvellement apparaîtra lorsque l'expiration approche, veuillez renouveler à temps),
          le nombre d'utilisateurs (fait référence au nombre maximum d'utilisateurs pouvant être enregistrés), les informations de droits d'auteur"
        >
          <div class="hidden-xs" style="float: right">
            <a-popover trigger="hover" :visible="hovered" @visibleChange="handleHoverChange">
              <div slot="content">
                <img src="/static/weixin.jpg" style="width: 258px" />
              </div>
              <a-button type="link" v-if="showWeixinSpan()">Mini-programme WeChat ERP</a-button>
            </a-popover>
            &copy; 2015-2030 {{ systemTitle }} V3.6
          </div>
          <a-tag v-if="tenant.type == 0" color="blue">Expiration de l'essai : {{ tenant.expireTime }}</a-tag>
          <a-tag v-if="tenant.type == 0" color="blue"
            >Utilisateurs d'essai : {{ tenant.userCurrentNum }}/{{ tenant.userNumLimit }}</a-tag
          >
          <a-tag v-if="tenant.type == 1" color="blue">Expiration du service : {{ tenant.expireTime }}</a-tag>
          <a-tag v-if="tenant.type == 1" color="blue"
            >Utilisateurs autorisés : {{ tenant.userCurrentNum }}/{{ tenant.userNumLimit }}</a-tag
          >
          <a v-if="hasExpire" style="color: red" :href="payFeeUrl" target="_blank">Renouveler immédiatement</a>
        </a-card>
      </a-col>
    </a-row>
  </div>
</template>
<script>
import ChartCard from '@/components/ChartCard'
import ACol from 'ant-design-vue/es/grid/Col'
import ATooltip from 'ant-design-vue/es/tooltip/Tooltip'
import MiniArea from '@/components/chart/MiniArea'
import MiniBar from '@/components/chart/MiniBar'
import MiniProgress from '@/components/chart/MiniProgress'
import Bar from '@/components/chart/Bar'
import LineChartMultid from '@/components/chart/LineChartMultid'
import HeadInfo from '@/components/tools/HeadInfo.vue'
import Trend from '@/components/Trend'
import { getBuyAndSaleStatistics, buyOrSalePrice, getPlatformConfigByKey } from '@/api/api'
import { handleIntroJs } from '@/utils/util'
import { getAction, postAction } from '../../api/manage'

export default {
  name: 'IndexChart',
  components: {
    ATooltip,
    ACol,
    ChartCard,
    MiniArea,
    MiniBar,
    MiniProgress,
    Bar,
    Trend,
    LineChartMultid,
    HeadInfo,
  },
  data() {
    return {
      hovered: false,
      systemTitle: window.SYS_TITLE,
      systemUrl: window.SYS_URL,
      loading: true,
      center: null,
      statistics: {},
      barHeight: document.documentElement.clientHeight - 585,
      yaxisText: 'Montant',
      buyPriceData: [],
      salePriceData: [],
      retailPriceData: [],
      visitFields: ['ip', 'visit'],
      visitInfo: [],
      hasExpire: false,
      payFeeUrl: '',
      tenant: {
        type: '',
        expireTime: '',
        userCurrentNum: '',
        userNumLimit: '',
        tenantId: '',
      },
    }
  },
  created() {
    setTimeout(() => {
      this.loading = !this.loading
    }, 1000)
    this.initInfo()
    this.initWithTenant()
  },
  mounted() {
    handleIntroJs('indexChart', 1)
  },
  methods: {
    initInfo() {
      getBuyAndSaleStatistics().then((res) => {
        if (res.code === 200) {
          this.statistics = res.data
        }
      })
      buyOrSalePrice().then((res) => {
        if (res.code === 200) {
          this.buyPriceData = res.data.buyPriceList
          this.salePriceData = res.data.salePriceList
          this.retailPriceData = res.data.retailPriceList
        }
      })
      getPlatformConfigByKey({ platformKey: 'pay_fee_url' }).then((res) => {
        if (res && res.code === 200) {
          this.payFeeUrl = res.data.platformValue
        }
      })
    },
    initWithTenant() {
      getAction('/user/infoWithTenant', {}).then((res) => {
        if (res && res.code === 200) {
          this.tenant = res.data
          let currentTime = new Date() // Créer un nouvel objet date, par défaut l'heure actuelle
          let expireTime = new Date(res.data.expireTime) // Définir un point temporel passé, format de date "yyyy-MM-dd HH:mm:ss"
          let difftime = expireTime - currentTime // Calculer la différence de temps
          // Si l'expiration est dans moins de 5 jours, afficher un rappel de renouvellement
          if (difftime < 86400000 * 5) {
            this.hasExpire = true
            // Envoyer un rappel d'expiration d'essai aux locataires gratuits
            if (res.data.type === '0') {
              // Vérifier d'abord s'il a déjà été envoyé, n'envoyer qu'une seule fois
              getAction('/msg/getMsgCountByType', { type: '试用到期' }).then((res) => {
                if (res && res.code === 200) {
                  if (res.data.count === 0) {
                    // Envoyer un message
                    let msgParam = {
                      msgTitle: "Rappel d'expiration de l'essai",
                      msgContent:
                        "La période d'essai se termine bientôt, veuillez renouveler à temps, l'expiration affectera l'utilisation normale !",
                      type: '试用到期',
                      userId: this.tenant.tenantId,
                    }
                    postAction('/msg/add', msgParam).then((res) => {
                      if (res && res.code === 200) {
                      }
                    })
                  }
                }
              })
            }
          }
        }
      })
    },
    handleHoverChange(visible) {
      this.hovered = visible
    },
    showWeixinSpan() {
      let host = window.location.host
      if (host === 'cloud.gyjerp.com') {
        return true
      } else {
        return false
      }
    },
  },
}
</script>
<style lang="less" scoped>
.circle-cust {
  position: relative;
  top: 28px;
  left: -100%;
}
.extra-wrapper {
  line-height: 55px;
  padding-right: 24px;

  .extra-item {
    display: inline-block;
    margin-right: 24px;

    a {
      margin-left: 24px;
    }
  }
}
/* Statistiques de visite de la page d'accueil */
.head-info {
  position: relative;
  text-align: left;
  padding: 0 32px 0 0;
  min-width: 125px;
  &.center {
    text-align: center;
    padding: 0 32px;
  }
  span {
    color: rgba(0, 0, 0, 0.45);
    display: inline-block;
    font-size: 0.95rem;
    line-height: 42px;
    margin-bottom: 4px;
  }
  p {
    line-height: 42px;
    margin: 0;
    a {
      font-weight: 600;
      font-size: 1rem;
    }
  }
}
</style>
