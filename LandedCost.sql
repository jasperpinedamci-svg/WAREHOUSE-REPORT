SELECT 
    I0."ItemCode" AS "SKU",
    I0."ItemName" AS "Description",
    L0."DocNum" AS "Last Landed Cost No.",
    L0."DocDate" AS "Last Landed Cost Date",
    COALESCE(L0."PriceAtWH", 0) AS "Last Landed Cost",
    I0."AvgPrice" AS "SAP Average Cost",
    (select MAX("DocDate") from oinm where "ItemCode" = I0."ItemCode" and "TransType" = '20') "Lst Rcpt Date",
    case when I0."validFor" = 'N' then 'Inactive' else 'Active' end "Status"

FROM OITM I0
LEFT JOIN (
    SELECT 
        A0."ItemCode",
        A0."PriceAtWH",
        A1."DocNum",
        A1."DocDate"
    FROM IPF1 A0
    INNER JOIN OIPF A1 ON A0."DocEntry" = A1."DocEntry"
    WHERE A1."Canceled" = 'N'
      AND A0."DocEntry" = (
          SELECT MAX(B0."DocEntry") 
          FROM IPF1 B0
          INNER JOIN OIPF B1 ON B0."DocEntry" = B1."DocEntry"
          WHERE B1."Canceled" = 'N' 
            AND B0."ItemCode" = A0."ItemCode"
      )
) L0 ON I0."ItemCode" = L0."ItemCode"
WHERE I0."InvntItem" = 'Y' 
      AND I0."ItmsGrpCod" = '156'
      AND I0."validFor" <> 'N'
ORDER BY I0."ItemCode";
