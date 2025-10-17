  METHOD kdv1.

    DATA ls_bkpf  TYPE mty_bkpf.
    DATA lt_bkpf  TYPE SORTED TABLE OF mty_bkpf WITH UNIQUE KEY bukrs belnr gjahr.
    DATA lt_bset  TYPE mtty_bset.
    DATA ls_bset  TYPE mty_bset.
    DATA lv_tabix TYPE sy-tabix.

    DATA lv_kbetr_s TYPE p LENGTH 16 DECIMALS 2..
    DATA lv_kbetr_h TYPE p LENGTH 16 DECIMALS 2..
    DATA lv_oran    TYPE p LENGTH 16 DECIMALS 2..
    DATA lv_bypass  TYPE abap_boolean.

    DATA ls_map   TYPE mty_map.
    DATA ls_map2  TYPE mty_map.
    DATA lt_map   TYPE TABLE OF mty_map.
    DATA lv_oran_int TYPE i.
    DATA lv_kiril3 TYPE ztax_e_acklm.

    DATA ls_collect TYPE ztax_ddl_i_vat1_dec_report."mty_collect.
*    DATA ls_account_balances TYPE bapi1028_4.
*    DATA lt_account_balances TYPE TABLE OF bapi1028_4.
    DATA lt_tax_voran TYPE TABLE OF ztax_t_voran.
    DATA ls_tax_voran TYPE  ztax_t_voran.

    TYPES BEGIN OF lty_k1mt.
    TYPES bukrs    TYPE ztax_t_k1mt-bukrs.
    TYPES gjahr    TYPE ztax_t_k1mt-gjahr.
    TYPES monat    TYPE ztax_t_k1mt-monat.
    TYPES kiril1   TYPE ztax_t_k1mt-kiril1.
    TYPES kiril2   TYPE ztax_t_k1mt-kiril2.
    TYPES mwskz    TYPE ztax_t_k1mt-mwskz.
    TYPES kschl    TYPE ztax_t_k1mt-kschl.
    TYPES hkont    TYPE ztax_t_k1mt-hkont.
    TYPES matrah   TYPE ztax_t_k1mt-matrah.
    TYPES vergi    TYPE ztax_t_k1mt-vergi.
    TYPES tevkt    TYPE ztax_t_k1mt-tevkt.
    TYPES manuel   TYPE ztax_t_k1mt-manuel.
    TYPES vergidis TYPE ztax_t_k1mt-vergidis.
    TYPES vergiic  TYPE ztax_t_k1mt-vergiic.
    TYPES END OF lty_k1mt.

    TYPES BEGIN OF lty_topal.
    TYPES split TYPE c LENGTH 10.
    TYPES END OF lty_topal.

    DATA ls_k1mt   TYPE lty_k1mt.
    DATA lt_k1mt   TYPE TABLE OF lty_k1mt.
    DATA ls_topal  TYPE lty_topal.
    DATA lt_topal  TYPE TABLE OF lty_topal.
    DATA lv_kiril2 TYPE ztax_e_kiril2.
    DATA lv_kiril1 TYPE ztax_e_kiril1.

    DATA ls_kostr TYPE mty_kostr.
    DATA lt_kostr TYPE TABLE OF mty_kostr.

    TYPES BEGIN OF lty_kostr_field.
    TYPES split TYPE c LENGTH 10.
    TYPES END OF lty_kostr_field.

    DATA lt_kostr_field TYPE TABLE OF lty_kostr_field.

    DATA lv_index       TYPE i.
    DATA lv_found_index TYPE i.
    DATA lv_length      TYPE i.

    DATA lv_butxt TYPE i_companycode-CompanyCodeName.

    TYPES BEGIN OF lty_kschl.
    TYPES sign(1) TYPE c.
    TYPES kschl TYPE kschl.
    TYPES END OF lty_kschl.

    DATA ls_kschl TYPE lty_kschl.
    DATA lt_kschl TYPE TABLE OF lty_kschl.
    DATA lr_kschl TYPE RANGE OF kschl.
    DATA lv_thlog_wrbtr TYPE ztax_t_thlog-wrbtr.

    DATA ls_read_tab TYPE mty_read_tab.
    DATA lt_bseg TYPE SORTED TABLE OF mty_bseg WITH UNIQUE KEY CompanyCode AccountingDocument FiscalYear AccountingDocumentItem.
    DATA ls_bseg TYPE mty_bseg.
    DATA lr_saknr TYPE RANGE OF I_OperationalAcctgDocItem-OperationalGLAccount.
    FIELD-SYMBOLS <fs_range>   TYPE any.
    FIELD-SYMBOLS <fs_field>   TYPE any.
    FIELD-SYMBOLS <fs_collect> TYPE ztax_ddl_i_vat1_dec_report." mty_collect.
*    FIELD-SYMBOLS <fs_detail>  TYPE ztax_s_detay_001.
    FIELD-SYMBOLS <lt_outtab> TYPE any .

    DATA : dref_it TYPE REF TO data.
    FIELD-SYMBOLS: <t_outtab>    TYPE any.

    DATA lr_ktosl TYPE RANGE OF ktosl.

    CLEAR me->ms_button_pushed.
    me->ms_button_pushed-kdv1 = abap_true.


    fill_monat_range( ).
    fill_det_kural_range( ).

    CLEAR mt_collect.
*    CLEAR mt_detail.
*    CLEAR mt_detail_alv.

    IF iv_bukrs IS NOT INITIAL.
      p_bukrs = iv_bukrs.
    ENDIF.

    IF iv_gjahr IS NOT INITIAL.
      p_gjahr = iv_gjahr.
    ENDIF.

    IF iv_monat IS NOT INITIAL.
      p_monat = iv_monat.
    ENDIF.

    IF iv_beyant IS NOT INITIAL.
      P_beyant = iv_beyant.
    ENDIF.

    IF iv_donemb IS NOT INITIAL.
      p_donemb = iv_donemb.
    ENDIF.

    me->get_condition_type( IMPORTING et_kostr = lt_kostr ).
    me->get_map_tab( IMPORTING et_map = lt_map ).

    SORT lt_map BY xmlsr ASCENDING.

    me->fill_saknr_range( EXPORTING it_map   = lt_map
                          IMPORTING er_saknr = lr_saknr ).
    me->get_prev_balance( IMPORTING ev_balance = lv_thlog_wrbtr ).

    CLEAR ls_read_tab.
    ls_read_tab-bset = abap_true.
    ls_read_tab-bseg = abap_true.
    me->find_document( EXPORTING is_read_tab = ls_read_tab
                                 ir_saknr    = lr_saknr
                       IMPORTING et_bkpf     = lt_bkpf
                                 et_bset     = lt_bset
                                 et_bseg     = lt_bseg ).

    SELECT bukrs ,
           gjahr ,
           monat ,
           kiril1 ,
           kiril2 ,
           mwskz ,
           kschl ,
           hkont ,
           matrah ,
           vergi ,
           tevkt ,
           manuel ,
           vergidis ,
           vergiic
           FROM ztax_t_k1mt
           WHERE bukrs EQ @p_bukrs
             AND gjahr EQ @p_gjahr
             AND monat IN @mr_monat
            INTO TABLE @lt_k1mt.

    SELECT SINGLE CompanyCodeName AS butxt
           FROM i_companycode
           WHERE CompanyCode EQ @p_bukrs
           INTO @lv_butxt.

    SORT lt_map BY xmlsr ASCENDING kural ASCENDING.

    LOOP AT lt_map INTO ls_map WHERE topal EQ space.
      CASE ls_map-kural.
        WHEN '001'. "Kural 1-Vergi Göstergesi
          CLEAR lv_tabix.

          lr_ktosl = VALUE #( sign = 'I' option = 'EQ' ( low =  'MWS' )
                                                       ( low =  'VST' ) ).
          IF ls_map-saknr IS NOT INITIAL.
            LOOP AT lt_bset INTO ls_bset WHERE mwskz EQ ls_map-mwskz
                                           AND hkont EQ ls_map-saknr
                                           AND ktosl IN lr_ktosl.

*              APPEND INITIAL LINE TO mt_detail ASSIGNING <fs_detail>.
*              IF <fs_detail> IS ASSIGNED.
*                CLEAR ls_bkpf.
*                READ TABLE lt_bkpf INTO ls_bkpf WITH TABLE KEY bukrs = ls_bset-bukrs
*                                                               belnr = ls_bset-belnr
*                                                               gjahr = ls_bset-gjahr.
*                CLEAR ls_bseg.
*                READ TABLE lt_bseg INTO ls_bseg WITH KEY bukrs = ls_bset-bukrs
*                                                         belnr = ls_bset-belnr
*                                                         gjahr = ls_bset-gjahr
*                                                         buzid = 'T'
*                                                         mwskz = ls_map-mwskz.
*                <fs_detail>-bukrs  = p_bukrs.
*                <fs_detail>-butxt  = lv_butxt.
*                <fs_detail>-kiril1 = ls_map-kiril1.
*                <fs_detail>-kiril2 = ls_map-kiril2.
*                <fs_detail>-acklm1 = ls_map-acklm1.
*                <fs_detail>-acklm2 = ls_map-acklm2.
*                <fs_detail>-belnr  = ls_bset-belnr.
*                <fs_detail>-gjahr  = ls_bset-gjahr.
*                <fs_detail>-monat  = ls_bkpf-monat.
*                <fs_detail>-buzei  = ls_bset-buzei.
*                <fs_detail>-mwskz  = ls_bset-mwskz.
*                <fs_detail>-kschl  = ls_bset-kschl.
*                <fs_detail>-hkont  = ls_bset-hkont.
*                <fs_detail>-matrah = ls_bset-hwbas.
*                <fs_detail>-vergi  = ls_bset-hwste.
*                <fs_detail>-shkzg  = ls_bset-shkzg.
*                <fs_detail>-zuonr  = ls_bseg-zuonr.
*                <fs_detail>-tevkt  = 0.
*                UNASSIGN <fs_detail>.
*              ENDIF.

              "1
              CLEAR ls_collect.
              ls_collect-kiril1 = ls_map-kiril1.
              ls_collect-acklm1 = ls_map-acklm1.
              IF ls_bset-shkzg EQ 'H'.
                ls_collect-matrah = ls_bset-hwbas * -1.
                ls_collect-vergi  = ls_bset-hwste * -1.
              ELSEIF ls_bset-shkzg EQ 'S'.
                ls_collect-matrah = ls_bset-hwbas.
                ls_collect-vergi  = ls_bset-hwste.
              ENDIF.
              COLLECT ls_collect INTO mt_collect.
              CLEAR ls_collect.
              "2
              CLEAR ls_collect.
              ls_collect-kiril1 = ls_map-kiril1.
              ls_collect-acklm1 = ls_map-acklm1.
              ls_collect-kiril2 = ls_map-kiril2.
              ls_collect-acklm2 = ls_map-acklm2.
              IF ls_bset-shkzg EQ 'S'.
                ls_collect-matrah = ls_bset-hwbas * -1.
                ls_collect-vergi  = ls_bset-hwste * -1.
              ELSEIF ls_bset-shkzg EQ 'H'.
                ls_collect-matrah = ls_bset-hwbas.
                ls_collect-vergi  = ls_bset-hwste.
              ENDIF.
              "<<D_ANANTU Comment
              COLLECT ls_collect INTO mt_collect.
              CLEAR ls_collect.
              "3
              CLEAR ls_collect.
              ls_collect-kiril1 = ls_map-kiril1.
              ls_collect-acklm1 = ls_map-acklm1.
              ls_collect-kiril2 = ls_map-kiril2.
              ls_collect-acklm2 = ls_map-acklm2.
              ">>D_ANANTU Comment
              ls_collect-kiril3 = ls_map-mwskz.

              CLEAR lv_oran_int.
              lv_oran_int = abs( ls_bset-kbetr ) / 10.
              ls_collect-oran = lv_oran_int.
              SHIFT ls_collect-oran LEFT DELETING LEADING space.
              IF ls_bset-shkzg EQ 'H'.
                ls_collect-matrah = ls_bset-hwbas * -1.
                ls_collect-vergi  = ls_bset-hwste * -1.
              ELSEIF ls_bset-shkzg EQ 'S'.
                ls_collect-matrah = ls_bset-hwbas.
                ls_collect-vergi  = ls_bset-hwste.
              ENDIF.
              COLLECT ls_collect INTO mt_collect.
              CLEAR ls_collect.
            ENDLOOP.
            IF sy-subrc IS NOT INITIAL.
              CLEAR ls_collect.
              ls_collect-kiril1 = ls_map-kiril1.
              ls_collect-acklm1 = ls_map-acklm1.
              COLLECT ls_collect INTO mt_collect.
              ls_collect-kiril2 = ls_map-kiril2.
              ls_collect-acklm2 = ls_map-acklm2.
              COLLECT ls_collect INTO mt_collect.
              ls_collect-kiril3 = ls_map-mwskz.
              COLLECT ls_collect INTO mt_collect.
              CLEAR ls_collect.
            ENDIF.

          ELSE.

            LOOP AT lt_bset INTO ls_bset WHERE mwskz EQ ls_map-mwskz
                                           AND ktosl IN lr_ktosl.
*              APPEND INITIAL LINE TO mt_detail ASSIGNING <fs_detail>.
*              IF <fs_detail> IS ASSIGNED.
*                CLEAR ls_bkpf.
*                READ TABLE lt_bkpf INTO ls_bkpf WITH TABLE KEY bukrs = ls_bset-bukrs
*                                                               belnr = ls_bset-belnr
*                                                               gjahr = ls_bset-gjahr.
*                CLEAR ls_bseg.
*                READ TABLE lt_bseg INTO ls_bseg WITH KEY bukrs = ls_bset-bukrs
*                                                         belnr = ls_bset-belnr
*                                                         gjahr = ls_bset-gjahr
*                                                         buzid = 'T'
*                                                         mwskz = ls_map-mwskz.
*                <fs_detail>-bukrs  = p_bukrs.
*                <fs_detail>-butxt  = lv_butxt.
*                <fs_detail>-kiril1 = ls_map-kiril1.
*                <fs_detail>-kiril2 = ls_map-kiril2.
*                <fs_detail>-acklm1 = ls_map-acklm1.
*                <fs_detail>-acklm2 = ls_map-acklm2.
*                <fs_detail>-belnr  = ls_bset-belnr.
*                <fs_detail>-gjahr  = ls_bset-gjahr.
*                <fs_detail>-monat  = ls_bkpf-monat.
*                <fs_detail>-buzei  = ls_bset-buzei.
*                <fs_detail>-mwskz  = ls_bset-mwskz.
*                <fs_detail>-kschl  = ls_bset-kschl.
*                <fs_detail>-hkont  = ls_bset-hkont.
*                <fs_detail>-matrah = ls_bset-hwbas.
*                <fs_detail>-vergi  = ls_bset-hwste.
*                <fs_detail>-shkzg  = ls_bset-shkzg.
*                <fs_detail>-zuonr  = ls_bseg-zuonr.
*                <fs_detail>-tevkt  = 0.
*                UNASSIGN <fs_detail>.
*              ENDIF.
*
*              "1
              CLEAR ls_collect.
              ls_collect-kiril1 = ls_map-kiril1.
              ls_collect-acklm1 = ls_map-acklm1.
              IF ls_bset-shkzg EQ 'H'.
                ls_collect-matrah = ls_bset-hwbas * -1.
                ls_collect-vergi  = ls_bset-hwste * -1.
              ELSEIF ls_bset-shkzg EQ 'S'.
                ls_collect-matrah = ls_bset-hwbas.
                ls_collect-vergi  = ls_bset-hwste.
              ENDIF.
              COLLECT ls_collect INTO mt_collect.
              CLEAR ls_collect.
              "2
              CLEAR ls_collect.
              ls_collect-kiril1 = ls_map-kiril1.
              ls_collect-acklm1 = ls_map-acklm1.
              ls_collect-kiril2 = ls_map-kiril2.
              ls_collect-acklm2 = ls_map-acklm2.
              IF ls_bset-shkzg EQ 'S'.
                ls_collect-matrah = ls_bset-hwbas * -1.
                ls_collect-vergi  = ls_bset-hwste * -1.
              ELSEIF ls_bset-shkzg EQ 'H'.
                ls_collect-matrah = ls_bset-hwbas.
                ls_collect-vergi  = ls_bset-hwste.
              ENDIF.
              "<<D_ANANTU Alper NANTU Comment
              COLLECT ls_collect INTO mt_collect.
              CLEAR ls_collect.
              "3
              CLEAR ls_collect.
              ls_collect-kiril1 = ls_map-kiril1.
              ls_collect-acklm1 = ls_map-acklm1.
              ls_collect-kiril2 = ls_map-kiril2.
              ls_collect-acklm2 = ls_map-acklm2.
              ">>D_ANANTU Alper NANTU comment
              ls_collect-kiril3 = ls_map-mwskz.

              CLEAR lv_oran_int.
              lv_oran_int = abs( ls_bset-kbetr ) / 10.
              ls_collect-oran = lv_oran_int.
              SHIFT ls_collect-oran LEFT DELETING LEADING space.
              IF ls_bset-shkzg EQ 'H'.
                ls_collect-matrah = ls_bset-hwbas * -1.
                ls_collect-vergi  = ls_bset-hwste * -1.
              ELSEIF ls_bset-shkzg EQ 'S'.
                ls_collect-matrah = ls_bset-hwbas.
                ls_collect-vergi  = ls_bset-hwste.
              ENDIF.
              COLLECT ls_collect INTO mt_collect.
              CLEAR ls_collect.
            ENDLOOP.
            IF sy-subrc IS NOT INITIAL.
              CLEAR ls_collect.
              ls_collect-kiril1 = ls_map-kiril1.
              ls_collect-acklm1 = ls_map-acklm1.
              COLLECT ls_collect INTO mt_collect.
              ls_collect-kiril2 = ls_map-kiril2.
              ls_collect-acklm2 = ls_map-acklm2.
              "D_ANANTU satır çoklama önüne geçmek için yapıldı.
              COLLECT ls_collect INTO mt_collect.
              IF ls_map-mwskz IS NOT INITIAL.
                ls_collect-kiril3 = ls_map-mwskz.
              ENDIF.
              COLLECT ls_collect INTO mt_collect.
              CLEAR ls_collect.
            ENDIF.
          ENDIF.
        WHEN '003'."Kural 3-Tevkifatlı Vergi Göstergesi
          CLEAR ls_collect.
          CLEAR lv_tabix.
          CLEAR lv_kbetr_s.
          CLEAR lv_kbetr_h.
          CLEAR ls_tax_voran.
          FREE : mt_tevita.
          FIELD-SYMBOLS <fs_value>  TYPE any.

          me->get_fieldname( IMPORTING et_tevita = mt_tevita ).
          me->get_gib( IMPORTING et_gib = mt_gib ).

          SELECT SINGLE * FROM ztax_t_voran
            WHERE bukrs EQ @p_bukrs
              AND mwskz EQ @ls_map-mwskz
              INTO @ls_tax_voran.

          LOOP AT lt_bset INTO ls_bset WHERE mwskz EQ ls_map-mwskz.

*            APPEND INITIAL LINE TO mt_detail ASSIGNING <fs_detail>.
*            IF <fs_detail> IS ASSIGNED.
*              CLEAR ls_bkpf.
*              READ TABLE lt_bkpf INTO ls_bkpf WITH TABLE KEY bukrs = ls_bset-bukrs
*                                                             belnr = ls_bset-belnr
*                                                             gjahr = ls_bset-gjahr.
*              CLEAR ls_bseg.
*              LOOP AT lt_bseg INTO ls_bseg WHERE bukrs = ls_bset-bukrs
*                                             AND belnr = ls_bset-belnr
*                                             AND gjahr = ls_bset-gjahr
*                                             AND buzid = 'T'.
*
*                CONTINUE.
*              ENDLOOP.
**              READ TABLE lt_bseg INTO ls_bseg WITH TABLE KEY bukrs = ls_bset-bukrs
**                                                             belnr = ls_bset-belnr
**                                                             gjahr = ls_bset-gjahr
**                                                             buzid = 'T'
*
*
*              <fs_detail>-bukrs  = p_bukrs.
*              <fs_detail>-butxt  = lv_butxt.
*              <fs_detail>-kiril1 = ls_map-kiril1.
*              <fs_detail>-kiril2 = ls_map-kiril2.
*              <fs_detail>-acklm1 = ls_map-acklm1.
*              <fs_detail>-acklm2 = ls_map-acklm2.
*              <fs_detail>-belnr  = ls_bset-belnr.
*              <fs_detail>-gjahr  = ls_bset-gjahr.
*              <fs_detail>-monat  = mv_monat.
*              <fs_detail>-buzei  = ls_bset-buzei.
*              <fs_detail>-mwskz  = ls_bset-mwskz.
*              <fs_detail>-kschl  = ls_bset-kschl.
*              <fs_detail>-hkont  = ls_bset-hkont.
*              <fs_detail>-matrah = ls_bset-hwbas.
*              <fs_detail>-vergi  = ls_bset-hwste.
*              <fs_detail>-shkzg  = ls_bset-shkzg.
*              <fs_detail>-zuonr  = ls_bseg-zuonr.
*              <fs_detail>-tevkt  = ls_bset-hwste.
*              UNASSIGN <fs_detail>.
*            ENDIF.
*
            CLEAR ls_collect.

            IF ls_map-kiril1 NE '031'.
              IF lines( mt_tevita ) GT 0.
                LOOP AT mt_tevita INTO DATA(ls_tevita).
                  ASSIGN COMPONENT ls_tevita-fieldname OF STRUCTURE ls_bseg TO <fs_value>.
                  IF <fs_value> IS ASSIGNED.

                    IF <fs_value> EQ ls_map-kiril2.
                      "1
                      ls_collect-kiril1 = ls_map-kiril1.
                      ls_collect-acklm1 = ls_map-acklm1.
                      IF ls_tax_voran-oran IS NOT INITIAL .
                        CASE ls_bset-shkzg.
                          WHEN 'H'.
                            ls_collect-matrah   = ls_bset-hwbas.
                            ls_collect-vergi    = ( ls_bset-hwbas * ls_tax_voran-oran ) / 100.
                            lv_kbetr_h          = ( ls_tax_voran-oran * 10 ).
                            lv_kbetr_s          = ( ls_tax_voran-oran * 10 ) - ls_bset-kbetr.
                            ls_collect-tevkifat = ( ( ls_bset-hwbas * ls_tax_voran-oran ) / 100 - ls_bset-hwste ).
                            ls_collect-vergi    = ls_collect-vergi + ( -1 * ( ( ls_bset-hwbas * ls_tax_voran-oran ) / 100 - ls_bset-hwste ) ).

                        ENDCASE.
                      ELSE.
                        CASE ls_bset-shkzg.
                          WHEN 'H'.
                            ls_collect-matrah   = ls_bset-hwbas.
                            ls_collect-vergi    = ls_bset-hwste.
                            lv_kbetr_h          = ls_bset-kbetr.
                          WHEN 'S'.
                            lv_kbetr_s          = ls_bset-kbetr.
                            ls_collect-tevkifat = ls_bset-hwste.
                            ls_collect-vergi    = -1 * ls_bset-hwste.
                        ENDCASE.
                      ENDIF.
                      COLLECT ls_collect INTO mt_collect.

                      ls_collect-kiril2 = ls_map-kiril2.
                      ls_collect-acklm2 = ls_map-acklm2.
                      COLLECT ls_collect INTO mt_collect.
                      "3
                      ls_collect-kiril3 = ls_map-mwskz.
                      COLLECT ls_collect INTO mt_collect.
                      UNASSIGN <fs_value>.
                    ENDIF.
                  ENDIF.
                ENDLOOP.

              ELSEIF lines( mt_gib ) GT 0.


                LOOP AT mt_gib INTO DATA(ls_gib).

                  CREATE DATA : dref_it TYPE (ls_gib-fieldname).
                  ASSIGN dref_it->* TO <lt_outtab>.
                  ASSIGN COMPONENT ls_gib-alan OF STRUCTURE <lt_outtab> TO <t_outtab>.

                  CASE ls_bkpf-awtyp(1).
                    WHEN 'R' OR 'V'.
                      SELECT SINGLE OriginalReferenceDocument FROM i_journalentry

                        WHERE CompanyCode = @ls_bkpf-bukrs
                          AND AccountingDocument = @ls_bkpf-belnr
                          AND FiscalYear = @ls_bkpf-gjahr
                          INTO @DATA(lv_awkey).

                      IF sy-subrc EQ 0.
                        SELECT SINGLE (ls_gib-alan) FROM (ls_gib-fieldname)

                           WHERE bukrs = @ls_bkpf-bukrs
                             AND belnr = @lv_awkey(10)
                             AND gjahr = @ls_bkpf-gjahr
                             INTO  @<t_outtab>.
                      ENDIF.

                    WHEN 'B' .
                      SELECT SINGLE (ls_gib-alan) FROM (ls_gib-fieldname)
                       WHERE bukrs = @ls_bkpf-bukrs
                         AND belnr = @ls_bkpf-belnr
                         AND gjahr = @ls_bkpf-gjahr
                         INTO  @<t_outtab>.



                  ENDCASE.

                  IF <t_outtab> EQ ls_map-kiril2.
                    "1
                    ls_collect-kiril1 = ls_map-kiril1.
                    ls_collect-acklm1 = ls_map-acklm1.
                    IF ls_tax_voran-oran IS NOT INITIAL .
                      CASE ls_bset-shkzg.
                        WHEN 'H'.
                          ls_collect-matrah   = ls_bset-hwbas.
                          ls_collect-vergi    = ( ls_bset-hwbas * ls_tax_voran-oran ) / 100.
                          lv_kbetr_h          = ( ls_tax_voran-oran * 10 ).
                          lv_kbetr_s          = ( ls_tax_voran-oran * 10 ) - ls_bset-kbetr.
                          ls_collect-tevkifat = ( ( ls_bset-hwbas * ls_tax_voran-oran ) / 100 - ls_bset-hwste ).
                          ls_collect-vergi    = ls_collect-vergi + ( -1 * ( ( ls_bset-hwbas * ls_tax_voran-oran ) / 100 - ls_bset-hwste ) ).

                      ENDCASE.
                    ELSE.
                      CASE ls_bset-shkzg.
                        WHEN 'H'.
                          ls_collect-matrah   = ls_bset-hwbas.
                          ls_collect-vergi    = ls_bset-hwste.
                          lv_kbetr_h          = ls_bset-kbetr.
                        WHEN 'S'.
                          lv_kbetr_s          = ls_bset-kbetr.
                          ls_collect-tevkifat = ls_bset-hwste.
                          ls_collect-vergi    = -1 * ls_bset-hwste.
                      ENDCASE.
                    ENDIF.
                    COLLECT ls_collect INTO mt_collect.

                    ls_collect-kiril2 = ls_map-kiril2.
                    ls_collect-acklm2 = ls_map-acklm2.
                    COLLECT ls_collect INTO mt_collect.
                    "3
                    ls_collect-kiril3 = ls_map-mwskz.
                    COLLECT ls_collect INTO mt_collect.
                    UNASSIGN <fs_value>.
                  ENDIF.
                ENDLOOP.
              ENDIF.

            ELSE.
              "1
              ls_collect-kiril1 = ls_map-kiril1.
              ls_collect-acklm1 = ls_map-acklm1.
              IF ls_tax_voran-oran IS NOT INITIAL .
                CASE ls_bset-shkzg.
                  WHEN 'H'.
                    ls_collect-matrah   = ls_bset-hwbas.
                    ls_collect-vergi    = ( ls_bset-hwbas * ls_tax_voran-oran ) / 100.
                    lv_kbetr_h          = ( ls_tax_voran-oran * 10 ).
                    lv_kbetr_s          = ( ls_tax_voran-oran * 10 ) - ls_bset-kbetr.
                    ls_collect-tevkifat = ( ( ls_bset-hwbas * ls_tax_voran-oran ) / 100 - ls_bset-hwste ).
                    ls_collect-vergi    = ls_collect-vergi + ( -1 * ( ( ls_bset-hwbas * ls_tax_voran-oran ) / 100 - ls_bset-hwste ) ).

                ENDCASE.
              ELSE.
                CASE ls_bset-shkzg.
                  WHEN 'H'.
                    ls_collect-matrah   = ls_bset-hwbas.
                    ls_collect-vergi    = ls_bset-hwste.
                    lv_kbetr_h          = ls_bset-kbetr.
                  WHEN 'S'.
                    lv_kbetr_s          = ls_bset-kbetr.
                    ls_collect-tevkifat = ls_bset-hwste.
                    ls_collect-vergi    = -1 * ls_bset-hwste.
                ENDCASE.
              ENDIF.
              COLLECT ls_collect INTO mt_collect.

              ls_collect-kiril2 = ls_map-kiril2.
              ls_collect-acklm2 = ls_map-acklm2.
              COLLECT ls_collect INTO mt_collect.

              "3
              ls_collect-kiril3 = ls_map-mwskz.
              COLLECT ls_collect INTO mt_collect.
            ENDIF.

          ENDLOOP.

          IF sy-subrc IS NOT INITIAL.
            CLEAR ls_collect.
            "1
            ls_collect-kiril1 = ls_map-kiril1.
            ls_collect-acklm1 = ls_map-acklm1.
            "2
            ls_collect-kiril2 = ls_map-kiril2.
            ls_collect-acklm2 = ls_map-acklm2.
            COLLECT ls_collect INTO mt_collect.
            "3
            ls_collect-kiril3 = ls_map-mwskz.
            COLLECT ls_collect INTO mt_collect.
            CLEAR ls_collect.
          ENDIF.

          READ TABLE mt_collect ASSIGNING <fs_collect> WITH KEY kiril1 = ls_map-kiril1
                                                                kiril2 = ls_map-kiril2
                                                                kiril3 = ls_map-mwskz.
          IF <fs_collect> IS ASSIGNED..
*            CLEAR lv_oran.
*            TRY.
*                lv_oran = ( abs( lv_kbetr_s ) / abs( lv_kbetr_h ) ) * 10.
*              CATCH cx_sy_zerodivide.
*            ENDTRY.
*            CLEAR lv_oran_int.
*            lv_oran_int = lv_oran.
*            <fs_collect>-tevkifato = lv_oran_int.
*            CLEAR lv_oran_int.
*            lv_oran_int = abs( lv_kbetr_h ) / 10.
*            <fs_collect>-oran      = lv_oran_int.
*            SHIFT <fs_collect>-oran LEFT DELETING LEADING space.
*            SHIFT <fs_collect>-tevkifato LEFT DELETING LEADING space.
*            CONCATENATE <fs_collect>-tevkifato '/10' INTO <fs_collect>-tevkifato.
*            UNASSIGN <fs_collect>.
          ENDIF.
        WHEN '004'."Kural 4-Önceki Dönem Hesap Bakiyesi
*          CLEAR lt_account_balances.
*          CALL FUNCTION 'BAPI_GL_GETGLACCPERIODBALANCES'
*            EXPORTING
*              companycode      = p_bukrs
*              glacct           = ls_map-saknr
*              fiscalyear       = p_gjahr
*              currencytype     = '10'
*            TABLES
*              account_balances = lt_account_balances.
*
*          READ TABLE lt_account_balances INTO ls_account_balances WITH KEY fis_period = ( p_monat - 1 ).
*          IF sy-subrc IS INITIAL.
*            CLEAR ls_collect.
*            ls_collect-kiril1 = ls_map-kiril1.
*            ls_collect-acklm1 = ls_map-acklm1.
*            ls_collect-vergi  = ls_account_balances-balance.
*            COLLECT ls_collect INTO mt_collect.
*
*            ls_collect-kiril2 = ls_map-kiril2.
*            ls_collect-acklm2 = ls_map-acklm2.
*            COLLECT ls_collect INTO mt_collect.
*
**            APPEND INITIAL LINE TO mt_detail ASSIGNING <fs_detail>.
**            IF <fs_detail> IS ASSIGNED.
**              <fs_detail>-bukrs  = p_bukrs.
**              <fs_detail>-butxt  = lv_butxt.
**              <fs_detail>-kiril1 = ls_map-kiril1.
**              <fs_detail>-kiril2 = ls_map-kiril2.
**              <fs_detail>-acklm1 = ls_map-acklm1.
**              <fs_detail>-acklm2 = ls_map-acklm2.
**              <fs_detail>-belnr  = space.
**              <fs_detail>-gjahr  = p_gjahr.
**              <fs_detail>-monat  = mv_monat.
**              <fs_detail>-buzei  = space.
**              <fs_detail>-mwskz  = space.
**              <fs_detail>-kschl  = space.
**              <fs_detail>-hkont  = ls_map-saknr.
**              <fs_detail>-matrah = 0.
**              <fs_detail>-vergi  = ls_account_balances-balance.
**              <fs_detail>-shkzg  = space.
**              <fs_detail>-zuonr  = space.
**              <fs_detail>-tevkt  = 0.
**              UNASSIGN <fs_detail>.
**            ENDIF.
*
*          ELSE.
*            CLEAR ls_collect.
*            ls_collect-kiril1 = ls_map-kiril1.
*            ls_collect-acklm1 = ls_map-acklm1.
*            ls_collect-vergi  = ls_account_balances-balance.
*            COLLECT ls_collect INTO mt_collect.
*
*            ls_collect-kiril2 = ls_map-kiril2.
*            ls_collect-acklm2 = ls_map-acklm2.
*            COLLECT ls_collect INTO mt_collect.
*            CLEAR ls_collect.
*          ENDIF.
        WHEN '005'."Kural 5-Vergi Göstergesi + Koşul Türü


*          me->call_badi_rule005(
*            EXPORTING
*              iv_bukrs  = p_bukrs
*              iv_gjahr  = p_gjahr
*              s_map     = ls_map
*            CHANGING
*              e_bypass  = lv_bypass
*              t_kostr   = lt_kostr
*              t_bset    = lt_bset
*              t_collect = mt_collect
*              t_bkpf    = lt_bkpf
*              t_detail  = mt_detail
*              t_bseg    = lt_bseg
*          ).

          CHECK lv_bypass EQ abap_false.
          CLEAR lt_kschl.
          CLEAR ls_kschl.
          CLEAR lv_found_index.
          READ TABLE lt_kostr INTO ls_kostr WITH KEY kiril2 = ls_map-kiril2.
          IF sy-subrc IS INITIAL.
            CONDENSE ls_kostr-kosult NO-GAPS.
            IF ls_kostr-kosult NE space.
              DO strlen( ls_kostr-kosult ) TIMES.
                lv_index = sy-index - 1.
                CASE ls_kostr-kosult+lv_index(1).
                  WHEN '+' OR '-'.
                    IF lv_index EQ 0.
                      lv_found_index = sy-index.
                      ls_kschl-sign =  ls_kostr-kosult+lv_index(1).
                      CONTINUE.
                    ENDIF.
                    lv_length = sy-index - lv_found_index - 1.
                    ls_kschl-kschl =  ls_kostr-kosult+lv_found_index(lv_length).
                    IF ls_kschl-kschl IS NOT INITIAL.
                      APPEND ls_kschl TO lt_kschl.
                    ENDIF.
                    lv_found_index = sy-index .
                    CLEAR ls_kschl.
                    IF lv_found_index NE 1.
                      ls_kschl-sign =  ls_kostr-kosult+lv_index(1).
                    ENDIF.
                ENDCASE.
              ENDDO.
              ls_kschl-kschl = ls_kostr-kosult+lv_found_index(*).
              APPEND ls_kschl TO lt_kschl.
              CLEAR ls_kschl.
            ENDIF.

            CLEAR lv_index.

            lv_index = lines( lt_kschl ).
            IF lv_index EQ 0.
              lv_index = 1.
            ENDIF.

            CLEAR lr_kschl.
            DO lv_index TIMES.
              CLEAR ls_kschl.
              READ TABLE lt_kschl INTO ls_kschl INDEX sy-index.
              IF sy-subrc IS INITIAL.
                APPEND INITIAL LINE TO lr_kschl ASSIGNING <fs_range>.
                IF <fs_range> IS ASSIGNED.
                  ASSIGN COMPONENT 'SIGN' OF STRUCTURE <fs_range> TO <fs_field>.
                  IF <fs_field> IS ASSIGNED.
                    <fs_field> = 'I'.
                    UNASSIGN <fs_field>.
                  ENDIF.
                  ASSIGN COMPONENT 'OPTION' OF STRUCTURE <fs_range> TO <fs_field>.
                  IF <fs_field> IS ASSIGNED.
                    <fs_field> = 'EQ'.
                    UNASSIGN <fs_field>.
                  ENDIF.
                  ASSIGN COMPONENT 'LOW' OF STRUCTURE <fs_range> TO <fs_field>.
                  IF <fs_field> IS ASSIGNED.
                    <fs_field> = ls_kschl-kschl.
                    UNASSIGN <fs_field>.
                  ENDIF.
                  UNASSIGN <fs_range>.
                ENDIF.
              ENDIF.
            ENDDO.
            LOOP AT lt_bset INTO ls_bset WHERE kschl IN lr_kschl
                                           AND mwskz EQ ls_map-mwskz.

              CLEAR ls_kschl.
              READ TABLE lt_kschl INTO ls_kschl WITH KEY kschl = ls_bset-kschl.

              CLEAR ls_collect.
              ls_bset-hwste = abs( ls_bset-hwste ).
              IF ls_kschl-sign EQ '-'.
                ls_bset-hwste = -1 * ls_bset-hwste.
              ENDIF.
              ls_collect-kiril1 = ls_map-kiril1.
              ls_collect-acklm1 = ls_map-acklm1.
              ls_collect-vergi  = ls_bset-hwste.
              COLLECT ls_collect INTO mt_collect.

              ls_collect-kiril2 = ls_map-kiril2.
              ls_collect-acklm2 = ls_map-acklm2.
              COLLECT ls_collect INTO mt_collect.

              ls_collect-kiril3 = ls_map-mwskz.

              COLLECT ls_collect INTO mt_collect.

*              APPEND INITIAL LINE TO mt_detail ASSIGNING <fs_detail>.
*              IF <fs_detail> IS ASSIGNED.
*                CLEAR ls_bkpf.
*                READ TABLE lt_bkpf INTO ls_bkpf WITH TABLE KEY bukrs = ls_bset-bukrs
*                                                               belnr = ls_bset-belnr
*                                                               gjahr = ls_bset-gjahr.
*                CLEAR ls_bseg.
*                READ TABLE lt_bseg INTO ls_bseg WITH KEY bukrs = ls_bset-bukrs
*                                                         belnr = ls_bset-belnr
*                                                         gjahr = ls_bset-gjahr
*                                                         buzid = 'T'.
*                <fs_detail>-bukrs  = p_bukrs.
*                <fs_detail>-butxt  = lv_butxt.
*                <fs_detail>-kiril1 = ls_map-kiril1.
*                <fs_detail>-kiril2 = ls_map-kiril2.
*                <fs_detail>-acklm1 = ls_map-acklm1.
*                <fs_detail>-acklm2 = ls_map-acklm2.
*                <fs_detail>-belnr  = ls_bset-belnr.
*                <fs_detail>-gjahr  = p_gjahr.
*                <fs_detail>-monat  = ls_bkpf-monat.
*                <fs_detail>-buzei  = ls_bset-buzei.
*                <fs_detail>-mwskz  = ls_bset-mwskz.
*                <fs_detail>-kschl  = ls_bset-kschl.
*                <fs_detail>-hkont  = ls_bset-hkont.
*                <fs_detail>-matrah = 0.
*                <fs_detail>-vergi  = ls_bset-hwste.
*                <fs_detail>-shkzg  = ls_bset-shkzg.
*                <fs_detail>-zuonr  = ls_bseg-zuonr.
*                <fs_detail>-tevkt  = 0.
*                UNASSIGN <fs_detail>.
*              ENDIF.

            ENDLOOP.
            IF sy-subrc IS NOT INITIAL.

              LOOP AT lt_kschl INTO ls_kschl.
                CLEAR ls_collect.
                ls_collect-kiril1 = ls_map-kiril1.
                ls_collect-acklm1 = ls_map-acklm1.
                COLLECT ls_collect INTO mt_collect.

                ls_collect-kiril2 = ls_map-kiril2.
                ls_collect-acklm2 = ls_map-acklm2.
                COLLECT ls_collect INTO mt_collect.

                ls_collect-kiril3 = ls_map-mwskz.
                COLLECT ls_collect INTO mt_collect.
                CLEAR ls_collect.
              ENDLOOP.
              IF sy-subrc IS NOT INITIAL.
                CLEAR ls_collect.
                ls_collect-kiril1 = ls_map-kiril1.
                ls_collect-acklm1 = ls_map-acklm1.
                COLLECT ls_collect INTO mt_collect.

                ls_collect-kiril2 = ls_map-kiril2.
                ls_collect-acklm2 = ls_map-acklm2.
                COLLECT ls_collect INTO mt_collect.

                ls_collect-kiril3    = ls_map-mwskz.
                COLLECT ls_collect INTO mt_collect.
                CLEAR ls_collect.
              ENDIF.

            ENDIF.
          ENDIF.
        WHEN '008'.
          me->calculate_sum_balance( EXPORTING is_map   = ls_map
                                               iv_bukrs = p_bukrs
                                               iv_gjahr = p_gjahr
                                               iv_monat = p_monat
                                               iv_butxt = lv_butxt
                                               is_bset  = ls_bset
                                               it_bkpf  = lt_bkpf
                                               it_bseg  = lt_bseg ).

          "Ana hesap
        WHEN '009'.
          CLEAR lv_tabix.
          IF ls_map-saknr IS INITIAL .
            CONTINUE.
          ENDIF.
          CLEAR lv_tabix.
          CLEAR ls_bseg.
          LOOP AT lt_bseg INTO ls_bseg WHERE GLAccount EQ ls_map-saknr
                                        AND  CompanyCode = p_bukrs
                                        AND  FiscalYear = p_gjahr.

*            APPEND INITIAL LINE TO mt_detail ASSIGNING <fs_detail>.
*            IF <fs_detail> IS ASSIGNED.
*              CLEAR ls_bkpf.
*              READ TABLE lt_bkpf INTO ls_bkpf WITH TABLE KEY bukrs = ls_bseg-bukrs
*                                                             belnr = ls_bseg-belnr
*                                                             gjahr = ls_bseg-gjahr.
*              CLEAR ls_bset.
*              READ TABLE lt_bset INTO ls_bset WITH KEY bukrs = ls_bseg-bukrs
*                                                       gjahr = ls_bseg-gjahr
*                                                       belnr = ls_bseg-belnr
*                                                       buzei = '001'.
*
*              <fs_detail>-bukrs  = p_bukrs.
*              <fs_detail>-butxt  = lv_butxt.
*              <fs_detail>-kiril1 = ls_map-kiril1.
*              <fs_detail>-kiril2 = ls_map-kiril2.
*              <fs_detail>-acklm1 = ls_map-acklm1.
*              <fs_detail>-acklm2 = ls_map-acklm2.
*              <fs_detail>-belnr  = ls_bset-belnr.
*              <fs_detail>-gjahr  = ls_bset-gjahr.
*              <fs_detail>-monat  = ls_bkpf-monat.
*              <fs_detail>-buzei  = ls_bset-buzei.
*              <fs_detail>-mwskz  = ls_bset-mwskz.
*              <fs_detail>-kschl  = ls_bset-kschl.
*              <fs_detail>-hkont  = ls_bset-hkont.
*              <fs_detail>-matrah = ls_bset-hwbas.
*              <fs_detail>-vergi  = ls_bset-hwste.
*              <fs_detail>-shkzg  = ls_bset-shkzg.
*              <fs_detail>-zuonr  = ls_bseg-zuonr.
*              <fs_detail>-tevkt  = 0.
*              UNASSIGN <fs_detail>.
*            ENDIF.

            "1
            CLEAR ls_collect.
            ls_collect-kiril1 = ls_map-kiril1.
            ls_collect-acklm1 = ls_map-acklm1.
            IF ls_bset-shkzg EQ 'H'.
              ls_collect-matrah = ls_bset-hwbas * -1.
              ls_collect-vergi  = ls_bset-hwste * -1.
            ELSEIF ls_bset-shkzg EQ 'S'.
              ls_collect-matrah = ls_bset-hwbas.
              ls_collect-vergi  = ls_bset-hwste.
            ENDIF.
            COLLECT ls_collect INTO mt_collect.
            CLEAR ls_collect.
            "2
            CLEAR ls_collect.
            ls_collect-kiril1 = ls_map-kiril1.
            ls_collect-acklm1 = ls_map-acklm1.
            ls_collect-kiril2 = ls_map-kiril2.
            ls_collect-acklm2 = ls_map-acklm2.
            IF ls_bset-shkzg EQ 'S'.
              ls_collect-matrah = ls_bset-hwbas * -1.
              ls_collect-vergi  = ls_bset-hwste * -1.
            ELSEIF ls_bset-shkzg EQ 'H'.
              ls_collect-matrah = ls_bset-hwbas.
              ls_collect-vergi  = ls_bset-hwste.
            ENDIF.
            COLLECT ls_collect INTO mt_collect.
            CLEAR ls_collect.
            "3
            CLEAR ls_collect.
            ls_collect-kiril1 = ls_map-kiril1.
            ls_collect-acklm1 = ls_map-acklm1.
            ls_collect-kiril2 = ls_map-kiril2.
            ls_collect-acklm2 = ls_map-acklm2.
            ls_collect-kiril3 = ls_map-mwskz.

            CLEAR lv_oran_int.
            lv_oran_int = abs( ls_bset-kbetr ) / 10.
            ls_collect-oran = lv_oran_int.
            SHIFT ls_collect-oran LEFT DELETING LEADING space.
            IF ls_bset-shkzg EQ 'H'.
              ls_collect-matrah = ls_bset-hwbas * -1.
              ls_collect-vergi  = ls_bset-hwste * -1.
            ELSEIF ls_bset-shkzg EQ 'S'.
              ls_collect-matrah = ls_bset-hwbas.
              ls_collect-vergi  = ls_bset-hwste.
            ENDIF.
            COLLECT ls_collect INTO mt_collect.
            CLEAR ls_collect.
          ENDLOOP.
          IF sy-subrc IS NOT INITIAL.
            CLEAR ls_collect.
            ls_collect-kiril1 = ls_map-kiril1.
            ls_collect-acklm1 = ls_map-acklm1.
            COLLECT ls_collect INTO mt_collect.
            ls_collect-kiril2 = ls_map-kiril2.
            ls_collect-acklm2 = ls_map-acklm2.
            COLLECT ls_collect INTO mt_collect.
            ls_collect-kiril3 = ls_map-mwskz.
            COLLECT ls_collect INTO mt_collect.
            CLEAR ls_collect.
          ENDIF.

          "Ana hesap +Vergi göstergesi
        WHEN '010'.
          CLEAR lv_tabix.
          CLEAR ls_bseg.
          DELETE ADJACENT DUPLICATES FROM lt_bseg COMPARING CompanyCode GLAccount FiscalYear TaxCode.
          LOOP AT lt_bseg INTO ls_bseg WHERE  GLAccount = ls_map-saknr
                                         AND  TaxCode = ls_map-mwskz
                                         AND  CompanyCode = p_bukrs
                                         AND  FiscalYear = p_gjahr.




*            APPEND INITIAL LINE TO mt_detail ASSIGNING <fs_detail>.
*            IF <fs_detail> IS ASSIGNED.
*              CLEAR ls_bkpf.
*              READ TABLE lt_bkpf INTO ls_bkpf WITH TABLE KEY bukrs = ls_bseg-bukrs
*                                                             belnr = ls_bseg-belnr
*                                                             gjahr = ls_bseg-gjahr.
*              CLEAR ls_bset.
*              READ TABLE lt_bset INTO ls_bset WITH KEY bukrs = ls_bseg-bukrs
*                                                       belnr = ls_bseg-belnr
*                                                       gjahr = ls_bseg-gjahr
*                                                       buzei = '001'
*                                                       mwskz = ls_map-mwskz.
*              <fs_detail>-bukrs  = p_bukrs.
*              <fs_detail>-butxt  = lv_butxt.
*              <fs_detail>-kiril1 = ls_map-kiril1.
*              <fs_detail>-kiril2 = ls_map-kiril2.
*              <fs_detail>-acklm1 = ls_map-acklm1.
*              <fs_detail>-acklm2 = ls_map-acklm2.
*              <fs_detail>-belnr  = ls_bset-belnr.
*              <fs_detail>-gjahr  = ls_bset-gjahr.
*              <fs_detail>-monat  = ls_bkpf-monat.
*              <fs_detail>-buzei  = ls_bset-buzei.
*              <fs_detail>-mwskz  = ls_bset-mwskz.
*              <fs_detail>-kschl  = ls_bset-kschl.
*              <fs_detail>-hkont  = ls_bset-hkont.
*              <fs_detail>-matrah = ls_bset-hwbas.
*              <fs_detail>-vergi  = ls_bset-hwste.
*              <fs_detail>-shkzg  = ls_bset-shkzg.
*              <fs_detail>-zuonr  = ls_bseg-zuonr.
*              <fs_detail>-tevkt  = 0.
*              UNASSIGN <fs_detail>.
*            ENDIF.

            "1
            CLEAR ls_collect.
            ls_collect-kiril1 = ls_map-kiril1.
            ls_collect-acklm1 = ls_map-acklm1.
            IF ls_bset-shkzg EQ 'H'.
              ls_collect-matrah = ls_bset-hwbas * -1.
              ls_collect-vergi  = ls_bset-hwste * -1.
            ELSEIF ls_bset-shkzg EQ 'S'.
              ls_collect-matrah = ls_bset-hwbas.
              ls_collect-vergi  = ls_bset-hwste.
            ENDIF.
            COLLECT ls_collect INTO mt_collect.
            CLEAR ls_collect.
            "2
            CLEAR ls_collect.
            ls_collect-kiril1 = ls_map-kiril1.
            ls_collect-acklm1 = ls_map-acklm1.
            ls_collect-kiril2 = ls_map-kiril2.
            ls_collect-acklm2 = ls_map-acklm2.
            IF ls_bset-shkzg EQ 'S'.
              ls_collect-matrah = ls_bset-hwbas * -1.
              ls_collect-vergi  = ls_bset-hwste * -1.
            ELSEIF ls_bset-shkzg EQ 'H'.
              ls_collect-matrah = ls_bset-hwbas.
              ls_collect-vergi  = ls_bset-hwste.
            ENDIF.
            COLLECT ls_collect INTO mt_collect.
            CLEAR ls_collect.
            "3
            CLEAR ls_collect.
            ls_collect-kiril1 = ls_map-kiril1.
            ls_collect-acklm1 = ls_map-acklm1.
            ls_collect-kiril2 = ls_map-kiril2.
            ls_collect-acklm2 = ls_map-acklm2.
            ls_collect-kiril3 = ls_map-mwskz.

            CLEAR lv_oran_int.
            lv_oran_int = abs( ls_bset-kbetr ) / 10.
            ls_collect-oran = lv_oran_int.
            SHIFT ls_collect-oran LEFT DELETING LEADING space.
            IF ls_bset-shkzg EQ 'H'.
              ls_collect-matrah = ls_bset-hwbas * -1.
              ls_collect-vergi  = ls_bset-hwste * -1.
            ELSEIF ls_bset-shkzg EQ 'S'.
              ls_collect-matrah = ls_bset-hwbas.
              ls_collect-vergi  = ls_bset-hwste.
            ENDIF.
            COLLECT ls_collect INTO mt_collect.
            CLEAR ls_collect.
          ENDLOOP.
          IF sy-subrc IS NOT INITIAL.
            CLEAR ls_collect.
            ls_collect-kiril1 = ls_map-kiril1.
            ls_collect-acklm1 = ls_map-acklm1.
            COLLECT ls_collect INTO mt_collect.
            ls_collect-kiril2 = ls_map-kiril2.
            ls_collect-acklm2 = ls_map-acklm2.
            COLLECT ls_collect INTO mt_collect.
            ls_collect-kiril3 = ls_map-mwskz.
            COLLECT ls_collect INTO mt_collect.
            CLEAR ls_collect.
          ENDIF.

      ENDCASE.
    ENDLOOP.



    LOOP AT mt_collect ASSIGNING <fs_collect>.

      <fs_collect>-matrah   = abs( <fs_collect>-matrah ).
      <fs_collect>-vergi    = abs( <fs_collect>-vergi ).
      <fs_collect>-tevkifat = abs( <fs_collect>-tevkifat ).

    ENDLOOP.


    " manuel olanları toplayalım .

    CLEAR ls_map.
    SORT lt_map BY kiril1 kiril2.
    LOOP AT lt_k1mt INTO ls_k1mt.

      CLEAR ls_map.
      READ TABLE lt_map INTO ls_map WITH KEY kiril1 = ls_k1mt-kiril1
                                             kiril2 = ls_k1mt-kiril2
                                             BINARY SEARCH.

      READ TABLE mt_collect ASSIGNING <fs_collect> WITH KEY kiril1 = ls_k1mt-kiril1
                                                            kiril2 = space.
      IF <fs_collect> IS ASSIGNED.
        <fs_collect>-matrah = <fs_collect>-matrah + ls_k1mt-matrah.
        <fs_collect>-vergi = <fs_collect>-vergi + ls_k1mt-vergi.
        <fs_collect>-vergi = <fs_collect>-vergi + ls_k1mt-tevkt.
*        ADD ls_k1mt-matrah TO <fs_collect>-matrah.
*        ADD ls_k1mt-vergi  TO <fs_collect>-vergi.
*        ADD ls_k1mt-tevkt  TO <fs_collect>-vergi.
        UNASSIGN <fs_collect>.
      ENDIF.

      READ TABLE mt_collect ASSIGNING <fs_collect> WITH KEY kiril1 = ls_k1mt-kiril1
                                                            kiril2 = ls_k1mt-kiril2.
      IF <fs_collect> IS ASSIGNED.
        <fs_collect>-matrah = <fs_collect>-matrah + ls_k1mt-matrah.
        <fs_collect>-vergi = <fs_collect>-vergi + ls_k1mt-vergi.
        <fs_collect>-vergi = <fs_collect>-vergi + ls_k1mt-tevkt.
*        ADD ls_k1mt-matrah TO <fs_collect>-matrah.
*        ADD ls_k1mt-vergi  TO <fs_collect>-vergi.
*        ADD ls_k1mt-tevkt  TO <fs_collect>-vergi.
        UNASSIGN <fs_collect>.
      ENDIF.

      READ TABLE mt_collect ASSIGNING <fs_collect> WITH KEY kiril1 = ls_k1mt-kiril1
                                                            kiril2 = ls_k1mt-kiril2
                                                            kiril3 = ls_k1mt-mwskz.
      IF <fs_collect> IS ASSIGNED.
        <fs_collect>-matrah = <fs_collect>-matrah + ls_k1mt-matrah.
        <fs_collect>-vergi = <fs_collect>-vergi + ls_k1mt-vergi.
        <fs_collect>-vergi = <fs_collect>-vergi + ls_k1mt-tevkt.
*        ADD ls_k1mt-matrah TO <fs_collect>-matrah.
*        ADD ls_k1mt-vergi  TO <fs_collect>-vergi.
*        ADD ls_k1mt-tevkt  TO <fs_collect>-vergi.
        UNASSIGN <fs_collect>.
      ENDIF.

*      APPEND INITIAL LINE TO mt_detail ASSIGNING <fs_detail>.
*      IF <fs_detail> IS ASSIGNED.
*        <fs_detail>-bukrs    = p_bukrs.
*        <fs_detail>-butxt    = lv_butxt.
*        <fs_detail>-kiril1   = ls_k1mt-kiril1.
*        <fs_detail>-kiril2   = ls_k1mt-kiril2.
*        <fs_detail>-acklm1   = ls_map-acklm1.
*        <fs_detail>-acklm2   = ls_map-acklm2.
*        <fs_detail>-belnr    = mc_new_line_belnr.
*        <fs_detail>-gjahr    = ls_k1mt-gjahr.
*        <fs_detail>-monat    = ls_k1mt-monat.
*        <fs_detail>-buzei    = space.
*        <fs_detail>-mwskz    = ls_k1mt-mwskz.
*        <fs_detail>-kschl    = ls_k1mt-kschl.
*        <fs_detail>-hkont    = ls_k1mt-hkont.
*        <fs_detail>-matrah   = ls_k1mt-matrah.
*        <fs_detail>-vergi    = ls_k1mt-vergi.
*        <fs_detail>-tevkt    = ls_k1mt-tevkt.
*        <fs_detail>-manuel   = ls_k1mt-manuel.
*        <fs_detail>-vergidis = ls_k1mt-vergidis.
*        <fs_detail>-vergiic  = ls_k1mt-vergiic.
*        UNASSIGN <fs_detail>.
*      ENDIF.

    ENDLOOP.
    "<
    LOOP AT lt_map INTO ls_map WHERE topal NE space.

      CONDENSE ls_map-topal NO-GAPS.
      CLEAR lt_topal.
      CLEAR lv_kiril2.
      CLEAR lv_kiril1.
      SPLIT ls_map-topal AT '+' INTO TABLE lt_topal.

      LOOP AT lt_topal INTO ls_topal.
        CLEAR lv_kiril2.
        CLEAR ls_map2.
        SHIFT ls_topal-split LEFT DELETING LEADING space.
        lv_kiril1 = ls_topal-split.

        LOOP AT mt_collect INTO ls_collect WHERE kiril1 EQ lv_kiril1
                                             AND kiril2 EQ lv_kiril2
                                             AND kiril3 EQ space.
          ls_collect-kiril1 = ls_map-kiril1.
          ls_collect-acklm1 = ls_map-acklm1.
          ls_collect-kiril2 = ls_map-kiril2.
          ls_collect-acklm2 = ls_map-acklm2.


          IF ls_map-topalk EQ '001'.
            CLEAR ls_collect-matrah.
            CLEAR ls_collect-oran.
            CLEAR ls_collect-tevkifat.
            CLEAR ls_collect-tevkifato.
          ELSE.
            CLEAR ls_collect-vergi.
            CLEAR ls_collect-tevkifat.
          ENDIF.

          COLLECT ls_collect INTO mt_collect.
          CLEAR ls_collect.

        ENDLOOP.
      ENDLOOP.
      IF ls_map-kural EQ '007'.
        READ TABLE mt_collect ASSIGNING <fs_collect> WITH KEY kiril1 = ls_map-kiril1
                                                              kiril2 = ls_map-kiril2.
        IF sy-subrc IS INITIAL.
          <fs_collect>-matrah = <fs_collect>-matrah + lv_thlog_wrbtr.
*          ADD lv_thlog_wrbtr TO <fs_collect>-matrah.
          UNASSIGN <fs_collect>.
        ENDIF.
      ENDIF.
    ENDLOOP.

    et_collect = mt_collect.
    er_monat   = mr_monat.

  ENDMETHOD.