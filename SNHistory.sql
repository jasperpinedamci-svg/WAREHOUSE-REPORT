SELECT 
    T0."DistNumber" AS "Serial Number",
    T0."ItemCode" AS "Item No.",
    CASE T2."DocType"
        WHEN 15 THEN 'DL ' || CAST(T2."DocEntry" AS VARCHAR)
        WHEN 20 THEN 'PD ' || CAST(T2."DocEntry" AS VARCHAR)
        WHEN 59 THEN 'SI ' || CAST(T2."DocEntry" AS VARCHAR)
        WHEN 60 THEN 'SO ' || CAST(T2."DocEntry" AS VARCHAR)
        WHEN 67 THEN 'IM ' || CAST(T2."DocEntry" AS VARCHAR)
        ELSE CAST(T2."DocType" AS VARCHAR) || ' ' || CAST(T2."DocEntry" AS VARCHAR)
    END AS "Document",
    T2."DocLine" AS "Doc. Row",
    T2."DocDate" AS "Date",
    COALESCE(T5."WhsCode", T2."LocCode") AS "Whse",
    T5."BinCode" AS "Bin Location"
    
FROM "OSRN" T0
-- Link Serial Number to tracking lines
INNER JOIN "ITL1" T1 ON T0."ItemCode" = T1."ItemCode" AND T0."SysNumber" = T1."SysNumber"
-- Link tracking lines to the main inventory tracking log
INNER JOIN "OITL" T2 ON T1."LogEntry" = T2."LogEntry"
-- Link the transaction log to Bin Location Document Lines using ITLEntry
LEFT JOIN "OBTL" T4 ON T2."LogEntry" = T4."ITLEntry" 
                   AND T0."AbsEntry" = T4."SnBMDAbs"
-- Get the actual Bin Code string
LEFT JOIN "OBIN" T5 ON T4."BinAbs" = T5."AbsEntry"

--WHERE T0."DistNumber" = '29540652060604335139' 

ORDER BY T2."DocDate", T2."LogEntry";
