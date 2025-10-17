  METHOD modify_account_group.

    TYPES : BEGIN OF t_customer,
              kunnr TYPE kunnr,
              ktokd TYPE ktokd,
            END OF t_customer,

            BEGIN OF t_vendor,
              lifnr TYPE lifnr,
              ktokk TYPE ktokk,
            END OF t_vendor,

            BEGIN OF t_kna1,
              kunnr    TYPE kunnr,
              vkn_tckn TYPE stcd2,
              ktokd    TYPE ktokd,
            END OF t_kna1,

            BEGIN OF t_lfa1,
              lifnr    TYPE lifnr,
              vkn_tckn TYPE stcd2,
              ktokk    TYPE ktokk,
            END OF t_lfa1.

    DATA: lt_customer TYPE SORTED TABLE OF t_customer WITH UNIQUE KEY kunnr,
          ls_customer LIKE LINE OF lt_customer,
          lt_vendor   TYPE SORTED TABLE OF t_vendor  WITH UNIQUE KEY lifnr,
          ls_vendor   LIKE LINE OF lt_vendor,
          lt_kna1     TYPE SORTED TABLE OF t_kna1 WITH UNIQUE KEY kunnr,
          ls_kna1     LIKE LINE OF lt_kna1,
          lt_lfa1     TYPE SORTED TABLE OF t_lfa1 WITH UNIQUE KEY lifnr,
          ls_lfa1     LIKE LINE OF lt_lfa1.

    DATA ls_language TYPE zreco_lang. "hkizilkaya

    DATA :lv_found TYPE c.

    FIELD-SYMBOLS :<fs_lfa1_tax> LIKE LINE OF gt_lfa1_tax,
                   <fs_kna1_tax> LIKE LINE OF gt_kna1_tax,
                   <fs_lfa1>     LIKE LINE OF lt_lfa1,
                   <fs_kna1>     LIKE LINE OF lt_kna1.

    FREE : lv_found,
           lt_customer,
           lt_vendor,
           lt_kna1,ls_kna1,
           lt_lfa1,ls_lfa1.

    READ TABLE gt_flds TRANSPORTING NO FIELDS WITH KEY hesap_tur = 'S'
                                                         name2_x = 'X'
                                                        name2_use = ''.
    IF sy-subrc EQ 0.
      lv_found = 'X'.
    ENDIF.

    LOOP AT gt_lfa1_tax ASSIGNING <fs_lfa1_tax>.
      IF <fs_lfa1_tax>-vkn_tckn IS INITIAL OR
         <fs_lfa1_tax>-lifnr IS INITIAL.
        CONTINUE.
      ENDIF.
      FREE : ls_lfa1.
      ls_lfa1-lifnr    = <fs_lfa1_tax>-lifnr.
      ls_lfa1-vkn_tckn = <fs_lfa1_tax>-vkn_tckn.
      ls_lfa1-ktokk    = <fs_lfa1_tax>-ktokl.
      INSERT ls_lfa1 INTO TABLE lt_lfa1.
    ENDLOOP.

    LOOP AT gt_kna1_tax ASSIGNING <fs_kna1_tax>.
      IF <fs_kna1_tax>-vkn_tckn IS INITIAL OR
         <fs_kna1_tax>-kunnr IS INITIAL.
        CONTINUE.
      ENDIF.
      FREE : ls_kna1.
      ls_kna1-kunnr    = <fs_kna1_tax>-kunnr.
      ls_kna1-vkn_tckn = <fs_kna1_tax>-vkn_tckn.
      ls_kna1-ktokd    = <fs_kna1_tax>-ktokl.
      INSERT ls_kna1 INTO TABLE lt_kna1.
    ENDLOOP.

* MÜŞTERI/SATıCı BILGISI OLAN CARILERIN GRUPLARıNı DOLDUR
    LOOP AT gt_account_info ASSIGNING FIELD-SYMBOL(<fs_info>)
                                WHERE lifnr IS NOT INITIAL
                                  AND ktokk IS NOT INITIAL.

      IF gt_language[] IS NOT INITIAL.
        READ TABLE gt_language INTO ls_language WITH KEY mtype = gv_mtype
                                                               ktokk = <fs_info>-ktokk.
        IF sy-subrc EQ 0.
          <fs_info>-spras = ls_language-spras.
        ENDIF.
      ENDIF.

      IF <fs_info>-land1 EQ 'TR'.
        <fs_info>-spras = 'T'.
      ELSE.
        <fs_info>-spras = 'E'.
      ENDIF.

      IF lv_found EQ 'X' AND <fs_info>-name2 IS NOT INITIAL.
        CONCATENATE <fs_info>-name1 <fs_info>-name2
               INTO <fs_info>-name1 SEPARATED BY space.
        CLEAR <fs_info>-name2.
      ENDIF.

      READ TABLE lt_lfa1 ASSIGNING <fs_lfa1> WITH KEY lifnr = <fs_info>-lifnr.
      IF sy-subrc EQ 0.
        <fs_info>-vkn_tckn = <fs_lfa1>-vkn_tckn.
      ENDIF.

      MOVE-CORRESPONDING <fs_info> TO ls_vendor.

      CASE gs_adrs-tax_office.
        WHEN 'STCD1'.
          <fs_info>-vd = <fs_info>-stcd1.
        WHEN 'STCD2'.
          <fs_info>-vd = <fs_info>-stcd2.
        WHEN 'STCD3'.
          <fs_info>-vd = <fs_info>-stcd3.
        WHEN 'STCD4'.
          <fs_info>-vd = <fs_info>-stcd4.
        WHEN 'FISKN'.

*          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*            EXPORTING
*              input  = <fs_info>-fiskn
*            IMPORTING
*              output = <fs_info>-fiskn.

          <fs_info>-fiskn = |{ <fs_info>-fiskn ALPHA = IN }|.

          SELECT SINGLE OrganizationBPName1 AS name1
                   FROM i_customer
                  WHERE customer EQ @<fs_info>-fiskn
                  INTO @<fs_info>-vd.
        WHEN 'STCEG'.
          <fs_info>-vd = <fs_info>-stceg.
      ENDCASE.

      INSERT ls_vendor INTO TABLE lt_vendor.

    ENDLOOP.

    FREE : lv_found.
    READ TABLE gt_flds TRANSPORTING NO FIELDS
    WITH KEY hesap_tur = 'M'
             name2_x = 'X'
             name2_use = ''.
    IF sy-subrc EQ 0.
      lv_found = 'X'.
    ENDIF.

    LOOP AT gt_account_info ASSIGNING <fs_info>
                                WHERE kunnr IS NOT INITIAL
                                  AND ktokd IS NOT INITIAL.

      IF gt_language[] IS NOT INITIAL.
        READ TABLE gt_language INTO ls_language WITH KEY mtype = gv_mtype
                                                         ktokd = <fs_info>-ktokd.
        IF sy-subrc EQ 0.
          <fs_info>-spras = ls_language-spras.
        ENDIF.
      ENDIF.

      IF <fs_info>-land1 EQ 'TR'.
        <fs_info>-spras = 'T'.
      ELSE.
        <fs_info>-spras = 'E'.
      ENDIF.


      IF lv_found EQ 'X' AND <fs_info>-name2 IS NOT INITIAL.
        CONCATENATE <fs_info>-name1 <fs_info>-name2
        INTO <fs_info>-name1 SEPARATED BY space.
        CLEAR <fs_info>-name2.
      ENDIF.

      READ TABLE lt_kna1 ASSIGNING <fs_kna1>
      WITH KEY kunnr = <fs_info>-kunnr.
      IF sy-subrc EQ 0.
        <fs_info>-vkn_tckn = <fs_kna1>-vkn_tckn.
      ENDIF.

      CASE gs_adrs-tax_office.
        WHEN 'STCD1'.
          <fs_info>-vd = <fs_info>-stcd1.
        WHEN 'STCD2'.
          <fs_info>-vd = <fs_info>-stcd2.
        WHEN 'STCD3'.
          <fs_info>-vd = <fs_info>-stcd3.
        WHEN 'STCD4'.
          <fs_info>-vd = <fs_info>-stcd4.
        WHEN 'FISKN'.

*          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*            EXPORTING
*              input  = <fs_info>-fiskn
*            IMPORTING
*              output = <fs_info>-fiskn.

          <fs_info>-fiskn = |{ <fs_info>-fiskn ALPHA = IN }|.

          SELECT SINGLE OrganizationBPName1 AS name1
         FROM i_customer
        WHERE customer EQ @<fs_info>-fiskn
        INTO @<fs_info>-vd.
        WHEN 'STCEG'.
          <fs_info>-vd = <fs_info>-stceg.
      ENDCASE.

      MOVE-CORRESPONDING <fs_info> TO ls_customer.

      INSERT ls_customer INTO TABLE lt_customer.

    ENDLOOP.

    FREE : lv_found.
    READ TABLE gt_flds TRANSPORTING NO FIELDS WITH KEY hesap_tur = 'S'
                                                         name2_x = 'X'
                                                       name2_use = ''.
    IF sy-subrc EQ 0.
      lv_found = 'X'.
    ENDIF.
    LOOP AT gt_account_info ASSIGNING <fs_info>
                                WHERE lifnr IS NOT INITIAL
                                  AND ktokk IS INITIAL.

      IF lv_found EQ 'X' AND <fs_info>-name2 IS NOT INITIAL.
        CONCATENATE <fs_info>-name1 <fs_info>-name2
        INTO <fs_info>-name1 SEPARATED BY space.
        CLEAR <fs_info>-name2.
      ENDIF.

      READ TABLE lt_lfa1 ASSIGNING <fs_lfa1>
      WITH KEY lifnr = <fs_info>-lifnr.
      IF sy-subrc EQ 0.
        <fs_info>-vkn_tckn = <fs_lfa1>-vkn_tckn.
      ENDIF.


      READ TABLE lt_vendor INTO ls_vendor WITH KEY lifnr = <fs_info>-lifnr.
      IF sy-subrc EQ 0.
        <fs_info>-ktokk = ls_vendor-ktokk.
      ELSE.
        IF <fs_lfa1> IS ASSIGNED.
          <fs_info>-ktokk = <fs_lfa1>-ktokk.
        ENDIF.
      ENDIF.

      IF gt_language[] IS NOT INITIAL.
        READ TABLE gt_language INTO ls_language WITH KEY mtype = gv_mtype
                                                         ktokk = <fs_info>-ktokk.
        IF sy-subrc EQ 0.
          <fs_info>-spras = ls_language-spras.
        ENDIF.
      ENDIF.

      IF <fs_info>-land1 EQ 'TR'.
        <fs_info>-spras = 'T'.
      ELSE.
        <fs_info>-spras = 'E'.
      ENDIF.

      CASE gs_adrs-tax_office.
        WHEN 'STCD1'.
          <fs_info>-vd = <fs_info>-stcd1.
        WHEN 'STCD2'.
          <fs_info>-vd = <fs_info>-stcd2.
        WHEN 'STCD3'.
          <fs_info>-vd = <fs_info>-stcd3.
        WHEN 'STCD4'.
          <fs_info>-vd = <fs_info>-stcd4.
        WHEN 'FISKN'.

*          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*            EXPORTING
*              input  = <fs_info>-fiskn
*            IMPORTING
*              output = <fs_info>-fiskn.

          <fs_info>-fiskn = |{  <fs_info>-fiskn ALPHA = IN }|.

          SELECT SINGLE OrganizationBPName1 AS name1
         FROM i_customer
        WHERE customer EQ @<fs_info>-fiskn
        INTO @<fs_info>-vd.
        WHEN 'STCEG'.
          <fs_info>-vd = <fs_info>-stceg.
      ENDCASE.

      MOVE-CORRESPONDING <fs_info> TO ls_vendor.

      INSERT ls_vendor INTO TABLE lt_vendor.
    ENDLOOP.

    FREE : lv_found.
    READ TABLE gt_flds TRANSPORTING NO FIELDS
    WITH KEY hesap_tur = 'M'
             name2_x = 'X'
             name2_use = ''.
    IF sy-subrc EQ 0.
      lv_found = 'X'.
    ENDIF.

    LOOP AT gt_account_info ASSIGNING <fs_info>
                                WHERE kunnr IS NOT INITIAL
                                  AND ktokd IS  INITIAL.



      IF lv_found EQ 'X' AND <fs_info>-name2 IS NOT INITIAL.
        CONCATENATE <fs_info>-name1 <fs_info>-name2
        INTO <fs_info>-name1 SEPARATED BY space.
        CLEAR <fs_info>-name2.
      ENDIF.

      READ TABLE lt_kna1 ASSIGNING <fs_kna1>
      WITH KEY kunnr = <fs_info>-kunnr.
      IF sy-subrc EQ 0.
        <fs_info>-vkn_tckn = <fs_kna1>-vkn_tckn.
      ENDIF.

      READ TABLE lt_customer INTO ls_customer WITH KEY kunnr = <fs_info>-kunnr.
      IF sy-subrc EQ 0.
        <fs_info>-ktokd = ls_customer-ktokd.
      ELSE.
        IF <fs_kna1> IS ASSIGNED.
          <fs_info>-ktokd = <fs_kna1>-ktokd.
        ENDIF.
      ENDIF.
      IF gt_language[] IS NOT INITIAL.
        READ TABLE gt_language INTO ls_language WITH KEY mtype = gv_mtype
                                                         ktokd = <fs_info>-ktokd.
        IF sy-subrc EQ 0.
          <fs_info>-spras = ls_language-spras.
        ENDIF.
      ENDIF.

      IF <fs_info>-land1 EQ 'TR'.
        <fs_info>-spras = 'T'.
      ELSE.
        <fs_info>-spras = 'E'.
      ENDIF.

      CASE gs_adrs-tax_office.
        WHEN 'STCD1'.
          <fs_info>-vd = <fs_info>-stcd1.
        WHEN 'STCD2'.
          <fs_info>-vd = <fs_info>-stcd2.
        WHEN 'STCD3'.
          <fs_info>-vd = <fs_info>-stcd3.
        WHEN 'STCD4'.
          <fs_info>-vd = <fs_info>-stcd4.
        WHEN 'FISKN'.

*          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*            EXPORTING
*              input  = <fs_info>-fiskn
*            IMPORTING
*              output = <fs_info>-fiskn.

          <fs_info>-fiskn = |{  <fs_info>-fiskn ALPHA = IN }|.

          SELECT SINGLE OrganizationBPName1 AS name1
         FROM i_customer
        WHERE customer EQ @<fs_info>-fiskn
        INTO @<fs_info>-vd.

        WHEN 'STCEG'.
          <fs_info>-vd = <fs_info>-stceg.
      ENDCASE.


    ENDLOOP.

    CASE gs_adrs-tax_number.
      WHEN 'STCD1'.
        LOOP AT gt_account_info ASSIGNING <fs_info>
          WHERE vkn_tckn IS INITIAL
          AND stcd1 IS NOT INITIAL .
          <fs_info>-vkn_tckn = <fs_info>-stcd1.
        ENDLOOP.
      WHEN 'STCD2'.
        LOOP AT gt_account_info ASSIGNING <fs_info>
          WHERE vkn_tckn IS INITIAL
          AND stcd2 IS NOT INITIAL .
          <fs_info>-vkn_tckn = <fs_info>-stcd2.
        ENDLOOP.
      WHEN 'STCD3'.
        LOOP AT gt_account_info ASSIGNING <fs_info>
          WHERE vkn_tckn IS INITIAL
          AND stcd3 IS NOT INITIAL .
          <fs_info>-vkn_tckn = <fs_info>-stcd3.
        ENDLOOP.
      WHEN 'STCD4'.
        LOOP AT gt_account_info ASSIGNING <fs_info>
          WHERE vkn_tckn IS INITIAL
          AND stcd4 IS NOT INITIAL .
          <fs_info>-vkn_tckn = <fs_info>-stcd4.
        ENDLOOP.
    ENDCASE.
  ENDMETHOD.