/* SELECT FROM ODLN T0 */
DECLARE DF date;
DECLARE DT date;
DF := /* T0."DocDate" */ '[%0]';
DT := /* T0."DocDate" */ '[%1]';

SELECT 
	*
FROM
(
	SELECT
		'DN' "Doc"
		, CASE WHEN A0."CANCELED" = 'C'
			THEN 'Cancelled'
			ELSE ( CASE A0."DocStatus"
						WHEN 'O' THEN 'Open'
						WHEN 'C' THEN 'Closed'
					END	) END "DocStatus"
                          , CASE WHEN A0."Printed" = 'Y' THEN 'Printed' ELSE 'Not Printed' END AS "Print Status"
		, A0."DocNum"
		, A0."DocDate"
		, MONTHNAME(A0."DocDate") "Month"
		, A0."CardCode"
		, A0."CardName"
		--, A0."Address2" "Ship-To Address"
		, IFNULL((SELECT S2."Street" FROM OCRD S1 INNER JOIN CRD1 S2 ON S1."CardCode" = S2."CardCode" 
		                  WHERE S2."AdresType" = 'S' AND A0."CardCode" = S2."CardCode" AND S1."ShipToDef" = S2."Address"), A0."Address2") AS "Ship-To Address"
		, A1."ItemCode"
                          , REPLACE_REGEXPR('[^0-9]' IN B2."Cellular" WITH '') "Mobile #"
		, A1."Dscription"
		, A3."ItmsGrpNam" "ItemGroup"
		/*, CASE WHEN A0."CANCELED" <> 'C' 
		THEN A1."Quantity"
		ELSE A1."Quantity"*-1
	  END "Quantity"*/
		, CASE WHEN A0."CANCELED" <> 'C'
			THEN IFNULL(B1."Quantity"*-1,A1."Quantity")
			ELSE IFNULL(B1."Quantity",A1."Quantity")*-1
		  END "Quantity"
		, B1."DistNumber" "Serial Number"
		, A1."WhsCode"
		, A4."OcrName" "Sales Type"
		, A5."OcrName"
		, A6."OcrName" "Sales Loc"
		, A7."Name" "BusLine"
		, A8."Name" "AppLine"
		, A9."Name" "Category"
		, A2."U_MODEL" "Model"
		, (SELECT "SlpName" FROM OSLP WHERE "SlpCode" = A0."SlpCode") "AO"
		, B0."FormatCode"
		, B0."AcctName"
  
	FROM
		ODLN A0 INNER JOIN DLN1 A1 ON A0."DocEntry" = A1."DocEntry"
		INNER JOIN OITM A2 ON A1."ItemCode" = A2."ItemCode"
		INNER JOIN OITB A3 ON A2."ItmsGrpCod" = A3."ItmsGrpCod"
		LEFT JOIN OOCR A4 ON A1."OcrCode" = A4."OcrCode"
		LEFT JOIN OOCR A5 ON A1."OcrCode2" = A5."OcrCode"
		LEFT JOIN OOCR A6 ON A1."OcrCode3" = A6."OcrCode"
		LEFT JOIN "@BUSSLINE" A7 ON A2."U_BUSSLINE" = A7."Code"
		LEFT JOIN "@APPLINE" A8 ON A2."U_APPLINE" = A8."Code"
		LEFT JOIN "@CATEGORY_1" A9 ON A2."U_CATEGORY_1" = A9."Code"
		INNER JOIN OACT B0 ON A1."CogsAcct" = B0."AcctCode"
                          LEFT JOIN OCRD B2 ON A0."CardCode" = B2."CardCode"
		LEFT JOIN (	SELECT
						C0."DistNumber"
						, C1."Quantity"
						, C2."ApplyEntry"
						, C2."ApplyLine"
						, C2."ApplyType"
					FROM
						OSRN C0 INNER JOIN ITL1 C1 ON C0."AbsEntry" = C1."MdAbsEntry"
						INNER JOIN OITL C2 ON C1."LogEntry" = C2."LogEntry"
					WHERE
						C1."Quantity" <> 0
						) B1 ON A1."DocEntry" = B1."ApplyEntry" AND A1."LineNum" = B1."ApplyLine" AND A1."ObjType"= B1."ApplyType"
	WHERE
		A0."DocDate" BETWEEN :DF AND :DT	
						
	UNION ALL
	
	SELECT
		'RE' "Doc"
		, CASE WHEN A0."CANCELED" = 'C'
			THEN 'Cancelled'
			ELSE ( CASE A0."DocStatus"
						WHEN 'O' THEN 'Open'
						WHEN 'C' THEN 'Closed'
					END	) END "DocStatus"
                         ,NULL
		, A0."DocNum"
		, A0."DocDate"
		, MONTHNAME(A0."DocDate") "Month"
		, A0."CardCode"
		, A0."CardName"
		--, A0."Address2" "Ship-To Address"
		, IFNULL((SELECT S2."Street" FROM OCRD S1 INNER JOIN CRD1 S2 ON S1."CardCode" = S2."CardCode" 
		                  WHERE S2."AdresType" = 'S' AND A0."CardCode" = S2."CardCode" AND S1."ShipToDef" = S2."Address"), A0."Address2") AS "Ship-To Address"
		, A1."ItemCode"
                          , REPLACE_REGEXPR('[^0-9]' IN B2."Cellular" WITH '') "Mobile #"
		, A1."Dscription"
		, A3."ItmsGrpNam" "ItemGroup"
		/*, CASE WHEN A0."CANCELED" <> 'C' 
		THEN A1."Quantity"*-1
		ELSE A1."Quantity"
	  END "Quantity"*/
		, CASE WHEN A0."CANCELED" <> 'C'
			THEN IFNULL(B1."Quantity",A1."Quantity"*-1)
			ELSE IFNULL(B1."Quantity",A1."Quantity")
		  END "Quantity"
		, B1."DistNumber"
		, A1."WhsCode"
		, A4."OcrName" "Sales Type"
		, A5."OcrName"
		, A6."OcrName" "Sales Loc"
		, A7."Name" "BusLine"
		, A8."Name" "AppLine"
		, A9."Name" "Category"
		, A2."U_MODEL" "Model"
		, (SELECT "SlpName" FROM OSLP WHERE "SlpCode" = A0."SlpCode") "AO"
		, B0."FormatCode"
		, B0."AcctName"
	FROM
		ORDN A0 INNER JOIN RDN1 A1 ON A0."DocEntry" = A1."DocEntry"
		INNER JOIN OITM A2 ON A1."ItemCode" = A2."ItemCode"
		INNER JOIN OITB A3 ON A2."ItmsGrpCod" = A3."ItmsGrpCod"
		LEFT JOIN OOCR A4 ON A1."OcrCode" = A4."OcrCode"
		LEFT JOIN OOCR A5 ON A1."OcrCode2" = A5."OcrCode"
		LEFT JOIN OOCR A6 ON A1."OcrCode3" = A6."OcrCode"
		LEFT JOIN "@BUSSLINE" A7 ON A2."U_BUSSLINE" = A7."Code"
		LEFT JOIN "@APPLINE" A8 ON A2."U_APPLINE" = A8."Code"
		LEFT JOIN "@CATEGORY_1" A9 ON A2."U_CATEGORY_1" = A9."Code"
		INNER JOIN OACT B0 ON A1."CogsAcct" = B0."AcctCode"
                          LEFT JOIN OCRD B2 ON A0."CardCode" = B2."CardCode"
		LEFT JOIN (	SELECT
						C0."DistNumber"
						, C1."Quantity"
						, C2."ApplyEntry"
						, C2."ApplyLine"
						, C2."ApplyType"
					FROM
						OSRN C0 INNER JOIN ITL1 C1 ON C0."AbsEntry" = C1."MdAbsEntry"
						INNER JOIN OITL C2 ON C1."LogEntry" = C2."LogEntry"
					WHERE
						C1."Quantity" <> 0
						) B1 ON A1."DocEntry" = B1."ApplyEntry" AND A1."LineNum" = B1."ApplyLine" AND A1."ObjType"= B1."ApplyType"
	WHERE
		A0."DocDate" BETWEEN :DF AND :DT
) D0

ORDER BY
	D0."DocDate"
	, D0."DocDate";
