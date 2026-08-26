WITH MonthlyMovements AS (
    SELECT 
        T0."ItemCode", 
        MAX(T1."ItemName") AS "ItemName",
        YEAR(T0."DocDate") AS "Year", 
        MONTH(T0."DocDate") AS "MonthNum", 
        MAX(MONTHNAME(T0."DocDate")) AS "MonthName", 
        SUM(T0."InQty") AS "TotalIn", 
        SUM(T0."OutQty") AS "TotalOut",
        SUM(T0."InQty" - T0."OutQty") AS "NetQty"
    FROM OINM T0
    INNER JOIN OITM T1 ON T0."ItemCode" = T1."ItemCode"
    
    WHERE T1."ItmsGrpCod" = '156'
    GROUP BY 
        T0."ItemCode", 
        YEAR(T0."DocDate"), 
        MONTH(T0."DocDate")
)
SELECT 
    "ItemCode" AS "SKU",
    "ItemName",
    "Year",
    "MonthName" AS "Month",
    IFNULL(SUM("NetQty") OVER (PARTITION BY "ItemCode" ORDER BY "Year", "MonthNum" ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0) AS "BeginningQty",
    "TotalIn",
    "TotalOut",
    SUM("NetQty") OVER (PARTITION BY "ItemCode" ORDER BY "Year", "MonthNum" ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS "EndingQty"
FROM MonthlyMovements
ORDER BY 
    "Year", 
    "MonthNum" 
