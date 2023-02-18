CREATE OR REPLACE TABLE keepcoding.ivr_summary AS 
SELECT 
        detail.calls_ivr_id 
                AS ivr_id
      , detail.calls_phone_number 
                AS phone_number
      , detail.calls_ivr_result 
                AS ivr_result
      , CASE WHEN STARTS_WITH(detail.calls_vdn_label, 'ATC') THEN 'FRONT'
             WHEN STARTS_WITH(detail.calls_vdn_label, 'TECH') THEN 'TECH'
             WHEN detail.calls_vdn_label = 'ABSORPTION' THEN 'ABSORPTION'
             ELSE 'RESTO'
        END     AS vdn_aggregation
      , detail.calls_start_date 
                AS start_date
      , detail.calls_end_date 
                AS end_date
      , detail.calls_total_duration 
                AS total_duration
      , detail.calls_customer_segment 
                AS customer_segment
      , detail.calls_ivr_language 
                AS ivr_language
      , detail.calls_steps_module 
                AS steps_module
      , detail.calls_module_aggregation 
                AS module_aggregation

      , IFNULL(MAX((NULLIF(detail.document_type, 'NULL'))), 'NO_CONOCIDO')
                AS document_type

      , IFNULL(MAX((NULLIF(detail.document_identification, 'NULL'))), 'NO_CONOCIDO')
                AS document_identification

       , IFNULL(MAX((NULLIF(detail.customer_phone, 'NULL'))), 'NO_CONOCIDO')
                AS customer_phone
 
       , IFNULL(MAX((NULLIF(detail.billing_account_id, 'NULL'))), 'NO_CONOCIDO')
                AS billing_account_id
      
      , MAX(IF(detail.module_name = 'AVERIA_MASIVA', 1, 0)) 
                AS masiva_lg
      
      , MAX(IF(detail.step_name = 'CUSTOMERINFOBYPHONE.TX' AND detail.step_description_error = 'NULL', 1, 0)) 
                AS info_by_phone_lg
      
      , MAX(IF(detail.step_name = 'CUSTOMERINFOBYDNI.TX' AND detail.step_description_error = 'NULL', 1, 0)) 
                AS info_by_dni_lg
      
      , MAX(IF(det2.calls_phone_number = detail.calls_phone_number
                                        AND detail.calls_start_date > det2.calls_start_date
                                         AND (TIMESTAMP_DIFF(detail.calls_start_date, det2.calls_start_date, MINUTE)) < 1440, 1, 0))
                AS repeated_phone_24H
      
      , MAX(IF(det2.calls_phone_number = detail.calls_phone_number
                                        AND detail.calls_start_date < det2.calls_start_date
                                         AND (ABS(TIMESTAMP_DIFF(detail.calls_start_date, det2.calls_start_date, MINUTE))) < 1440, 1, 0))
                AS cause_recall_phone_24H

        FROM 
                keepcoding.ivr_detail detail
        LEFT 
        JOIN
                keepcoding.ivr_detail det2
        ON 
                detail.calls_phone_number = det2.calls_phone_number
             AND detail.calls_ivr_id <> det2.calls_ivr_id

GROUP BY ivr_id
        , phone_number
        , ivr_result
        , vdn_aggregation
        , start_date
        , end_date
        , total_duration
        , customer_segment
        , ivr_language
        , steps_module
        , module_aggregation
;
