package com.jsh.erp.utils;

import com.jsh.erp.constants.BusinessConstants;
import java.io.*;
import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.util.*;

import jxl.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.util.StringUtils;
import jxl.format.*;
import jxl.write.Label;
import jxl.write.WritableCellFormat;
import jxl.write.WritableFont;
import jxl.write.WritableSheet;
import jxl.write.WritableWorkbook;

import javax.servlet.http.HttpServletResponse;

@Slf4j
public class ExcelUtils {

	public static InputStream getPathByFileName(String template, String tmpFileName) {
		File tmpFile = new File(template, tmpFileName);
		InputStream path = null;
		// Vérifier si le fichier ou le dossier existe
		if (tmpFile.exists()) {
			try {
				path = new FileInputStream(tmpFile);
			} catch (FileNotFoundException e) {
				log.error("", e);
			}
		}
		return path;
	}

	/**
	 * Exporter excel, avec plusieurs feuilles
	 *
	 * @param wtwb
	 * @param tip
	 * @param names
	 * @param title
	 * @param index
	 * @param objects
	 * @return
	 * @throws Exception
	 */
	public static void exportObjectsManySheet(WritableWorkbook wtwb, String tip,
											  String[] names, String title, int index, List<String[]> objects) throws Exception {
		WritableSheet sheet = wtwb.createSheet(title, index);
		sheet.getSettings().setDefaultColumnWidth(12);

		// Format du titre - rouge
		WritableFont redWF = new WritableFont(WritableFont.ARIAL, 12,
				WritableFont.BOLD, false, UnderlineStyle.NO_UNDERLINE,
				Colour.RED);
		WritableCellFormat redWFFC = new WritableCellFormat(redWF);
		redWFFC.setVerticalAlignment(VerticalAlignment.CENTRE);
		redWFFC.setBorder(Border.ALL, BorderLineStyle.THIN);

		// Format du titre - noir
		WritableFont blackWF = new WritableFont(WritableFont.ARIAL, 12,
				WritableFont.BOLD, false, UnderlineStyle.NO_UNDERLINE,
				Colour.BLACK);
		WritableCellFormat blackWFFC = new WritableCellFormat(blackWF);
		blackWFFC.setVerticalAlignment(VerticalAlignment.CENTRE);
		blackWFFC.setBorder(Border.ALL, BorderLineStyle.THIN);

		// Définir la police et le format de cellule
		WritableFont wfont = new WritableFont(WritableFont.createFont(BusinessConstants.EXCEL_FONT_NAME), 12);
		WritableCellFormat format = new WritableCellFormat(wfont);
		format.setAlignment(Alignment.LEFT);
		format.setVerticalAlignment(VerticalAlignment.TOP);
		format.setBorder(jxl.format.Border.ALL,jxl.format.BorderLineStyle.THIN);

		// Écrire l'avertissement dans la première ligne
		if(com.jsh.erp.utils.StringUtil.isNotEmpty(tip) && tip.contains("*")) {
			sheet.addCell(new Label(0, 0, tip, redWFFC));
		} else {
			sheet.addCell(new Label(0, 0, tip, blackWFFC));
		}

		// Écrire les titres dans la deuxième ligne
		for (int i = 0; i < names.length; i++) {
			if(StringUtil.isNotEmpty(names[i]) && names[i].contains("*")) {
				sheet.addCell(new Label(i, 1, names[i], redWFFC));
			} else {
				sheet.addCell(new Label(i, 1, names[i], blackWFFC));
			}
		}

		// Écrire les données dans les lignes restantes
		int rowNum = 2;
		for (int j = 0; j < objects.size(); j++) {
			String[] obj = objects.get(j);
			for (int h = 0; h < obj.length; h++) {
				sheet.addCell(new Label(h, rowNum, obj[h], format));
			}
			rowNum = rowNum + 1;
		}
	}

	/**
	 * Exporter excel, avec une seule feuille
	 *
	 * @param fileName
	 * @param names
	 * @param title
	 * @param objects
	 * @return
	 * @throws Exception
	 */

	public static File exportObjectsOneSheet(String fileName, String tip,
											 String[] names, String title, List<Object[]> objects) throws Exception {
		File excelFile = new File("/opt/"+ fileName);
		WritableWorkbook wtwb = Workbook.createWorkbook(excelFile);
		WritableSheet sheet = wtwb.createSheet(title, 0);
		sheet.getSettings().setDefaultColumnWidth(12);

		// Format du titre - rouge
		WritableFont redWF = new WritableFont(WritableFont.ARIAL, 12,
				WritableFont.BOLD, false, UnderlineStyle.NO_UNDERLINE, Colour.RED);
		WritableCellFormat redWFFC = new WritableCellFormat(redWF);
		redWFFC.setVerticalAlignment(VerticalAlignment.CENTRE);
		redWFFC.setBorder(jxl.format.Border.ALL,jxl.format.BorderLineStyle.THIN);

		// Format du titre - noir
		WritableFont blackWF = new WritableFont(WritableFont.ARIAL, 12,
				WritableFont.BOLD, false, UnderlineStyle.NO_UNDERLINE, Colour.BLACK);
		WritableCellFormat blackWFFC = new WritableCellFormat(blackWF);
		blackWFFC.setVerticalAlignment(VerticalAlignment.CENTRE);
		blackWFFC.setBorder(jxl.format.Border.ALL,jxl.format.BorderLineStyle.THIN);

		// Définir la police et le format de cellule
		WritableFont wfont = new WritableFont(WritableFont.createFont(BusinessConstants.EXCEL_FONT_NAME), 12);
		WritableCellFormat format = new WritableCellFormat(wfont);
		format.setAlignment(Alignment.LEFT);
		format.setVerticalAlignment(VerticalAlignment.TOP);
		format.setBorder(jxl.format.Border.ALL,jxl.format.BorderLineStyle.THIN);

		// Écrire l'avertissement dans la première ligne
		if(StringUtil.isNotEmpty(tip) && tip.contains("*")) {
			sheet.addCell(new Label(0, 0, tip, redWFFC));
		} else {
			sheet.addCell(new Label(0, 0, tip, blackWFFC));
		}

		// Écrire les titres dans la deuxième ligne
		for (int i = 0; i < names.length; i++) {
			if(StringUtil.isNotEmpty(names[i]) && names[i].contains("*")) {
				sheet.addCell(new Label(i, 1, names[i], redWFFC));
			} else {
				sheet.addCell(new Label(i, 1, names[i], blackWFFC));
			}
		}

		// Écrire les données dans les lignes restantes
		int rowNum = 2;
		for (int j = 0; j < objects.size(); j++) {
			Object[] obj = objects.get(j);
			for (int h = 0; h < obj.length; h++) {
				if(obj[h] instanceof String) {
					sheet.addCell(new Label(h, rowNum, obj[h].toString(), format));
				} else if(obj[h] instanceof BigDecimal || obj[h] instanceof Double || obj[h] instanceof Integer || obj[h] instanceof Long) {
					sheet.addCell(new jxl.write.Number(h, rowNum, Double.parseDouble(obj[h].toString()), format));
				} else {
					String cont = obj[h]!=null?obj[h].toString():"";
					sheet.addCell(new Label(h, rowNum, cont, format));
				}
			}
			rowNum = rowNum + 1;
		}
		wtwb.write();
		wtwb.close();
		return excelFile;
	}

	public static String getContent(Sheet src, int rowNum, int colNum) {
		if(colNum < src.getRow(rowNum).length) {
			return src.getRow(rowNum)[colNum].getContents().trim();
		} else {
			return null;
		}
	}

	public static String getContentNumber(Sheet src, int rowNum, int colNum) {
		if(colNum < src.getRow(rowNum).length) {
			Cell cell = src.getCell(colNum, rowNum);
			if(cell.getType() == CellType.NUMBER) {
				NumberCell numCell = (NumberCell)cell;
				double value = numCell.getValue(); // Obtenir la valeur numérique avec précision complète
				DecimalFormat df = new DecimalFormat("#.######"); // Définir suffisamment de décimales
				return df.format(value);
			} else {
				return cell.getContents().trim(); // Obtenir le contenu de la chaîne originale
			}
		} else {
			return null;
		}
	}

	/**
	 * Obtenir le nombre réel de lignes, en excluant les lignes vides
	 * @param src
	 * @return
	 */
	public static int getRightRows(Sheet src) {
		int rsRows = src.getRows(); // Nombre de lignes
		int rsCols = src.getColumns(); // Nombre de colonnes
		int nullCellNum;
		int rightRows = rsRows;
		for (int i = 1; i < rsRows; i++) { // Compter le nombre de cellules vides dans la ligne
			nullCellNum = 0;
			for (int j = 0; j < rsCols; j++) {
				String val = src.getCell(j, i).getContents().trim();
				if (StringUtils.isEmpty(val)) {
					nullCellNum++;
				}
			}
			if (nullCellNum >= rsCols) { // Si nullCellNum est supérieur ou égal au nombre total de colonnes
				rightRows--; // Décrémenter le nombre de lignes
			}
		}
		return rightRows;
	}

	public static void downloadExcel(File excelFile, String fileName, HttpServletResponse response) throws Exception{
		response.setContentType("application/octet-stream");
		fileName = new String(fileName.getBytes("gbk"),"ISO8859_1");
		response.setHeader("Content-Disposition", "attachment;filename=\"" + fileName + ".xls" + "\"");
		FileInputStream fis = new FileInputStream(excelFile);
		OutputStream out = response.getOutputStream();

		int SIZE = 1024 * 1024;
		byte[] bytes = new byte[SIZE];
		int LENGTH = -1;
		while((LENGTH = fis.read(bytes)) != -1){
			out.write(bytes,0,LENGTH);
		}
		out.flush();
		fis.close();
	}
}
