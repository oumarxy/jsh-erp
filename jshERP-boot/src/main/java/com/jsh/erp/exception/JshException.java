package com.jsh.erp.exception;

import com.jsh.erp.constants.ExceptionConstants;
import org.slf4j.Logger;

/**
 * Encapsulation de l'impression des journaux, collecte des journaux
 * author: ji shenghua, qq 752718 920
 */
public class JshException {

    public static void readFail(Logger logger, Exception e) {
        logger.error("Code d'erreur[{}], Message d'erreur[{}], Exception[{}]",
                ExceptionConstants.DATA_READ_FAIL_CODE, ExceptionConstants.DATA_READ_FAIL_MSG,e);
        throw new BusinessRunTimeException(ExceptionConstants.DATA_READ_FAIL_CODE,
                ExceptionConstants.DATA_READ_FAIL_MSG);
    }

    public static void writeFail(Logger logger, Exception e) {
        logger.error("Code d'erreur[{}], Message d'erreur[{}], Exception[{}]",
                ExceptionConstants.DATA_WRITE_FAIL_CODE,ExceptionConstants.DATA_WRITE_FAIL_MSG,e);
        throw new BusinessRunTimeException(ExceptionConstants.DATA_WRITE_FAIL_CODE,
                ExceptionConstants.DATA_WRITE_FAIL_MSG);
    }


}
