/**
 * Adresse e-mail
 * @param {*} s
 */
export function isEmail(s) {
  return /^([a-zA-Z0-9._-])+@([a-zA-Z0-9_-])+((.[a-zA-Z0-9_-]{2,3}){1,2})$/.test(s)
}

/**
 * Numéro de téléphone portable
 * @param {*} s
 */
export function isMobile(s) {
  return /^1[0-9]{10}$/.test(s)
}

/**
 * Numéro de téléphone
 * @param {*} s
 */
export function isPhone(s) {
  return /^([0-9]{3,4}-)?[0-9]{7,8}$/.test(s)
}

/**
 * Adresse URL
 * @param {*} s
 */
export function isURL(s) {
  return /^http[s]?:\/\/.*/.test(s)
}

/**
 * 两位小数
 * @param {*} s
 */
export function isDecimalTwo(s) {
  let reg = /^[0-9]+(\.[0-9]{1,2})?$/
  return reg.test(s)
}

/**
 * Trois décimales
 * @param {*} s
 */
export function isDecimalThree(s) {
  let reg = /^[0-9]+(\.[0-9]{1,3})?$/
  return reg.test(s)
}
