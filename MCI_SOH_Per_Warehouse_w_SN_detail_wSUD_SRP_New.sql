/* select from oinm t0 */
declare DF date;
DF := /* t0."DocDate" */ '[%0]';


Select
          *	
          , (Select "AvgPrice" From OITM Where "ItemCode" = T0."ItemCode")  "Unit LC"	
          , (Select "AvgPrice" From OITM Where "ItemCode" = T0."ItemCode") * T0."Qty"  "Total LC"	
          , (Select "Price" From ITM1 Where "ItemCode" = T0."ItemCode" AND "PriceList" = 2) "SRP"	
          , T0."WhsCode" || ' ' || T0."WhsName" "Location"

From
(
Select
	CASE WHEN A0."ItemCode" = 'SUD' THEN A0."U_ITEMCODE" ELSE A0."ItemCode" END AS "ItemCode"
    , CASE WHEN A3."ItemCode" = 'SUD' THEN D0."ItemName" ELSE A3."ItemName" END AS "Description"
	, A0."InDate" "Admission Date"
	, A0."DistNumber" "Serial Number"
	, A2."LocCode" "WhsCode"
	, (Select "WhsName" From OWHS Where "WhsCode" = A2."LocCode") "WhsName"
	, C0."BinCode"
	, SUM(A1."Quantity") "Qty"
	, CAST(A0."Notes" AS NVARCHAR) "Notes"
             , CASE WHEN A3."ItemCode" = 'SUD' THEN D0."BL" ELSE A4."Name" END AS "BussLine"
             , CASE WHEN A3."ItemCode" = 'SUD' THEN D0."AL" ELSE A5."Name" END AS "AppLine"
             , CASE WHEN A3."ItemCode" = 'SUD' THEN D0."PL" ELSE A6."Name" END AS "Prodline"
             , CASE WHEN A3."ItemCode" = 'SUD' THEN D0."IS" ELSE A3."Name" END AS "ItemStatus"
             , A0."U_DRNO"
             , A0."U_INDATE"
             , A0."U_CUSTNAME"
            

From
	OSRN A0 INNER JOIN ITL1 A1 ON A0."AbsEntry" = A1."MdAbsEntry"
	INNER JOIN OITL A2 ON A1."LogEntry" = A2."LogEntry"
	LEFT JOIN (	Select
					B0."ItemCode" "ItemCode"
					, B0."SnBMDAbs"
					, MAX(B0."WhsCode") "WhsCode"
					, MAX(B1."BinCode") "BinCode"
				From	
					OSBQ B0 LEFT JOIN OBIN B1 ON B0."BinAbs" = B1."AbsEntry"
				Group By
					B0."ItemCode"
					, B0."SnBMDAbs"
					, B0."WhsCode"
					) C0 ON A0."AbsEntry" = C0."SnBMDAbs" AND C0."WhsCode" = A2."LocCode"
	LEFT JOIN OITM A3 ON A0."ItemCode" = A3."ItemCode"

  LEFT JOIN (SELECT DISTINCT		
              B1."ItemName",
		      B2."Name" "BL",
	          B3."Name" "AL",
	          B4."Name"  "PL",
	          B5."Name" "IS",		
              A0."AbsEntry" AS "SnAbsEntry"	
                                   FROM		
                                   OSRN A0 INNER JOIN OITM B1 ON A0."U_ITEMCODE" = B1."ItemCode"
                                     LEFT JOIN "@BUSLINE" B2 ON B1."U_BUSLINE" = B2."Code"
	                                 LEFT JOIN "@APLINE" B3 ON B1."U_APLINE" = B3."Code"
	                                 LEFT JOIN "@PRODLINE" B4 ON B1."U_PRODLINE" = B4."Code"
	                                 LEFT JOIN "@ITEMSTAT" B5 ON B1."U_ITEMSTAT" = B5."Code"
                                    ) D0 ON D0."SnAbsEntry" = A0."AbsEntry"

	LEFT JOIN "@BUSLINE" A4 ON A3."U_BUSLINE" = A4."Code"
	LEFT JOIN "@APLINE" A5 ON A3."U_APLINE" = A5."Code"
	LEFT JOIN "@PRODLINE" A6 ON A3."U_PRODLINE" = A6."Code"
	LEFT JOIN "@ITEMSTAT" A7 ON A3."U_ITEMSTAT" = A7."Code"
Where
	A2."DocDate" <= :DF
	AND A3."ItmsGrpCod" = 156 --> FINISHED GOODS
Group By
	A0."ItemCode"
  , A3."ItemName"
  , A0."InDate"
	, A0."DistNumber"
	, A0."AbsEntry"
	, A2."LocCode"
	, C0."BinCode" 
	, CAST(A0."Notes" AS NVARCHAR)
	, A4."Name"
	, A5."Name" 
	, A6."Name" 
	, A7."Name" 
	, A0."U_ITEMCODE"
  , D0."ItemName"
  , A3."ItemCode"
  , D0."BL"
  , D0."AL"
  , D0."PL"
  , D0."IS"
  , A0."U_DRNO"
  , A0."U_INDATE"
  , A0."U_CUSTNAME"
         
Having
	SUM(A1."Quantity") > 0

UNION ALL

Select
	A0."ItemCode"
    , NULL
	, NULL
    , NULL
	, A0."Warehouse"
	, (Select "WhsName" From OWHS Where "WhsCode" = A0."Warehouse") "WhsName"
	, NULL
	, SUM(A0."InQty" - A0."OutQty") "Qty"
	, NULL
	, A4."Name" "BussLine"
	, A5."Name" "AppLine"
	, A6."Name" "Category"
	, A1."U_MODEL" "Model"
    , NULL
    , NULL
    , NULL
From
	OINM A0 INNER JOIN OITM A1 ON A0."ItemCode" = A1."ItemCode"
	LEFT JOIN "@BUSLINE" A4 ON A1."U_BUSLINE" = A4."Code"
	LEFT JOIN "@APLINE" A5 ON A1."U_APLINE" = A5."Code"
	LEFT JOIN "@PRODLINE" A6 ON A1."U_PRODLINE" = A6."Code"
	LEFT JOIN "@ITEMSTAT" A7 ON A1."U_ITEMSTAT" = A7."Code"
Where
	A1."ManSerNum" = 'N'
	AND A1."ItmsGrpCod" = 156 --> FINISHED GOODS
	AND A0."DocDate" <= :DF
Group By
	A0."ItemCode"
	, A0."Warehouse"
	, A4."Name"
	, A5."Name" 
	, A6."Name" 
	, A7."Name" 
Having 
	SUM(A0."InQty" - A0."OutQty") > 0
) T0

Order By
	T0."ItemCode";
