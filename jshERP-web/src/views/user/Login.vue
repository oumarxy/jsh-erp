<!-- b y 7 5 2 7  1 8 9 2 0 -->
<template>
  <div class="main" :style="mainStyle">
    <a-form :form="form" class="user-layout-login" ref="formLogin" id="formLogin">
      <a-form-item>
        <a-input
          size="large"
          v-decorator="['loginName', { initialValue: '', rules: validatorRules.loginName.rules }]"
          type="text"
          placeholder="Veuillez saisir le nom d'utilisateur"
        >
          <a-icon slot="prefix" type="user" :style="{ color: 'rgba(0,0,0,.25)' }" />
        </a-input>
      </a-form-item>

      <a-form-item>
        <a-input-password
          v-decorator="['password', { initialValue: '', rules: validatorRules.password.rules }]"
          size="large"
          type="password"
          autocomplete="false"
          placeholder="Veuillez saisir le mot de passe"
        >
          <a-icon slot="prefix" type="lock" :style="{ color: 'rgba(0,0,0,.25)' }" />
        </a-input-password>
      </a-form-item>

      <a-row :gutter="0" v-if="checkcodeFlag === '1'">
        <a-col :span="14">
          <a-form-item>
            <a-input
              v-decorator="['inputCode', { initialValue: '', rules: validatorRules.inputCode.rules }]"
              size="large"
              type="text"
              default-value=""
              placeholder="Veuillez saisir le code de vérification"
            >
              <a-icon slot="prefix" type="smile" :style="{ color: 'rgba(0,0,0,.25)' }" />
            </a-input>
          </a-form-item>
        </a-col>
        <a-col :span="10" style="text-align: right">
          <img v-if="requestCodeSuccess" style="margin-top: 2px" :src="randCodeImage" @click="handleChangeCheckCode" />
          <img v-else style="margin-top: 2px" src="../../assets/checkcode.png" @click="handleChangeCheckCode" />
        </a-col>
      </a-row>

      <a-form-item>
        <a-checkbox :checked="checked" @change="handleChange">Se souvenir du mot de passe</a-checkbox>
        <router-link
          v-if="registerFlag === '1'"
          :to="{ name: 'register' }"
          class="forge-password"
          style="float: right; margin-right: 10px"
        >
          Enregistrer un locataire
        </router-link>
      </a-form-item>

      <a-form-item :style="btnStyle">
        <a-button
          size="large"
          type="primary"
          htmlType="submit"
          class="login-button"
          :loading="loginBtn"
          @click.stop.prevent="handleSubmit"
          :disabled="loginBtn"
          >Se connecter
        </a-button>
      </a-form-item>

      <div class="login-copyright" v-if="device === 'mobile'">
        <a-row>
          <a-col>
            © 2015-2030 Powered By
            <a style="color: #00458a" :href="systemUrl" target="_blank">Site officiel</a>
          </a-col>
        </a-row>
      </div>
    </a-form>
  </div>
</template>
<!-- BY cao_yu_li -->
<script>
import md5 from 'md5'
import TwoStepCaptcha from '@/components/tools/TwoStepCaptcha'
import { mapActions } from 'vuex'
import { timeFix } from '@/utils/util'
import Vue from 'vue'
import { getPlatformConfigByKey } from '@/api/api'
import { ACCESS_TOKEN, ENCRYPTED_STRING } from '@/store/mutation-types'
import { getAction } from '@/api/manage'
import { getEncryptedString } from '@/utils/encryption/aesEncrypt'
import { mixinDevice } from '@/utils/mixin.js'

export default {
  components: {
    TwoStepCaptcha,
  },
  mixins: [mixinDevice],
  data() {
    return {
      customActiveKey: 'tab1',
      systemTitle: window.SYS_TITLE,
      systemUrl: window.SYS_URL,
      loginBtn: false,
      // login type: 0 email, 1 username, 2 telephone
      loginType: 0,
      requiredTwoStepCaptcha: false,
      stepCaptchaVisible: false,
      form: this.$form.createForm(this),
      encryptedString: {
        key: '',
        iv: '',
      },
      state: {
        time: 60,
        smsSendBtn: false,
      },
      validatorRules: {
        loginName: {
          rules: [
            { required: true, message: "Veuillez saisir le nom d'utilisateur!" },
            { validator: this.handleLoginName },
          ],
        },
        password: { rules: [{ required: true, message: 'Veuillez saisir le mot de passe!', validator: 'click' }] },
        inputCode: {
          rules: [{ required: true, message: 'Veuillez saisir le code de vérification!', validator: 'click' }],
        },
      },
      verifiedCode: '',
      inputCodeContent: '', //20200510 cfm: Pour faciliter les tests, ne pas saisir le code de vérification peut être ""-->"xxxx"
      inputCodeNull: true,
      departList: [],
      departVisible: false,
      departSelected: '',
      currentUsername: '',
      validate_status: '',
      currdatetime: '',
      uuid: '',
      randCodeImage: '',
      registerFlag: '',
      checkcodeFlag: '',
      mainStyle: '',
      btnStyle: 'margin-top:16px',
      requestCodeSuccess: false,
      checked: false,
    }
  },
  created() {
    this.loadInfo()
    this.checkScreen()
    this.currdatetime = new Date().getTime()
    Vue.ls.remove(ACCESS_TOKEN)
    this.getRouterData()
    this.getRegisterFlag()
    this.getCheckcodeFlag()
    this.handleChangeCheckCode()
  },
  methods: {
    ...mapActions(['Login', 'Logout']),
    // handler
    loadInfo() {
      // Récupérer le nom d'utilisateur et le mot de passe depuis le cache
      this.$nextTick(() => {
        if (Vue.ls.get('cache_loginName') && Vue.ls.get('cache_password')) {
          this.form.setFieldsValue({ loginName: Vue.ls.get('cache_loginName') })
          this.form.setFieldsValue({ password: Vue.ls.get('cache_password') })
          this.checked = true
        }
      })
      // Depuis la page d'enregistrement, assigner le nom d'utilisateur
      if (this.$route.params.loginName) {
        this.$nextTick(() => {
          // Vider d'abord le cache
          Vue.ls.remove('cache_loginName')
          Vue.ls.remove('cache_password')
          this.form.setFieldsValue({ loginName: this.$route.params.loginName })
          this.form.setFieldsValue({ password: '' })
          this.checked = false
        })
      }
    },
    handleLoginName(rule, value, callback) {
      const regex = /^([a-zA-Z0-9_-])+@([a-zA-Z0-9_-])+((\.[a-zA-Z0-9_-]{2,3}){1,2})$/
      if (regex.test(value)) {
        this.loginType = 0
      } else {
        this.loginType = 1
      }
      callback()
    },
    // Basculer la sélection
    handleChange(e) {
      this.checked = e.target.checked
    },
    handleChangeCheckCode() {
      getAction('/user/randomImage')
        .then((res) => {
          if (res.code == 200) {
            this.uuid = res.data.uuid
            this.randCodeImage = res.data.base64
            this.requestCodeSuccess = true
          } else {
            this.$message.error(res.data)
            this.requestCodeSuccess = false
          }
        })
        .catch(() => {
          this.requestCodeSuccess = false
        })
    },
    handleSubmit() {
      let that = this
      let loginParams = {}
      that.loginBtn = true
      // Utiliser le nom d'utilisateur et le mot de passe pour se connecter
      if (that.customActiveKey === 'tab1') {
        that.form.validateFields(['loginName', 'password', 'inputCode'], { force: true }, (err, values) => {
          if (!err) {
            loginParams.loginName = values.loginName
            loginParams.password = md5(values.password)
            loginParams.code = values.inputCode
            loginParams.uuid = that.uuid
            if (that.checked) {
              // Mettre en cache lorsque coché
              Vue.ls.set('cache_loginName', values.loginName)
              Vue.ls.set('cache_password', values.password)
            } else {
              // Vider le cache lorsque non coché
              Vue.ls.remove('cache_loginName')
              Vue.ls.remove('cache_password')
            }
            that
              .Login(loginParams)
              .then((res) => {
                this.departConfirm(res, loginParams.loginName)
              })
              .catch((err) => {
                that.requestFailed(err)
              })
          } else {
            that.loginBtn = false
          }
        })
      }
    },
    loginSuccess(res) {
      let that = this
      this.$router.push({ path: '/dashboard/analysis' })
      this.$notification.success({
        message: 'Bienvenue',
        description: `${timeFix()}，bienvenue de retour`,
      })
      if (res.data.pwdSimple) {
        setTimeout(function () {
          that.$notification.warning({
            message: 'Rappel amical',
            description: 'Le mot de passe est trop simple, veuillez le modifier dès que possible',
          })
        }, 3000)
      }
      if (res.data && res.data.user) {
        if (res.data.user.loginName === 'admin') {
          let desc =
            'admin est uniquement un utilisateur de maintenance de la plateforme, le véritable administrateur est le locataire (compte de test : jsh), admin ne peut pas modifier de données métier, il ne peut que configurer le menu de la plateforme et créer des locataires'
          this.$message.info(desc, 30)
        } else {
          getPlatformConfigByKey({ platformKey: 'bill_excel_url' }).then((res) => {
            if (res && res.code === 200) {
              if (res.data.platformValue) {
                Vue.ls.set('isShowExcel', true)
              } else {
                Vue.ls.set('isShowExcel', false)
              }
            }
          })
          getAction('/user/infoWithTenant', {}).then((res) => {
            if (res && res.code === 200) {
              let currentTime = new Date() // Créer un nouvel objet date, par défaut l'heure actuelle
              let expireTime = new Date(res.data.expireTime) // Définir un point dans le temps passé, format de date "yyyy-MM-dd HH:mm:ss"
              let type = res.data.type // Type de locataire, 0 locataire gratuit, 1 locataire payant
              let difftime = expireTime - currentTime // Calculer la différence de temps
              let tipInfo = 'Bonjour, le service expire bientôt, veuillez renouveler à temps !'
              // 0 locataire gratuit - si il reste 5 jours avant l'expiration, afficher un rappel de renouvellement
              if (type === '0' && difftime < 86400000 * 5) {
                this.$message.warning(tipInfo, 8)
              }
              // 1 locataire payant - si il reste 15 jours avant l'expiration, afficher un rappel de renouvellement
              if (type === '1' && difftime < 86400000 * 15) {
                this.$message.warning(tipInfo, 8)
              }
            }
          })
        }
      }
      this.initMPropertyShort()
    },
    cmsFailed(err) {
      this.$notification['error']({
        message: 'Échec de la connexion',
        description: err,
        duration: 4,
      })
    },
    requestFailed(err) {
      this.$notification['error']({
        message: 'Échec de la connexion',
        description:
          ((err.response || {}).data || {}).message ||
          err.message ||
          err.data.message ||
          "Une erreur s'est produite, veuillez réessayer plus tard",
        duration: 4,
      })
      // Actualiser le code de vérification
      this.form.setFieldsValue({ inputCode: '' })
      this.handleChangeCheckCode()
      this.loginBtn = false
    },
    generateCode(value) {
      this.verifiedCode = value.toLowerCase()
    },
    departConfirm(res, loginName) {
      if (res.code === 200) {
        let err = {}
        if (res.data.msgTip === 'user can login') {
          this.loginSuccess(res)
        } else if (res.data.msgTip === 'user is not exist') {
          err.message = "L'utilisateur n'existe pas"
          this.requestFailed(err)
          this.Logout()
        } else if (res.data.msgTip === 'user password error') {
          err.message = "Le mot de passe de l'utilisateur est incorrect"
          this.requestFailed(err)
          this.Logout()
        } else if (res.data.msgTip === 'user is black') {
          err.message = "L'utilisateur est désactivé"
          this.requestFailed(err)
          this.Logout()
        } else if (res.data.msgTip === 'tenant is black') {
          if (loginName === 'jsh') {
            err.message = "L'utilisateur jsh a été désactivé, veuillez enregistrer un locataire pour tester !"
          } else {
            err.message = "Le locataire auquel appartient l'utilisateur est désactivé"
          }
          this.requestFailed(err)
          this.Logout()
        } else if (res.data.msgTip === 'tenant is expire') {
          err.message = "La période d'essai est terminée, veuillez contacter le service client pour renouveler"
          this.requestFailed(err)
          this.Logout()
        } else if (res.data.msgTip === 'access service error') {
          err.message = 'Erreur du service de requête'
          this.requestFailed(err)
          this.Logout()
        }
      } else {
        this.requestFailed(res)
        this.Logout()
      }
    },
    getRouterData() {
      this.$nextTick(() => {
        if (this.$route.params.username) {
          this.form.setFieldsValue({
            username: this.$route.params.username,
          })
        }
      })
    },
    getRegisterFlag() {
      getAction('/platformConfig/getPlatform/registerFlag').then((res) => {
        this.registerFlag = res + ''
      })
    },
    getCheckcodeFlag() {
      getAction('/platformConfig/getPlatform/checkcodeFlag').then((res) => {
        this.checkcodeFlag = res + ''
        if (this.checkcodeFlag === '1') {
          this.mainStyle = ''
          this.btnStyle = 'margin-top:16px'
        } else {
          this.mainStyle = 'padding-top:20px'
          this.btnStyle = 'margin-top:26px'
        }
      })
    },
    // Obtenir les règles de chiffrement du mot de passe
    getEncrypte() {
      var encryptedString = Vue.ls.get(ENCRYPTED_STRING)
      if (encryptedString == null) {
        getEncryptedString().then((data) => {
          this.encryptedString = data
        })
      } else {
        this.encryptedString = encryptedString
      }
    },
    // Charger les propriétés des produits
    initMPropertyShort() {
      getAction('/materialProperty/getAllList').then((res) => {
        if (res && res.code === 200) {
          if (res.data) {
            let thisRows = res.data // Liste des propriétés
            Vue.ls.set('materialPropertyList', thisRows, 7 * 24 * 60 * 60 * 1000)
          }
        }
      })
    },
    checkScreen() {
      let percentage = '100%'
      let basicWidth = 1920
      const currentWidth = window.screen.width
      const currentHeight = window.screen.height
      // Ratio actuel du navigateur
      const currentRatio = window.devicePixelRatio.toFixed(2)
      // Ratio que le navigateur doit ajuster
      let needRatio = 1
      let ratio = currentWidth / basicWidth
      if (ratio > 0.5 && ratio < 0.67) {
        percentage = '50%'
        needRatio = 0.5
      }
      if (ratio >= 0.67 && ratio < 0.75) {
        percentage = '67%'
        needRatio = 0.67
      } else if (ratio >= 0.75 && ratio < 0.8) {
        percentage = '75%'
        needRatio = 0.75
      } else if (ratio >= 0.8 && ratio < 0.9) {
        percentage = '80%'
        needRatio = 0.8
      } else if (ratio >= 1.1 && ratio < 1.25) {
        percentage = '110%'
        needRatio = 1.1
      } else if (ratio >= 1.25 && ratio < 1.5) {
        percentage = '125%'
        needRatio = 1.25
      } else if (ratio >= 1.5 && ratio < 1.75) {
        percentage = '150%'
        needRatio = 1.5
      }
      //console.log(currentRatio)
      //console.log(needRatio)
      if (currentRatio - 0 !== needRatio) {
        this.openNotificationWithIcon('warning', currentWidth, currentHeight, percentage)
      }
    },
    openNotificationWithIcon(type, currentWidth, currentHeight, percentage) {
      this.$notification[type]({
        message: "Avertissement d'ajustement du zoom du navigateur",
        description:
          'Résolution de votre écran détectée : ' +
          currentWidth +
          '*' +
          currentHeight +
          " ，pour une meilleure expérience d'utilisation, il est recommandé d'ajuster le zoom du navigateur à " +
          percentage,
        duration: 10,
      })
    },
  },
}
</script>

<style lang="less" scoped>
.user-layout-login {
  label {
    font-size: 14px;
  }

  .ant-form-item {
    margin-bottom: 16px;
  }

  .getCaptcha {
    display: block;
    width: 100%;
    height: 40px;
  }

  .forge-password {
    font-size: 14px;
    font-weight: bolder;
  }

  button.login-button {
    padding: 0 15px;
    font-size: 16px;
    height: 40px;
    width: 100%;
  }

  .user-login-other {
    text-align: left;
    margin-top: 24px;
    line-height: 22px;

    .item-icon {
      font-size: 24px;
      color: rgba(0, 0, 0, 0.2);
      margin-left: 16px;
      vertical-align: middle;
      cursor: pointer;
      transition: color 0.3s;

      &:hover {
        color: #1890ff;
      }
    }

    .register {
      float: right;
    }
  }

  .weixin {
    padding-left: 10px;
    color: red;
    cursor: pointer;
  }
}
</style>
<style>
.valid-error .ant-select-selection__placeholder {
  color: #f5222d;
}
.login-copyright {
  text-align: center;
  margin-top: 20px;
}
.login-copyright,
.login-copyright a {
  color: #666;
}
</style>
