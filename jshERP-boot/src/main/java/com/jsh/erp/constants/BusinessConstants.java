package com.jsh.erp.constants;

/**
 * @ClassName:BusinessConstants
 * @Description Classe de dictionnaire métier
 * @Author qiankunpingtai
 * @Date 2019-3-6 17:58
 * @Version 1.0
 **/
public class BusinessConstants {

    /**
     * Format de date par défaut
     */
    public static final String DEFAULT_DATETIME_FORMAT = "yyyy-MM-dd HH:mm:ss";
    /**
     * Heure initiale d'une journée
     */
    public static final String DAY_FIRST_TIME = " 00:00:00";
    /**
     * Heure de fin d'une journée
     */
    public static final String DAY_LAST_TIME = " 23:59:59";
    /**
     * Numéro de page de départ par défaut pour la pagination
     */
    public static final Integer DEFAULT_PAGINATION_PAGE_NUMBER = 1;
    /**
     * Nombre d'éléments par défaut renvoyé par la liste lorsqu'il n'y a pas de données
     */
    public static final Long DEFAULT_LIST_NULL_NUMBER = 0L;
    /**
     * Nombre d'éléments par page par défaut pour la pagination
     */
    public static final Integer DEFAULT_PAGINATION_PAGE_SIZE = 10;
    /**
     * Type d'entrée/sortie de stock de la table principale des documents type (Entrée/Sortie/Autre)
     * depothead
     * */
    public static final String DEPOTHEAD_TYPE_IN = "Entrée";
    public static final String DEPOTHEAD_TYPE_OUT = "Sortie";
    public static final String DEPOTHEAD_TYPE_OTHER = "Autre";
    /**
     * Type de paiement payType (Paiement comptant/Prépaiement)
     * */
    public static final String PAY_TYPE_PREPAID = "Prépaiement";
    public static final String PAY_TYPE_BY_CASH = "Paiement comptant";
    /**
     * Marque de suppression deleteFlag '0' non supprimé '1' supprimé
     * */
    public static final String DELETE_FLAG_DELETED = "1";
    public static final String DELETE_FLAG_EXISTS = "0";
    /**
     * Indicateur de vente isSell '0' non vendu '1' vendu
     * */
    public static final String IS_SELL_SELLED = "1";
    public static final String IS_SELL_HOLD = "0";
    /**
     * Indicateur d'activation du numéro de série pour les produits enableSerialNumber '0' non activé '1' activé
     * */
    public static final String ENABLE_SERIAL_NUMBER_ENABLED = "1";
    public static final String ENABLE_SERIAL_NUMBER_NOT_ENABLED = "0";
    /**
     * Indicateur d'activation du numéro de lot pour les produits enableBatchNumber '0' non activé '1' activé
     * */
    public static final String ENABLE_BATCH_NUMBER_ENABLED = "1";
    public static final String ENABLE_BATCH_NUMBER_NOT_ENABLED = "0";
    /**
     * Statut du document billsStatus '0' non approuvé '1' approuvé '2' achat|vente terminé '3' achat|vente partiel
     * */
    public static final String BILLS_STATUS_UN_AUDIT = "0";
    public static final String BILLS_STATUS_AUDIT = "1";
    public static final String BILLS_STATUS_SKIPED = "2";
    public static final String BILLS_STATUS_SKIPING = "3";
    /**
     * Statut d'achat du document purchaseStatus '0' non acheté '2' achat terminé '3' achat partiel
     * */
    public static final String PURCHASE_STATUS_UN_AUDIT = "0";
    public static final String PURCHASE_STATUS_SKIPED = "2";
    public static final String PURCHASE_STATUS_SKIPING = "3";
    /**
     * Classification entrée/sortie de stock
     * Demande d'achat, Achat, Retour d'achat, Autre, Vente au détail, Vente, Transfert, Révision d'inventaire, etc.
     * */
    public static final String SUB_TYPE_PURCHASE_APPLY = "Demande d'achat";
    public static final String SUB_TYPE_PURCHASE_ORDER = "Commande d'achat";
    public static final String SUB_TYPE_PURCHASE = "Achat";
    public static final String SUB_TYPE_PURCHASE_RETURN = "Retour d'achat";
    public static final String SUB_TYPE_OTHER = "Autre";
    public static final String SUB_TYPE_RETAIL = "Vente au détail";
    public static final String SUB_TYPE_RETAIL_RETURN = "Retour de vente au détail";
    public static final String SUB_TYPE_SALES_ORDER = "Commande de vente";
    public static final String SUB_TYPE_SALES = "Vente";
    public static final String SUB_TYPE_SALES_RETURN = "Retour de vente";
    public static final String SUB_TYPE_TRANSFER = "Transfert";
    public static final String SUB_TYPE_CHECK_ENTER = "Saisie d'inventaire";
    public static final String SUB_TYPE_REPLAY = "Révision d'inventaire";
    public static final String SUB_TYPE_ASSEMBLE = "Bon d'assemblage";
    public static final String SUB_TYPE_DISASSEMBLE = "Bon de démontage";
    /**
     * Pattern de recherche pour tous les types de retours (utilisé dans LIKE)
     * */
    public static final String SUB_TYPE_RETURN_PATTERN = "Retour";
    /**
     * Classification des types de production
     * Entrée de production
     * */
    public static final String BILL_TYPE_PRODUCE_IN = "生产入库";
    /**
     * Classification des documents financiers
     * Recette, Paiement, Transfert
     * */
    public static final String TYPE_MONEY_IN = "Recette";
    public static final String TYPE_MONEY_OUT = "Paiement";
    public static final String TYPE_GIRO = "Transfert";
    public static final String TYPE_ADVANCE_IN = "Réception prépaiement";
    /**
     * Nombre maximum d'enregistrements lors de l'insertion SQL en lot
     * */
    public static final int BATCH_INSERT_MAX_NUMBER = 500;
    /**
     * Nom de la séquence
     * */
    // Longueur minimale de la chaîne retournée par la séquence
    public static final Long SEQ_TO_STRING_MIN_LENGTH = 10000000000L;
    // Valeur de base ajoutée au début lorsque la longueur de la séquence est inférieure à la longueur de référence
    public static final String SEQ_TO_STRING_LESS_INSERT = "0";
    // Numéro de document
    public static final String DEPOT_NUMBER_SEQ = "depot_number_seq";
    /**
     * ID du répertoire racine de la catégorie de produits
     * */
    /**
     * create by: qiankunpingtai
     * create time: 2019/3/14 11:41
     * description:
     * Pour permettre aux utilisateurs de créer leur propre répertoire initial, l'ID du répertoire parent du répertoire racine est défini à -1
     *
     */
    public static final Long MATERIAL_CATEGORY_ROOT_PARENT_ID = -1L;
    /**
     * État de la catégorie de produits
     * 0 système par défaut, 1 activé, 2 supprimé
     * */
    public static final String MATERIAL_CATEGORY_STATUS_DEFAULT = "0";
    public static final String MATERIAL_CATEGORY_STATUS_ENABLE = "1";
    public static final String MATERIAL_CATEGORY_STATUS_DELETE = "2";
    /**
     * État de l'organisation
     * 1 non ouvert, 2 fonctionnement normal, 3 activité suspendue, 4 activité terminée, 5 exclu
     * */
    public static final String ORGANIZATION_STCD_NOT_OPEN = "1";
    public static final String ORGANIZATION_STCD_OPEN = "2";
    public static final String ORGANIZATION_STCD_BUSINESS_SUSPENDED = "3";
    public static final String ORGANIZATION_STCD_BUSINESS_TERMINATED = "4";
    public static final String ORGANIZATION_STCD_REMOVED = "5";
    /**
     * Numéro de l'organisation parente racine
     * Le numéro de l'organisation parente racine est par défaut -1
     * */
    public static final String ORGANIZATION_ROOT_PARENT_NO = "-1";
    /**
     * Mot de passe par défaut pour les nouveaux utilisateurs
     * */
    public static final String USER_DEFAULT_PASSWORD = "123456";
    /**
     * Indicateur si l'utilisateur est fourni par le système
     * 0 non fourni par le système, 1 fourni par le système
     * */
    public static final byte USER_NOT_SYSTEM = 0;
    public static final byte USER_IS_SYSTEM = 1;
    /**
     * Indicateur si l'utilisateur est un manager
     * 0 manager, 1 employé
     * */
    public static final byte USER_IS_MANAGER = 0;
    public static final byte USER_NOT_MANAGER = 1;
    /**
     * État de l'utilisateur
     * 0 : normal, 2 banni
     * */
    public static final byte USER_STATUS_NORMAL = 0;
    public static final byte USER_STATUS_BANNED = 2;
    /**
     * Opérations de journal
     * Ajouter, Modifier, Supprimer, Connexion, Importer
     * */
    public static final String LOG_OPERATION_TYPE_ADD = "新增";
    public static final String LOG_OPERATION_TYPE_BATCH_ADD = "批量新增";
    public static final String LOG_OPERATION_TYPE_EDIT = "修改";
    public static final String LOG_OPERATION_TYPE_DELETE = "删除";
    public static final String LOG_OPERATION_TYPE_LOGIN = "登录";
    public static final String LOG_OPERATION_TYPE_IMPORT = "导入";
    public static final String LOG_OPERATION_TYPE_ENABLED = "更新状态";

    /**
     * Nom du module de journal
     * */
    public static final String LOG_MODULE_BILL = "单据";
    public static final String LOG_MODULE_FINANCIAL_BILL = "Document financier";

    /**
     * Étiquettes de statut du journal
     * */
    public static final String LOG_STATUS_AUDITED = "[Approuvé]";
    public static final String LOG_STATUS_UNAUDITED = "[Désapprouvé]";

    /**
     * Unité de quantité de données
     * élément
     * */
    public static final String LOG_DATA_UNIT = "条";

    /**
     * Type de suppression
     * 1 suppression normale
     * 2 suppression forcée
     * */
    public static final String DELETE_TYPE_NORMAL = "1";
    public static final String DELETE_TYPE_FORCE = "2";

    /**
     * Compte administrateur par défaut
     */
    public static final String DEFAULT_MANAGER = "admin";

    public static final String ROLE_TYPE_PRIVATE = "个人数据";

    public static final String ROLE_TYPE_THIS_ORG = "本机构数据";

    public static final String ROLE_TYPE_PUBLIC = "全部数据";

    /**
     * Paramètres Redis
     * */
    // Durée de vie de la session, en secondes
    public static final Long MAX_SESSION_IN_SECONDS=60*60*24*3L;

    /**
     * Clé Redis pour le code de vérification
     */
    public static final String CAPTCHA_CODE_KEY = "captcha_codes:";
    /**
     * Durée de validité du code de vérification (en minutes)
     */
    public static final Integer CAPTCHA_EXPIRATION = 2;

    /**
     * Interface de connexion WeChat
     */
    public static final String WEIXIN_LOGIN = "/sns/jscode2session";

    /**
     * Interface pour obtenir le token WeChat
     */
    public static final String WEIXIN_TOKEN = "/cgi-bin/token";

    /**
     * Interface pour envoyer des messages d'abonnement WeChat
     */
    public static final String WEIXIN_MESSAGE_SEND = "/cgi-bin/message/subscribe/send";

    /**
     * Type de fournisseur
     * Fournisseur, Client, Membre
     * */
    public static final String SUPPLIER_TYPE_VENDOR = "供应商";
    public static final String SUPPLIER_TYPE_CUSTOMER = "客户";
    public static final String SUPPLIER_TYPE_MEMBER = "会员";

    /**
     * Type de produit
     * Pièce composite, Pièce normale
     * */
    public static final String MATERIAL_TYPE_ASSEMBLE = "组合件";
    public static final String MATERIAL_TYPE_NORMAL = "普通子件";

    /**
     * En-têtes de colonnes pour l'export Excel
     * */
    public static final String EXCEL_COL_NAME = "名称*";
    public static final String EXCEL_COL_CONTACTS = "联系人";
    public static final String EXCEL_COL_PHONE = "手机号码";
    public static final String EXCEL_COL_TELEPHONE = "联系电话";
    public static final String EXCEL_COL_EMAIL = "电子邮箱";
    public static final String EXCEL_COL_FAX = "传真";
    public static final String EXCEL_COL_BEGIN_NEED_PAY = "期初应付";
    public static final String EXCEL_COL_BEGIN_NEED_GET = "期初应收";
    public static final String EXCEL_COL_TAX_NUM = "纳税人识别号";
    public static final String EXCEL_COL_TAX_RATE = "税率(%)";
    public static final String EXCEL_COL_BANK_NAME = "开户行";
    public static final String EXCEL_COL_ACCOUNT_NUMBER = "账号";
    public static final String EXCEL_COL_ADDRESS = "地址";
    public static final String EXCEL_COL_REMARK = "备注";
    public static final String EXCEL_COL_SORT = "排序";
    public static final String EXCEL_COL_STATUS = "状态*";
    public static final String EXCEL_COL_MEMBER_CARD = "会员卡号*";
    public static final String EXCEL_TITLE_INFO = "信息内容";

    /**
     * Police Excel par défaut
     * */
    public static final String EXCEL_FONT_NAME = "Arial";
}
