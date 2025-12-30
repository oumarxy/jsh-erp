/*
 Navicat Premium Data Transfer

 Source Server         : 127.0.0.1
 Source Server Type    : MySQL
 Source Server Version : 80029
 Source Host           : 127.0.0.1:3306
 Source Schema         : jsh_erp

 Target Server Type    : MySQL
 Target Server Version : 80029
 File Encoding         : 65001

 Date: 05/11/2025 22:26:57
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for jsh_account
-- ----------------------------
DROP TABLE IF EXISTS `jsh_account`;
CREATE TABLE `jsh_account`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'Clé primaire',
  `name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Nom',
  `serial_no` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Numéro',
  `initial_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Montant initial',
  `current_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Solde actuel',
  `remark` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Remarque',
  `enabled` bit(1) NULL DEFAULT NULL COMMENT 'Activé',
  `sort` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Tri',
  `is_default` bit(1) NULL DEFAULT NULL COMMENT 'Par défaut',
  `tenant_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID locataire',
  `delete_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque de suppression, 0 non supprimé, 1 supprimé',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `tenant_id`(`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 24 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'Informations du compte' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of jsh_account
-- ----------------------------
INSERT INTO `jsh_account` VALUES (17, 'Compte 1', 'zzz111', 100.000000, 829.000000, 'aabb', b'1', NULL, b'1', 63, '0');
INSERT INTO `jsh_account` VALUES (18, 'Compte 2', '1234131324', 200.000000, -1681.000000, 'bbbb', b'1', NULL, b'0', 63, '0');

-- ----------------------------
-- Table structure for jsh_account_head
-- ----------------------------
DROP TABLE IF EXISTS `jsh_account_head`;
CREATE TABLE `jsh_account_head`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'Clé primaire',
  `type` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Type (Dépense/Revenu/Recette/Paiement/Transfert)',
  `organ_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID organisation (Organisation recette/paiement)',
  `hands_person_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID personne responsable',
  `creator` bigint(0) NULL DEFAULT NULL COMMENT 'Opérateur',
  `change_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Montant variable (Remise/Recette/Paiement/Paiement réel)',
  `discount_money` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Montant de remise',
  `total_price` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Montant total',
  `account_id` bigint(0) NULL DEFAULT NULL COMMENT 'Compte (Recette/Paiement)',
  `bill_no` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Numéro de document',
  `bill_time` datetime(0) NULL DEFAULT NULL COMMENT 'Date du document',
  `remark` varchar(1000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Remarque',
  `file_name` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Nom de la pièce jointe',
  `status` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Statut, 0 non approuvé, 1 approuvé, 9 en cours d''approbation',
  `source` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Source du document, 0-PC, 1-mobile',
  `tenant_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID locataire',
  `delete_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque de suppression, 0 non supprimé, 1 supprimé',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `FK9F4C0D8DB610FC06`(`organ_id`) USING BTREE,
  INDEX `FK9F4C0D8DAAE50527`(`account_id`) USING BTREE,
  INDEX `FK9F4C0D8DC4170B37`(`hands_person_id`) USING BTREE,
  INDEX `bill_no`(`bill_no`) USING BTREE,
  INDEX `tenant_id`(`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 127 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'Table principale financière' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for jsh_account_item
-- ----------------------------
DROP TABLE IF EXISTS `jsh_account_item`;
CREATE TABLE `jsh_account_item`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'Clé primaire',
  `header_id` bigint(0) NOT NULL COMMENT 'ID en-tête',
  `account_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID compte',
  `in_out_item_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID projet recettes/dépenses',
  `bill_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID document',
  `need_debt` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Créance à recevoir',
  `finish_debt` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Créance reçue',
  `each_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Montant unitaire',
  `remark` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Remarque du document',
  `tenant_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID locataire',
  `delete_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque de suppression, 0 non supprimé, 1 supprimé',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `FK9F4CBAC0AAE50527`(`account_id`) USING BTREE,
  INDEX `FK9F4CBAC0C5FE6007`(`header_id`) USING BTREE,
  INDEX `FK9F4CBAC0D203EDC5`(`in_out_item_id`) USING BTREE,
  INDEX `bill_id`(`bill_id`) USING BTREE,
  INDEX `tenant_id`(`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 152 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'Sous-table financière' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for jsh_depot
-- ----------------------------
DROP TABLE IF EXISTS `jsh_depot`;
CREATE TABLE `jsh_depot`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'Clé primaire',
  `name` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Nom de l''entrepôt',
  `address` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Adresse de l''entrepôt',
  `warehousing` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Frais de stockage',
  `truckage` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Frais de manutention',
  `type` int(0) NULL DEFAULT NULL COMMENT 'Type',
  `sort` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Tri',
  `remark` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Description',
  `principal` bigint(0) NULL DEFAULT NULL COMMENT 'Responsable',
  `enabled` bit(1) NULL DEFAULT NULL COMMENT 'Activé',
  `tenant_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID locataire',
  `delete_Flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque de suppression, 0 non supprimé, 1 supprimé',
  `is_default` bit(1) NULL DEFAULT NULL COMMENT 'Par défaut',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `tenant_id`(`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 19 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'Table des entrepôts' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of jsh_depot
-- ----------------------------
INSERT INTO `jsh_depot` VALUES (14, 'Entrepôt 1', 'dizhi', 12.000000, 12.000000, 0, '1', 'Description', 131, b'1', 63, '0', b'1');
INSERT INTO `jsh_depot` VALUES (15, 'Entrepôt 2', 'Adresse 100', 555.000000, 666.000000, 0, '2', 'dfdf', 131, b'1', 63, '0', b'0');
INSERT INTO `jsh_depot` VALUES (17, 'Entrepôt 3', '123123', 123.000000, 123.000000, 0, '3', '123', 131, b'1', 63, '0', b'0');

-- ----------------------------
-- Table structure for jsh_depot_head
-- ----------------------------
DROP TABLE IF EXISTS `jsh_depot_head`;
CREATE TABLE `jsh_depot_head`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'Clé primaire',
  `type` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Type (Entrée/Sortie/Autre)',
  `sub_type` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Classification: Demande d\'achat, Commande d\'achat, Achat, Retour d\'achat, Vente au détail, Retour de vente au détail, Commande de vente, Vente, Retour de vente, Autre, Transfert, Saisie d\'inventaire, Révision d\'inventaire, Bon d\'assemblage, Bon de démontage',
  `default_number` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Numéro de document initial',
  `number` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Numéro de document',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT 'Date de création',
  `oper_time` datetime(0) NULL DEFAULT NULL COMMENT 'Date entrée/sortie',
  `organ_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID fournisseur',
  `creator` bigint(0) NULL DEFAULT NULL COMMENT 'Opérateur',
  `account_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID compte',
  `change_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Montant variable (Recette/Paiement)',
  `back_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Montant de monnaie',
  `total_price` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Montant total',
  `pay_type` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Type de paiement (Espèces, crédit, etc.)',
  `bill_type` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Type de document',
  `remark` varchar(1000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Remarque',
  `file_name` varchar(1000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Nom de la pièce jointe',
  `sales_man` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Vendeur (peut être multiple)',
  `account_id_list` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Liste des ID de comptes multiples',
  `account_money_list` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Liste des montants de comptes multiples',
  `discount` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Taux de remise',
  `discount_money` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Montant de remise',
  `discount_last_money` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Montant après remise',
  `other_money` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Total des frais de vente ou d''achat',
  `deposit` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Acompte',
  `status` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Statut, 0 non approuvé, 1 approuvé, 2 achat|vente terminé, 3 achat|vente partiel, 9 en cours d''approbation',
  `purchase_status` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Statut d''achat, 0 non acheté, 2 achat terminé, 3 achat partiel',
  `source` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Source du document, 0-PC, 1-mobile',
  `link_number` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Numéro de commande associé',
  `link_apply` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Demande d''achat associée',
  `tenant_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID locataire',
  `delete_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque de suppression, 0 non supprimé, 1 supprimé',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `FK2A80F214B610FC06`(`organ_id`) USING BTREE,
  INDEX `FK2A80F214AAE50527`(`account_id`) USING BTREE,
  INDEX `number`(`number`) USING BTREE,
  INDEX `link_number`(`link_number`) USING BTREE,
  INDEX `creator`(`creator`) USING BTREE,
  INDEX `tenant_id`(`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 277 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'Table principale des documents' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for jsh_depot_item
-- ----------------------------
DROP TABLE IF EXISTS `jsh_depot_item`;
CREATE TABLE `jsh_depot_item`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'Clé primaire',
  `header_id` bigint(0) NOT NULL COMMENT 'ID en-tête',
  `material_id` bigint(0) NOT NULL COMMENT 'ID produit',
  `material_extend_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID extension produit',
  `material_unit` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Unité du produit',
  `sku` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Multi-attributs',
  `oper_number` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Quantité',
  `basic_number` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Quantité de base, ex. kg, bouteille',
  `unit_price` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Prix unitaire',
  `purchase_unit_price` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Prix unitaire d''achat',
  `tax_unit_price` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Prix unitaire TTC',
  `all_price` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Montant',
  `remark` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Remarque',
  `depot_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID entrepôt',
  `another_depot_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID entrepôt destinataire lors du transfert',
  `tax_rate` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Taux de taxe',
  `tax_money` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Montant de taxe',
  `tax_last_money` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Total TTC',
  `material_type` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Type de produit',
  `sn_list` varchar(2000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Liste des numéros de série',
  `batch_number` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Numéro de lot',
  `expiration_date` datetime(0) NULL DEFAULT NULL COMMENT 'Date d''expiration',
  `link_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID détail associé',
  `tenant_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID locataire',
  `delete_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque de suppression, 0 non supprimé, 1 supprimé',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `FK2A819F475D61CCF7`(`material_id`) USING BTREE,
  INDEX `FK2A819F474BB6190E`(`header_id`) USING BTREE,
  INDEX `FK2A819F479485B3F5`(`depot_id`) USING BTREE,
  INDEX `FK2A819F47729F5392`(`another_depot_id`) USING BTREE,
  INDEX `material_extend_id`(`material_extend_id`) USING BTREE,
  INDEX `tenant_id`(`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 334 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'Sous-table des documents' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for jsh_function
-- ----------------------------
DROP TABLE IF EXISTS `jsh_function`;
CREATE TABLE `jsh_function`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'Clé primaire',
  `number` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Numéro',
  `name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Nom',
  `parent_number` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Numéro parent',
  `url` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Lien',
  `component` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Composant',
  `state` bit(1) NULL DEFAULT NULL COMMENT 'Réduire',
  `sort` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Tri',
  `enabled` bit(1) NULL DEFAULT NULL COMMENT 'Activé',
  `type` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Type',
  `push_btn` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Bouton de fonction',
  `icon` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Icône',
  `delete_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque de suppression, 0 non supprimé, 1 supprimé',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `url`(`url`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 262 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'Table des modules fonctionnels' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of jsh_function
-- ----------------------------
INSERT INTO `jsh_function` VALUES (1, '0001', 'Gestion système', '0', '/system', '/layouts/TabLayout', b'1', '0910', b'1', 'Version PC', '', 'setting', '0');
INSERT INTO `jsh_function` VALUES (13, '000102', 'Gestion des rôles', '0001', '/system/role', '/system/RoleList', b'0', '0130', b'1', 'Version PC', '1', 'profile', '0');
INSERT INTO `jsh_function` VALUES (14, '000103', 'Gestion des utilisateurs', '0001', '/system/user', '/system/UserList', b'0', '0140', b'1', 'Version PC', '1', 'profile', '0');
INSERT INTO `jsh_function` VALUES (15, '000104', 'Gestion des journaux', '0001', '/system/log', '/system/LogList', b'0', '0160', b'1', 'Version PC', '', 'profile', '0');
INSERT INTO `jsh_function` VALUES (16, '000105', 'Gestion des fonctions', '0001', '/system/function', '/system/FunctionList', b'0', '0166', b'1', 'Version PC', '1', 'profile', '0');
INSERT INTO `jsh_function` VALUES (18, '000109', 'Gestion des locataires', '0001', '/system/tenant', '/system/TenantList', b'0', '0167', b'1', 'Version PC', '1', 'profile', '0');
INSERT INTO `jsh_function` VALUES (21, '0101', 'Gestion des produits', '0', '/material', '/layouts/TabLayout', b'0', '0620', b'1', 'Version PC', NULL, 'shopping', '0');
INSERT INTO `jsh_function` VALUES (22, '010101', 'Catégories de produits', '0101', '/material/material_category', '/material/MaterialCategoryList', b'0', '0230', b'1', 'Version PC', '1', 'profile', '0');
INSERT INTO `jsh_function` VALUES (23, '010102', 'Informations produit', '0101', '/material/material', '/material/MaterialList', b'0', '0240', b'1', 'Version PC', '1,3', 'profile', '0');
INSERT INTO `jsh_function` VALUES (24, '0102', 'Données de base', '0', '/systemA', '/layouts/TabLayout', b'0', '0750', b'1', 'Version PC', NULL, 'appstore', '0');
INSERT INTO `jsh_function` VALUES (25, '01020101', 'Informations fournisseur', '0102', '/system/vendor', '/system/VendorList', b'0', '0260', b'1', 'Version PC', '1,3', 'profile', '0');
INSERT INTO `jsh_function` VALUES (26, '010202', 'Informations entrepôt', '0102', '/system/depot', '/system/DepotList', b'0', '0270', b'1', 'Version PC', '1', 'profile', '0');
INSERT INTO `jsh_function` VALUES (31, '010206', 'Gestion des personnes responsables', '0102', '/system/person', '/system/PersonList', b'0', '0284', b'1', 'Version PC', '1', 'profile', '0');
INSERT INTO `jsh_function` VALUES (32, '0502', 'Gestion des achats', '0', '/bill', '/layouts/TabLayout', b'0', '0330', b'1', 'Version PC', '', 'retweet', '0');
INSERT INTO `jsh_function` VALUES (33, '050201', 'Entrée d''achat', '0502', '/bill/purchase_in', '/bill/PurchaseInList', b'0', '0340', b'1', 'Version PC', '1,2,3,7', 'profile', '0');
INSERT INTO `jsh_function` VALUES (38, '0603', 'Gestion des ventes', '0', '/billB', '/layouts/TabLayout', b'0', '0390', b'1', 'Version PC', '', 'shopping-cart', '0');
INSERT INTO `jsh_function` VALUES (40, '080107', 'Sortie de transfert', '0801', '/bill/allocation_out', '/bill/AllocationOutList', b'0', '0807', b'1', 'Version PC', '1,2,3,7', 'profile', '0');
INSERT INTO `jsh_function` VALUES (41, '060303', 'Sortie de vente', '0603', '/bill/sale_out', '/bill/SaleOutList', b'0', '0394', b'1', 'Version PC', '1,2,3,7', 'profile', '0');
INSERT INTO `jsh_function` VALUES (44, '0704', 'Gestion financière', '0', '/financial', '/layouts/TabLayout', b'0', '0450', b'1', 'Version PC', '', 'money-collect', '0');
INSERT INTO `jsh_function` VALUES (59, '030101', 'Statistiques stock', '0301', '/report/in_out_stock_report', '/report/InOutStockReport', b'0', '0658', b'1', 'Version PC', '', 'profile', '0');
INSERT INTO `jsh_function` VALUES (194, '010204', 'Projet recettes/dépenses', '0102', '/system/in_out_item', '/system/InOutItemList', b'0', '0282', b'1', 'Version PC', '1', 'profile', '0');
INSERT INTO `jsh_function` VALUES (195, '010205', 'Comptes de règlement', '0102', '/system/account', '/system/AccountList', b'0', '0283', b'1', 'Version PC', '1', 'profile', '0');
INSERT INTO `jsh_function` VALUES (197, '070402', 'Bon de recette', '0704', '/financial/item_in', '/financial/ItemInList', b'0', '0465', b'1', 'Version PC', '1,2,3,7', 'profile', '0');
INSERT INTO `jsh_function` VALUES (198, '0301', 'Requête de rapports', '0', '/report', '/layouts/TabLayout', b'0', '0570', b'1', 'Version PC', NULL, 'pie-chart', '0');
INSERT INTO `jsh_function` VALUES (199, '050204', 'Retour d''achat', '0502', '/bill/purchase_back', '/bill/PurchaseBackList', b'0', '0345', b'1', 'Version PC', '1,2,3,7', 'profile', '0');
INSERT INTO `jsh_function` VALUES (200, '060305', 'Retour de vente', '0603', '/bill/sale_back', '/bill/SaleBackList', b'0', '0396', b'1', 'Version PC', '1,2,3,7', 'profile', '0');
INSERT INTO `jsh_function` VALUES (201, '080103', 'Autre entrée', '0801', '/bill/other_in', '/bill/OtherInList', b'0', '0803', b'1', 'Version PC', '1,2,3,7', 'profile', '0');
INSERT INTO `jsh_function` VALUES (202, '080105', 'Autre sortie', '0801', '/bill/other_out', '/bill/OtherOutList', b'0', '0805', b'1', 'Version PC', '1,2,3,7', 'profile', '0');
INSERT INTO `jsh_function` VALUES (203, '070403', 'Bon de dépense', '0704', '/financial/item_out', '/financial/ItemOutList', b'0', '0470', b'1', 'Version PC', '1,2,3,7', 'profile', '0');
INSERT INTO `jsh_function` VALUES (204, '070404', 'Bon de recette', '0704', '/financial/money_in', '/financial/MoneyInList', b'0', '0475', b'1', 'Version PC', '1,2,3,7', 'profile', '0');
INSERT INTO `jsh_function` VALUES (205, '070405', 'Bon de paiement', '0704', '/financial/money_out', '/financial/MoneyOutList', b'0', '0480', b'1', 'Version PC', '1,2,3,7', 'profile', '0');
INSERT INTO `jsh_function` VALUES (206, '070406', 'Bon de transfert', '0704', '/financial/giro', '/financial/GiroList', b'0', '0490', b'1', 'Version PC', '1,2,3,7', 'profile', '0');
INSERT INTO `jsh_function` VALUES (207, '030102', 'Statistiques de compte', '0301', '/report/account_report', '/report/AccountReport', b'0', '0610', b'1', 'Version PC', '', 'profile', '0');
INSERT INTO `jsh_function` VALUES (208, '030103', 'Statistiques d''achat', '0301', '/report/buy_in_report', '/report/BuyInReport', b'0', '0620', b'1', 'Version PC', '', 'profile', '0');
INSERT INTO `jsh_function` VALUES (209, '030104', 'Statistiques de vente', '0301', '/report/sale_out_report', '/report/SaleOutReport', b'0', '0630', b'1', 'Version PC', '', 'profile', '0');
INSERT INTO `jsh_function` VALUES (210, '040102', 'Sortie de détail', '0401', '/bill/retail_out', '/bill/RetailOutList', b'0', '0405', b'1', 'Version PC', '1,2,3,7', 'profile', '0');
INSERT INTO `jsh_function` VALUES (211, '040104', 'Retour de détail', '0401', '/bill/retail_back', '/bill/RetailBackList', b'0', '0407', b'1', 'Version PC', '1,2,3,7', 'profile', '0');
INSERT INTO `jsh_function` VALUES (212, '070407', 'Réception prépaiement', '0704', '/financial/advance_in', '/financial/AdvanceInList', b'0', '0495', b'1', 'Version PC', '1,2,3,7', 'profile', '0');
INSERT INTO `jsh_function` VALUES (217, '01020102', 'Informations client', '0102', '/system/customer', '/system/CustomerList', b'0', '0262', b'1', 'Version PC', '1,3', 'profile', '0');
INSERT INTO `jsh_function` VALUES (218, '01020103', 'Informations membre', '0102', '/system/member', '/system/MemberList', b'0', '0263', b'1', 'Version PC', '1,3', 'profile', '0');
INSERT INTO `jsh_function` VALUES (220, '010103', 'Multi-unités', '0101', '/system/unit', '/system/UnitList', b'0', '0245', b'1', 'Version PC', '1', 'profile', '0');
INSERT INTO `jsh_function` VALUES (225, '0401', 'Gestion de détail', '0', '/billC', '/layouts/TabLayout', b'0', '0101', b'1', 'Version PC', '', 'gift', '0');
INSERT INTO `jsh_function` VALUES (226, '030106', 'Détails d''entrée', '0301', '/report/in_detail', '/report/InDetail', b'0', '0640', b'1', 'Version PC', '', 'profile', '0');
INSERT INTO `jsh_function` VALUES (227, '030107', 'Détails de sortie', '0301', '/report/out_detail', '/report/OutDetail', b'0', '0645', b'1', 'Version PC', '', 'profile', '0');
INSERT INTO `jsh_function` VALUES (228, '030108', 'Résumé d''entrée', '0301', '/report/in_material_count', '/report/InMaterialCount', b'0', '0650', b'1', 'Version PC', '', 'profile', '0');
INSERT INTO `jsh_function` VALUES (229, '030109', 'Résumé de sortie', '0301', '/report/out_material_count', '/report/OutMaterialCount', b'0', '0655', b'1', 'Version PC', '', 'profile', '0');
INSERT INTO `jsh_function` VALUES (232, '080109', 'Bon d''assemblage', '0801', '/bill/assemble', '/bill/AssembleList', b'0', '0809', b'1', 'Version PC', '1,2,3,7', 'profile', '0');
INSERT INTO `jsh_function` VALUES (233, '080111', 'Bon de démontage', '0801', '/bill/disassemble', '/bill/DisassembleList', b'0', '0811', b'1', 'Version PC', '1,2,3,7', 'profile', '0');
INSERT INTO `jsh_function` VALUES (234, '000105', 'Configuration système', '0001', '/system/system_config', '/system/SystemConfigList', b'0', '0164', b'1', 'Version PC', '1', 'profile', '0');
INSERT INTO `jsh_function` VALUES (235, '030110', 'Réconciliation client', '0301', '/report/customer_account', '/report/CustomerAccount', b'0', '0660', b'1', 'Version PC', '', 'profile', '0');
INSERT INTO `jsh_function` VALUES (236, '000106', 'Attributs produit', '0001', '/material/material_property', '/material/MaterialPropertyList', b'0', '0163', b'1', 'Version PC', '1', 'profile', '0');
INSERT INTO `jsh_function` VALUES (237, '030111', 'Réconciliation fournisseur', '0301', '/report/vendor_account', '/report/VendorAccount', b'0', '0665', b'1', 'Version PC', '', 'profile', '0');
INSERT INTO `jsh_function` VALUES (239, '0801', 'Gestion d''entrepôt', '0', '/billD', '/layouts/TabLayout', b'0', '0420', b'1', 'Version PC', '', 'hdd', '0');
INSERT INTO `jsh_function` VALUES (241, '050202', 'Commande d''achat', '0502', '/bill/purchase_order', '/bill/PurchaseOrderList', b'0', '0335', b'1', 'Version PC', '1,2,3,7', 'profile', '0');
INSERT INTO `jsh_function` VALUES (242, '060301', 'Commande de vente', '0603', '/bill/sale_order', '/bill/SaleOrderList', b'0', '0392', b'1', 'Version PC', '1,2,3,7', 'profile', '0');
INSERT INTO `jsh_function` VALUES (243, '000108', 'Gestion des organisations', '0001', '/system/organization', '/system/OrganizationList', b'1', '0150', b'1', 'Version PC', '1', 'profile', '0');
INSERT INTO `jsh_function` VALUES (244, '030112', 'Alerte de stock', '0301', '/report/stock_warning_report', '/report/StockWarningReport', b'0', '0670', b'1', 'Version PC', '', 'profile', '0');
INSERT INTO `jsh_function` VALUES (245, '000107', 'Gestion des plugins', '0001', '/system/plugin', '/system/PluginList', b'0', '0170', b'1', 'Version PC', '1', 'profile', '0');
INSERT INTO `jsh_function` VALUES (246, '030113', 'Stock produit', '0301', '/report/material_stock', '/report/MaterialStock', b'0', '0605', b'1', 'Version PC', '', 'profile', '0');
INSERT INTO `jsh_function` VALUES (247, '010105', 'Multi-attributs', '0101', '/material/material_attribute', '/material/MaterialAttributeList', b'0', '0250', b'1', 'Version PC', '1', 'profile', '0');
INSERT INTO `jsh_function` VALUES (248, '030150', 'Détails de transfert', '0301', '/report/allocation_detail', '/report/AllocationDetail', b'0', '0646', b'1', 'Version PC', '', 'profile', '0');
INSERT INTO `jsh_function` VALUES (258, '000112', 'Configuration plateforme', '0001', '/system/platform_config', '/system/PlatformConfigList', b'0', '0175', b'1', 'Version PC', '', 'profile', '0');
INSERT INTO `jsh_function` VALUES (259, '030105', 'Statistiques de détail', '0301', '/report/retail_out_report', '/report/RetailOutReport', b'0', '0615', b'1', 'Version PC', '', 'profile', '0');
INSERT INTO `jsh_function` VALUES (261, '050203', 'Demande d''achat', '0502', '/bill/purchase_apply', '/bill/PurchaseApplyList', b'0', '0330', b'1', 'Version PC', '1,2,3,7', 'profile', '0');

-- ----------------------------
-- Table structure for jsh_in_out_item
-- ----------------------------
DROP TABLE IF EXISTS `jsh_in_out_item`;
CREATE TABLE `jsh_in_out_item`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'Clé primaire',
  `name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Nom',
  `type` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Type',
  `remark` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Remarque',
  `enabled` bit(1) NULL DEFAULT NULL COMMENT 'Activé',
  `sort` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Tri',
  `tenant_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID locataire',
  `delete_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque de suppression, 0 non supprimé, 1 supprimé',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `tenant_id`(`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 28 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'Projet recettes/dépenses' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of jsh_in_out_item
-- ----------------------------
INSERT INTO `jsh_in_out_item` VALUES (21, 'Frais d''expédition', 'Dépense', '', b'1', NULL, 63, '0');
INSERT INTO `jsh_in_out_item` VALUES (22, 'Revenu location', 'Revenu', '', b'1', NULL, 63, '0');
INSERT INTO `jsh_in_out_item` VALUES (23, 'Revenu intérêts', 'Revenu', 'Revenu', b'1', NULL, 63, '0');

-- ----------------------------
-- Table structure for jsh_log
-- ----------------------------
DROP TABLE IF EXISTS `jsh_log`;
CREATE TABLE `jsh_log`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'Clé primaire',
  `user_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID utilisateur',
  `operation` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Nom du module d''opération',
  `client_ip` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'IP client',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT 'Date de création',
  `status` tinyint(0) NULL DEFAULT NULL COMMENT 'Statut de l''opération 0==succès, 1==échec',
  `content` varchar(5000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Détails',
  `tenant_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID locataire',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `FKF2696AA13E226853`(`user_id`) USING BTREE,
  INDEX `create_time`(`create_time`) USING BTREE,
  INDEX `tenant_id`(`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7608 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'Journal des opérations' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for jsh_material
-- ----------------------------
DROP TABLE IF EXISTS `jsh_material`;
CREATE TABLE `jsh_material`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'Clé primaire',
  `category_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID type de produit',
  `name` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Nom',
  `mfrs` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Fabricant',
  `model` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Modèle',
  `standard` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Spécification',
  `brand` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Marque',
  `mnemonic` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Code mnémonique',
  `color` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Couleur',
  `unit` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Unité - unitaire',
  `remark` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Remarque',
  `img_name` varchar(1000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Nom de l''image',
  `unit_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID unité',
  `expiry_num` int(0) NULL DEFAULT NULL COMMENT 'Durée de conservation en jours',
  `weight` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Poids de base (kg)',
  `enabled` bit(1) NULL DEFAULT NULL COMMENT 'Activé 0-désactivé 1-activé',
  `other_field1` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Personnalisé 1',
  `other_field2` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Personnalisé 2',
  `other_field3` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Personnalisé 3',
  `enable_serial_number` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Activer le numéro de série, 0 non, 1 oui',
  `enable_batch_number` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Activer le numéro de lot, 0 non, 1 oui',
  `position` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Emplacement étagère',
  `attribute` varchar(1000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Informations multi-attributs',
  `tenant_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID locataire',
  `delete_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque de suppression, 0 non supprimé, 1 supprimé',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `FK675951272AB6672C`(`category_id`) USING BTREE,
  INDEX `UnitId`(`unit_id`) USING BTREE,
  INDEX `tenant_id`(`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 620 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'Table des produits' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of jsh_material
-- ----------------------------
INSERT INTO `jsh_material` VALUES (568, 17, 'Produit 1', 'Fabricant 1', 'sp1', '', NULL, NULL, '', 'unité', '', NULL, NULL, NULL, NULL, b'1', '', '', '', '0', '0', NULL, NULL, 63, '0');
INSERT INTO `jsh_material` VALUES (569, 17, 'Produit 2', '', 'sp2', '', NULL, NULL, '', 'pièce', '', NULL, NULL, NULL, NULL, b'1', '', '', '', '0', '0', NULL, NULL, 63, '0');
INSERT INTO `jsh_material` VALUES (570, 17, 'Produit 3', '', 'sp3', '', NULL, NULL, '', 'unité', '', NULL, NULL, NULL, NULL, b'1', '', '', '', '0', '0', NULL, NULL, 63, '0');
INSERT INTO `jsh_material` VALUES (577, NULL, 'Produit 8', '', 'sp8', '', NULL, NULL, '', '', '', NULL, 15, NULL, NULL, b'1', '', '', '', '0', '0', NULL, NULL, 63, '0');
INSERT INTO `jsh_material` VALUES (579, 21, 'Produit 17', '', 'sp17', '', NULL, NULL, '', '', '', NULL, 15, NULL, NULL, b'1', '', '', '', '0', '0', NULL, NULL, 63, '0');
INSERT INTO `jsh_material` VALUES (586, 17, 'Test produit numéro série', '', 'xlh123', '', NULL, NULL, '', 'unité', '', NULL, NULL, NULL, NULL, b'1', '', '', '', '1', '0', NULL, NULL, 63, '0');
INSERT INTO `jsh_material` VALUES (587, 17, 'Produit test1', 'Nantong Zhongyuan', '', 'test1', NULL, NULL, '', 'unité', '', NULL, NULL, NULL, NULL, b'1', '', '', '', '0', '0', NULL, NULL, 63, '0');
INSERT INTO `jsh_material` VALUES (588, 21, 'Produit 200', 'fafda', 'weqwe', '300ml', NULL, NULL, 'Rouge', 'unité', 'aaaabbbbb', NULL, NULL, NULL, NULL, b'1', '', '', '', '0', '0', NULL, NULL, 63, '0');
INSERT INTO `jsh_material` VALUES (619, NULL, 'Vêtement', NULL, NULL, NULL, NULL, NULL, NULL, 'article', NULL, '', NULL, NULL, NULL, b'1', NULL, NULL, NULL, '0', '0', NULL, NULL, 63, '0');

-- ----------------------------
-- Table structure for jsh_material_attribute
-- ----------------------------
DROP TABLE IF EXISTS `jsh_material_attribute`;
CREATE TABLE `jsh_material_attribute`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT,
  `attribute_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Nom de l''attribut',
  `attribute_value` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Valeur de l''attribut',
  `tenant_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID locataire',
  `delete_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque de suppression, 0 non supprimé, 1 supprimé',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `tenant_id`(`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'Table des attributs de produit' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of jsh_material_attribute
-- ----------------------------
INSERT INTO `jsh_material_attribute` VALUES (1, 'Multi-couleurs', 'Rouge|Orange|Jaune|Vert|Bleu|Violet', 63, '0');
INSERT INTO `jsh_material_attribute` VALUES (2, 'Multi-tailles', 'S|M|L|XL|XXL|XXXL', 63, '0');
INSERT INTO `jsh_material_attribute` VALUES (3, 'Personnalisé 1', 'Xiaomi|Huawei', 63, '0');
INSERT INTO `jsh_material_attribute` VALUES (4, 'Personnalisé 2', NULL, 63, '0');
INSERT INTO `jsh_material_attribute` VALUES (5, 'Personnalisé 3', NULL, 63, '0');

-- ----------------------------
-- Table structure for jsh_material_category
-- ----------------------------
DROP TABLE IF EXISTS `jsh_material_category`;
CREATE TABLE `jsh_material_category`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'Clé primaire',
  `name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Nom',
  `category_level` smallint(0) NULL DEFAULT NULL COMMENT 'Niveau',
  `parent_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID parent',
  `sort` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Ordre d''affichage',
  `serial_no` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Numéro',
  `remark` varchar(1024) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Remarque',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT 'Date de création',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT 'Date de mise à jour',
  `tenant_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID locataire',
  `delete_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque de suppression, 0 non supprimé, 1 supprimé',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `FK3EE7F725237A77D8`(`parent_id`) USING BTREE,
  INDEX `tenant_id`(`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 29 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'Table des types de produits' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of jsh_material_category
-- ----------------------------
INSERT INTO `jsh_material_category` VALUES (17, 'Répertoire 1', NULL, NULL, '11', 'wae12', 'eee', '2019-04-10 22:18:12', '2021-02-17 15:11:35', 63, '0');
INSERT INTO `jsh_material_category` VALUES (21, 'Répertoire 2', NULL, 17, '22', 'ada112', 'ddd', '2020-07-20 23:08:44', '2020-07-20 23:08:44', 63, '0');

-- ----------------------------
-- Table structure for jsh_material_current_stock
-- ----------------------------
DROP TABLE IF EXISTS `jsh_material_current_stock`;
CREATE TABLE `jsh_material_current_stock`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'Clé primaire',
  `material_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID produit',
  `depot_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID entrepôt',
  `current_number` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Quantité de stock actuelle',
  `current_unit_price` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Prix unitaire actuel',
  `tenant_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID locataire',
  `delete_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque de suppression, 0 non supprimé, 1 supprimé',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `material_id`(`material_id`) USING BTREE,
  INDEX `depot_id`(`depot_id`) USING BTREE,
  INDEX `tenant_id`(`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 26 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'Stock actuel du produit' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of jsh_material_current_stock
-- ----------------------------
INSERT INTO `jsh_material_current_stock` VALUES (19, 588, 14, 7.000000, NULL, 63, '0');
INSERT INTO `jsh_material_current_stock` VALUES (20, 568, 14, 2.000000, NULL, 63, '0');
INSERT INTO `jsh_material_current_stock` VALUES (21, 568, 15, 1.000000, NULL, 63, '0');
INSERT INTO `jsh_material_current_stock` VALUES (22, 570, 14, 8.000000, NULL, 63, '0');
INSERT INTO `jsh_material_current_stock` VALUES (23, 619, 14, 5.000000, NULL, 63, '0');
INSERT INTO `jsh_material_current_stock` VALUES (24, 619, 15, 0.000000, NULL, 63, '0');
INSERT INTO `jsh_material_current_stock` VALUES (25, 619, 17, 0.000000, NULL, 63, '0');

-- ----------------------------
-- Table structure for jsh_material_extend
-- ----------------------------
DROP TABLE IF EXISTS `jsh_material_extend`;
CREATE TABLE `jsh_material_extend`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'Clé primaire',
  `material_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID produit',
  `bar_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Code-barres du produit',
  `commodity_unit` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Unité du produit',
  `sku` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Multi-attributs',
  `purchase_decimal` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Prix d''achat',
  `commodity_decimal` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Prix de détail',
  `wholesale_decimal` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Prix de vente',
  `low_decimal` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Prix de vente minimum',
  `default_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '1' COMMENT 'Unité par défaut, 1 oui, 0 non',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT 'Date de création',
  `create_serial` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Code créateur',
  `update_serial` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Code modificateur',
  `update_time` bigint(0) NULL DEFAULT NULL COMMENT 'Horodatage de mise à jour',
  `tenant_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID locataire',
  `delete_Flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque de suppression, 0 non supprimé, 1 supprimé',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `material_id`(`material_id`) USING BTREE,
  INDEX `bar_code`(`bar_code`) USING BTREE,
  INDEX `tenant_id`(`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 40 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'Extension de prix du produit' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of jsh_material_extend
-- ----------------------------
INSERT INTO `jsh_material_extend` VALUES (1, 587, '1000', 'unité', NULL, 11.000000, 22.000000, 22.000000, 22.000000, '1', '2020-02-20 23:22:03', 'jsh', 'jsh', 1595263657135, 63, '0');
INSERT INTO `jsh_material_extend` VALUES (2, 568, '1001', 'unité', NULL, 11.000000, 15.000000, 15.000000, 15.000000, '1', '2020-02-20 23:44:57', 'jsh', 'jsh', 1595265439418, 63, '0');
INSERT INTO `jsh_material_extend` VALUES (3, 569, '1002', 'pièce', NULL, 10.000000, 15.000000, 15.000000, 13.000000, '1', '2020-02-20 23:45:15', 'jsh', 'jsh', 1582213514731, 63, '0');
INSERT INTO `jsh_material_extend` VALUES (4, 570, '1003', 'unité', NULL, 8.000000, 15.000000, 14.000000, 13.000000, '1', '2020-02-20 23:45:37', 'jsh', 'jsh', 1587657604430, 63, '0');
INSERT INTO `jsh_material_extend` VALUES (5, 577, '1004', 'unité', NULL, 10.000000, 20.000000, 20.000000, 20.000000, '1', '2020-02-20 23:46:36', 'jsh', 'jsh', 1582213596494, 63, '0');
INSERT INTO `jsh_material_extend` VALUES (6, 577, '1005', 'caisse', NULL, 120.000000, 240.000000, 240.000000, 240.000000, '0', '2020-02-20 23:46:36', 'jsh', 'jsh', 1582213596497, 63, '0');
INSERT INTO `jsh_material_extend` VALUES (7, 579, '1006', 'unité', NULL, 20.000000, 30.000000, 30.000000, 30.000000, '1', '2020-02-20 23:47:04', 'jsh', 'jsh', 1595264270458, 63, '0');
INSERT INTO `jsh_material_extend` VALUES (8, 579, '1007', 'caisse', NULL, 240.000000, 360.000000, 360.000000, 360.000000, '0', '2020-02-20 23:47:04', 'jsh', 'jsh', 1595264270466, 63, '0');
INSERT INTO `jsh_material_extend` VALUES (9, 586, '1008', 'unité', NULL, 12.000000, 15.000000, 15.000000, 15.000000, '1', '2020-02-20 23:47:23', 'jsh', 'jsh', 1595254981896, 63, '0');
INSERT INTO `jsh_material_extend` VALUES (10, 588, '1009', 'unité', NULL, 11.000000, 22.000000, 22.000000, 22.000000, '1', '2020-07-21 00:58:15', 'jsh', 'jsh', 1614699799073, 63, '0');
INSERT INTO `jsh_material_extend` VALUES (36, 619, '1014', 'article', 'Orange,M', 12.000000, 15.000000, 14.000000, NULL, '1', '2021-07-28 01:00:20', 'jsh', 'jsh', 1627405220316, 63, '0');
INSERT INTO `jsh_material_extend` VALUES (37, 619, '1015', 'article', 'Orange,L', 12.000000, 15.000000, 14.000000, NULL, '0', '2021-07-28 01:00:20', 'jsh', 'jsh', 1627405220327, 63, '0');
INSERT INTO `jsh_material_extend` VALUES (38, 619, '1016', 'article', 'Vert,M', 12.000000, 15.000000, 14.000000, NULL, '0', '2021-07-28 01:00:20', 'jsh', 'jsh', 1627405220336, 63, '0');
INSERT INTO `jsh_material_extend` VALUES (39, 619, '1017', 'article', 'Vert,L', 12.000000, 15.000000, 14.000000, NULL, '0', '2021-07-28 01:00:20', 'jsh', 'jsh', 1627405220346, 63, '0');

-- ----------------------------
-- Table structure for jsh_material_initial_stock
-- ----------------------------
DROP TABLE IF EXISTS `jsh_material_initial_stock`;
CREATE TABLE `jsh_material_initial_stock`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'Clé primaire',
  `material_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID produit',
  `depot_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID entrepôt',
  `number` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Quantité de stock initial',
  `low_safe_stock` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Quantité de stock minimum',
  `high_safe_stock` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Quantité de stock maximum',
  `tenant_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID locataire',
  `delete_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque de suppression, 0 non supprimé, 1 supprimé',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `material_id`(`material_id`) USING BTREE,
  INDEX `depot_id`(`depot_id`) USING BTREE,
  INDEX `tenant_id`(`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 205 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'Stock initial du produit' ROW_FORMAT = Compact;

-- ----------------------------
-- Table structure for jsh_material_property
-- ----------------------------
DROP TABLE IF EXISTS `jsh_material_property`;
CREATE TABLE `jsh_material_property`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'Clé primaire',
  `native_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Nom original',
  `enabled` bit(1) NULL DEFAULT NULL COMMENT 'Activé',
  `sort` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Tri',
  `another_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Alias',
  `tenant_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID locataire',
  `delete_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque de suppression, 0 non supprimé, 1 supprimé',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'Table des champs d''extension de produit' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for jsh_msg
-- ----------------------------
DROP TABLE IF EXISTS `jsh_msg`;
CREATE TABLE `jsh_msg`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'Clé primaire',
  `msg_title` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Titre du message',
  `msg_content` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Contenu du message',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT 'Date de création',
  `type` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Type de message',
  `user_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID destinataire',
  `status` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Statut, 1 non lu, 2 lu',
  `tenant_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID locataire',
  `delete_Flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque de suppression, 0 non supprimé, 1 supprimé',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `tenant_id`(`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'Table des messages' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of jsh_msg
-- ----------------------------
INSERT INTO `jsh_msg` VALUES (2, 'Titre 1', 'Contenu 1', '2019-09-10 00:11:39', 'Type 1', 63, '2', 63, '0');

-- ----------------------------
-- Table structure for jsh_orga_user_rel
-- ----------------------------
DROP TABLE IF EXISTS `jsh_orga_user_rel`;
CREATE TABLE `jsh_orga_user_rel`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'Clé primaire',
  `orga_id` bigint(0) NOT NULL COMMENT 'ID organisation',
  `user_id` bigint(0) NOT NULL COMMENT 'ID utilisateur',
  `user_blng_orga_dspl_seq` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Ordre d''affichage de l''utilisateur dans l''organisation',
  `delete_flag` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque de suppression, 0 non supprimé, 1 supprimé',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT 'Date de création',
  `creator` bigint(0) NULL DEFAULT NULL COMMENT 'Créateur',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT 'Date de mise à jour',
  `updater` bigint(0) NULL DEFAULT NULL COMMENT 'Modificateur',
  `tenant_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID locataire',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `orga_id`(`orga_id`) USING BTREE,
  INDEX `user_id`(`user_id`) USING BTREE,
  INDEX `creator`(`creator`) USING BTREE,
  INDEX `tenant_id`(`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'Table de relation organisation-utilisateur' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of jsh_orga_user_rel
-- ----------------------------
INSERT INTO `jsh_orga_user_rel` VALUES (10, 13, 131, '2', '0', '2019-12-28 12:13:15', 63, '2021-03-18 22:33:19', 63, 63);
INSERT INTO `jsh_orga_user_rel` VALUES (11, 12, 63, '15', '0', '2020-09-13 18:42:45', 63, '2021-03-19 00:11:40', 63, 63);
INSERT INTO `jsh_orga_user_rel` VALUES (12, 13, 135, '9', '0', '2021-03-18 22:24:25', 63, '2021-03-19 00:09:23', 63, 63);
INSERT INTO `jsh_orga_user_rel` VALUES (13, 13, 134, '1', '0', '2021-03-18 22:31:39', 63, '2021-03-18 23:59:55', 63, 63);
INSERT INTO `jsh_orga_user_rel` VALUES (14, 22, 133, '22', '0', '2021-03-18 22:31:44', 63, '2021-03-18 22:32:04', 63, 63);
INSERT INTO `jsh_orga_user_rel` VALUES (15, 12, 144, NULL, '0', '2021-03-19 00:00:40', 63, '2021-03-19 00:08:07', 63, 63);
INSERT INTO `jsh_orga_user_rel` VALUES (16, 12, 145, NULL, '0', '2021-03-19 00:03:44', 63, '2021-03-19 00:03:44', 63, 63);

-- ----------------------------
-- Table structure for jsh_organization
-- ----------------------------
DROP TABLE IF EXISTS `jsh_organization`;
CREATE TABLE `jsh_organization`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'Clé primaire',
  `org_no` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Numéro d''organisation',
  `org_abr` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Abréviation de l''organisation',
  `parent_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID organisation parente',
  `sort` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Ordre d''affichage de l''organisation',
  `remark` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Remarque',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT 'Date de création',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT 'Date de mise à jour',
  `tenant_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID locataire',
  `delete_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque de suppression, 0 non supprimé, 1 supprimé',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `tenant_id`(`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 24 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'Table des organisations' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of jsh_organization
-- ----------------------------
INSERT INTO `jsh_organization` VALUES (12, '001', 'Organisation test', NULL, '2', 'aaaa2', '2019-12-28 12:13:01', '2019-12-28 12:13:01', 63, '0');
INSERT INTO `jsh_organization` VALUES (13, 'jg1', 'Organisation 1', 12, '3', '', '2020-07-21 00:09:57', '2020-07-21 00:10:22', 63, '0');
INSERT INTO `jsh_organization` VALUES (14, '12', 'Organisation 2', 13, '4', '', '2020-07-21 22:45:42', '2021-02-15 22:18:30', 63, '0');

-- ----------------------------
-- Table structure for jsh_person
-- ----------------------------
DROP TABLE IF EXISTS `jsh_person`;
CREATE TABLE `jsh_person`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'Clé primaire',
  `type` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Type',
  `name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Nom',
  `enabled` bit(1) NULL DEFAULT NULL COMMENT 'Activé',
  `sort` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Tri',
  `tenant_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID locataire',
  `delete_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque de suppression, 0 non supprimé, 1 supprimé',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `tenant_id`(`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 18 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'Table des personnes responsables' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of jsh_person
-- ----------------------------
INSERT INTO `jsh_person` VALUES (14, 'Vendeur', 'Xiao Li', b'1', NULL, 63, '0');
INSERT INTO `jsh_person` VALUES (15, 'Gestionnaire d''entrepôt', 'Xiao Jun', b'1', NULL, 63, '0');
INSERT INTO `jsh_person` VALUES (16, 'Comptable', 'Xiao Xia', b'1', NULL, 63, '0');
INSERT INTO `jsh_person` VALUES (17, 'Comptable', 'Xiao Cao', b'1', NULL, 63, '0');

-- ----------------------------
-- Table structure for jsh_platform_config
-- ----------------------------
DROP TABLE IF EXISTS `jsh_platform_config`;
CREATE TABLE `jsh_platform_config`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT,
  `platform_key` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Mot-clé',
  `platform_key_info` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Nom du mot-clé',
  `platform_value` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Valeur',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 23 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'Paramètres de la plateforme' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of jsh_platform_config
-- ----------------------------
INSERT INTO `jsh_platform_config` VALUES (1, 'platform_name', 'Nom de la plateforme', 'Guan Yijia ERP');
INSERT INTO `jsh_platform_config` VALUES (2, 'activation_code', 'Code d''activation', '');
INSERT INTO `jsh_platform_config` VALUES (3, 'platform_url', 'Site web officiel', 'http://www.gyjerp.com/');
INSERT INTO `jsh_platform_config` VALUES (4, 'bill_print_flag', 'Marque d''activation impression triple', '0');
INSERT INTO `jsh_platform_config` VALUES (5, 'bill_print_url', 'Adresse impression triple', '');
INSERT INTO `jsh_platform_config` VALUES (6, 'pay_fee_url', 'Adresse renouvellement locataire', '');
INSERT INTO `jsh_platform_config` VALUES (7, 'register_flag', 'Marque d''activation inscription', '1');
INSERT INTO `jsh_platform_config` VALUES (8, 'app_activation_code', 'Code d''activation mobile', '');
INSERT INTO `jsh_platform_config` VALUES (9, 'send_workflow_url', 'Adresse démarrage processus', '');
INSERT INTO `jsh_platform_config` VALUES (10, 'weixinUrl', 'URL WeChat', '');
INSERT INTO `jsh_platform_config` VALUES (11, 'weixinAppid', 'AppID WeChat', '');
INSERT INTO `jsh_platform_config` VALUES (12, 'weixinSecret', 'Secret WeChat', '');
INSERT INTO `jsh_platform_config` VALUES (13, 'aliOss_endpoint', 'Endpoint OSS Alibaba', '');
INSERT INTO `jsh_platform_config` VALUES (14, 'aliOss_accessKeyId', 'AccessKeyId OSS Alibaba', '');
INSERT INTO `jsh_platform_config` VALUES (15, 'aliOss_accessKeySecret', 'AccessKeySecret OSS Alibaba', '');
INSERT INTO `jsh_platform_config` VALUES (16, 'aliOss_bucketName', 'BucketName OSS Alibaba', '');
INSERT INTO `jsh_platform_config` VALUES (17, 'aliOss_linkUrl', 'LinkUrl OSS Alibaba', '');
INSERT INTO `jsh_platform_config` VALUES (18, 'bill_excel_url', 'Adresse Excel document', '');
INSERT INTO `jsh_platform_config` VALUES (19, 'email_from', 'Expéditeur email', '');
INSERT INTO `jsh_platform_config` VALUES (20, 'email_auth_code', 'Code d''autorisation email', '');
INSERT INTO `jsh_platform_config` VALUES (21, 'email_smtp_host', 'Serveur SMTP email', '');
INSERT INTO `jsh_platform_config` VALUES (22, 'checkcode_flag', 'Marque d''activation code de vérification', '1');

-- ----------------------------
-- Table structure for jsh_role
-- ----------------------------
DROP TABLE IF EXISTS `jsh_role`;
CREATE TABLE `jsh_role`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'Clé primaire',
  `name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Nom',
  `type` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Type',
  `price_limit` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Masquage de prix 1-masquer prix d''achat 2-masquer prix de détail 3-masquer prix de vente',
  `value` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Valeur',
  `description` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Description',
  `enabled` bit(1) NULL DEFAULT NULL COMMENT 'Activé',
  `sort` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Tri',
  `tenant_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID locataire',
  `delete_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque de suppression, 0 non supprimé, 1 supprimé',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `tenant_id`(`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 21 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'Table des rôles' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of jsh_role
-- ----------------------------
INSERT INTO `jsh_role` VALUES (4, 'Administrateur', 'Toutes les données', NULL, NULL, NULL, b'1', NULL, NULL, '0');
INSERT INTO `jsh_role` VALUES (10, 'Locataire', 'Toutes les données', NULL, NULL, '', b'1', NULL, NULL, '0');
INSERT INTO `jsh_role` VALUES (16, 'Manager commercial', 'Toutes les données', NULL, NULL, 'ddd', b'1', NULL, 63, '0');
INSERT INTO `jsh_role` VALUES (17, 'Représentant commercial', 'Données personnelles', NULL, NULL, 'rrr', b'1', NULL, 63, '0');

-- ----------------------------
-- Table structure for jsh_sequence
-- ----------------------------
DROP TABLE IF EXISTS `jsh_sequence`;
CREATE TABLE `jsh_sequence`  (
  `seq_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'Nom de la séquence',
  `min_value` bigint(0) NOT NULL COMMENT 'Valeur minimum',
  `max_value` bigint(0) NOT NULL COMMENT 'Valeur maximum',
  `current_val` bigint(0) NOT NULL COMMENT 'Valeur actuelle',
  `increment_val` int(0) NOT NULL DEFAULT 1 COMMENT 'Incrément',
  `remark` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Remarque',
  PRIMARY KEY (`seq_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'Table des numéros de documents' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of jsh_sequence
-- ----------------------------
INSERT INTO `jsh_sequence` VALUES ('depot_number_seq', 1, 999999999999999999, 672, 1, 'Séquence numéro document');

-- ----------------------------
-- Table structure for jsh_serial_number
-- ----------------------------
DROP TABLE IF EXISTS `jsh_serial_number`;
CREATE TABLE `jsh_serial_number`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'Clé primaire',
  `material_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID table produit',
  `depot_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID entrepôt',
  `serial_number` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Numéro de série',
  `is_sell` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Vendu, 0 non vendu, 1 vendu',
  `in_price` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Prix unitaire d''entrée',
  `remark` varchar(1024) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Remarque',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT 'Date de création',
  `creator` bigint(0) NULL DEFAULT NULL COMMENT 'Créateur',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT 'Date de mise à jour',
  `updater` bigint(0) NULL DEFAULT NULL COMMENT 'Modificateur',
  `in_bill_no` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Numéro de document d''entrée',
  `out_bill_no` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Numéro de document de sortie',
  `tenant_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID locataire',
  `delete_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque de suppression, 0 non supprimé, 1 supprimé',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `material_id`(`material_id`) USING BTREE,
  INDEX `depot_id`(`depot_id`) USING BTREE,
  INDEX `tenant_id`(`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 110 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'Table des numéros de série' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for jsh_supplier
-- ----------------------------
DROP TABLE IF EXISTS `jsh_supplier`;
CREATE TABLE `jsh_supplier`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'Clé primaire',
  `supplier` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'Nom du fournisseur',
  `contacts` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Contact',
  `phone_num` varchar(30) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Téléphone',
  `email` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Email',
  `description` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Remarque',
  `isystem` tinyint(0) NULL DEFAULT NULL COMMENT 'Système intégré 0==système 1==non système',
  `type` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Type',
  `enabled` bit(1) NULL DEFAULT NULL COMMENT 'Activé',
  `advance_in` decimal(24, 6) NULL DEFAULT 0.000000 COMMENT 'Prérecette',
  `begin_need_get` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Créance initiale à recevoir',
  `begin_need_pay` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Dette initiale à payer',
  `all_need_get` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Créance cumulative à recevoir',
  `all_need_pay` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Dette cumulative à payer',
  `fax` varchar(30) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Fax',
  `telephone` varchar(30) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Téléphone portable',
  `address` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Adresse',
  `tax_num` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Numéro d''identification fiscale',
  `bank_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Banque',
  `account_number` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Numéro de compte',
  `tax_rate` decimal(24, 6) NULL DEFAULT NULL COMMENT 'Taux de taxe',
  `sort` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Tri',
  `creator` bigint(0) NULL DEFAULT NULL COMMENT 'Opérateur',
  `tenant_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID locataire',
  `delete_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque de suppression, 0 non supprimé, 1 supprimé',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `type`(`type`) USING BTREE,
  INDEX `tenant_id`(`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 90 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'Table des informations fournisseur/client' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of jsh_supplier
-- ----------------------------
INSERT INTO `jsh_supplier` VALUES (57, 'Fournisseur 1', 'Xiao Jun', '12345678', '', '', NULL, 'Fournisseur', b'1', 0.000000, 0.000000, 0.000000, 0.000000, 4.000000, '', '15000000000', 'Adresse 1', '', '', '', 12.000000, NULL, 63, 63, '0');
INSERT INTO `jsh_supplier` VALUES (58, 'Client 1', 'Xiao Li', '12345678', '', '', NULL, 'Client', b'1', 0.000000, 0.000000, 0.000000, -100.000000, NULL, '', '', '', '', '', '', 12.000000, NULL, 63, 63, '0');
INSERT INTO `jsh_supplier` VALUES (59, 'Client 2', 'Xiao Chen', '', '', '', NULL, 'Client', b'1', 0.000000, 0.000000, 0.000000, 0.000000, NULL, '', '', '', '', '', '', NULL, NULL, 63, 63, '0');
INSERT INTO `jsh_supplier` VALUES (60, '12312666', 'Xiao Cao', '', '', '', NULL, 'Membre', b'1', 970.000000, 0.000000, 0.000000, NULL, NULL, '', '13000000000', '', '', '', '', NULL, NULL, 63, 63, '0');
INSERT INTO `jsh_supplier` VALUES (68, 'Fournisseur 3', 'Xiao Li', '12345678', '', 'fasdfadf', NULL, 'Fournisseur', b'1', 0.000000, 0.000000, 0.000000, 0.000000, -35.000000, '', '13000000000', 'aaaa', '1341324', '', '', 13.000000, NULL, 63, 63, '0');
INSERT INTO `jsh_supplier` VALUES (71, 'Client 3', 'Xiao Zhou', '', '', '', NULL, 'Client', b'1', 0.000000, 0.000000, 0.000000, 0.000000, NULL, '', '', '', '', '', '', NULL, NULL, 63, 63, '0');
INSERT INTO `jsh_supplier` VALUES (74, 'Fournisseur 5', 'Xiao Ji', '77779999', '', '', NULL, 'Fournisseur', b'1', 0.000000, 0.000000, 5.000000, 0.000000, 5.000000, '', '15806283912', '', '', '', '', 3.000000, NULL, 63, 63, '0');

-- ----------------------------
-- Table structure for jsh_system_config
-- ----------------------------
DROP TABLE IF EXISTS `jsh_system_config`;
CREATE TABLE `jsh_system_config`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'Clé primaire',
  `company_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Nom de l''entreprise',
  `company_contacts` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Contact de l''entreprise',
  `company_address` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Adresse de l''entreprise',
  `company_tel` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Téléphone de l''entreprise',
  `company_fax` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Fax de l''entreprise',
  `company_post_code` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Code postal de l''entreprise',
  `sale_agreement` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Accord de vente',
  `depot_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque d''activation entrepôt, 0 non activé, 1 activé',
  `customer_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque d''activation client, 0 non activé, 1 activé',
  `minus_stock_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque d''activation stock négatif, 0 non activé, 1 activé',
  `purchase_by_sale_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque d''activation achat basé sur vente, 0 non activé, 1 activé',
  `multi_level_approval_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque d''activation approbation multi-niveaux, 0 non activé, 1 activé',
  `multi_bill_type` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Type de processus, sélection multiple possible',
  `force_approval_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque d''activation approbation forcée, 0 non activé, 1 activé',
  `update_unit_price_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '1' COMMENT 'Marque d''activation mise à jour prix unitaire, 0 non activé, 1 activé',
  `over_link_bill_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque d''activation dépassement document associé, 0 non activé, 1 activé',
  `in_out_manage_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque d''activation gestion entrée/sortie, 0 non activé, 1 activé',
  `multi_account_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque d''activation multi-comptes, 0 non activé, 1 activé',
  `move_avg_price_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque d''activation prix moyen mobile, 0 non activé, 1 activé',
  `audit_print_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque d''activation approbation avant impression, 0 non activé, 1 activé',
  `zero_change_amount_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque d''activation recette/paiement zéro, 0 non activé, 1 activé',
  `customer_static_price_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque d''activation prix unitaire statique client, 0 non activé, 1 activé',
  `tenant_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID locataire',
  `delete_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque de suppression, 0 non supprimé, 1 supprimé',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'Paramètres système' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of jsh_system_config
-- ----------------------------
INSERT INTO `jsh_system_config` VALUES (11, 'Entreprise test', 'Xiao Li', 'Adresse 1', '12345678', NULL, NULL, 'Note : Ce document sert de base pour le règlement dans le délai convenu entre notre entreprise et le client, prend effet après signature par le client ou son employé, et engage la responsabilité légale.', '0', '0', '1', '0', '0', '', '0', '1', '0', '0', '0', '0', '0', '0', '0', 63, '0');

-- ----------------------------
-- Table structure for jsh_tenant
-- ----------------------------
DROP TABLE IF EXISTS `jsh_tenant`;
CREATE TABLE `jsh_tenant`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'Clé primaire',
  `tenant_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID utilisateur',
  `login_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Nom de connexion',
  `user_num_limit` int(0) NULL DEFAULT NULL COMMENT 'Limite du nombre d''utilisateurs',
  `type` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Type de locataire, 0 locataire gratuit, 1 locataire payant',
  `enabled` bit(1) NULL DEFAULT b'1' COMMENT 'Activé 0-désactivé 1-activé',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT 'Date de création',
  `expire_time` datetime(0) NULL DEFAULT NULL COMMENT 'Date d''expiration',
  `remark` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Remarque',
  `delete_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque de suppression, 0 non supprimé, 1 supprimé',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `create_time`(`create_time`) USING BTREE,
  INDEX `tenant_id`(`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'Locataire' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of jsh_tenant
-- ----------------------------
INSERT INTO `jsh_tenant` VALUES (13, 63, 'jsh', 2000, '1', b'1', '2021-02-17 23:19:17', '2099-02-17 23:19:17', NULL, '0');

-- ----------------------------
-- Table structure for jsh_unit
-- ----------------------------
DROP TABLE IF EXISTS `jsh_unit`;
CREATE TABLE `jsh_unit`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'Clé primaire',
  `name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Nom, support multi-unités',
  `basic_unit` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Unité de base',
  `other_unit` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Unité secondaire',
  `other_unit_two` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Unité secondaire 2',
  `other_unit_three` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Unité secondaire 3',
  `ratio` decimal(24, 3) NULL DEFAULT NULL COMMENT 'Ratio',
  `ratio_two` decimal(24, 3) NULL DEFAULT NULL COMMENT 'Ratio 2',
  `ratio_three` decimal(24, 3) NULL DEFAULT NULL COMMENT 'Ratio 3',
  `enabled` bit(1) NULL DEFAULT NULL COMMENT 'Activé',
  `tenant_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID locataire',
  `delete_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque de suppression, 0 non supprimé, 1 supprimé',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 22 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'Table multi-unités' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of jsh_unit
-- ----------------------------
INSERT INTO `jsh_unit` VALUES (15, 'unité/(caisse=12 unités)', 'unité', 'caisse', NULL, NULL, 12.000, NULL, NULL, b'1', 63, '0');
INSERT INTO `jsh_unit` VALUES (19, 'unité/(boîte=15 unités)', 'unité', 'boîte', NULL, NULL, 15.000, NULL, NULL, b'1', 63, '0');
INSERT INTO `jsh_unit` VALUES (20, 'boîte/(caisse=8 boîtes)', 'boîte', 'caisse', NULL, NULL, 8.000, NULL, NULL, b'1', 63, '0');
INSERT INTO `jsh_unit` VALUES (21, 'bouteille/(caisse=12 bouteilles)', 'bouteille', 'caisse', NULL, NULL, 12.000, NULL, NULL, b'1', 63, '0');

-- ----------------------------
-- Table structure for jsh_user
-- ----------------------------
DROP TABLE IF EXISTS `jsh_user`;
CREATE TABLE `jsh_user`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'Clé primaire',
  `username` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'Nom de l''utilisateur - ex. Zhang San',
  `login_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'Nom d''utilisateur de connexion',
  `password` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Mot de passe de connexion',
  `leader_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Manager, 0 non, 1 oui',
  `position` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Poste',
  `department` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Département',
  `email` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Email',
  `phonenum` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Numéro de téléphone portable',
  `ismanager` tinyint(0) NOT NULL DEFAULT 1 COMMENT 'Manager 0==manager 1==employé',
  `isystem` tinyint(0) NOT NULL DEFAULT 0 COMMENT 'Données système intégrées',
  `status` tinyint(0) NULL DEFAULT 0 COMMENT 'Statut, 0 normal, 2 banni',
  `description` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Informations de description utilisateur',
  `remark` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Remarque',
  `weixin_open_id` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Liaison WeChat',
  `tenant_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID locataire',
  `delete_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque de suppression, 0 non supprimé, 1 supprimé',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 146 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'Table des utilisateurs' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of jsh_user
-- ----------------------------
INSERT INTO `jsh_user` VALUES (63, 'Utilisateur test', 'jsh', 'e10adc3949ba59abbe56e057f20f883e', '0', 'Superviseur', NULL, '666666@qq.com', '1123123123132', 1, 1, 0, '', NULL, NULL, 63, '0');
INSERT INTO `jsh_user` VALUES (120, 'Administrateur', 'admin', 'e10adc3949ba59abbe56e057f20f883e', '0', NULL, NULL, NULL, NULL, 1, 0, 0, NULL, NULL, NULL, 0, '0');
INSERT INTO `jsh_user` VALUES (131, 'test123', 'test123', 'e10adc3949ba59abbe56e057f20f883e', '0', 'Directeur', NULL, '7777777@qq.com', '', 1, 0, 0, '', NULL, NULL, 63, '0');

-- ----------------------------
-- Table structure for jsh_user_business
-- ----------------------------
DROP TABLE IF EXISTS `jsh_user_business`;
CREATE TABLE `jsh_user_business`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'Clé primaire',
  `type` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Catégorie',
  `key_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'ID principal',
  `value` varchar(10000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Valeur',
  `btn_str` varchar(2000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Permissions des boutons',
  `tenant_id` bigint(0) NULL DEFAULT NULL COMMENT 'ID locataire',
  `delete_flag` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT 'Marque de suppression, 0 non supprimé, 1 supprimé',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `type`(`type`) USING BTREE,
  INDEX `key_id`(`key_id`) USING BTREE,
  INDEX `tenant_id`(`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 83 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'Table de relation utilisateur/rôle/module' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of jsh_user_business
-- ----------------------------
INSERT INTO `jsh_user_business` VALUES (5, 'RoleFunctions', '4', '[210][225][211][241][33][199][242][38][41][200][201][239][202][40][232][233][197][44][203][204][205][206][212][246][198][207][259][208][209][226][227][248][228][229][59][235][237][244][22][21][23][220][247][25][24][217][218][26][194][195][31][13][1][14][243][15][234][16][18][236][245][258][261][32]', '[{\"funId\":13,\"btnStr\":\"1\"},{\"funId\":14,\"btnStr\":\"1\"},{\"funId\":243,\"btnStr\":\"1\"},{\"funId\":234,\"btnStr\":\"1\"},{\"funId\":16,\"btnStr\":\"1\"},{\"funId\":18,\"btnStr\":\"1\"},{\"funId\":236,\"btnStr\":\"1\"},{\"funId\":245,\"btnStr\":\"1\"},{\"funId\":22,\"btnStr\":\"1\"},{\"funId\":23,\"btnStr\":\"1,3\"},{\"funId\":220,\"btnStr\":\"1\"},{\"funId\":247,\"btnStr\":\"1\"},{\"funId\":25,\"btnStr\":\"1,3\"},{\"funId\":217,\"btnStr\":\"1,3\"},{\"funId\":218,\"btnStr\":\"1,3\"},{\"funId\":26,\"btnStr\":\"1\"},{\"funId\":194,\"btnStr\":\"1\"},{\"funId\":195,\"btnStr\":\"1\"},{\"funId\":31,\"btnStr\":\"1\"},{\"funId\":261,\"btnStr\":\"1,2,7,3\"},{\"funId\":241,\"btnStr\":\"1,2,7,3\"},{\"funId\":33,\"btnStr\":\"1,2,7,3\"},{\"funId\":199,\"btnStr\":\"1,2,7,3\"},{\"funId\":242,\"btnStr\":\"1,2,7,3\"},{\"funId\":41,\"btnStr\":\"1,2,7,3\"},{\"funId\":200,\"btnStr\":\"1,2,7,3\"},{\"funId\":210,\"btnStr\":\"1,2,7,3\"},{\"funId\":211,\"btnStr\":\"1,2,7,3\"},{\"funId\":197,\"btnStr\":\"1,7,2,3\"},{\"funId\":203,\"btnStr\":\"1,7,2,3\"},{\"funId\":204,\"btnStr\":\"1,7,2,3\"},{\"funId\":205,\"btnStr\":\"1,7,2,3\"},{\"funId\":206,\"btnStr\":\"1,2,7,3\"},{\"funId\":212,\"btnStr\":\"1,7,2,3\"},{\"funId\":201,\"btnStr\":\"1,2,7,3\"},{\"funId\":202,\"btnStr\":\"1,2,7,3\"},{\"funId\":40,\"btnStr\":\"1,2,7,3\"},{\"funId\":232,\"btnStr\":\"1,2,7,3\"},{\"funId\":233,\"btnStr\":\"1,2,7,3\"}]', NULL, '0');
INSERT INTO `jsh_user_business` VALUES (6, 'RoleFunctions', '5', '[22][23][25][26][194][195][31][33][200][201][41][199][202]', NULL, NULL, '0');
INSERT INTO `jsh_user_business` VALUES (7, 'RoleFunctions', '6', '[22][23][220][240][25][217][218][26][194][195][31][59][207][208][209][226][227][228][229][235][237][210][211][241][33][199][242][41][200][201][202][40][232][233][197][203][204][205][206][212]', '[{\"funId\":\"33\",\"btnStr\":\"4\"}]', NULL, '0');
INSERT INTO `jsh_user_business` VALUES (9, 'RoleFunctions', '7', '[168][13][12][16][14][15][189][18][19][132]', NULL, NULL, '0');
INSERT INTO `jsh_user_business` VALUES (10, 'RoleFunctions', '8', '[168][13][12][16][14][15][189][18][19][132][22][23][25][26][27][157][158][155][156][125][31][127][126][128][33][34][35][36][37][39][40][41][42][43][46][47][48][49][50][51][52][53][54][55][56][57][192][59][60][61][62][63][65][66][68][69][70][71][73][74][76][77][79][191][81][82][83][85][89][161][86][176][165][160][28][134][91][92][29][94][95][97][104][99][100][101][102][105][107][108][110][111][113][114][116][117][118][120][121][131][135][123][122][20][130][146][147][138][148][149][153][140][145][184][152][143][170][171][169][166][167][163][164][172][173][179][178][181][182][183][186][187][247]', NULL, NULL, '0');
INSERT INTO `jsh_user_business` VALUES (11, 'RoleFunctions', '9', '[168][13][12][16][14][15][189][18][19][132][22][23][25][26][27][157][158][155][156][125][31][127][126][128][33][34][35][36][37][39][40][41][42][43][46][47][48][49][50][51][52][53][54][55][56][57][192][59][60][61][62][63][65][66][68][69][70][71][73][74][76][77][79][191][81][82][83][85][89][161][86][176][165][160][28][134][91][92][29][94][95][97][104][99][100][101][102][105][107][108][110][111][113][114][116][117][118][120][121][131][135][123][122][20][130][146][147][138][148][149][153][140][145][184][152][143][170][171][169][166][167][163][164][172][173][179][178][181][182][183][186][187][188]', NULL, NULL, '0');
INSERT INTO `jsh_user_business` VALUES (12, 'UserRole', '1', '[5]', NULL, NULL, '0');
INSERT INTO `jsh_user_business` VALUES (13, 'UserRole', '2', '[6][7]', NULL, NULL, '0');
INSERT INTO `jsh_user_business` VALUES (14, 'UserDepot', '2', '[1][2][6][7]', NULL, NULL, '0');
INSERT INTO `jsh_user_business` VALUES (15, 'UserDepot', '1', '[1][2][5][6][7][10][12][14][15][17]', NULL, NULL, '0');
INSERT INTO `jsh_user_business` VALUES (16, 'UserRole', '63', '[10]', NULL, 63, '0');
INSERT INTO `jsh_user_business` VALUES (18, 'UserDepot', '63', '[14][15]', NULL, 63, '0');
INSERT INTO `jsh_user_business` VALUES (19, 'UserDepot', '5', '[6][45][46][50]', NULL, NULL, '0');
INSERT INTO `jsh_user_business` VALUES (20, 'UserRole', '5', '[5]', NULL, NULL, '0');
INSERT INTO `jsh_user_business` VALUES (21, 'UserRole', '64', '[13]', NULL, NULL, '0');
INSERT INTO `jsh_user_business` VALUES (22, 'UserDepot', '64', '[1]', NULL, NULL, '0');
INSERT INTO `jsh_user_business` VALUES (23, 'UserRole', '65', '[5]', NULL, NULL, '0');
INSERT INTO `jsh_user_business` VALUES (24, 'UserDepot', '65', '[1]', NULL, NULL, '0');
INSERT INTO `jsh_user_business` VALUES (25, 'UserCustomer', '64', '[5][2]', NULL, NULL, '0');
INSERT INTO `jsh_user_business` VALUES (26, 'UserCustomer', '65', '[6]', NULL, NULL, '0');
INSERT INTO `jsh_user_business` VALUES (27, 'UserCustomer', '63', '[58]', NULL, 63, '0');
INSERT INTO `jsh_user_business` VALUES (28, 'UserDepot', '96', '[7]', NULL, NULL, '0');
INSERT INTO `jsh_user_business` VALUES (29, 'UserRole', '96', '[6]', NULL, NULL, '0');
INSERT INTO `jsh_user_business` VALUES (30, 'UserRole', '113', '[10]', NULL, NULL, '0');
INSERT INTO `jsh_user_business` VALUES (32, 'RoleFunctions', '10', '[210][225][211][261][32][241][33][199][242][38][41][200][201][239][202][40][232][233][197][44][203][204][205][206][212][246][198][207][259][208][209][226][227][248][228][229][59][235][237][244][22][21][23][220][247][25][24][217][218][26][194][195][31][13][14][243][15][234][236]', '[{\"funId\":13,\"btnStr\":\"1\"},{\"funId\":14,\"btnStr\":\"1\"},{\"funId\":243,\"btnStr\":\"1\"},{\"funId\":234,\"btnStr\":\"1\"},{\"funId\":236,\"btnStr\":\"1\"},{\"funId\":22,\"btnStr\":\"1\"},{\"funId\":23,\"btnStr\":\"1,3\"},{\"funId\":220,\"btnStr\":\"1\"},{\"funId\":247,\"btnStr\":\"1\"},{\"funId\":25,\"btnStr\":\"1,3\"},{\"funId\":217,\"btnStr\":\"1,3\"},{\"funId\":218,\"btnStr\":\"1,3\"},{\"funId\":26,\"btnStr\":\"1\"},{\"funId\":194,\"btnStr\":\"1\"},{\"funId\":195,\"btnStr\":\"1\"},{\"funId\":31,\"btnStr\":\"1\"},{\"funId\":261,\"btnStr\":\"1,2,7,3\"},{\"funId\":241,\"btnStr\":\"1,2,7,3\"},{\"funId\":33,\"btnStr\":\"1,2,7,3\"},{\"funId\":199,\"btnStr\":\"1,7,2,3\"},{\"funId\":242,\"btnStr\":\"1,2,7,3\"},{\"funId\":41,\"btnStr\":\"1,2,7,3\"},{\"funId\":200,\"btnStr\":\"1,2,7,3\"},{\"funId\":210,\"btnStr\":\"1,2,7,3\"},{\"funId\":211,\"btnStr\":\"1,2,7,3\"},{\"funId\":197,\"btnStr\":\"1,2,7,3\"},{\"funId\":203,\"btnStr\":\"1,7,2,3\"},{\"funId\":204,\"btnStr\":\"1,7,2,3\"},{\"funId\":205,\"btnStr\":\"1,2,7,3\"},{\"funId\":206,\"btnStr\":\"1,7,2,3\"},{\"funId\":212,\"btnStr\":\"1,2,7,3\"},{\"funId\":201,\"btnStr\":\"1,2,7,3\"},{\"funId\":202,\"btnStr\":\"1,2,7,3\"},{\"funId\":40,\"btnStr\":\"1,2,7,3\"},{\"funId\":232,\"btnStr\":\"1,2,7,3\"},{\"funId\":233,\"btnStr\":\"1,2,7,3\"}]', NULL, '0');
INSERT INTO `jsh_user_business` VALUES (34, 'UserRole', '115', '[10]', NULL, NULL, '0');
INSERT INTO `jsh_user_business` VALUES (35, 'UserRole', '117', '[10]', NULL, NULL, '0');
INSERT INTO `jsh_user_business` VALUES (36, 'UserDepot', '117', '[8][9]', NULL, NULL, '0');
INSERT INTO `jsh_user_business` VALUES (37, 'UserCustomer', '117', '[52]', NULL, NULL, '0');
INSERT INTO `jsh_user_business` VALUES (38, 'UserRole', '120', '[4]', NULL, NULL, '0');
INSERT INTO `jsh_user_business` VALUES (41, 'RoleFunctions', '12', '', NULL, NULL, '0');
INSERT INTO `jsh_user_business` VALUES (48, 'RoleFunctions', '13', '[59][207][208][209][226][227][228][229][235][237][210][211][241][33][199][242][41][200]', NULL, NULL, '0');
INSERT INTO `jsh_user_business` VALUES (51, 'UserRole', '74', '[10]', NULL, NULL, '0');
INSERT INTO `jsh_user_business` VALUES (52, 'UserDepot', '121', '[13]', NULL, NULL, '0');
INSERT INTO `jsh_user_business` VALUES (54, 'UserDepot', '115', '[13]', NULL, NULL, '0');
INSERT INTO `jsh_user_business` VALUES (56, 'UserCustomer', '115', '[56]', NULL, NULL, '0');
INSERT INTO `jsh_user_business` VALUES (57, 'UserCustomer', '121', '[56]', NULL, NULL, '0');
INSERT INTO `jsh_user_business` VALUES (67, 'UserRole', '131', '[17]', NULL, 63, '0');
INSERT INTO `jsh_user_business` VALUES (68, 'RoleFunctions', '16', '[210]', NULL, 63, '0');
INSERT INTO `jsh_user_business` VALUES (69, 'RoleFunctions', '17', '[210][225][211][241][32][33][199][242][38][41][200][201][239][202][40][232][233][197][44][203][204][205][206][212]', '[{\"funId\":\"241\",\"btnStr\":\"1,2\"},{\"funId\":\"33\",\"btnStr\":\"1,2\"},{\"funId\":\"199\",\"btnStr\":\"1,2\"},{\"funId\":\"242\",\"btnStr\":\"1,2\"},{\"funId\":\"41\",\"btnStr\":\"1,2\"},{\"funId\":\"200\",\"btnStr\":\"1,2\"},{\"funId\":\"210\",\"btnStr\":\"1,2\"},{\"funId\":\"211\",\"btnStr\":\"1,2\"},{\"funId\":\"197\",\"btnStr\":\"1\"},{\"funId\":\"203\",\"btnStr\":\"1\"},{\"funId\":\"204\",\"btnStr\":\"1\"},{\"funId\":\"205\",\"btnStr\":\"1\"},{\"funId\":\"206\",\"btnStr\":\"1\"},{\"funId\":\"212\",\"btnStr\":\"1\"},{\"funId\":\"201\",\"btnStr\":\"1,2\"},{\"funId\":\"202\",\"btnStr\":\"1,2\"},{\"funId\":\"40\",\"btnStr\":\"1,2\"},{\"funId\":\"232\",\"btnStr\":\"1,2\"},{\"funId\":\"233\",\"btnStr\":\"1,2\"}]', 63, '0');

SET FOREIGN_KEY_CHECKS = 1;

-- ----------------------------
-- Migration: Traduction des types de documents du chinois vers le français
-- Date: 2025-11-05
-- Description: Met à jour les valeurs de sub_type et type dans la table jsh_depot_head
-- ----------------------------

-- Mise à jour des sub_type du chinois vers le français
UPDATE jsh_depot_head SET sub_type = "Demande d'achat" WHERE sub_type = "请购单";
UPDATE jsh_depot_head SET sub_type = "Commande d'achat" WHERE sub_type = "采购订单";
UPDATE jsh_depot_head SET sub_type = "Achat" WHERE sub_type = "采购";
UPDATE jsh_depot_head SET sub_type = "Retour d'achat" WHERE sub_type = "采购退货";
UPDATE jsh_depot_head SET sub_type = "Autre" WHERE sub_type = "其它";
UPDATE jsh_depot_head SET sub_type = "Vente au détail" WHERE sub_type = "零售";
UPDATE jsh_depot_head SET sub_type = "Retour de vente au détail" WHERE sub_type = "零售退货";
UPDATE jsh_depot_head SET sub_type = "Commande de vente" WHERE sub_type = "销售订单";
UPDATE jsh_depot_head SET sub_type = "Vente" WHERE sub_type = "销售";
UPDATE jsh_depot_head SET sub_type = "Retour de vente" WHERE sub_type = "销售退货";
UPDATE jsh_depot_head SET sub_type = "Transfert" WHERE sub_type = "调拨";
UPDATE jsh_depot_head SET sub_type = "Saisie d'inventaire" WHERE sub_type = "盘点录入";
UPDATE jsh_depot_head SET sub_type = "Révision d'inventaire" WHERE sub_type = "盘点复盘";
UPDATE jsh_depot_head SET sub_type = "Bon d'assemblage" WHERE sub_type = "组装单";
UPDATE jsh_depot_head SET sub_type = "Bon de démontage" WHERE sub_type = "拆卸单";

-- Mise à jour des type du chinois vers le français
UPDATE jsh_depot_head SET type = "Entrée" WHERE type = "入库";
UPDATE jsh_depot_head SET type = "Sortie" WHERE type = "出库";
UPDATE jsh_depot_head SET type = "Autre" WHERE type = "其它";

-- Mise à jour des pay_type du chinois vers le français
UPDATE jsh_depot_head SET pay_type = "Paiement comptant" WHERE pay_type = "现付";
UPDATE jsh_depot_head SET pay_type = "Prépaiement" WHERE pay_type = "预付款";