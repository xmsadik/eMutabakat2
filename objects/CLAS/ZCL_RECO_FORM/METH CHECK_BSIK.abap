  METHOD check_bsik.
*    DATA ls_bsik TYPE bsik_view.
*
    SELECT SINGLE *
         FROM zetr_reco_ddl_bsik
             WHERE CompanyCode IN @s_bukrs  AND
                   supplier EQ @iv_lifnr AND
                       ( PostingDate LE @gv_last_date AND PostingDate GE @iv_budat ) AND
                       SpecialGLCode IN @r_umskz_m
                       INTO @DATA(ls_bsik) .
*
    cv_closing_rc = sy-subrc.

  ENDMETHOD.