/* select from oinm t0 */
declare DF date;
DF := /* t0."DocDate" */ '[%0]';

Select
      *	
    , CASE WHEN T0."IsSUD" = 1 THEN 0 ELSE (Select "AvgPrice" From OITM Where "ItemCode" = T0."ItemCode")  END AS "Unit LC"	
    , CASE WHEN T0."IsSUD" = 1 THEN 0 ELSE (Select "AvgPrice" From OITM Where "ItemCode" = T0."ItemCode") * T0."Qty" END AS "Total LC"	
    , CASE WHEN T0."IsSUD" = 1 THEN 0 ELSE (Select "Price" From ITM1 Where "ItemCode" = T0."ItemCode" AND "PriceList" = 2) END AS "SRP"	
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
    , CASE WHEN A3."ItemCode" = 'SUD' THEN D0."CAT" ELSE A6."Name" END AS "Category"
    , CASE WHEN A3."ItemCode" = 'SUD' THEN D0."MOD" ELSE A3."U_MODEL" END AS "Model"
  --New Tagging
    , CASE WHEN A3."ItemCode" = 'SUD' THEN D0."NBL" ELSE A7."Name" END AS "New_BussLine"
    , CASE WHEN A3."ItemCode" = 'SUD' THEN D0."NAL" ELSE A9."Name" END AS "New_AppLine"
    , CASE WHEN A3."ItemCode" = 'SUD' THEN D0."PROD" ELSE A10."Name" END AS "New_ProdLine"
    , CASE WHEN A3."ItemCode" = 'SUD' THEN D0."DES" ELSE A11."Name" END AS "New_Des"
    , CASE WHEN A3."ItemCode" = 'SUD' THEN D0."STAT" ELSE A12."Name" END AS "New_ItemStat"

    , A0."U_DRNO"
    , A0."U_INDATE"
    , A0."U_CUSTNAME"
    , CASE WHEN A0."ItemCode" = 'SUD' THEN 1 ELSE  0  END AS "IsSUD"  

From
    OSRN A0 
    INNER JOIN ITL1 A1 ON A0."AbsEntry" = A1."MdAbsEntry"
    INNER JOIN OITL A2 ON A1."LogEntry" = A2."LogEntry"
    LEFT JOIN (
        Select
              B0."SnBMDAbs"
            , B0."WhsCode"
            , B1."BinCode"
        From    
            OSBQ B0 
            INNER JOIN OBIN B1 ON B0."BinAbs" = B1."AbsEntry"
        Where B0."OnHandQty" > 0 
    ) C0 ON A0."AbsEntry" = C0."SnBMDAbs" AND C0."WhsCode" = A2."LocCode"
    
    LEFT JOIN OITM A3 ON A0."ItemCode" = A3."ItemCode"
    LEFT JOIN (
        SELECT DISTINCT     
            B1."ItemName",
            B2."Name" "BL",
            B3."Name" "AL",
            B4."Name" "CAT",
            B1."U_MODEL" "MOD",   
  --NEW
            B5."Name" "NBL",
            B6."Name" "NAL",
            B7."Name" "PROD",
            B8."Name" "DES",
            B9."Name" "STAT",
            A0."AbsEntry" AS "SnAbsEntry"
        FROM        
            OSRN A0 
            INNER JOIN OITM B1 ON A0."U_ITEMCODE" = B1."ItemCode"
            LEFT JOIN "@BUSSLINE" B2 ON B1."U_BUSSLINE" = B2."Code"
            LEFT JOIN "@APPLINE" B3 ON B1."U_APPLINE" = B3."Code"
            LEFT JOIN "@CATEGORY_1" B4 ON B1."U_CATEGORY_1" = B4."Code"
            -- new Tagging--
                 LEFT JOIN "@BUSLINE" B5 on B1."U_BUSLINE" = B5."Code"
                 LEFT JOIN "@APLINE" B6 on B1."U_APLINE" = B6."Code"
                 LEFT JOIN "@PRODLINE" B7 on B1."U_PRODLINE" = B7."Code"
                 LEFT JOIN "@DESLINE" B8 on B1."U_DESLINE" = B8."Code"
                 LEFT JOIN "@ITEMSTAT" B9 on B1."U_ITEMSTAT" = B9."Code"
    ) D0 ON D0."SnAbsEntry" = A0."AbsEntry"
    
    LEFT JOIN "@BUSSLINE" A4 ON A3."U_BUSSLINE" = A4."Code"
    LEFT JOIN "@APPLINE" A5 ON A3."U_APPLINE" = A5."Code"
    LEFT JOIN "@CATEGORY_1" A6 ON A3."U_CATEGORY_1" = A6."Code"
    -- new Tagging--
    LEFT JOIN "@BUSLINE" A7 on A3."U_BUSLINE" = A7."Code"
    LEFT JOIN "@APLINE" A9 on A3."U_APLINE" = A9."Code"
    LEFT JOIN "@PRODLINE" A10 on A3."U_PRODLINE" = A10."Code"
    LEFT JOIN "@DESLINE" A11 on A3."U_DESLINE" = A11."Code"
    LEFT JOIN "@ITEMSTAT" A12 on A3."U_ITEMSTAT" = A12."Code"
  

Where
    A2."DocDate" <= :DF
    AND A3."ItmsGrpCod" = 156 

Group By
    A0."ItemCode", 
    A3."ItemName", 
    A0."InDate", 
    A0."DistNumber", 
    A0."AbsEntry", 
    A2."LocCode",
    C0."BinCode", 
    CAST(A0."Notes" AS NVARCHAR), 
    A4."Name", 
    A5."Name", 
    A6."Name",
    A3."U_MODEL",
    A0."U_ITEMCODE", 
    D0."ItemName", 
    A3."ItemCode", 
    D0."BL", 
    D0."AL", 
    D0."CAT", 
    D0."MOD",
  
    D0."NBL",
    D0."NAL",
    D0."PROD",
    D0."DES",
    D0."STAT",
  
    A0."U_DRNO", 
    A0."U_INDATE", 
    A0."U_CUSTNAME"

  
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
  
    , A7."Name" "New_BusLine"
    , A9."Name" "New_ApLine"
    , A10."Name" "New_ProdLine"
    , A11."Name" "New_DesLine"
    , A12."Name" "New_ItemStat"
  
    , A1."U_MODEL" "Model"
    , NULL
    , NULL
    , NULL
    , 0 AS "IsSUD"  

From
    OINM A0 
    INNER JOIN OITM A1 ON A0."ItemCode" = A1."ItemCode"
    LEFT JOIN "@BUSSLINE" A4 ON A1."U_BUSSLINE" = A4."Code"
    LEFT JOIN "@APPLINE" A5 ON A1."U_APPLINE" = A5."Code" 
    LEFT JOIN "@CATEGORY_1" A6 ON A1."U_CATEGORY_1" = A6."Code"

  -- new Tagging--
    LEFT JOIN "@BUSLINE" A7 on A3."U_BUSLINE" = A7."Code"
    LEFT JOIN "@APLINE" A9 on A3."U_APLINE" = A9."Code"
    LEFT JOIN "@PRODLINE" A10 on A3."U_PRODLINE" = A10."Code"
    LEFT JOIN "@DESLINE" A11 on A3."U_DESLINE" = A11."Code"
    LEFT JOIN "@ITEMSTAT" A12 on A3."U_ITEMSTAT" = A12."Code"

Where
    A1."ManSerNum" = 'N'
    AND A1."ItmsGrpCod" = 156 
    AND A0."DocDate" <= :DF

Group By
    A0."ItemCode", 
    A0."Warehouse", 
    A4."Name", 
    A5."Name", 
    A6."Name", 
    A7."Name", 
    A9."Name", 
    A10."Name", 
    A11."Name", 
    A12."Name", 
    A1."U_MODEL" 

Having 
    SUM(A0."InQty" - A0."OutQty") > 0
) T0

Order By
    T0."ItemCode";
