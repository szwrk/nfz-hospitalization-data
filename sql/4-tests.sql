SET SERVEROUTPUT ON
PROMPT Running row count assertion on mv_hospitalizations...
DECLARE
    v_expected INTEGER := 21194349;
    v_row_count_assertion_result VARCHAR2(100);
BEGIN
    SELECT
        CASE
            WHEN COUNT(1) = v_expected THEN '[PASS]'
            ELSE '[FAIL, expected ' || v_expected || ' rows, but returned ' || COUNT(1) || ']'
        END INTO v_row_count_assertion_result
    FROM dm_nfzhosp.mv_hospitalizations;

    DBMS_OUTPUT.PUT_LINE(v_row_count_assertion_result);
END;
/
EXIT;
EOF
