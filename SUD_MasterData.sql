SELECT
    A0."TransType",
	A0."Gate_Pass_No." AS "MR_No",
	A0."SI No",
	A0."Dr No",
	A0."In Date",
	A0."Qty" AS "Qty",
	A0."Age",
	A0."0-30_Days",
	A0."31-60_Days",
	A0."61-90_Days",
	A0."91-120_Days",
	A0."Over 120_Days",
	A0."Prepared_By",
	A0."Requested_By",
	A0."Approved_By",
	A0."ItemName",
	A0."Serial Number",
	A0."Item Code",
	A0."Customer_Name",
	A0."Date",
	A0."Dist1",
	A0."Dist2",
	A0."G/L Account",
	A0."S_Employee",
    A0."OcrCode3",
    A0."BussLine",
	A0."AppLine",
	A0."Category",
	A0."Model"
	
FROM
(
	SELECT
		'GI' AS "TransType",
		A3."DocEntry",
		A0."DistNumber" AS "Serial Number",
		A0."U_ITEMCODE" AS "Item Code",
		A1."Quantity" AS "Qty",
		A0."U_SINO" AS "SI No",
		A0."U_DRNO" AS "Dr No",
		IFNULL(A0."U_INDATE", (SELECT "DocDate" FROM ODLN WHERE A0."U_DRNO" = "DocNum")) AS "In Date",
		DAYS_BETWEEN(IFNULL(A0."U_INDATE", (SELECT "DocDate" FROM ODLN WHERE A0."U_DRNO" = "DocNum")), {?Date}) AS "Age",
		CASE WHEN DAYS_BETWEEN(IFNULL(A0."U_INDATE", (SELECT "DocDate" FROM ODLN WHERE A0."U_DRNO" = "DocNum")), {?Date}) <= 30 THEN A1."Quantity" ELSE 0 END AS "0-30_Days",
		CASE WHEN DAYS_BETWEEN(IFNULL(A0."U_INDATE", (SELECT "DocDate" FROM ODLN WHERE A0."U_DRNO" = "DocNum")), {?Date}) BETWEEN 31 AND 60 THEN A1."Quantity" ELSE 0 END AS "31-60_Days",
		CASE WHEN DAYS_BETWEEN(IFNULL(A0."U_INDATE", (SELECT "DocDate" FROM ODLN WHERE A0."U_DRNO" = "DocNum")), {?Date}) BETWEEN 61 AND 90 THEN A1."Quantity" ELSE 0 END AS "61-90_Days",
		CASE WHEN DAYS_BETWEEN(IFNULL(A0."U_INDATE", (SELECT "DocDate" FROM ODLN WHERE A0."U_DRNO" = "DocNum")), {?Date}) BETWEEN 91 AND 120 THEN A1."Quantity" ELSE 0 END AS "91-120_Days",
		CASE WHEN DAYS_BETWEEN(IFNULL(A0."U_INDATE", (SELECT "DocDate" FROM ODLN WHERE A0."U_DRNO" = "DocNum")), {?Date}) > 120 THEN A1."Quantity" ELSE 0 END AS "Over 120_Days",

		A4."U_PrepBy" AS "Prepared_By",
		A4."U_ReqBy" AS "Requested_By",
		A4."U_AppBy" AS "Approved_By",
		A4."DocNum" AS "Gate_Pass_No.",
		A4."DocDate" AS "Date",
		A6."Name" AS "Reason",
		A5."CardName" AS "Customer_Name",
		A5."ShipToCode" AS "Address",
		A7."ItemName",
		A3."ItemCode",
		A3."Dscription",
		OOCR_Dist1."OcrName" AS "Dist1",
		OOCR_Dist2."OcrName" AS "Dist2",
		P3."AcctName" "G/L Account",
		P4."SlpName" "S_Employee",
        P2."OcrCode3",
        S1."Name"  "BussLine",
        S2."Name"  "AppLine",
        S3."Name"  "Category",
        A7."U_MODEL" "Model"

	FROM
		OSRN A0 INNER JOIN ITL1 A1  
		           ON A0."AbsEntry" = A1."MdAbsEntry"
		           
		INNER JOIN OITL A2  
		           ON A1."LogEntry" = A2."LogEntry"
		           
		INNER JOIN IGE1 A3  
		           ON A2."ApplyEntry" = A3."DocEntry"  
		           AND A2."ApplyType" = A3."ObjType"  
		           AND A2."ApplyLine" = A3."LineNum"
		           
		INNER JOIN OIGE A4  
		           ON A3."DocEntry" = A4."DocEntry"
		           
		LEFT JOIN OINV A5  
		           ON A0."U_SINO" = A5."DocNum"
		           
		LEFT JOIN INV1 P2  
		           ON A5."DocEntry" = P2."DocEntry"
		
		LEFT JOIN OOCR OOCR_Dist1  
		           ON P2."OcrCode2" = OOCR_Dist1."OcrCode"

		LEFT JOIN OOCR OOCR_Dist2  
		           ON P2."OcrCode3" = OOCR_Dist2."OcrCode"
        
        LEFT JOIN OACT P3  
                    ON P2."AcctCode" = P3."AcctCode"
                    
        LEFT JOIN OSLP P4  
                    ON P2."SlpCode" = P4."SlpCode"

		LEFT JOIN "@ISSUE_TYPE" A6  
		           ON A3."U_ISSUE_TYPE" = A6."Code"
		           
		LEFT JOIN OITM A7  
		           ON A0."U_ITEMCODE" = A7."ItemCode"

		LEFT JOIN "@BUSSLINE" S1  
		           ON A7."U_BUSSLINE" = S1."Code"
		           
		LEFT JOIN "@APPLINE" S2  
		           ON A7."U_APPLINE" = S2."Code"
		           
		LEFT JOIN "@CATEGORY_1" S3  
		           ON A7."U_CATEGORY_1" = S3."Code"
		           	         
	WHERE
		A4."DocDate" <= {?Date}
		AND A3."ItemCode" = 'SUD'
		
	UNION ALL

	-- GR (Goods Receipt) subquery - We add a check here!
	SELECT
		'GR' AS "TransType",
		T3."DocEntry",
		A0."DistNumber" AS "Serial Number",
		A0."U_ITEMCODE" AS "Item Code",
		A1."Quantity" AS "Qty",
		MAX(A0."U_SINO") AS "SI No",
		MAX(A0."U_DRNO") AS "Dr No",
		IFNULL(MAX(A0."U_INDATE"), (SELECT "DocDate" FROM ODLN WHERE A0."U_DRNO" = "DocNum")) AS "In Date",
		DAYS_BETWEEN(IFNULL(A0."U_INDATE", (SELECT "DocDate" FROM ODLN WHERE A0."U_DRNO" = "DocNum")), {?Date}) AS "Age",
		CASE WHEN DAYS_BETWEEN(IFNULL(A0."U_INDATE", (SELECT "DocDate" FROM ODLN WHERE A0."U_DRNO" = "DocNum")), {?Date}) <= 30 THEN A1."Quantity" ELSE 0 END AS "0-30_Days",
		CASE WHEN DAYS_BETWEEN(IFNULL(A0."U_INDATE", (SELECT "DocDate" FROM ODLN WHERE A0."U_DRNO" = "DocNum")), {?Date}) BETWEEN 31 AND 60 THEN A1."Quantity" ELSE 0 END AS "31-60_Days",
		CASE WHEN DAYS_BETWEEN(IFNULL(A0."U_INDATE", (SELECT "DocDate" FROM ODLN WHERE A0."U_DRNO" = "DocNum")), {?Date}) BETWEEN 61 AND 90 THEN A1."Quantity" ELSE 0 END AS "61-90_Days",
		CASE WHEN DAYS_BETWEEN(IFNULL(A0."U_INDATE", (SELECT "DocDate" FROM ODLN WHERE A0."U_DRNO" = "DocNum")), {?Date}) BETWEEN 91 AND 120 THEN A1."Quantity" ELSE 0 END AS "91-120_Days",
		CASE WHEN DAYS_BETWEEN(IFNULL(A0."U_INDATE", (SELECT "DocDate" FROM ODLN WHERE A0."U_DRNO" = "DocNum")), {?Date}) > 120 THEN A1."Quantity" ELSE 0 END AS "Over 120_Days",

		T4."U_PrepBy" AS "Prepared_By",
		T4."U_ReqBy" AS "Requested_By",
		T4."U_AppBy" AS "Approved_By",
		T4."DocNum" AS "Gate_Pass_No.",
		T4."DocDate" AS "Date",
		A6."Name" AS "Reason",
		A5."CardName" AS "Customer_Name",
		A5."ShipToCode" AS "Address",
		A7."ItemName",
		T3."ItemCode",
		T3."Dscription",
		OOCR_Dist1."OcrName" AS "Dist1",
		OOCR_Dist2."OcrName" AS "Dist2",
		P3."AcctName" "G/L Account",
		P4."SlpName" "S_Employee",
        P2."OcrCode3",
        S1."Name"  "BussLine",
        S2."Name"  "AppLine",
        S3."Name"  "Category",
        A7."U_MODEL" "Model"

	FROM
		OSRN A0 INNER JOIN ITL1 A1  
		           ON A0."AbsEntry" = A1."MdAbsEntry"
		           
		INNER JOIN OITL A2  
		           ON A1."LogEntry" = A2."LogEntry"
		           
		INNER JOIN IGN1 T3  
		           ON A2."ApplyEntry" = T3."DocEntry"  
		           AND A2."ApplyType" = T3."ObjType"  
		           AND A2."ApplyLine" = T3."LineNum"
		           
		INNER JOIN OIGN T4  
		           ON T3."DocEntry" = T4."DocEntry"
		           
		LEFT JOIN OINV A5  
		           ON A0."U_SINO" = A5."DocNum"
		           
		LEFT JOIN INV1 P2  
		           ON A5."DocEntry" = P2."DocEntry"

		LEFT JOIN OOCR OOCR_Dist1  
		           ON P2."OcrCode2" = OOCR_Dist1."OcrCode"

		LEFT JOIN OOCR OOCR_Dist2  
		           ON P2."OcrCode3" = OOCR_Dist2."OcrCode"
        
        LEFT JOIN OACT P3  
                    ON P2."AcctCode" = P3."AcctCode"
                    
        LEFT JOIN OSLP P4  
                    ON P2."SlpCode" = P4."SlpCode"

		LEFT JOIN "@ISSUE_TYPE" A6  
		           ON T3."U_ISSUE_TYPE" = A6."Code"
		           
		LEFT JOIN OITM A7  
		           ON A0."U_ITEMCODE" = A7."ItemCode"
		           
		LEFT JOIN "@BUSSLINE" S1  
		           ON A7."U_BUSSLINE" = S1."Code"
		           
		LEFT JOIN "@APPLINE" S2  
		           ON A7."U_APPLINE" = S2."Code"
		           
		LEFT JOIN "@CATEGORY_1" S3  
		           ON A7."U_CATEGORY_1" = S3."Code"
		           	         
	WHERE
		T4."DocDate" <= {?Date}
		AND T3."ItemCode" = 'SUD'
		--AND A1."Quantity" = '1'
		AND NOT EXISTS (
			SELECT 1
			FROM OITL OITL_GI
			INNER JOIN IGE1 IGE1_GI ON OITL_GI."ApplyEntry" = IGE1_GI."DocEntry"
			INNER JOIN ITL1 ITL1_GI ON OITL_GI."LogEntry" = ITL1_GI."LogEntry"
			WHERE ITL1_GI."MdAbsEntry" = A0."AbsEntry"
		)
		
	GROUP BY
	T3."DocEntry",
	A0."DistNumber",
	A0."U_ITEMCODE",
	A1."Quantity",
	A0."U_INDATE",
	T4."U_PrepBy",
	T4."U_ReqBy",
	T4."U_AppBy",
	T4."DocNum",
	T4."DocDate",
	A6."Name",
	A5."CardName",
	A5."ShipToCode",
	A7."ItemName",
	T3."ItemCode",
	T3."Dscription",
	OOCR_Dist1."OcrName",
	OOCR_Dist2."OcrName",
	P3."AcctName",
	P4."SlpName",
	P2."OcrCode3",
	S1."Name",
	S2."Name",
	S3."Name",
	A7."U_MODEL",
	A0."U_DRNO"
		
) A0


WHERE A0."TransType" = 'GR' 


GROUP BY
    A0."TransType",
	A0."Gate_Pass_No.",
	A0."SI No",
	A0."Dr No",
	A0."In Date",
	A0."Age",
	A0."0-30_Days",
	A0."31-60_Days",
	A0."61-90_Days",
	A0."91-120_Days",
	A0."Over 120_Days",
	A0."Prepared_By",
	A0."Requested_By",
	A0."Approved_By",
	A0."ItemName",
	A0."Serial Number",
	A0."Item Code",
	A0."Customer_Name",
	A0."Date",
	A0."Dist1",
	A0."Dist2",
	A0."G/L Account",
	A0."S_Employee",
    A0."Qty",
    A0."OcrCode3",
    A0."BussLine",
	A0."AppLine",
	A0."Category",
	A0."Model"
	
	
HAVING
	SUM(A0."Qty") > 0
