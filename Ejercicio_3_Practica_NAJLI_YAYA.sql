CREATE OR REPLACE FUNCTION keepcoding.clean_integer (int_num INT64) RETURNS INT64
AS (SELECT IF(int_num IS NULL, -999999, int_num));
