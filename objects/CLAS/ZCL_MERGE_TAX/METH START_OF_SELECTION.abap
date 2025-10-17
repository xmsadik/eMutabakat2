  METHOD start_of_Selection.



    FIELD-SYMBOLS: <lr_loevm> TYPE ty_loevm.
    FIELD-SYMBOLS: <lr_bukrs> TYPE ty_bukrs.
    FIELD-SYMBOLS: <lr_ktokd> TYPE ty_ktokd.
    FIELD-SYMBOLS: <lr_sperr> TYPE ty_sperr.

    IF p_blk IS NOT INITIAL.
      APPEND INITIAL LINE TO r_sperr ASSIGNING <lr_sperr>.
      <lr_sperr>-sign   = 'I'.
      <lr_sperr>-option = 'EQ'.
      <lr_sperr>-low    = zreco_if_common_types=>mc_select_no.
    ENDIF.

    IF p_del IS NOT INITIAL.
      APPEND INITIAL LINE TO r_loevm ASSIGNING <lr_loevm>.
      <lr_loevm>-sign = 'I'.
      <lr_loevm>-option = 'EQ'.
      <lr_loevm>-low = ''.
    ENDIF.


* Mutabakat yapılan şirketleri bul
    SELECT * FROM zreco_adrs INTO TABLE @lt_adrs.

    LOOP AT lt_adrs INTO ls_adrs.
      APPEND INITIAL LINE TO r_bukrs ASSIGNING <lr_bukrs>.
      <lr_bukrs>-sign = 'I'.
      <lr_bukrs>-option = 'EQ'.
      <lr_bukrs>-low = ls_adrs-bukrs.
    ENDLOOP.

    CHECK sy-subrc EQ 0.

* Herhangi bir şirketin mutabakat uyarlamasına bak
    READ TABLE lt_adrs INTO ls_adrs INDEX 1.

* Hariç tutulacak VKN/TCKN
    SELECT * FROM zreco_etax INTO TABLE @lt_etax.

* Birleştirme yapılacak müşteri/satıcı grupları
    SELECT * FROM zreco_taxg INTO TABLE @lt_taxg.

* Müşterileri seç
    IF p_seld IS NOT INITIAL.

      DELETE FROM zreco_taxm WHERE hesap_tur EQ 'M'
                                     AND hesap_no IN @s_kunnr.

      DELETE FROM Zreco_taxn WHERE hesap_tur EQ 'M'
                                     AND hesap_no IN @s_kunnr.

      LOOP AT lt_taxg INTO DATA(ls_taxg) WHERE ktokd IS NOT INITIAL.
        APPEND INITIAL LINE TO r_ktokd ASSIGNING <lr_ktokd>.
        <lr_ktokd>-sign = 'I'.
        <lr_ktokd>-option = 'EQ'.
        <lr_ktokd>-low = ls_taxg-ktokd.
      ENDLOOP.


*      OPEN CURSOR WITH HOLD s_cursor_kna1 FOR
      SELECT kna1~customer AS kunnr,
             kna1~AddressID AS adrnr,
             kna1~FiscalAddress AS fiskn,
             kna1~CustomerAccountGroup AS ktokd,
             kna1~supplier AS lifnr,
             kna1~TaxNumber1 AS stcd1,
             kna1~TaxNumber2 AS stcd2,
             kna1~VATRegistration AS stceg,
             kna1~TaxNumber3 AS stcd3,
             kna1~TaxNumber4 AS stcd4
        FROM i_customer AS  kna1 INNER JOIN i_customercompany AS knb1 ON knb1~customer EQ kna1~customer
        WHERE knb1~CompanyCode IN @r_bukrs
        AND knb1~customer IN @s_kunnr
        AND knb1~ReconciliationAccount NE ''
*        AND knb1~erdat IN @s_erdat                 "YiğitcanÖzdemir
        AND kna1~creationdate IN @s_erdat
        AND kna1~PostingIsBlocked IN @r_sperr
        AND kna1~DeletionIndicator IN @r_loevm
        AND kna1~IsOneTimeAccount EQ ''
        INTO TABLE @lt_kna1.

*      DO.
*        FETCH NEXT CURSOR s_cursor_kna1
*        APPENDING TABLE lt_kna1
*        PACKAGE SIZE 1000.
*
*        IF sy-subrc NE 0.
*          EXIT.
*        ENDIF.
*      ENDDO.

*      CLOSE CURSOR s_cursor_kna1.

      CLEAR : lt_taxm,lt_taxn,
              lv_count_m,lv_count_n.

      LOOP AT lt_kna1 INTO DATA(s_kna1).

        CLEAR: ls_taxm, ls_taxn.

        ls_taxm-hesap_tur = 'M'.
        ls_taxm-hesap_no = s_kna1-kunnr.
        ls_taxm-ktokl = s_kna1-ktokd.
        ls_taxm-kunnr = s_kna1-kunnr.
        ls_taxm-lifnr = s_kna1-lifnr.
        ls_taxm-adrnr = s_kna1-adrnr.

        CASE ls_adrs-tax_number.
          WHEN 'STCD1'.
            ls_taxm-vkn_tckn = s_kna1-stcd1.
          WHEN 'STCD2'.
            ls_taxm-vkn_tckn = s_kna1-stcd2.
          WHEN 'STCD3'.
            ls_taxm-vkn_tckn = s_kna1-stcd3.
          WHEN 'STCD4'.
            ls_taxm-vkn_tckn = s_kna1-stcd4.
          WHEN 'STCEG'.
            ls_taxm-vkn_tckn = s_kna1-stceg.
          WHEN 'FISKN'.
            ls_taxm-vkn_tckn = s_kna1-fiskn.
        ENDCASE.

        IF ls_adrs-tax_person IS NOT INITIAL AND
           ls_taxm-vkn_tckn IS INITIAL.

          CASE ls_adrs-tax_person.
            WHEN 'STCD1'.
              ls_taxm-vkn_tckn = s_kna1-stcd1.
            WHEN 'STCD2'.
              ls_taxm-vkn_tckn = s_kna1-stcd2.
            WHEN 'STCD3'.
              ls_taxm-vkn_tckn = s_kna1-stcd3.
            WHEN 'STCD4'.
              ls_taxm-vkn_tckn = s_kna1-stcd4.
            WHEN 'STCEG'.
              ls_taxm-vkn_tckn = s_kna1-stceg.
            WHEN 'FISKN'.
              ls_taxm-vkn_tckn = s_kna1-fiskn.
          ENDCASE.

        ENDIF.


        IF ls_taxm-ktokl NOT IN r_ktokd.
* Birleştirme yapılmayacak grup ise
          MOVE-CORRESPONDING ls_taxm TO ls_taxn.

          IF ls_taxn IS NOT INITIAL.

            APPEND ls_taxn TO lt_taxn.

            lv_count_n = lv_count_n + 1.

          ENDIF.

        ELSE.
          IF ls_taxm IS NOT INITIAL.
* Birleştirilmeyecek VKN/TCKN ise
            READ TABLE lt_etax INTO DATA(s_etax) WITH KEY stcd2 = ls_taxm-vkn_tckn.
            IF sy-subrc NE 0.

              APPEND ls_taxm TO lt_taxm.

              lv_count_m = lv_count_m + 1.

            ELSE.

              MOVE-CORRESPONDING ls_taxm TO ls_taxn.

              IF ls_taxn IS NOT INITIAL.

                APPEND ls_taxn TO lt_taxn.

                lv_count_n = lv_count_n + 1.

              ENDIF.

            ENDIF.
          ENDIF.
        ENDIF.

*        IF lv_count_n EQ 10000.
*          MODIFY zreco_taxn FROM TABLE @lt_taxn.
*          CLEAR : lt_taxn,lv_count_n.
*        ENDIF.
*
*        IF lv_count_m EQ 10000.
*          MODIFY zreco_taxm FROM TABLE @lt_taxm.
*          CLEAR : lt_taxm,lv_count_m.
*        ENDIF.

      ENDLOOP.

*      IF lv_count_n NE 0.
      MODIFY zreco_taxn FROM TABLE @lt_taxn.
      CLEAR : lt_taxn,lv_count_n.
*      ENDIF.

*      IF lv_count_m NE 0.
      MODIFY zreco_taxm FROM TABLE @lt_taxm.
      CLEAR : lt_taxm,lv_count_m.
      COMMIT WORK AND WAIT .
*      ENDIF.

    ENDIF.


    " Satıcıları seç
    IF p_selk IS NOT INITIAL.

      DELETE FROM zreco_taxm WHERE hesap_tur EQ 'S'
                                     AND hesap_no IN @s_lifnr.

      DELETE FROM zreco_taxn WHERE hesap_tur EQ 'S'
                                     AND hesap_no IN @s_lifnr.

      LOOP AT lt_taxg INTO DATA(s_taxg) WHERE ktokk IS NOT INITIAL.
        APPEND INITIAL LINE TO r_ktokk ASSIGNING FIELD-SYMBOL(<fs_ktokk>).
        <fs_ktokk>-sign = 'I'.
        <fs_ktokk>-option = 'EQ'.
        <fs_ktokk>-low = s_taxg-ktokk.
*        APPEND r_ktokk.
      ENDLOOP.

*      OPEN CURSOR WITH HOLD s_cursor_lfa1 FOR
      SELECT lfa1~supplier AS lifnr,
             lfa1~AddressID AS adrnr,
             lfa1~FiscalAddress AS fiskn,
             lfa1~SupplierAccountGroup AS ktokk,
             lfa1~Customer AS kunnr,
             lfa1~TaxNumber1 AS stcd1,
             lfa1~TaxNumber2 AS stcd2,
             lfa1~VATRegistration AS stceg,
             lfa1~TaxNumber3 AS stcd3,
             lfa1~TaxNumber4 AS stcd4
        FROM i_supplier AS lfa1 INNER JOIN i_suppliercompany AS lfb1 ON lfb1~supplier EQ lfa1~supplier
        WHERE lfb1~companycode IN @r_bukrs
        AND lfb1~supplier IN @s_lifnr
        AND lfb1~ReconciliationAccount NE ''
*         AND lfb1~erdat IN @s_erdat
        AND lfa1~creationdate IN @s_erdat
        AND lfa1~PostingIsBlocked IN @r_sperr
        AND lfa1~DeletionIndicator IN @r_loevm
        AND lfa1~IsOneTimeAccount EQ ''
        INTO TABLE @lt_lfa1.

*      DO.
*        FETCH NEXT CURSOR s_cursor_lfa1
*        APPENDING TABLE lt_lfa1
*        PACKAGE SIZE 10000.
*
*        IF sy-subrc NE 0.
*          EXIT.
*        ENDIF.
*      ENDDO.

*      CLOSE CURSOR s_cursor_lfa1.

      LOOP AT lt_lfa1 INTO DATA(s_lfa1).

        CLEAR: ls_taxm, ls_taxn.

        ls_taxm-hesap_tur = 'S'.
        ls_taxm-hesap_no = s_lfa1-lifnr.
        ls_taxm-ktokl = s_lfa1-ktokk.
        ls_taxm-kunnr = s_lfa1-kunnr.
        ls_taxm-lifnr = s_lfa1-lifnr.
        ls_taxm-adrnr = s_lfa1-adrnr.

        CASE ls_adrs-tax_number.
          WHEN 'STCD1'.
            ls_taxm-vkn_tckn = s_lfa1-stcd1.
          WHEN 'STCD2'.
            ls_taxm-vkn_tckn = s_lfa1-stcd2.
          WHEN 'STCD3'.
            ls_taxm-vkn_tckn = s_lfa1-stcd3.
          WHEN 'STCD4'.
            ls_taxm-vkn_tckn = s_lfa1-stcd4.
          WHEN 'STCEG'.
            ls_taxm-vkn_tckn = s_lfa1-stceg.
          WHEN 'FISKN'.
            ls_taxm-vkn_tckn = s_lfa1-fiskn.
        ENDCASE.

        IF ls_adrs-tax_person IS NOT INITIAL AND
           ls_taxm-vkn_tckn IS INITIAL.

          CASE ls_adrs-tax_person.
            WHEN 'STCD1'.
              ls_taxm-vkn_tckn = s_lfa1-stcd1.
            WHEN 'STCD2'.
              ls_taxm-vkn_tckn = s_lfa1-stcd2.
            WHEN 'STCD3'.
              ls_taxm-vkn_tckn = s_lfa1-stcd3.
            WHEN 'STCD4'.
              ls_taxm-vkn_tckn = s_lfa1-stcd4.
            WHEN 'STCEG'.
              ls_taxm-vkn_tckn = s_lfa1-stceg.
            WHEN 'FISKN'.
              ls_taxm-vkn_tckn = s_lfa1-fiskn.
          ENDCASE.

        ENDIF.

        IF ls_taxm-ktokl NOT IN r_ktokk.
* Birleştirme yapılmayacak grup ise
          MOVE-CORRESPONDING ls_taxm TO ls_taxn.

          IF ls_taxn IS NOT INITIAL.

            APPEND ls_taxn TO lt_taxn.

            lv_count_n = lv_count_n + 1.

          ENDIF.

        ELSE.

          IF ls_taxm IS NOT INITIAL.
* Birleştirilmeyecek VKN/TCKN ise
            READ TABLE lt_etax INTO DATA(ls_etax) WITH KEY stcd2 = ls_taxm-vkn_tckn.
            IF sy-subrc NE 0.

              APPEND ls_taxm TO lt_taxm.

              lv_count_m = lv_count_m + 1.

            ELSE.

              MOVE-CORRESPONDING ls_taxm TO ls_taxn.

              IF ls_taxn IS NOT INITIAL.

                APPEND ls_taxn TO lt_taxn.

                lv_count_n = lv_count_n + 1.

              ENDIF.

            ENDIF.
          ENDIF.

        ENDIF.

*        IF lv_count_n EQ 10000.
*          MODIFY /itetr/reco_taxn FROM TABLE lt_taxn.
*          CLEAR : lt_taxn,lv_count_n.
*        ENDIF.
*
*        IF lv_count_m EQ 10000.
*          MODIFY /itetr/reco_taxm FROM TABLE lt_taxm.
*          CLEAR : lt_taxm,lv_count_m.
*        ENDIF.

      ENDLOOP.

*      IF lv_count_n NE 0.
      MODIFY zreco_taxn FROM TABLE @lt_taxn.
      CLEAR : lt_taxn,lv_count_n.
*      ENDIF.

*      IF lv_count_m NE 0.
      MODIFY zreco_taxm FROM TABLE @lt_taxm.
      CLEAR : lt_taxm,lv_count_m.
*      ENDIF.

      COMMIT WORK AND WAIT .

    ENDIF.

*    MESSAGE 'VKN/TCKN bilgileri güncellendi' TYPE 'S'.


  ENDMETHOD.