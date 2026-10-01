/* select from oinm t0 */
declare DF date;
declare DT date;
DF := /* t0."DocDate" */ '[%0]';
DT := /* t0."DocDate" */ '[%1]';

select
    'MR' "Doc"
    , t12."Ref2" "Reference"
    , t0."BASE_REF" "DocNum"
    , t0."DocDate"
    , t0."ItemCode"
    , t0."Dscription"
    , t11."ItmsGrpNam"
    , case when t1."validFor" = 'N' then 'Inactive' else 'Active' end "Status"
    , t0."InQty" "Qty"
    , t0."TransValue" "Net of VAT"
    , t0."Warehouse"
    , t5."OcrName" "Sales Type"
    , t7."OcrName" "Sales Loc"
    , t2."Name" "BusLine"
    , t3."Name" "AppLine"
    , t4."Name" "Category"
    , t1."U_MODEL" "Model"
    , t0."Comments"
    , t8."FormatCode"
    , t8."AcctName"
from
    oinm t0 inner join oitm t1 on t0."ItemCode" = t1."ItemCode"
    left join "@BUSSLINE" t2 on t1."U_BUSSLINE" = t2."Code"
    left join "@APPLINE" t3 on t1."U_APPLINE" = t3."Code"
    left join "@CATEGORY_1" t4 on t1."U_CATEGORY_1" = t4."Code"
    left join oocr t5 on t0."OcrCode" = t5."OcrCode"
    left join oocr t6 on t0."OcrCode2" = t6."OcrCode"
    left join oocr t7 on t0."OcrCode3" = t7."OcrCode"
    left join oact t8 on t0."CardCode" = t8."AcctCode"
    left join oitb t11 on t1."ItmsGrpCod" = t11."ItmsGrpCod"
    left join OIGN t12 on t0."CreatedBy" = t12."DocEntry" AND t0."TransType" = 59 
where
    t0."DocDate" between :DF and :DT
    --and t8."FormatCode" not in ('130600','131000','131100','122100')
    and t0."TransType" = 59 -->> Goods Receipt
    and t11."ItmsGrpCod" IN ('120', '156')  -->> Spare Parts (MISSING 'AND' WAS HERE)
ORDER BY t0."DocDate" ASC;
