package com.jsh.erp.service;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.jsh.erp.constants.BusinessConstants;
import com.jsh.erp.constants.ExceptionConstants;
import com.jsh.erp.datasource.entities.*;
import com.jsh.erp.datasource.mappers.*;
import com.jsh.erp.datasource.vo.DepotItemStockWarningCount;
import com.jsh.erp.datasource.vo.DepotItemVo4Stock;
import com.jsh.erp.datasource.vo.DepotItemVoBatchNumberList;
import com.jsh.erp.datasource.vo.InOutPriceVo;
import com.jsh.erp.exception.BusinessRunTimeException;
import com.jsh.erp.exception.JshException;
import com.jsh.erp.utils.StringUtil;
import com.jsh.erp.utils.Tools;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import java.math.BigDecimal;
import java.util.*;

@Service
public class DepotItemService {
    private Logger logger = LoggerFactory.getLogger(DepotItemService.class);

    private final static String TYPE = BusinessConstants.DEPOTHEAD_TYPE_IN;
    private final static String SUM_TYPE = "number";
    private final static String IN = "in";
    private final static String OUT = "out";

    @Resource
    private DepotItemMapper depotItemMapper;
    @Resource
    private DepotItemMapperEx depotItemMapperEx;
    @Resource
    private MaterialService materialService;
    @Resource
    private MaterialExtendService materialExtendService;
    @Resource
    private SerialNumberMapperEx serialNumberMapperEx;
    @Resource
    private DepotHeadService depotHeadService;
    @Resource
    private DepotHeadMapper depotHeadMapper;
    @Resource
    private SerialNumberService serialNumberService;
    @Resource
    private UserService userService;
    @Resource
    private SystemConfigService systemConfigService;
    @Resource
    private DepotService depotService;
    @Resource
    private UnitService unitService;
    @Resource
    private MaterialCurrentStockMapper materialCurrentStockMapper;
    @Resource
    private MaterialCurrentStockMapperEx materialCurrentStockMapperEx;
    @Resource
    private LogService logService;

    public DepotItem getDepotItem(long id)throws Exception {
        DepotItem result=null;
        try{
            result=depotItemMapper.selectByPrimaryKey(id);
        }catch(Exception e){
            JshException.readFail(logger, e);
        }
        return result;
    }

    public List<DepotItem> getDepotItem()throws Exception {
        DepotItemExample example = new DepotItemExample();
        example.createCriteria().andDeleteFlagNotEqualTo(BusinessConstants.DELETE_FLAG_DELETED);
        List<DepotItem> list=null;
        try{
            list=depotItemMapper.selectByExample(example);
        }catch(Exception e){
            JshException.readFail(logger, e);
        }
        return list;
    }

    public List<DepotItem> select(String name, Integer type, String remark, int offset, int rows)throws Exception {
        List<DepotItem> list=null;
        try{
            list=depotItemMapperEx.selectByConditionDepotItem(name, type, remark, offset, rows);
        }catch(Exception e){
            JshException.readFail(logger, e);
        }
        return list;
    }

    public Long countDepotItem(String name, Integer type, String remark) throws Exception{
        Long result =null;
        try{
            result=depotItemMapperEx.countsByDepotItem(name, type, remark);
        }catch(Exception e){
            JshException.readFail(logger, e);
        }
        return result;
    }

    @Transactional(value = "transactionManager", rollbackFor = Exception.class)
    public int insertDepotItem(JSONObject obj, HttpServletRequest request)throws Exception {
        DepotItem depotItem = JSONObject.parseObject(obj.toJSONString(), DepotItem.class);
        int result =0;
        try{
            result=depotItemMapper.insertSelective(depotItem);
        }catch(Exception e){
            JshException.readFail(logger, e);
        }
        return result;
    }

    @Transactional(value = "transactionManager", rollbackFor = Exception.class)
    public int updateDepotItem(JSONObject obj, HttpServletRequest request)throws Exception {
        DepotItem depotItem = JSONObject.parseObject(obj.toJSONString(), DepotItem.class);
        int result =0;
        try{
            result=depotItemMapper.updateByPrimaryKeySelective(depotItem);
        }catch(Exception e){
            JshException.readFail(logger, e);
        }
        return result;
    }

    @Transactional(value = "transactionManager", rollbackFor = Exception.class)
    public int deleteDepotItem(Long id, HttpServletRequest request)throws Exception {
        int result =0;
        try{
            result=depotItemMapper.deleteByPrimaryKey(id);
        }catch(Exception e){
            JshException.writeFail(logger, e);
        }
        return result;
    }

    @Transactional(value = "transactionManager", rollbackFor = Exception.class)
    public int batchDeleteDepotItem(String ids, HttpServletRequest request)throws Exception {
        List<Long> idList = StringUtil.strToLongList(ids);
        DepotItemExample example = new DepotItemExample();
        example.createCriteria().andIdIn(idList);
        int result =0;
        try{
            result=depotItemMapper.deleteByExample(example);
        }catch(Exception e){
            JshException.writeFail(logger, e);
        }
        return result;
    }

    public int checkIsNameExist(Long id, String name)throws Exception {
        DepotItemExample example = new DepotItemExample();
        example.createCriteria().andIdNotEqualTo(id).andDeleteFlagNotEqualTo(BusinessConstants.DELETE_FLAG_DELETED);
        List<DepotItem> list =null;
        try{
            list=depotItemMapper.selectByExample(example);
        }catch(Exception e){
            JshException.readFail(logger, e);
        }
        return list==null?0:list.size();
    }

    public List<DepotItemVo4DetailByTypeAndMId> findDetailByDepotIdsAndMaterialIdList(String depotIds, Boolean forceFlag, Boolean inOutManageFlag, String sku, String batchNumber,
                                                                                      String number, String beginTime, String endTime, Long mId, Integer offset, Integer rows)throws Exception {
        String[] depotIdArrOld = null;
        if(StringUtil.isNotEmpty(depotIds)) {
            depotIdArrOld = depotIds.split(",");
        }
        List<Long> depotList = depotService.parseDepotListByArr(depotIdArrOld);
        Long[] depotIdArray = StringUtil.listToLongArray(depotList);
        List<DepotItemVo4DetailByTypeAndMId> list =null;
        try{
            list = depotItemMapperEx.findDetailByDepotIdsAndMaterialIdList(depotIdArray, forceFlag, inOutManageFlag, sku, batchNumber, number, beginTime, endTime, mId, offset, rows);
        }catch(Exception e){
            JshException.readFail(logger, e);
        }
        return list;
    }

    public Long findDetailByDepotIdsAndMaterialIdCount(String depotIds, Boolean forceFlag, Boolean inOutManageFlag, String sku, String batchNumber,
                                                       String number, String beginTime, String endTime, Long mId)throws Exception {
        String[] depotIdArrOld = null;
        if(StringUtil.isNotEmpty(depotIds)) {
            depotIdArrOld = depotIds.split(",");
        }
        List<Long> depotList = depotService.parseDepotListByArr(depotIdArrOld);
        Long[] depotIdArray = StringUtil.listToLongArray(depotList);
        Long result =null;
        try{
            result = depotItemMapperEx.findDetailByDepotIdsAndMaterialIdCount(depotIdArray, forceFlag, inOutManageFlag, sku, batchNumber, number, beginTime, endTime, mId);
        }catch(Exception e){
            JshException.readFail(logger, e);
        }
        return result;
    }

    @Transactional(value = "transactionManager", rollbackFor = Exception.class)
    public int insertDepotItemWithObj(DepotItem depotItem)throws Exception {
        int result =0;
        try{
            result = depotItemMapper.insertSelective(depotItem);
        }catch(Exception e){
            JshException.writeFail(logger, e);
        }
        return result;
    }

    @Transactional(value = "transactionManager", rollbackFor = Exception.class)
    public int updateDepotItemWithObj(DepotItem depotItem)throws Exception {
        int result =0;
        try{
            result = depotItemMapper.updateByPrimaryKeySelective(depotItem);
        }catch(Exception e){
            JshException.writeFail(logger, e);
        }
        return result;
    }

    public List<DepotItem> getListByHeaderId(Long headerId)throws Exception {
        List<DepotItem> list =null;
        try{
            DepotItemExample example = new DepotItemExample();
            example.createCriteria().andHeaderIdEqualTo(headerId).andDeleteFlagNotEqualTo(BusinessConstants.DELETE_FLAG_DELETED);
            list = depotItemMapper.selectByExample(example);
        }catch(Exception e){
            JshException.readFail(logger, e);
        }
        return list;
    }

    /**
     * 查询当前单据中指定商品的明细信息
     * @param headerId
     * @param meId
     * @return
     * @throws Exception
     */
    public DepotItem getItemByHeaderIdAndMaterial(Long headerId, Long meId)throws Exception {
        DepotItem depotItem = new DepotItem();
        try{
            DepotItemExample example = new DepotItemExample();
            example.createCriteria().andHeaderIdEqualTo(headerId).andMaterialExtendIdEqualTo(meId).andDeleteFlagNotEqualTo(BusinessConstants.DELETE_FLAG_DELETED);
            List<DepotItem> list = depotItemMapper.selectByExample(example);
            if(list!=null && list.size()>0) {
                depotItem = list.get(0);
            }
        }catch(Exception e){
            JshException.readFail(logger, e);
        }
        return depotItem;
    }

    /**
     * 查询被关联订单中指定商品的明细信息
     * @param linkStr
     * @param meId
     * @return
     * @throws Exception
     */
    public DepotItem getPreItemByHeaderIdAndMaterial(String linkStr, Long meId, Long linkId)throws Exception {
        DepotItem depotItem = new DepotItem();
        try{
            DepotHead depotHead = depotHeadService.getDepotHead(linkStr);
            if(null!=depotHead && null!=depotHead.getId()) {
                DepotItemExample example = new DepotItemExample();
                example.createCriteria().andHeaderIdEqualTo(depotHead.getId()).andMaterialExtendIdEqualTo(meId).andIdEqualTo(linkId).andDeleteFlagNotEqualTo(BusinessConstants.DELETE_FLAG_DELETED);
                List<DepotItem> list = depotItemMapper.selectByExample(example);
                if(list!=null && list.size()>0) {
                    depotItem = list.get(0);
                }
            }
        }catch(Exception e){
            JshException.readFail(logger, e);
        }
        return depotItem;
    }

    public List<DepotItemVo4WithInfoEx> getDetailList(Long headerId)throws Exception {
        List<DepotItemVo4WithInfoEx> list =null;
        try{
            list = depotItemMapperEx.getDetailList(headerId);
        }catch(Exception e){
            JshException.readFail(logger, e);
        }
        return list;
    }

    public List<DepotItemVo4WithInfoEx> getInOutStock(String materialParam, List<Long> categoryIdList, String endTime, Integer offset, Integer rows)throws Exception {
        List<DepotItemVo4WithInfoEx> list =null;
        try{
            list = depotItemMapperEx.getInOutStock(materialParam, categoryIdList, endTime, offset, rows);
        }catch(Exception e){
            JshException.readFail(logger, e);
        }
        return list;
    }

    public int getInOutStockCount(String materialParam, List<Long> categoryIdList, String endTime)throws Exception {
        int result=0;
        try{
            result = depotItemMapperEx.getInOutStockCount(materialParam, categoryIdList, endTime);
        }catch(Exception e){
            JshException.readFail(logger, e);
        }
        return result;
    }

    public List<DepotItemVo4WithInfoEx> getListWithBuyOrSale(String materialParam, String billType,
                                                             String beginTime, String endTime, String[] creatorArray, Long organId, String[] organArray, List<Long> categoryList, List<Long> depotList, Boolean forceFlag, Integer offset, Integer rows)throws Exception {
        List<DepotItemVo4WithInfoEx> list =null;
        try{
            list = depotItemMapperEx.getListWithBuyOrSale(materialParam, billType, beginTime, endTime, creatorArray, organId, organArray, categoryList, depotList, forceFlag, offset, rows);
        }catch(Exception e){
            JshException.readFail(logger, e);
        }
        return list;
    }

    public int getListWithBuyOrSaleCount(String materialParam, String billType,
                                         String beginTime, String endTime, String[] creatorArray, Long organId, String[] organArray, List<Long> categoryList, List<Long> depotList, Boolean forceFlag)throws Exception {
        int result=0;
        try{
            result = depotItemMapperEx.getListWithBuyOrSaleCount(materialParam, billType, beginTime, endTime, creatorArray, organId, organArray, categoryList, depotList, forceFlag);
        }catch(Exception e){
            JshException.readFail(logger, e);
        }
        return result;
    }

    public BigDecimal buyOrSale(String type, String subType, Long meId, String beginTime, String endTime,
                                String[] creatorArray, Long organId, String [] organArray, List<Long> depotList, Boolean forceFlag, String sumType) throws Exception{
        BigDecimal result= BigDecimal.ZERO;
        try{
            if (SUM_TYPE.equals(sumType)) {
                result= depotItemMapperEx.buyOrSaleNumber(type, subType, meId, beginTime, endTime, creatorArray, organId, organArray, depotList, forceFlag, sumType);
            } else {
                result= depotItemMapperEx.buyOrSalePrice(type, subType, meId, beginTime, endTime, creatorArray, organId, organArray, depotList, forceFlag, sumType);
            }
        }catch(Exception e){
            JshException.readFail(logger, e);
        }
        return result;
    }

    public BigDecimal buyOrSalePriceTotal(String type, String subType, String materialParam, String beginTime, String endTime,
                                String[] creatorArray, Long organId, String [] organArray, List<Long> categoryList, List<Long> depotList, Boolean forceFlag) throws Exception{
        BigDecimal result= BigDecimal.ZERO;
        try{
            result= depotItemMapperEx.buyOrSalePriceTotal(type, subType, materialParam, beginTime, endTime, creatorArray, organId, organArray, categoryList, depotList, forceFlag);
        }catch(Exception e){
            JshException.readFail(logger, e);
        }
        return result;

    }

    /**
     * 统计采购、销售、零售的总金额列表
     * @param beginTime
     * @param endTime
     * @return
     * @throws Exception
     */
    public List<InOutPriceVo> inOrOutPriceList(String beginTime, String endTime) throws Exception{
        List<InOutPriceVo> result = new ArrayList<>();
        try{
            String [] creatorArray = depotHeadService.getCreatorArray();
            Boolean forceFlag = systemConfigService.getForceApprovalFlag();
            result = depotItemMapperEx.inOrOutPriceList(beginTime, endTime, creatorArray, forceFlag);
        }catch(Exception e){
            JshException.readFail(logger, e);
        }
        return result;
    }

    @Transactional(value = "transactionManager", rollbackFor = Exception.class)
    public void saveDetials(String rows, Long headerId, String actionType, HttpServletRequest request) throws Exception{
        // Rechercher les informations de la table principale du document
        DepotHead depotHead =depotHeadMapper.selectByPrimaryKey(headerId);
        // Supprimer les numéros de série et récupérer les numéros de série
        deleteOrCancelSerialNumber(actionType, depotHead, headerId);
        // Supprimer les détails du document
        deleteDepotItemHeadId(headerId);
        JSONArray rowArr = JSONArray.parseArray(rows);
        if (null != rowArr && rowArr.size()>0) {
            // Vérifier s'il existe des composants combinés et des sous-composants normaux pour les bons d'assemblage et de démontage
            checkAssembleWithMaterialType(rowArr, depotHead.getSubType());
            // Vérifier s'il existe des numéros de série dupliqués dans les détails multiples
            checkSerialNumberRepeat(rowArr);
            for (int i = 0; i < rowArr.size(); i++) {
                DepotItem depotItem = new DepotItem();
                JSONObject rowObj = JSONObject.parseObject(rowArr.getString(i));
                depotItem.setHeaderId(headerId);
                String barCode = rowObj.getString("barCode");
                MaterialExtend materialExtend = materialExtendService.getInfoByBarCode(barCode);
                if(materialExtend == null) {
                    throw new BusinessRunTimeException(ExceptionConstants.MATERIAL_BARCODE_IS_NOT_EXIST_CODE,
                            String.format(ExceptionConstants.MATERIAL_BARCODE_IS_NOT_EXIST_MSG, barCode));
                }
                depotItem.setMaterialId(materialExtend.getMaterialId());
                depotItem.setMaterialExtendId(materialExtend.getId());
                depotItem.setMaterialUnit(rowObj.getString("unit"));
                Material material= materialService.getMaterial(depotItem.getMaterialId());
                if (BusinessConstants.ENABLE_SERIAL_NUMBER_ENABLED.equals(material.getEnableSerialNumber()) ||
                        BusinessConstants.ENABLE_BATCH_NUMBER_ENABLED.equals(material.getEnableBatchNumber())) {
                    // Les bons d'assemblage et de démontage ne peuvent pas choisir des produits avec numéro de lot ou de série
                    if(BusinessConstants.SUB_TYPE_ASSEMBLE.equals(depotHead.getSubType()) ||
                            BusinessConstants.SUB_TYPE_DISASSEMBLE.equals(depotHead.getSubType())) {
                        throw new BusinessRunTimeException(ExceptionConstants.MATERIAL_ASSEMBLE_SELECT_ERROR_CODE,
                                String.format(ExceptionConstants.MATERIAL_ASSEMBLE_SELECT_ERROR_MSG, barCode));
                    }
                    // Le bon de transfert ne peut pas choisir des produits avec numéro de lot ou de série (ce scénario génère des documents de sortie et d'entrée)
                    if(BusinessConstants.SUB_TYPE_TRANSFER.equals(depotHead.getSubType())) {
                        throw new BusinessRunTimeException(ExceptionConstants.MATERIAL_TRANSFER_SELECT_ERROR_CODE,
                                String.format(ExceptionConstants.MATERIAL_TRANSFER_SELECT_ERROR_MSG, barCode));
                    }
                    // L'inventaire ne peut pas choisir des produits avec numéro de lot ou de série (ce scénario génère des documents de sortie et d'entrée)
                    if(BusinessConstants.SUB_TYPE_CHECK_ENTER.equals(depotHead.getSubType())
                       ||BusinessConstants.SUB_TYPE_REPLAY.equals(depotHead.getSubType())) {
                        throw new BusinessRunTimeException(ExceptionConstants.MATERIAL_STOCK_CHECK_ERROR_CODE,
                                String.format(ExceptionConstants.MATERIAL_STOCK_CHECK_ERROR_MSG, barCode));
                    }
                }
                if (StringUtil.isExist(rowObj.get("snList"))) {
                    depotItem.setSnList(rowObj.getString("snList"));
                    if(StringUtil.isExist(rowObj.get("depotId"))) {
                        String [] snArray = depotItem.getSnList().split(",");
                        int operNum = rowObj.getInteger("operNumber");
                        if(snArray.length == operNum) {
                            Long depotId = rowObj.getLong("depotId");
                            BigDecimal inPrice = BigDecimal.ZERO;
                            if (StringUtil.isExist(rowObj.get("unitPrice"))) {
                                inPrice = rowObj.getBigDecimal("unitPrice");
                            }
                            serialNumberService.addSerialNumberByBill(depotHead.getType(), depotHead.getSubType(),
                                    depotHead.getNumber(), materialExtend.getMaterialId(), depotId, inPrice, depotItem.getSnList());
                        } else {
                            throw new BusinessRunTimeException(ExceptionConstants.DEPOT_HEAD_SN_NUMBERE_FAILED_CODE,
                                    String.format(ExceptionConstants.DEPOT_HEAD_SN_NUMBERE_FAILED_MSG, barCode));
                        }
                    }
                } else {
                    // Entrée ou sortie
                    if (BusinessConstants.DEPOTHEAD_TYPE_IN.equals(depotHead.getType()) ||
                            BusinessConstants.DEPOTHEAD_TYPE_OUT.equals(depotHead.getType())) {
                        // Le numéro de série ne peut pas être vide
                        if (BusinessConstants.ENABLE_SERIAL_NUMBER_ENABLED.equals(material.getEnableSerialNumber())) {
                            // Si la gestion des entrées/sorties est activée et que le type correspond à achat, retour d'achat, vente, retour de vente, alors ignorer
                            if(systemConfigService.getInOutManageFlag() &&
                                    (BusinessConstants.SUB_TYPE_PURCHASE.equals(depotHead.getSubType())
                                            ||BusinessConstants.SUB_TYPE_PURCHASE_RETURN.equals(depotHead.getSubType())
                                            ||BusinessConstants.SUB_TYPE_SALES.equals(depotHead.getSubType())
                                            ||BusinessConstants.SUB_TYPE_SALES_RETURN.equals(depotHead.getSubType()))) {
                                // Ignorer
                            } else {
                                throw new BusinessRunTimeException(ExceptionConstants.MATERIAL_SERIAL_NUMBERE_EMPTY_CODE,
                                        String.format(ExceptionConstants.MATERIAL_SERIAL_NUMBERE_EMPTY_MSG, barCode));
                            }
                        }
                    }
                }
                if (StringUtil.isExist(rowObj.get("batchNumber"))) {
                    depotItem.setBatchNumber(rowObj.getString("batchNumber"));
                } else {
                    // Entrée ou sortie
                    if(BusinessConstants.DEPOTHEAD_TYPE_IN.equals(depotHead.getType()) ||
                            BusinessConstants.DEPOTHEAD_TYPE_OUT.equals(depotHead.getType())) {
                        // Le numéro de lot ne peut pas être vide
                        if (BusinessConstants.ENABLE_BATCH_NUMBER_ENABLED.equals(material.getEnableBatchNumber())) {
                            // Si la gestion des entrées/sorties est activée et que le type correspond à achat, retour d'achat, vente, retour de vente, alors ignorer
                            if(systemConfigService.getInOutManageFlag() &&
                                    (BusinessConstants.SUB_TYPE_PURCHASE.equals(depotHead.getSubType())
                                            ||BusinessConstants.SUB_TYPE_PURCHASE_RETURN.equals(depotHead.getSubType())
                                            ||BusinessConstants.SUB_TYPE_SALES.equals(depotHead.getSubType())
                                            ||BusinessConstants.SUB_TYPE_SALES_RETURN.equals(depotHead.getSubType()))) {
                                // Ignorer
                            } else {
                                throw new BusinessRunTimeException(ExceptionConstants.DEPOT_HEAD_BATCH_NUMBERE_EMPTY_CODE,
                                        String.format(ExceptionConstants.DEPOT_HEAD_BATCH_NUMBERE_EMPTY_MSG, barCode));
                            }
                        }
                    }
                }
                if (StringUtil.isExist(rowObj.get("expirationDate"))) {
                    depotItem.setExpirationDate(rowObj.getDate("expirationDate"));
                }
                if (StringUtil.isExist(rowObj.get("sku"))) {
                    depotItem.setSku(rowObj.getString("sku"));
                }
                if (StringUtil.isExist(rowObj.get("linkId"))) {
                    depotItem.setLinkId(rowObj.getLong("linkId"));
                }
                // Conversion d'unité ci-dessous
                Unit unitInfo = materialService.findUnit(materialExtend.getMaterialId()); // Rechercher les informations multi-unités
                if (StringUtil.isExist(rowObj.get("operNumber"))) {
                    depotItem.setOperNumber(rowObj.getBigDecimal("operNumber"));
                    String unit = rowObj.get("unit").toString();
                    BigDecimal oNumber = rowObj.getBigDecimal("operNumber");
                    if (StringUtil.isNotEmpty(unitInfo.getName())) {
                        String basicUnit = unitInfo.getBasicUnit(); // Unité de base
                        if (unit.equals(basicUnit)) { // Si égal à l'unité de base
                            depotItem.setBasicNumber(oNumber); // Quantité identique
                        } else if (unit.equals(unitInfo.getOtherUnit())) { // Si égal à l'unité secondaire
                            depotItem.setBasicNumber(oNumber.multiply(unitInfo.getRatio())); // Quantité multipliée par le ratio
                        } else if (unit.equals(unitInfo.getOtherUnitTwo())) { // Si égal à l'unité secondaire 2
                            depotItem.setBasicNumber(oNumber.multiply(unitInfo.getRatioTwo())); // Quantité multipliée par le ratio
                        } else if (unit.equals(unitInfo.getOtherUnitThree())) { // Si égal à l'unité secondaire 3
                            depotItem.setBasicNumber(oNumber.multiply(unitInfo.getRatioThree())); // Quantité multipliée par le ratio
                        } else {
                            depotItem.setBasicNumber(oNumber); // Quantité identique
                        }
                    } else {
                        depotItem.setBasicNumber(oNumber); // Autres cas
                    }
                }
                // Si quantité + quantité terminée > quantité de commande originale, donner un avertissement (condition préalable : existence d'une commande associée | demande d'achat associée)
                String linkStr = StringUtil.isNotEmpty(depotHead.getLinkNumber())? depotHead.getLinkNumber(): depotHead.getLinkApply();
                if (StringUtil.isNotEmpty(linkStr) && StringUtil.isExist(rowObj.get("preNumber")) && StringUtil.isExist(rowObj.get("finishNumber"))) {
                    if("add".equals(actionType)) {
                        // Affecter le statut en mode ajout
                        BigDecimal preNumber = rowObj.getBigDecimal("preNumber");
                        BigDecimal finishNumber = rowObj.getBigDecimal("finishNumber");
                        if(depotItem.getOperNumber().add(finishNumber).compareTo(preNumber)>0) {
                            if(!systemConfigService.getOverLinkBillFlag()) {
                                throw new BusinessRunTimeException(ExceptionConstants.DEPOT_HEAD_NUMBER_NEED_EDIT_FAILED_CODE,
                                        String.format(ExceptionConstants.DEPOT_HEAD_NUMBER_NEED_EDIT_FAILED_MSG, barCode));
                            }
                        }
                    } else if("update".equals(actionType)) {
                        // Type du document actuel
                        String currentSubType = depotHead.getSubType();
                        // Affecter le statut en mode mise à jour
                        String unit = rowObj.get("unit").toString();
                        Long preHeaderId = depotHeadService.getDepotHead(linkStr).getId();
                        if(null!=preHeaderId) {
                            // Quantité du document précédent
                            BigDecimal preNumber = getPreItemByHeaderIdAndMaterial(linkStr, depotItem.getMaterialExtendId(), depotItem.getLinkId()).getOperNumber();
                            // Entrées | sorties en dehors de ce document
                            BigDecimal realFinishNumber = getRealFinishNumber(currentSubType, depotItem.getMaterialExtendId(), depotItem.getLinkId(), preHeaderId, headerId, unitInfo, unit);
                            if(preNumber!=null) {
                                if (depotItem.getOperNumber().add(realFinishNumber).compareTo(preNumber) > 0) {
                                    if (!systemConfigService.getOverLinkBillFlag()) {
                                        throw new BusinessRunTimeException(ExceptionConstants.DEPOT_HEAD_NUMBER_NEED_EDIT_FAILED_CODE,
                                                String.format(ExceptionConstants.DEPOT_HEAD_NUMBER_NEED_EDIT_FAILED_MSG, barCode));
                                    }
                                }
                            } else {
                                throw new BusinessRunTimeException(ExceptionConstants.DEPOT_ITEM_PRE_BILL_IS_CHANGE_CODE,
                                        ExceptionConstants.DEPOT_ITEM_PRE_BILL_IS_CHANGE_MSG);
                            }
                        }
                    }
                }
                if (StringUtil.isExist(rowObj.get("unitPrice"))) {
                    BigDecimal unitPrice = rowObj.getBigDecimal("unitPrice");
                    depotItem.setUnitPrice(unitPrice);
                    if(materialExtend.getLowDecimal()!=null) {
                        // Si le prix unitaire de vente au détail ou de vente est inférieur au prix de vente minimum, afficher un message
                        if(BusinessConstants.SUB_TYPE_RETAIL.equals(depotHead.getSubType()) || BusinessConstants.SUB_TYPE_SALES.equals(depotHead.getSubType())) {
                            if (unitPrice.compareTo(materialExtend.getLowDecimal()) < 0) {
                                throw new BusinessRunTimeException(ExceptionConstants.DEPOT_HEAD_UNIT_PRICE_LOW_CODE,
                                        String.format(ExceptionConstants.DEPOT_HEAD_UNIT_PRICE_LOW_MSG, barCode));
                            }
                        }
                    }
                }
                // Si c'est une sortie de vente, retour de vente, sortie de vente au détail, retour de vente au détail, alors assigner une valeur au champ prix unitaire d'achat (si c'est un produit en lot, rechercher le prix d'entrée précédent selon le numéro de lot)
                if(BusinessConstants.SUB_TYPE_SALES.equals(depotHead.getSubType()) ||
                    BusinessConstants.SUB_TYPE_SALES_RETURN.equals(depotHead.getSubType()) ||
                    BusinessConstants.SUB_TYPE_RETAIL.equals(depotHead.getSubType()) ||
                    BusinessConstants.SUB_TYPE_RETAIL_RETURN.equals(depotHead.getSubType())) {
                    boolean moveAvgPriceFlag = systemConfigService.getMoveAvgPriceFlag();
                    BigDecimal currentUnitPrice = materialCurrentStockMapperEx.getCurrentUnitPriceByMId(materialExtend.getMaterialId());
                    currentUnitPrice = unitService.parseUnitPriceByUnit(currentUnitPrice, unitInfo, depotItem.getMaterialUnit());
                    BigDecimal unitPrice = moveAvgPriceFlag? currentUnitPrice: materialExtend.getPurchaseDecimal();
                    depotItem.setPurchaseUnitPrice(unitPrice);
                    if(StringUtil.isNotEmpty(depotItem.getBatchNumber())) {
                        depotItem.setPurchaseUnitPrice(getDepotItemByBatchNumber(depotItem.getMaterialExtendId(),depotItem.getBatchNumber()).getUnitPrice());
                    }
                }
                if (StringUtil.isExist(rowObj.get("taxUnitPrice"))) {
                    depotItem.setTaxUnitPrice(rowObj.getBigDecimal("taxUnitPrice"));
                }
                if (StringUtil.isExist(rowObj.get("allPrice"))) {
                    depotItem.setAllPrice(rowObj.getBigDecimal("allPrice"));
                }
                if (StringUtil.isExist(rowObj.get("depotId"))) {
                    depotItem.setDepotId(rowObj.getLong("depotId"));
                } else {
                    if(!BusinessConstants.SUB_TYPE_PURCHASE_APPLY.equals(depotHead.getSubType())
                            && !BusinessConstants.SUB_TYPE_PURCHASE_ORDER.equals(depotHead.getSubType())
                            && !BusinessConstants.SUB_TYPE_SALES_ORDER.equals(depotHead.getSubType())) {
                        throw new BusinessRunTimeException(ExceptionConstants.DEPOT_HEAD_DEPOT_FAILED_CODE,
                                String.format(ExceptionConstants.DEPOT_HEAD_DEPOT_FAILED_MSG));
                    }
                }
                if(BusinessConstants.SUB_TYPE_TRANSFER.equals(depotHead.getSubType())) {
                    if (StringUtil.isExist(rowObj.get("anotherDepotId"))) {
                        if(rowObj.getLong("anotherDepotId").equals(rowObj.getLong("depotId"))) {
                            throw new BusinessRunTimeException(ExceptionConstants.DEPOT_HEAD_ANOTHER_DEPOT_EQUAL_FAILED_CODE,
                                    String.format(ExceptionConstants.DEPOT_HEAD_ANOTHER_DEPOT_EQUAL_FAILED_MSG));
                        } else {
                            depotItem.setAnotherDepotId(rowObj.getLong("anotherDepotId"));
                        }
                    } else {
                        throw new BusinessRunTimeException(ExceptionConstants.DEPOT_HEAD_ANOTHER_DEPOT_FAILED_CODE,
                                String.format(ExceptionConstants.DEPOT_HEAD_ANOTHER_DEPOT_FAILED_MSG));
                    }
                }
                if (StringUtil.isExist(rowObj.get("taxRate"))) {
                    depotItem.setTaxRate(rowObj.getBigDecimal("taxRate"));
                }
                if (StringUtil.isExist(rowObj.get("taxMoney"))) {
                    depotItem.setTaxMoney(rowObj.getBigDecimal("taxMoney"));
                }
                if (StringUtil.isExist(rowObj.get("taxLastMoney"))) {
                    depotItem.setTaxLastMoney(rowObj.getBigDecimal("taxLastMoney"));
                }
                if (StringUtil.isExist(rowObj.get("mType"))) {
                    depotItem.setMaterialType(rowObj.getString("mType"));
                }
                if (StringUtil.isExist(rowObj.get("remark"))) {
                    depotItem.setRemark(rowObj.getString("remark"));
                }
                // Vérifier si le stock est suffisant lors de la sortie
                if(BusinessConstants.DEPOTHEAD_TYPE_OUT.equals(depotHead.getType())){
                    String stockMsg = material.getName() + "-" + barCode;
                    BigDecimal stock = getCurrentStockByParam(depotItem.getDepotId(),depotItem.getMaterialId());
                    if(StringUtil.isNotEmpty(depotItem.getSku())) {
                        // Pour les produits SKU, utiliser une autre méthode pour calculer le stock
                        stock = getSkuStockByParam(depotItem.getDepotId(),depotItem.getMaterialExtendId(),null,null);
                    }
                    if(StringUtil.isNotEmpty(depotItem.getBatchNumber())) {
                        // Pour les produits en lot, utiliser une autre méthode pour calculer le stock
                        stock = getOneBatchNumberStock(depotItem.getDepotId(), barCode, depotItem.getBatchNumber());
                        stockMsg += "-批号" + depotItem.getBatchNumber();
                    }
                    BigDecimal thisRealNumber = depotItem.getBasicNumber()==null?BigDecimal.ZERO:depotItem.getBasicNumber();
                    if(StringUtil.isNotEmpty(depotItem.getBatchNumber())) {
                        // Pour les produits en lot, utiliser directement la quantité actuellement saisie
                        thisRealNumber = depotItem.getOperNumber()==null?BigDecimal.ZERO:depotItem.getOperNumber();
                    }
                    if(!systemConfigService.getMinusStockFlag() && stock.compareTo(thisRealNumber)<0){
                        throw new BusinessRunTimeException(ExceptionConstants.MATERIAL_STOCK_NOT_ENOUGH_CODE,
                                String.format(ExceptionConstants.MATERIAL_STOCK_NOT_ENOUGH_MSG, stockMsg));
                    }
                    // Traiter les numéros de série lors de la sortie
                    if(!BusinessConstants.SUB_TYPE_TRANSFER.equals(depotHead.getSubType())) {
                        // Vérifier si le produit a les numéros de série activés, vendre les numéros de série si activés, ignorer si non activés
                        if(BusinessConstants.ENABLE_SERIAL_NUMBER_ENABLED.equals(material.getEnableSerialNumber())) {
                            // Si la gestion des entrées/sorties est activée et que le type correspond à achat, retour d'achat, vente, retour de vente, alors ignorer
                            if(systemConfigService.getInOutManageFlag() &&
                                    (BusinessConstants.SUB_TYPE_PURCHASE.equals(depotHead.getSubType())
                                            ||BusinessConstants.SUB_TYPE_PURCHASE_RETURN.equals(depotHead.getSubType())
                                            ||BusinessConstants.SUB_TYPE_SALES.equals(depotHead.getSubType())
                                            ||BusinessConstants.SUB_TYPE_SALES_RETURN.equals(depotHead.getSubType()))) {
                                // Ignorer
                            } else {
                                // Vendre les numéros de série, obtenir l'opérateur actuel
                                User userInfo = userService.getCurrentUser();
                                serialNumberService.checkAndUpdateSerialNumber(depotItem, depotHead.getNumber(), userInfo, StringUtil.toNull(depotItem.getSnList()));
                            }
                        }
                    }
                }
                this.insertDepotItemWithObj(depotItem);
                // Mettre à jour le stock actuel
                updateCurrentStock(depotItem);
                // Mettre à jour le prix de revient actuel
                updateCurrentUnitPrice(depotItem);
                // Mettre à jour le prix du produit
                updateMaterialExtendPrice(materialExtend.getId(), depotHead.getSubType(), depotHead.getBillType(), rowObj);
            }
            // Si le numéro de document associé n'est pas vide, mettre à jour le statut de la commande, types de documents : bon d'entrée d'achat, bon de sortie de vente, bon de révision d'inventaire, autre bon d'entrée, autre bon de sortie
            if(BusinessConstants.SUB_TYPE_PURCHASE.equals(depotHead.getSubType())
                    || BusinessConstants.SUB_TYPE_SALES.equals(depotHead.getSubType())
                    || BusinessConstants.SUB_TYPE_REPLAY.equals(depotHead.getSubType())
                    || BusinessConstants.SUB_TYPE_OTHER.equals(depotHead.getSubType())) {
                if(StringUtil.isNotEmpty(depotHead.getLinkNumber())) {
                    // Statut du document : est-ce entièrement terminé 2-entièrement terminé 3-partiellement terminé (pour les entrées/sorties par lots des commandes)
                    String billStatus = getBillStatusByParam(depotHead, depotHead.getLinkNumber(), "normal");
                    changeBillStatus(depotHead.getLinkNumber(), billStatus);
                }
            }
            // Logique pour le type de document actuel étant une commande d'achat
            if(BusinessConstants.SUB_TYPE_PURCHASE_ORDER.equals(depotHead.getSubType())) {
                // Si le numéro de document associé n'est pas vide, mettre à jour le statut de la commande, ici pour le scénario de conversion d'une commande de vente en commande d'achat
                if(StringUtil.isNotEmpty(depotHead.getLinkNumber())) {
                    String billStatus = getBillStatusByParam(depotHead, depotHead.getLinkNumber(), "normal");
                    changeBillPurchaseStatus(depotHead.getLinkNumber(), billStatus);
                }
                // Si le numéro de document associé n'est pas vide, mettre à jour le statut de la commande, ici pour le scénario de conversion d'une demande d'achat en commande d'achat
                if(StringUtil.isNotEmpty(depotHead.getLinkApply())) {
                    String billStatus = getBillStatusByParam(depotHead, depotHead.getLinkApply(), "apply");
                    changeBillStatus(depotHead.getLinkApply(), billStatus);
                }
            }
        } else {
            throw new BusinessRunTimeException(ExceptionConstants.DEPOT_HEAD_ROW_FAILED_CODE,
                    String.format(ExceptionConstants.DEPOT_HEAD_ROW_FAILED_MSG));
        }
    }
    /**
     * Déterminer le statut du document
     * Comparaison par tableau : produits et quantités du document original (résumé) avec produits et quantités du document après opération par lots (résumé)
     * @param depotHead
     * @param linkStr
     * @return
     */
    @Transactional(value = "transactionManager", rollbackFor = Exception.class)
    public String getBillStatusByParam(DepotHead depotHead, String linkStr, String linkType) {
        String res = BusinessConstants.BILLS_STATUS_SKIPED;
        // Obtenir les produits et quantités du document original (résumé)
        List<DepotItemVo4MaterialAndSum> linkList = depotItemMapperEx.getLinkBillDetailMaterialSum(linkStr);
        // Obtenir les produits et quantités du document après opération par lots (résumé)
        List<DepotItemVo4MaterialAndSum> batchList = depotItemMapperEx.getBatchBillDetailMaterialSum(linkStr, linkType, depotHead.getType());
        // Construire un Map avec les produits et données du document après opération par lots
        Map<Long, BigDecimal> materialSumMap = new HashMap<>();
        for(DepotItemVo4MaterialAndSum materialAndSum : batchList) {
            materialSumMap.put(materialAndSum.getMaterialExtendId(), materialAndSum.getOperNumber());
        }
        for(DepotItemVo4MaterialAndSum materialAndSum : linkList) {
            // Filtrer les produits avec une quantité de 0 dans le document original
            if(materialAndSum.getOperNumber().compareTo(BigDecimal.ZERO) != 0) {
                BigDecimal materialSum = materialSumMap.get(materialAndSum.getMaterialExtendId());
                if (materialSum != null) {
                    if (materialSum.compareTo(materialAndSum.getOperNumber()) < 0) {
                        res = BusinessConstants.BILLS_STATUS_SKIPING;
                    }
                } else {
                    res = BusinessConstants.BILLS_STATUS_SKIPING;
                }
            }
        }
        return res;
    }

    /**
     * Mettre à jour le statut du document
     * @param linkStr
     * @param billStatus
     */
    @Transactional(value = "transactionManager", rollbackFor = Exception.class)
    public void changeBillStatus(String linkStr, String billStatus) {
        DepotHead depotHeadOrders = new DepotHead();
        depotHeadOrders.setStatus(billStatus);
        DepotHeadExample example = new DepotHeadExample();
        List<String> linkNoList = StringUtil.strToStringList(linkStr);
        example.createCriteria().andNumberIn(linkNoList);
        try{
            depotHeadMapper.updateByExampleSelective(depotHeadOrders, example);
        }catch(Exception e){
            logger.error("Code d'erreur[{}], Message d'erreur[{}], Exception[{}]",
                    ExceptionConstants.DATA_WRITE_FAIL_CODE,ExceptionConstants.DATA_WRITE_FAIL_MSG,e);
            throw new BusinessRunTimeException(ExceptionConstants.DATA_WRITE_FAIL_CODE,
                    ExceptionConstants.DATA_WRITE_FAIL_MSG);
        }
    }

    /**
     * Mettre à jour le statut du document, ici pour le scénario de conversion d'une commande de vente en commande d'achat
     * @param linkStr
     * @param billStatus
     */
    @Transactional(value = "transactionManager", rollbackFor = Exception.class)
    public void changeBillPurchaseStatus(String linkStr, String billStatus) {
        DepotHead depotHeadOrders = new DepotHead();
        depotHeadOrders.setPurchaseStatus(billStatus);
        DepotHeadExample example = new DepotHeadExample();
        List<String> linkNoList = StringUtil.strToStringList(linkStr);
        example.createCriteria().andNumberIn(linkNoList);
        try{
            depotHeadMapper.updateByExampleSelective(depotHeadOrders, example);
        }catch(Exception e){
            logger.error("Code d'erreur[{}], Message d'erreur[{}], Exception[{}]",
                    ExceptionConstants.DATA_WRITE_FAIL_CODE,ExceptionConstants.DATA_WRITE_FAIL_MSG,e);
            throw new BusinessRunTimeException(ExceptionConstants.DATA_WRITE_FAIL_CODE,
                    ExceptionConstants.DATA_WRITE_FAIL_MSG);
        }
    }

    /**
     * Rechercher les informations détaillées du document selon le numéro de lot
     * @param materialExtendId
     * @param batchNumber
     * @return
     */
    public DepotItem getDepotItemByBatchNumber(Long materialExtendId, String batchNumber) {
        List<DepotItem> depotItemList = depotItemMapperEx.getDepotItemByBatchNumber(materialExtendId, batchNumber);
        if(null != depotItemList && depotItemList.size() > 0){
            return depotItemList.get(0);
        } else {
            return new DepotItem();
        }
    }

    @Transactional(value = "transactionManager", rollbackFor = Exception.class)
    public void deleteDepotItemHeadId(Long headerId)throws Exception {
        try{
            // 1. Rechercher les détails du document avant suppression
            List<DepotItem> depotItemList = getListByHeaderId(headerId);
            // 2. Supprimer les détails du document
            DepotItemExample example = new DepotItemExample();
            example.createCriteria().andHeaderIdEqualTo(headerId);
            depotItemMapper.deleteByExample(example);
            // 3. Calculer le stock des produits dans les détails du document après suppression
            for(DepotItem depotItem : depotItemList){
                updateCurrentStock(depotItem);
            }
        }catch(Exception e){
            JshException.writeFail(logger, e);
        }
    }

    /**
     * Supprimer les numéros de série et récupérer les numéros de série
     * @param actionType
     * @throws Exception
     */
    @Transactional(value = "transactionManager", rollbackFor = Exception.class)
    public void deleteOrCancelSerialNumber(String actionType, DepotHead depotHead, Long headerId) throws Exception {
        if(actionType.equals("update")) {
            User userInfo = userService.getCurrentUser();
            if(BusinessConstants.DEPOTHEAD_TYPE_IN.equals(depotHead.getType())){
                // Logique d'entrée
                String number = depotHead.getNumber();
                SerialNumberExample example = new SerialNumberExample();
                example.createCriteria().andInBillNoEqualTo(number);
                serialNumberService.deleteByExample(example);
            } else if(BusinessConstants.DEPOTHEAD_TYPE_OUT.equals(depotHead.getType())){
                // Logique de sortie
                DepotItemExample example = new DepotItemExample();
                example.createCriteria().andHeaderIdEqualTo(headerId).andDeleteFlagNotEqualTo(BusinessConstants.DELETE_FLAG_DELETED);
                List<DepotItem> depotItemList = depotItemMapper.selectByExample(example);
                if(null != depotItemList && depotItemList.size() > 0){
                    for (DepotItem depotItem : depotItemList){
                        if(StringUtil.isNotEmpty(depotItem.getSnList())){
                            serialNumberService.cancelSerialNumber(depotItem.getMaterialId(), depotHead.getNumber(), (depotItem.getBasicNumber() == null ? 0 : depotItem.getBasicNumber()).intValue(), userInfo);
                        }
                    }
                }
            }
        }
    }

    /**
     * Vérifier s'il existe des composants combinés et des sous-composants normaux pour les bons d'assemblage et de démontage
     * @param rowArr
     * @param subType
     */
    public void checkAssembleWithMaterialType(JSONArray rowArr, String subType) {
        if(BusinessConstants.SUB_TYPE_ASSEMBLE.equals(subType) ||
                BusinessConstants.SUB_TYPE_DISASSEMBLE.equals(subType)) {
            if(rowArr.size() > 1) {
                JSONObject firstRowObj = JSONObject.parseObject(rowArr.getString(0));
                JSONObject secondRowObj = JSONObject.parseObject(rowArr.getString(1));
                String firstMaterialType = firstRowObj.getString("mType");
                String secondMaterialType = secondRowObj.getString("mType");
                if(!BusinessConstants.MATERIAL_TYPE_ASSEMBLE.equals(firstMaterialType) || !BusinessConstants.MATERIAL_TYPE_NORMAL.equals(secondMaterialType)) {
                    throw new BusinessRunTimeException(ExceptionConstants.DEPOT_HEAD_CHECK_ASSEMBLE_EMPTY_CODE,
                            String.format(ExceptionConstants.DEPOT_HEAD_CHECK_ASSEMBLE_EMPTY_MSG));
                }
            } else {
                throw new BusinessRunTimeException(ExceptionConstants.DEPOT_HEAD_CHECK_ASSEMBLE_EMPTY_CODE,
                        String.format(ExceptionConstants.DEPOT_HEAD_CHECK_ASSEMBLE_EMPTY_MSG));
            }
        }
    }

    /**
     * Vérifier s'il existe des numéros de série dupliqués dans les détails multiples
     * @param rowArr
     */
    public void checkSerialNumberRepeat(JSONArray rowArr) {
        List<String> allSnArr = new ArrayList<>();
        for (int i = 0; i < rowArr.size(); i++) {
            JSONObject rowObj = JSONObject.parseObject(rowArr.getString(i));
            if(StringUtil.isNotEmpty(rowObj.getString("snList"))) {
                String snList = rowObj.getString("snList");
                snList = snList.replaceAll("，", ",");
                List<String> snArr = StringUtil.strToStringList(snList);
                if(snArr!=null && !snArr.isEmpty()) {
                    allSnArr.addAll(snArr);
                }
            }
        }
        Set<String> seen = new HashSet<>();
        Set<String> duplicates = new HashSet<>();
        for (String str : allSnArr) {
            if (!seen.add(str)) {
                duplicates.add(str);
            }
        }
        if(!duplicates.isEmpty()) {
            throw new BusinessRunTimeException(ExceptionConstants.DEPOT_HEAD_CHECK_SERIAL_NUMBER_REPEAT_CODE,
                    String.format(ExceptionConstants.DEPOT_HEAD_CHECK_SERIAL_NUMBER_REPEAT_MSG, String.join(", ", duplicates)));
        }
    }

    /**
     * Mettre à jour le prix du produit
     * @param meId
     * @param subType
     * @param rowObj
     */
    @Transactional(value = "transactionManager", rollbackFor = Exception.class)
    public void updateMaterialExtendPrice(Long meId, String subType, String billType, JSONObject rowObj) throws Exception {
        if(systemConfigService.getUpdateUnitPriceFlag()) {
            if (StringUtil.isExist(rowObj.get("unitPrice"))) {
                BigDecimal unitPrice = rowObj.getBigDecimal("unitPrice");
                MaterialExtend materialExtend = new MaterialExtend();
                materialExtend.setId(meId);
                if(BusinessConstants.SUB_TYPE_PURCHASE.equals(subType)) {
                    materialExtend.setPurchaseDecimal(unitPrice);
                }
                if(BusinessConstants.SUB_TYPE_SALES.equals(subType)) {
                    materialExtend.setWholesaleDecimal(unitPrice);
                }
                if(BusinessConstants.SUB_TYPE_RETAIL.equals(subType)) {
                    materialExtend.setCommodityDecimal(unitPrice);
                }
                // Autre entrée - cas d'entrée de production, mettre à jour le prix unitaire d'achat
                if(BusinessConstants.SUB_TYPE_OTHER.equals(subType)) {
                    if(BusinessConstants.BILL_TYPE_PRODUCE_IN.equals(billType)) {
                        materialExtend.setPurchaseDecimal(unitPrice);
                    }
                }
                materialExtendService.updateMaterialExtend(materialExtend);
            }
        }
    }

    @Transactional(value = "transactionManager", rollbackFor = Exception.class)
    public List<DepotItemStockWarningCount> findStockWarningCount(Integer offset, Integer rows, String materialParam, List<Long> depotList, List<Long> categoryList) {
        List<DepotItemStockWarningCount> list = null;
        try{
            list =depotItemMapperEx.findStockWarningCount(offset, rows, materialParam, depotList, categoryList);
        }catch(Exception e){
            JshException.readFail(logger, e);
        }
        return list;
    }

    @Transactional(value = "transactionManager", rollbackFor = Exception.class)
    public int findStockWarningCountTotal(String materialParam, List<Long> depotList, List<Long> categoryList) {
        int result = 0;
        try{
            result =depotItemMapperEx.findStockWarningCountTotal(materialParam, depotList, categoryList);
        }catch(Exception e){
            JshException.readFail(logger, e);
        }
        return result;
    }

    /**
     * Statistiques de stock - SKU
     * @param depotId
     * @param meId
     * @param beginTime
     * @param endTime
     * @return
     */
    public BigDecimal getSkuStockByParam(Long depotId, Long meId, String beginTime, String endTime) throws Exception {
        Boolean forceFlag = systemConfigService.getForceApprovalFlag();
        Boolean inOutManageFlag = systemConfigService.getInOutManageFlag();
        List<Long> depotList = depotService.parseDepotList(depotId);
        // Variation de quantité après révision d'inventaire
        BigDecimal stockCheckSum = depotItemMapperEx.getSkuStockCheckSumByDepotList(depotList, meId, forceFlag, beginTime, endTime);
        DepotItemVo4Stock stockObj = depotItemMapperEx.getSkuStockByParamWithDepotList(depotList, meId, forceFlag, inOutManageFlag, beginTime, endTime);
        BigDecimal stockSum = BigDecimal.ZERO;
        if(stockObj!=null) {
            BigDecimal inTotal = stockObj.getInTotal();
            BigDecimal transfInTotal = stockObj.getTransfInTotal();
            BigDecimal assemInTotal = stockObj.getAssemInTotal();
            BigDecimal disAssemInTotal = stockObj.getDisAssemInTotal();
            BigDecimal outTotal = stockObj.getOutTotal();
            BigDecimal transfOutTotal = stockObj.getTransfOutTotal();
            BigDecimal assemOutTotal = stockObj.getAssemOutTotal();
            BigDecimal disAssemOutTotal = stockObj.getDisAssemOutTotal();
            stockSum = inTotal.add(transfInTotal).add(assemInTotal).add(disAssemInTotal)
                    .subtract(outTotal).subtract(transfOutTotal).subtract(assemOutTotal).subtract(disAssemOutTotal);
        }
        return stockCheckSum.add(stockSum);
    }

    /**
     * Statistiques de stock - entrepôt unique
     * @param depotId
     * @param mId
     * @param beginTime
     * @param endTime
     * @return
     */
    public BigDecimal getStockByParam(Long depotId, Long mId, String beginTime, String endTime) throws Exception {
        List<Long> depotList = depotService.parseDepotList(depotId);
        return getStockByParamWithDepotList(depotList, mId, beginTime, endTime);
    }

    /**
     * Statistiques de stock - entrepôts multiples
     * @param depotList
     * @param mId
     * @param beginTime
     * @param endTime
     * @return
     */
    public BigDecimal getStockByParamWithDepotList(List<Long> depotList, Long mId, String beginTime, String endTime) throws Exception {
        Boolean forceFlag = systemConfigService.getForceApprovalFlag();
        Boolean inOutManageFlag = systemConfigService.getInOutManageFlag();
        // Stock initial
        BigDecimal initStock = materialService.getInitStockByMidAndDepotList(depotList, mId);
        // Variation de quantité après révision d'inventaire
        BigDecimal stockCheckSum = depotItemMapperEx.getStockCheckSumByDepotList(depotList, mId, forceFlag, beginTime, endTime);
        DepotItemVo4Stock stockObj = depotItemMapperEx.getStockByParamWithDepotList(depotList, mId, forceFlag, inOutManageFlag, beginTime, endTime);
        BigDecimal stockSum = BigDecimal.ZERO;
        if(stockObj!=null) {
            BigDecimal inTotal = stockObj.getInTotal();
            BigDecimal transfInTotal = stockObj.getTransfInTotal();
            BigDecimal assemInTotal = stockObj.getAssemInTotal();
            BigDecimal disAssemInTotal = stockObj.getDisAssemInTotal();
            BigDecimal outTotal = stockObj.getOutTotal();
            BigDecimal transfOutTotal = stockObj.getTransfOutTotal();
            BigDecimal assemOutTotal = stockObj.getAssemOutTotal();
            BigDecimal disAssemOutTotal = stockObj.getDisAssemOutTotal();
            stockSum = inTotal.add(transfInTotal).add(assemInTotal).add(disAssemInTotal)
                    .subtract(outTotal).subtract(transfOutTotal).subtract(assemOutTotal).subtract(disAssemOutTotal);
        }
        return initStock.add(stockCheckSum).add(stockSum);
    }

    /**
     * Statistiques des quantités d'entrée et de sortie dans la période - entrepôts multiples
     * @param depotList
     * @param mId
     * @param beginTime
     * @param endTime
     * @return
     */
    public Map<String, BigDecimal> getIntervalMapByParamWithDepotList(List<Long> depotList, Long mId, String beginTime, String endTime) throws Exception {
        Boolean forceFlag = systemConfigService.getForceApprovalFlag();
        Boolean inOutManageFlag = systemConfigService.getInOutManageFlag();
        Map<String,BigDecimal> intervalMap = new HashMap<>();
        BigDecimal inSum = BigDecimal.ZERO;
        BigDecimal outSum = BigDecimal.ZERO;
        // Variation de quantité après révision d'inventaire
        BigDecimal stockCheckSum = depotItemMapperEx.getStockCheckSumByDepotList(depotList, mId, forceFlag, beginTime, endTime);
        DepotItemVo4Stock stockObj = depotItemMapperEx.getStockByParamWithDepotList(depotList, mId, forceFlag, inOutManageFlag, beginTime, endTime);
        if(stockObj!=null) {
            BigDecimal inTotal = stockObj.getInTotal();
            BigDecimal transfInTotal = stockObj.getTransfInTotal();
            BigDecimal assemInTotal = stockObj.getAssemInTotal();
            BigDecimal disAssemInTotal = stockObj.getDisAssemInTotal();
            inSum = inTotal.add(transfInTotal).add(assemInTotal).add(disAssemInTotal);
            BigDecimal outTotal = stockObj.getOutTotal();
            BigDecimal transfOutTotal = stockObj.getTransfOutTotal();
            BigDecimal assemOutTotal = stockObj.getAssemOutTotal();
            BigDecimal disAssemOutTotal = stockObj.getDisAssemOutTotal();
            outSum = outTotal.add(transfOutTotal).add(assemOutTotal).add(disAssemOutTotal);
        }
        if(stockCheckSum.compareTo(BigDecimal.ZERO)>0) {
            inSum = inSum.add(stockCheckSum);
        } else {
            // Si la quantité de révision d'inventaire est négative, cela représente une sortie
            outSum = outSum.subtract(stockCheckSum);
        }
        intervalMap.put("inSum", inSum);
        intervalMap.put("outSum", outSum);
        return intervalMap;
    }

    /**
     * 根据单据明细来批量更新当前库存
     * @param depotItem
     */
    @Transactional(value = "transactionManager", rollbackFor = Exception.class)
    public void updateCurrentStock(DepotItem depotItem) throws Exception {
        BigDecimal currentUnitPrice = materialCurrentStockMapperEx.getCurrentUnitPriceByMId(depotItem.getMaterialId());
        updateCurrentStockFun(depotItem.getMaterialId(), depotItem.getDepotId(), currentUnitPrice);
        if(depotItem.getAnotherDepotId()!=null){
            updateCurrentStockFun(depotItem.getMaterialId(), depotItem.getAnotherDepotId(), currentUnitPrice);
        }
    }

    /**
     * 根据单据明细来批量更新当前成本价
     * @param depotItem
     */
    @Transactional(value = "transactionManager", rollbackFor = Exception.class)
    public void updateCurrentUnitPrice(DepotItem depotItem) throws Exception {
        Boolean forceFlag = systemConfigService.getForceApprovalFlag();
        // Ici, la valeur par défaut pour la gestion des entrées/sorties est false, sinon cela empêcherait de trouver les documents de vente
        Boolean inOutManageFlag = false;
        // Rechercher les informations multi-unités
        Unit unitInfo = materialService.findUnit(depotItem.getMaterialId());
        List<DepotItemVo4DetailByTypeAndMId> itemList = findDetailByDepotIdsAndMaterialIdList(null, forceFlag, inOutManageFlag, null,
                null, null, null, null, depotItem.getMaterialId(), null, null);
        Collections.reverse(itemList); // Après inversion, trier par ordre chronologique du plus ancien au plus récent
        BigDecimal currentNumber = BigDecimal.ZERO;
        BigDecimal currentUnitPrice = BigDecimal.ZERO;
        BigDecimal currentAllPrice = BigDecimal.ZERO;
        for(DepotItemVo4DetailByTypeAndMId item: itemList) {
            BigDecimal basicNumber = item.getBnum()!=null?item.getBnum():BigDecimal.ZERO;
            // Quantité * prix unitaire, calculer également le nouveau prix de revient
            BigDecimal allPrice = unitService.parseAllPriceByUnit(item.getAllPrice()!=null?item.getAllPrice():BigDecimal.ZERO, unitInfo, item.getMaterialUnit());
            if(basicNumber.compareTo(BigDecimal.ZERO)!=0 && allPrice.compareTo(BigDecimal.ZERO)!=0) {
                // Entrée
                if (BusinessConstants.DEPOTHEAD_TYPE_IN.equals(item.getType())) {
                    // Retour de vente au détail, retour de vente
                    if (BusinessConstants.SUB_TYPE_RETAIL_RETURN.equals(item.getSubType()) || BusinessConstants.SUB_TYPE_SALES_RETURN.equals(item.getSubType())) {
                        // Quantité * prix unitaire de revient actuel
                        currentNumber = currentNumber.add(basicNumber);
                        currentAllPrice = currentAllPrice.add(basicNumber.multiply(currentUnitPrice));
                    } else {
                        currentAllPrice = currentAllPrice.add(allPrice);
                        currentNumber = currentNumber.add(basicNumber);
                        // Calculer le prix moyen mobile uniquement si le montant total du stock actuel et la quantité du stock actuel sont tous deux supérieurs à 0
                        if (currentAllPrice.compareTo(BigDecimal.ZERO) > 0 && currentNumber.compareTo(BigDecimal.ZERO) > 0) {
                            currentUnitPrice = currentAllPrice.divide(currentNumber, 4, BigDecimal.ROUND_HALF_UP);
                        } else {
                            currentUnitPrice = item.getUnitPrice();
                        }
                    }
                }
                // Sortie
                if (BusinessConstants.DEPOTHEAD_TYPE_OUT.equals(item.getType())) {
                    // Retour d'achat
                    if (BusinessConstants.SUB_TYPE_PURCHASE_RETURN.equals(item.getSubType())) {
                        currentAllPrice = currentAllPrice.add(allPrice);
                        currentNumber = currentNumber.add(basicNumber);
                        // Calculer le prix moyen mobile uniquement si le montant total du stock actuel et la quantité du stock actuel sont tous deux supérieurs à 0
                        if (currentAllPrice.compareTo(BigDecimal.ZERO) > 0 && currentNumber.compareTo(BigDecimal.ZERO) > 0) {
                            currentUnitPrice = currentAllPrice.divide(currentNumber, 4, BigDecimal.ROUND_HALF_UP);
                        } else {
                            currentUnitPrice = item.getUnitPrice();
                        }
                    } else {
                        // Quantité * prix unitaire de revient actuel
                        currentNumber = currentNumber.add(basicNumber);
                        currentAllPrice = currentAllPrice.add(basicNumber.multiply(currentUnitPrice));
                    }
                }
                // Cas spéciaux : 1-Bon d'assemblage 2-Bon de démontage 3-Révision d'inventaire
                if(BusinessConstants.SUB_TYPE_ASSEMBLE.equals(item.getSubType())||
                        BusinessConstants.SUB_TYPE_DISASSEMBLE.equals(item.getSubType())||
                        BusinessConstants.SUB_TYPE_REPLAY.equals(item.getSubType())) {
                    //数量*当前的成本单价
                    currentNumber = currentNumber.add(basicNumber);
                    currentAllPrice = currentAllPrice.add(basicNumber.multiply(currentUnitPrice));
                }
                // Empêcher le débordement du montant du prix unitaire
                if(currentUnitPrice.compareTo(BigDecimal.valueOf(100000000))>0 || currentUnitPrice.compareTo(BigDecimal.valueOf(-100000000))<0) {
                    currentUnitPrice = BigDecimal.ZERO;
                }
            }
        }
        // Mettre à jour le prix unitaire actuel dans le stock en temps réel
        materialCurrentStockMapperEx.updateUnitPriceByMId(currentUnitPrice, depotItem.getMaterialId());
    }

    /**
     * 根据商品和仓库来更新当前库存
     * @param mId
     * @param dId
     */
    public void updateCurrentStockFun(Long mId, Long dId, BigDecimal currentUnitPrice) throws Exception {
        if(mId!=null && dId!=null) {
            MaterialCurrentStockExample example = new MaterialCurrentStockExample();
            example.createCriteria().andMaterialIdEqualTo(mId).andDepotIdEqualTo(dId)
                    .andDeleteFlagNotEqualTo(BusinessConstants.DELETE_FLAG_DELETED);
            List<MaterialCurrentStock> list = materialCurrentStockMapper.selectByExample(example);
            MaterialCurrentStock materialCurrentStock = new MaterialCurrentStock();
            materialCurrentStock.setMaterialId(mId);
            materialCurrentStock.setDepotId(dId);
            materialCurrentStock.setCurrentNumber(getStockByParam(dId,mId,null,null));
            materialCurrentStock.setCurrentUnitPrice(currentUnitPrice);
            if(list!=null && list.size()>0) {
                Long mcsId = list.get(0).getId();
                materialCurrentStock.setId(mcsId);
                materialCurrentStockMapper.updateByPrimaryKeySelective(materialCurrentStock);
            } else {
                materialCurrentStockMapper.insertSelective(materialCurrentStock);
            }
        }
    }

    @Transactional(value = "transactionManager", rollbackFor = Exception.class)
    public BigDecimal getFinishNumber(Long meId, Long id, Long headerId, Unit unitInfo, String materialUnit, String linkType) {
        Long linkId = id;
        String goToType = "";
        DepotHead depotHead =depotHeadMapper.selectByPrimaryKey(headerId);
        String linkStr = depotHead.getNumber(); // Numéro de commande
        if("purchase".equals(linkType)) {
            // Pour le cas d'achat basé sur la vente
            if(BusinessConstants.SUB_TYPE_SALES_ORDER.equals(depotHead.getSubType())) {
                goToType = BusinessConstants.SUB_TYPE_PURCHASE_ORDER;
            }
        } else if("other".equals(linkType)) {
            // Entrée d'achat, retour d'achat, sortie de vente, retour de vente sont tous convertis en autre entrée
            if(BusinessConstants.SUB_TYPE_PURCHASE.equals(depotHead.getSubType())
                    || BusinessConstants.SUB_TYPE_PURCHASE_RETURN.equals(depotHead.getSubType())
                    || BusinessConstants.SUB_TYPE_SALES.equals(depotHead.getSubType())
                    || BusinessConstants.SUB_TYPE_SALES_RETURN.equals(depotHead.getSubType())) {
                goToType = BusinessConstants.SUB_TYPE_OTHER;
            }
        } else if("basic".equals(linkType)) {
            // Commande d'achat convertie en entrée d'achat
            if(BusinessConstants.SUB_TYPE_PURCHASE_ORDER.equals(depotHead.getSubType())) {
                goToType = BusinessConstants.SUB_TYPE_PURCHASE;
            }
            // Commande de vente convertie en sortie de vente
            if(BusinessConstants.SUB_TYPE_SALES_ORDER.equals(depotHead.getSubType())) {
                goToType = BusinessConstants.SUB_TYPE_SALES;
            }
            // Entrée d'achat convertie en retour d'achat
            if(BusinessConstants.SUB_TYPE_PURCHASE.equals(depotHead.getSubType())) {
                goToType = BusinessConstants.SUB_TYPE_PURCHASE_RETURN;
            }
            // Sortie de vente convertie en retour de vente
            if(BusinessConstants.SUB_TYPE_SALES.equals(depotHead.getSubType())) {
                goToType = BusinessConstants.SUB_TYPE_SALES_RETURN;
            }
        }
        String noType = "normal";
        if(BusinessConstants.SUB_TYPE_PURCHASE_APPLY.equals(depotHead.getSubType())) {
            noType = "apply";
        }
        BigDecimal count = depotItemMapperEx.getFinishNumber(meId, linkId, linkStr, noType, goToType);
        // Conversion de quantité selon la situation multi-unités
        if(materialUnit.equals(unitInfo.getOtherUnit()) && unitInfo.getRatio()!=null && unitInfo.getRatio().compareTo(BigDecimal.ZERO)!=0) {
            count = count.divide(unitInfo.getRatio(),2,BigDecimal.ROUND_HALF_UP);
        }
        if(materialUnit.equals(unitInfo.getOtherUnitTwo()) && unitInfo.getRatioTwo()!=null && unitInfo.getRatioTwo().compareTo(BigDecimal.ZERO)!=0) {
            count = count.divide(unitInfo.getRatioTwo(),2,BigDecimal.ROUND_HALF_UP);
        }
        if(materialUnit.equals(unitInfo.getOtherUnitThree()) && unitInfo.getRatioThree()!=null && unitInfo.getRatioThree().compareTo(BigDecimal.ZERO)!=0) {
            count = count.divide(unitInfo.getRatioThree(),2,BigDecimal.ROUND_HALF_UP);
        }
        return count;
    }

    /**
     * Entrées | sorties | conversions en achat en dehors de ce document
     * @param currentSubType
     * @param meId
     * @param linkId
     * @param preHeaderId
     * @param currentHeaderId
     * @param unitInfo
     * @param materialUnit
     * @return
     */
    @Transactional(value = "transactionManager", rollbackFor = Exception.class)
    public BigDecimal getRealFinishNumber(String currentSubType, Long meId, Long linkId, Long preHeaderId, Long currentHeaderId, Unit unitInfo, String materialUnit) {
        String goToType = currentSubType;
        DepotHead depotHead =depotHeadMapper.selectByPrimaryKey(preHeaderId);
        String linkStr = depotHead.getNumber(); // Numéro de commande
        String linkType = "normal";
        if(BusinessConstants.SUB_TYPE_PURCHASE_APPLY.equals(depotHead.getSubType())) {
            linkType = "apply";
        }
        BigDecimal count = depotItemMapperEx.getRealFinishNumber(meId, linkId, linkStr, linkType, currentHeaderId, goToType);
        // Conversion de quantité selon la situation multi-unités
        if(materialUnit.equals(unitInfo.getOtherUnit()) && unitInfo.getRatio()!=null && unitInfo.getRatio().compareTo(BigDecimal.ZERO)!=0) {
            count = count.divide(unitInfo.getRatio(),2,BigDecimal.ROUND_HALF_UP);
        }
        if(materialUnit.equals(unitInfo.getOtherUnitTwo()) && unitInfo.getRatioTwo()!=null && unitInfo.getRatioTwo().compareTo(BigDecimal.ZERO)!=0) {
            count = count.divide(unitInfo.getRatioTwo(),2,BigDecimal.ROUND_HALF_UP);
        }
        if(materialUnit.equals(unitInfo.getOtherUnitThree()) && unitInfo.getRatioThree()!=null && unitInfo.getRatioThree().compareTo(BigDecimal.ZERO)!=0) {
            count = count.divide(unitInfo.getRatioThree(),2,BigDecimal.ROUND_HALF_UP);
        }
        return count;
    }

    public List<DepotItemVoBatchNumberList> getBatchNumberList(String number, String name, Long depotId, String barCode,
                                                               String batchNumber, Boolean forceFlag, Boolean inOutManageFlag) throws Exception {
        List<DepotItemVoBatchNumberList> reslist = new ArrayList<>();
        List<DepotItemVoBatchNumberList> list =  depotItemMapperEx.getBatchNumberList(StringUtil.toNull(number), name,
                depotId, barCode, batchNumber, forceFlag, inOutManageFlag);
        for(DepotItemVoBatchNumberList bn: list) {
            if(bn.getTotalNum()!=null && bn.getTotalNum().compareTo(BigDecimal.ZERO)>0) {
                bn.setExpirationDateStr(Tools.parseDateToStr(bn.getExpirationDate()));
                if(bn.getUnitId()!=null) {
                    Unit unit = unitService.getUnit(bn.getUnitId());
                    String commodityUnit = bn.getCommodityUnit();
                    bn.setTotalNum(unitService.parseStockByUnit(bn.getTotalNum(), unit, commodityUnit));
                }
                reslist.add(bn);
            }
        }
        return reslist;
    }

    /**
     * 查询某个批号的商品库存
     * @param depotId
     * @param barCode
     * @param batchNumber
     * @return
     * @throws Exception
     */
    public BigDecimal getOneBatchNumberStock(Long depotId, String barCode, String batchNumber) throws Exception {
        BigDecimal totalNum = BigDecimal.ZERO;
        Boolean forceFlag = systemConfigService.getForceApprovalFlag();
        Boolean inOutManageFlag = systemConfigService.getInOutManageFlag();
        List<DepotItemVoBatchNumberList> list =  depotItemMapperEx.getBatchNumberList(null, null,
                depotId, barCode, batchNumber, forceFlag, inOutManageFlag);
        if(list!=null && list.size()>0) {
            DepotItemVoBatchNumberList bn = list.get(0);
            totalNum = bn.getTotalNum();
            if(bn.getTotalNum()!=null && bn.getTotalNum().compareTo(BigDecimal.ZERO)>0) {
                if(bn.getUnitId()!=null) {
                    Unit unit = unitService.getUnit(bn.getUnitId());
                    String commodityUnit = bn.getCommodityUnit();
                    totalNum = unitService.parseStockByUnit(bn.getTotalNum(), unit, commodityUnit);
                }
            }
        }
        return totalNum;
    }

    public Long getCountByMaterialAndDepot(Long mId, Long depotId) {
        return depotItemMapperEx.getCountByMaterialAndDepot(mId, depotId);
    }

    public JSONObject parseMapByExcelData(String barCodes, List<Map<String, String>> detailList, String prefixNo) throws Exception {
        JSONObject map = new JSONObject();
        JSONArray arr = new JSONArray();
        List<MaterialVo4Unit> list = depotItemMapperEx.getBillItemByParam(barCodes);
        Map<String, MaterialVo4Unit> materialMap = new HashMap<>();
        Map<String, Long> depotMap = new HashMap<>();
        for (MaterialVo4Unit material: list) {
            materialMap.put(material.getmBarCode(), material);
        }
        JSONArray depotArr = depotService.findDepotByCurrentUser();
        for (Object depotObj: depotArr) {
            if(depotObj!=null) {
                JSONObject depotObject = JSONObject.parseObject(depotObj.toString());
                depotMap.put(depotObject.getString("depotName"), depotObject.getLong("id"));
            }
        }
        for (Map<String, String> detailMap: detailList) {
            JSONObject item = new JSONObject();
            String barCode = detailMap.get("barCode");
            if(StringUtil.isNotEmpty(barCode)) {
                MaterialVo4Unit m = materialMap.get(barCode);
                if(m!=null) {
                    // Vérifier si l'entrepôt existe
                    String depotName = detailMap.get("depotName");
                    if(StringUtil.isNotEmpty(depotName)) {
                        if(depotMap.get(depotName)!=null) {
                            item.put("depotName", depotName);
                            item.put("depotId", depotMap.get(depotName));
                        } else {
                            throw new BusinessRunTimeException(ExceptionConstants.DEPOT_ITEM_DEPOTNAME_IS_NOT_EXIST_CODE,
                                    String.format(ExceptionConstants.DEPOT_ITEM_DEPOTNAME_IS_NOT_EXIST_MSG, depotName));
                        }
                    }
                    item.put("barCode", barCode);
                    item.put("name", m.getName());
                    item.put("standard", m.getStandard());
                    if(StringUtil.isNotEmpty(m.getModel())) {
                        item.put("model", m.getModel());
                    }
                    if(StringUtil.isNotEmpty(m.getColor())) {
                        item.put("color", m.getColor());
                    }
                    if(StringUtil.isNotEmpty(m.getSku())) {
                        item.put("sku", m.getSku());
                    }
                    BigDecimal stock = BigDecimal.ZERO;
                    if(StringUtil.isNotEmpty(m.getSku())){
                        stock = getSkuStockByParam(null, m.getMeId(),null,null);
                    } else {
                        stock = getCurrentStockByParam(null, m.getId());
                    }
                    item.put("stock", stock);
                    item.put("unit", m.getCommodityUnit());
                    BigDecimal operNumber = BigDecimal.ZERO;
                    BigDecimal unitPrice = BigDecimal.ZERO;
                    BigDecimal taxRate = BigDecimal.ZERO;
                    if(StringUtil.isNotEmpty(detailMap.get("num"))) {
                        operNumber = new BigDecimal(detailMap.get("num"));
                    }
                    if(StringUtil.isNotEmpty(detailMap.get("unitPrice"))) {
                        unitPrice = new BigDecimal(detailMap.get("unitPrice"));
                    } else {
                        if("CGDD".equals(prefixNo)) {
                            unitPrice = m.getPurchaseDecimal();
                        } else if("XSDD".equals(prefixNo)) {
                            unitPrice = m.getWholesaleDecimal();
                        }
                    }
                    if(StringUtil.isNotEmpty(detailMap.get("taxRate"))) {
                        taxRate = new BigDecimal(detailMap.get("taxRate"));
                    }
                    String remark = detailMap.get("remark");
                    item.put("operNumber", operNumber);
                    item.put("unitPrice", unitPrice);
                    BigDecimal allPrice = BigDecimal.ZERO;
                    if(unitPrice!=null && unitPrice.compareTo(BigDecimal.ZERO)!=0) {
                        allPrice = unitPrice.multiply(operNumber).setScale(2, BigDecimal.ROUND_HALF_UP);
                    }
                    BigDecimal taxMoney = BigDecimal.ZERO;
                    if(taxRate.compareTo(BigDecimal.ZERO) != 0) {
                        taxMoney = taxRate.multiply(allPrice).divide(BigDecimal.valueOf(100), 2, BigDecimal.ROUND_HALF_UP);
                    }
                    BigDecimal taxLastMoney = allPrice.add(taxMoney);
                    item.put("allPrice", allPrice);
                    item.put("taxRate", taxRate);
                    item.put("taxMoney", taxMoney);
                    item.put("taxLastMoney", taxLastMoney);
                    item.put("remark", remark);
                    arr.add(item);
                } else {
                    throw new BusinessRunTimeException(ExceptionConstants.DEPOT_ITEM_BARCODE_IS_NOT_EXIST_CODE,
                            String.format(ExceptionConstants.DEPOT_ITEM_BARCODE_IS_NOT_EXIST_MSG, barCode));
                }
            }
        }
        map.put("rows", arr);
        return map;
    }

    public BigDecimal getLastUnitPriceByParam(Long organId, Long meId, String prefixNo) {
        String type = "";
        String subType = "";
        if("XSDD".equals(prefixNo)) {
            type = BusinessConstants.DEPOTHEAD_TYPE_OTHER;
            subType = BusinessConstants.SUB_TYPE_SALES_ORDER;
        } else if("XSCK".equals(prefixNo)) {
            type = BusinessConstants.DEPOTHEAD_TYPE_OUT;
            subType = BusinessConstants.SUB_TYPE_SALES;
        } else if("XSTH".equals(prefixNo)) {
            type = BusinessConstants.DEPOTHEAD_TYPE_IN;
            subType = BusinessConstants.SUB_TYPE_SALES_RETURN;
        } else if("QTCK".equals(prefixNo)) {
            type = BusinessConstants.DEPOTHEAD_TYPE_OUT;
            subType = BusinessConstants.DEPOTHEAD_TYPE_OTHER;
        }
        return depotItemMapperEx.getLastUnitPriceByParam(organId, meId, type, subType);
    }

    public BigDecimal getCurrentStockByParam(Long depotId, Long mId) {
        BigDecimal stock = depotItemMapperEx.getCurrentStockByParam(depotId, mId);
        return stock!=null? stock: BigDecimal.ZERO;
    }
}
