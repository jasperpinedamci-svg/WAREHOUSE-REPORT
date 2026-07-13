-- Open Sales Orders by Warehouse
SELECT 
    'Sales Order' AS "Doc Type",
    T0."DocNum" AS "Doc No.", 
    T0."CardCode" AS "Customer/Vendor",
    T1."ItemCode" AS "Item", 
    T1."WhsCode" AS "Warehouse", 
    X1."WhsName" AS "Warehouse Name", 
    T1."OpenQty" AS "Open Qty",
    T1."LineTotal" AS "Open Value"
FROM ORDR T0 
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN OWHS X1 ON T1."WhsCode" = X1."WhsCode"
WHERE T0."DocStatus" = 'O' 
  AND T1."LineStatus" = 'O' 
  AND T1."WhsCode" = 'FGDTRV-A'

UNION ALL

-- Open Purchase Orders by Warehouse
SELECT 
    'Purchase Order' AS "Doc Type",
    T2."DocNum" AS "Doc No.", 
    T2."CardCode" AS "Customer/Vendor",
    T3."ItemCode" AS "Item", 
    T3."WhsCode" AS "Warehouse", 
    X3."WhsName" AS "Warehouse Name", 
    T3."OpenQty" AS "Open Qty",
    T3."LineTotal" AS "Open Value"
FROM OPOR T2 
INNER JOIN POR1 T3 ON T2."DocEntry" = T3."DocEntry"
LEFT JOIN OWHS X3 ON T3."WhsCode" = X3."WhsCode"
WHERE T2."DocStatus" = 'O' 
  AND T3."LineStatus" = 'O' 
  AND T3."WhsCode" = 'FGDTRV-A'
ORDER BY "Warehouse", "Doc Type";
