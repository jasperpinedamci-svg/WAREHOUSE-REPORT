SELECT DISTINCT
    CASE 
         WHEN A3."LineStatus" = 'C' THEN 'CLOSED'
         WHEN A3."LineStatus" = 'O' AND A0."DistNumber" IS NOT NULL AND A5."DocNum" IS NOT NULL THEN 'CLOSED'
         WHEN A3."LineStatus" = 'O' THEN 'OPEN'
         ELSE 'OPEN'
    END AS "Status",
    A4."CreateDate",
    A4."DocDate" AS "ITR Date",
    A4."DocNum" AS "ITR No",
    A3."ItemCode",
    A3."Dscription" AS "Item Description",
    IFNULL(A1."Quantity" + 1, A3."Quantity") AS "Quantity",
    A0."DistNumber" AS "Serial Number",
    A3."FromWhsCod" AS "From Whse Code",
    W_From."WhsName" AS "From WhsName",
    A3."WhsCode" AS "To Whse Code",
    W_To."WhsName" AS "To WhseName",
    A5."DocNum" AS "WTFG No.",
    A5."DocDate" AS "WTFG Date.",
    A4."Comments" AS "Remarks"

FROM
    WTQ1 A3 
    INNER JOIN OWTQ A4 ON A3."DocEntry" = A4."DocEntry"
          
    LEFT JOIN OITL A2 ON A3."DocEntry" = A2."ApplyEntry"
                     AND A3."ObjType" = A2."ApplyType"
                     AND A3."LineNum" = A2."ApplyLine"
          
    LEFT JOIN ITL1 A1 ON A2."LogEntry" = A1."LogEntry"
          
    LEFT JOIN OSRN A0 ON A1."MdAbsEntry" = A0."AbsEntry"
           
    LEFT JOIN OWHS W_From ON A3."FromWhsCod" = W_From."WhsCode"
          
    LEFT JOIN OWHS W_To ON A3."WhsCode" = W_To."WhsCode"
          
    -- Revised Subquery: Now includes OITL and ITL1 to grab the specific Serial Number transferred
    LEFT JOIN ( 
        SELECT
            B0."DocDate",
            B0."DocNum",
            B1."BaseEntry",
            B1."BaseType",
            B1."BaseLine",
            B1."Quantity" AS "DlvrQty",
            T1."MdAbsEntry" -- The Serial Number ID in the WTFG
        FROM
            OWTR B0 
            INNER JOIN WTR1 B1 ON B0."DocEntry" = B1."DocEntry"
            LEFT JOIN OITL T0 ON B1."DocEntry" = T0."ApplyEntry" 
                             AND B1."ObjType" = T0."ApplyType" 
                             AND B1."LineNum" = T0."ApplyLine"
            LEFT JOIN ITL1 T1 ON T0."LogEntry" = T1."LogEntry"
        WHERE   
            B0."CANCELED" = 'N' 
    ) A5 ON A3."DocEntry" = A5."BaseEntry" 
        AND A3."LineNum" = A5."BaseLine" 
        AND A3."ObjType" = A5."BaseType"
        AND IFNULL(A1."MdAbsEntry", -1) = IFNULL(A5."MdAbsEntry", -1) 

WHERE
    A4."DocDate" BETWEEN '[%0]' AND '[%1]'    

ORDER BY 
    A4."DocDate" ASC
