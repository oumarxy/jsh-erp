import { message } from 'ant-design-vue/es'
// import defaultSettings from '../defaultSettings';

let lessNodesAppended

const colorList = [
  {
    key: 'Crépuscule',
    color: '#F5222D',
  },
  {
    key: 'Volcan',
    color: '#FA541C',
  },
  {
    key: 'Coucher de soleil',
    color: '#FAAD14',
  },
  {
    key: 'Cyan clair',
    color: '#13C2C2',
  },
  {
    key: 'Vert aurore',
    color: '#52C41A',
  },
  {
    key: 'Bleu aube (par défaut)',
    color: '#1890FF',
  },
  {
    key: 'Bleu geek',
    color: '#2F54EB',
  },
  {
    key: 'Violet',
    color: '#722ED1',
  },
]

const updateTheme = (primaryColor) => {
  // Don't compile less in production!
  /* if (process.env.NODE_ENV === 'production') {
    return;
  } */
  // Determine if the component is remounted
  if (!primaryColor) {
    return
  }
  const hideMessage = message.loading('Compilation du thème en cours !', 0)
  console.info(`Compilation du thème en cours !`)
  function buildIt() {
    // 正确的判定less是否已经加载less.modifyVars可用
    if (!window.less || !window.less.modifyVars) {
      return
    }
    // less.modifyVars可用
    window.less
      .modifyVars({
        '@primary-color': primaryColor,
      })
      .then(() => {
        hideMessage()
      })
      .catch(() => {
        message.error('Failed to update theme')
        hideMessage()
      })
  }
  if (!lessNodesAppended) {
    // insert less.js and color.less
    const lessStyleNode = document.createElement('link')
    const lessConfigNode = document.createElement('script')
    const lessScriptNode = document.createElement('script')
    lessStyleNode.setAttribute('rel', 'stylesheet/less')
    lessStyleNode.setAttribute('href', '/static/color.less')
    lessConfigNode.innerHTML = `
      window.less = {
        async: true,
        env: 'production',
        javascriptEnabled: true
      };
    `
    lessScriptNode.src = '/static/less.min.js'
    lessScriptNode.async = true
    lessScriptNode.onload = () => {
      buildIt()
      lessScriptNode.onload = null
    }
    document.body.appendChild(lessStyleNode)
    document.body.appendChild(lessConfigNode)
    document.body.appendChild(lessScriptNode)
    lessNodesAppended = true
  } else {
    buildIt()
  }
}

const updateColorWeak = (colorWeak) => {
  // document.body.className = colorWeak ? 'colorWeak' : '';
  colorWeak ? document.body.classList.add('colorWeak') : document.body.classList.remove('colorWeak')
}

export { updateTheme, colorList, updateColorWeak }
