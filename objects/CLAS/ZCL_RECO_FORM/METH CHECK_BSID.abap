  METHOD check_bsid.
*    DATA ls_bsid TYPE bsid. "YiğitcanÖzdemir

*    SELECT SINGLE *
*    FROM bsid
*    WHERE bukrs IN @s_bukrs AND
*          kunnr EQ @iv_kunnr AND
*          ( budat LE @gv_last_date AND budat GE @iv_budat ) AND
*          umskz IN @r_umskz_m
*    INTO @data(ls_bsid).

    SELECT SINGLE *
       FROM zetr_reco_ddl_bsid
           WHERE CompanyCode IN @s_bukrs  AND
                 Customer EQ @iv_kunnr AND
                     ( PostingDate LE @gv_last_date AND PostingDate GE @iv_budat ) AND
                     SpecialGLCode IN @r_umskz_m
                     INTO @DATA(ls_bsid) .

    cv_closing_rc = sy-subrc.

  ENDMETHOD.