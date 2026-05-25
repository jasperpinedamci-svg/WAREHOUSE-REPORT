SELECT DISTINCT
    'DR Cancellation' AS "Cancellation Type",
    T2."DocNum" AS "Orig DR. No ",
    T0."DocNum" AS "Cancellation Doc. No.",
    T0."DocDate" AS "Date",
    T0."Comments" AS "Remarks"
FROM ODLN T0
INNER JOIN DLN1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN ODLN T2 ON T1."BaseEntry" = T2."DocEntry"
WHERE T0."CANCELED" = 'C' 
  AND T1."BaseType" = 15

UNION ALL

SELECT DISTINCT
    'CM' AS "Cancellation Type",
    T3."DocNum" AS "Orig DR. No",
    T0."DocNum" AS "Cancellation Doc. No.",
    T0."DocDate" AS "Cancellation Date",
    T0."Comments" AS "Remarks"
FROM ORIN T0
INNER JOIN RIN1 T1 ON T0."DocEntry" = T1."DocEntry"
-- Bridge 1: Credit Memo to A/R Invoice
INNER JOIN INV1 T2 ON T1."BaseEntry" = T2."DocEntry" AND T1."BaseLine" = T2."LineNum" AND T1."BaseType" = 13 
-- Bridge 2: A/R Invoice to Delivery
INNER JOIN ODLN T3 ON T2."BaseEntry" = T3."DocEntry" AND T2."BaseType" = 15;
