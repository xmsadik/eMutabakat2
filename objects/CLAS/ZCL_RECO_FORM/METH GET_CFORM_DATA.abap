  METHOD get_cform_data.



    DATA: lv_opening_rc LIKE sy-subrc,
          lv_closing_rc LIKE sy-subrc,
          lv_auth       TYPE abap_boolean.

    DATA: lt_kunnr TYPE TABLE OF zreco_range_kunnr,
          ls_kunnr TYPE zreco_range_kunnr,
          lt_lifnr TYPE TABLE OF zreco_range_lifnr,
          ls_lifnr TYPE Zreco_range_lifnr,
          lt_blart TYPE TABLE OF Zreco_range_blart,
          ls_blart TYPE Zreco_range_blart,
          lt_umskz TYPE TABLE OF Zreco_range_umskz,
          ls_umskz TYPE Zreco_range_umskz,
          lt_belnr TYPE TABLE OF Zreco_range_belnr,
          ls_belnr TYPE Zreco_range_belnr.

    DATA : ls_umskz_m LIKE LINE OF r_umskz_m,
           ls_umskz_s LIKE LINE OF r_umskz_s,
           ls_umskz_r LIKE LINE OF r_umskz.

    DATA: ls_kna1_tax TYPE zreco_kunnr_tax, "hkizilkaya
          ls_lfa1_tax TYPE zreco_lifnr_tax. "hkizilkaya

    CLEAR : gt_out_c, "gt_bsid, gt_bsik,
    gt_curr,
    "gt_tcure,
     gt_odk,
             r_umskz_m, r_umskz_s.

* SADECE UPB MUTABAKATLAR
    SELECT * FROM zreco_cloc
      WHERE bukrs IN @s_bukrs
            INTO TABLE @gt_cloc.

* İKAME EDILEN PARA BIRIMLERI
    SELECT * FROM zreco_ccur
      WHERE bukrs EQ @gs_adrs-bukrs
          INTO TABLE @gt_curr.

* TEDAVÜLDEN KALKAN PARA BIRIMLERI
*    SELECT * FROM tcure             "YiğitcanÖzdemir
*    INTO TABLE @gt_tcure.

    IF p_sgli IS INITIAL.
* MUTABAKAT YAPıLAN ÖDK'LAR
      SELECT * FROM zreco_odk
        INTO TABLE @gt_odk.

      LOOP AT gt_odk INTO gs_odk WHERE hesap_tur EQ 'M'.
        ls_umskz_m-sign = 'I'.
        ls_umskz_m-option = 'EQ'.
        ls_umskz_m-low = gs_odk-umskz.
        COLLECT ls_umskz_m INTO r_umskz_m.
      ENDLOOP.

      LOOP AT gt_odk INTO gs_odk WHERE hesap_tur EQ 'S'.
        ls_umskz_s-sign = 'I'.
        ls_umskz_s-option = 'EQ'.
        ls_umskz_s-low = gs_odk-umskz.
        COLLECT ls_umskz_s INTO r_umskz_s.
      ENDLOOP.

    ELSE.

      SELECT * FROM zreco_odk
        INTO TABLE @gt_odk.
      DELETE gt_odk WHERE hesap_tur NOT IN s_sgli.
      DELETE gt_odk WHERE umskz IN s_og.

      LOOP AT gt_odk INTO gs_odk WHERE hesap_tur EQ 'M'.
        ls_umskz_m-sign = 'I'.
        ls_umskz_m-option = 'EQ'.
        ls_umskz_m-low = gs_odk-umskz.
        COLLECT ls_umskz_m INTO r_umskz_m.
      ENDLOOP.

      LOOP AT gt_odk INTO gs_odk WHERE hesap_tur EQ 'S'.
        ls_umskz_s-sign = 'I'.
        ls_umskz_s-option = 'EQ'.
        ls_umskz_s-low = gs_odk-umskz.
        COLLECT ls_umskz_s INTO r_umskz_s.
      ENDLOOP.
    ENDIF.

    ls_umskz_m-sign = 'I'.
    ls_umskz_m-option = 'EQ'.
    ls_umskz_m-low = ''.
    APPEND ls_umskz_m TO r_umskz_m.

    ls_umskz_s-sign = 'I'.
    ls_umskz_s-option = 'EQ'.
    ls_umskz_s-low = ''.
    APPEND ls_umskz_s TO r_umskz_s.

    IF p_seld IS INITIAL AND p_tran IS INITIAL.
      CLEAR gt_kna1_tax[].
    ENDIF.

    IF p_selk IS INITIAL AND p_tran IS INITIAL.
      CLEAR gt_lfa1_tax[].
    ENDIF.

* BELIRTILEN TARIHE GÖRE HAREKET GÖRMEMIŞ CARILERI SIL
* (BAKIYELI/BAKIYESIZ)
* P_BUDAT1
    IF p_date IS NOT INITIAL AND p_bli IS NOT INITIAL.

      LOOP AT gt_kna1_tax INTO ls_kna1_tax.

        CLEAR: lv_opening_rc, lv_closing_rc.

        check_bsid( EXPORTING iv_kunnr      = ls_kna1_tax-kunnr
                              iv_budat      = p_date
                    CHANGING  cv_closing_rc = lv_opening_rc ).

*        check_bsad( EXPORTING iv_kunnr = ls_kna1_tax-kunnr
*                              iv_budat = p_date
*                              CHANGING cv_closing_rc = lv_closing_rc ).
        IF lv_opening_rc IS NOT INITIAL AND
           lv_closing_rc IS NOT INITIAL.

*          CALL METHOD go_log->bal_log_msg_add      "YiğitcanÖzdemir
*            EXPORTING
*              i_type       = /itetr/reco_if_common_types=>mc_msg_w
*              i_no         = '178'
*              i_id         = /itetr/reco_if_common_types=>mc_msg_class
*              i_v1         = ls_kna1_tax-kunnr
*              i_v2         = TEXT-tr1
*              i_v3         = p_date
*              i_v4         = '1'
*              i_log_handle = gv_log_handle
*            EXCEPTIONS
*              OTHERS       = 1.
          DELETE gt_kna1_tax.
          CONTINUE.
        ENDIF.

      ENDLOOP.

      LOOP AT gt_lfa1_tax INTO ls_lfa1_tax.

        CLEAR: lv_opening_rc, lv_closing_rc.

*        check_bsik( EXPORTING iv_lifnr = ls_lfa1_tax-lifnr
*                              iv_budat = p_date
*            CHANGING cv_closing_rc = lv_opening_rc ).
*
*        check_bsak( EXPORTING iv_lifnr = ls_lfa1_tax-lifnr
*                              iv_budat = p_date
*                    CHANGING cv_closing_rc = lv_closing_rc ).

        IF lv_opening_rc IS NOT INITIAL AND
           lv_closing_rc IS NOT INITIAL.

*          CALL METHOD go_log->bal_log_msg_add                      "YiğitcanÖzdemir
*            EXPORTING
*              i_type       = /itetr/reco_if_common_types=>mc_msg_w
*              i_no         = '178'
*              i_id         = /itetr/reco_if_common_types=>mc_msg_class
*              i_v1         = ls_lfa1_tax-lifnr
*              i_v2         = TEXT-tr2
*              i_v3         = p_date
*              i_v4         = '1'
*              i_log_handle = gv_log_handle
*            EXCEPTIONS
*              OTHERS       = 1.

          DELETE gt_lfa1_tax.
          CONTINUE.
        ENDIF.

      ENDLOOP.

    ENDIF.



    IF p_all IS INITIAL ."AND p_submit IS INITIAL.                         "YiğitcanÖzdemir

      LOOP AT gt_kna1_tax INTO gs_kna1_tax.

        CLEAR gv_send.

*GÖNDERIM KONTROLÜ
        control_send( EXPORTING iv_kunnr    = gs_kna1_tax-kunnr
                                iv_lifnr    = ''
                                iv_vkn_tckn = gs_kna1_tax-vkn_tckn
                      CHANGING  c_send      = gv_send
                                c_mnumber   = gv_mnumber ).

        IF gv_send IS NOT INITIAL. "DAHA ÖNCE GÖNDERILMIŞ

*          CALL METHOD go_log->bal_log_msg_add                                  "YiğitcanÖzdemir
*            EXPORTING
*              i_type       = /itetr/reco_if_common_types=>mc_msg_w
*              i_no         = '174'
*              i_id         = /itetr/reco_if_common_types=>mc_msg_class
*              i_v1         = gs_kna1_tax-kunnr
*              i_v2         = TEXT-tr1
*              i_v3         = p_period
*              i_v4         = gv_mnumber
*              i_log_handle = gv_log_handle
*            EXCEPTIONS
*              OTHERS       = 1.

          DELETE gt_kna1_tax.
        ENDIF.

      ENDLOOP.

      LOOP AT gt_lfa1_tax INTO gs_lfa1_tax.

        CLEAR gv_send.

*GÖNDERIM KONTROLÜ
        control_send( EXPORTING iv_kunnr    = ''
                                iv_lifnr    = gs_lfa1_tax-lifnr
                                iv_vkn_tckn = gs_lfa1_tax-vkn_tckn
                      CHANGING  c_send      = gv_send
                                c_mnumber   = gv_mnumber ).
        IF gv_send IS NOT INITIAL. "DAHA ÖNCE GÖNDERILMIŞ
*          CALL METHOD go_log->bal_log_msg_add                                              ""YiğitcanÖzdemir
*            EXPORTING
*              i_type       = /itetr/reco_if_common_types=>mc_msg_w
*              i_no         = '174'
*              i_id         = /itetr/reco_if_common_types=>mc_msg_class
*              i_v1         = gs_lfa1_tax-lifnr
*              i_v2         = TEXT-tr2
*              i_v3         = p_period
*              i_v4         = gv_mnumber
*              i_log_handle = gv_log_handle
*            EXCEPTIONS
*              OTHERS       = 1.
          DELETE gt_lfa1_tax.
        ENDIF.

      ENDLOOP.

    ENDIF.


    IF gt_kna1_tax[] IS NOT INITIAL.

* MÜŞTERI ILETIŞIM BILGILERI
      SELECT kna1~customer AS kunnr,
             kna1~CustomerAccountGroup AS ktokd,
             kna1~supplier AS lifnr,
             knb1~ReconciliationAccount AS akont,
             kna1~OrganizationBPName1 AS name1,
             kna1~OrganizationBPName2 AS name2,
             kna1~Country AS land1,
             kna1~Language AS spras,
             kna1~AddressID AS adrnr,
             kna1~TelephoneNumber1 AS telf1,
             kna1~TelephoneNumber2 AS telf2,
             kna1~FaxNumber AS telfx,
             kna1~TaxNumber1 AS stcd1,
             kna1~TaxNumber2 AS stcd2,
             kna1~TaxNumber3 AS stcd3,
             kna1~TaxNumber4 AS stcd4,
             kna1~FiscalAddress AS fiskn,
             kna1~VATRegistration AS stceg,
*             knb1~RecordCreatedDate AS erdat,              "YiğitcanÖzdemir
             knb1~BPPeriodicAccountStatement
             FROM i_customer AS kna1 INNER JOIN i_customercompany AS knb1 ON kna1~customer EQ knb1~customer
        FOR ALL ENTRIES IN @gt_kna1_tax
        WHERE kna1~customer EQ @gt_kna1_tax-kunnr
        AND knb1~companycode IN @s_bukrs
        AND kna1~PostingIsBlocked IN @r_sperr
        AND kna1~DeletionIndicator IN @r_loevm
        AND knb1~PhysicalInventoryBlockInd IN @r_sperr
        AND knb1~DeletionIndicator IN @r_loevm
        AND knb1~ReconciliationAccount NE ''
             APPENDING CORRESPONDING FIELDS OF TABLE @gt_account_info.


      gs_account_info-spras = sy-langu.

      MODIFY gt_account_info FROM gs_account_info TRANSPORTING spras WHERE spras EQ ''.

      DATA lo_zreco_common  TYPE REF TO zreco_common.
      CREATE OBJECT lo_zreco_common.

      lo_zreco_common->zreco_excluded_values(
        EXPORTING
          i_bukrs  = gs_adrs-bukrs
        IMPORTING
          it_kunnr = lt_kunnr
          it_blart = lt_blart
          it_umskz = lt_umskz
          it_belnr = lt_belnr
      ).

      LOOP AT lt_kunnr INTO ls_kunnr WHERE low IS NOT INITIAL.
        DELETE gt_kna1_tax WHERE kunnr EQ ls_kunnr-low.
      ENDLOOP.

      LOOP AT lt_umskz INTO ls_umskz WHERE low IS NOT INITIAL.
        MOVE-CORRESPONDING ls_umskz TO ls_umskz_m.
        COLLECT ls_umskz_m INTO r_umskz_m.
      ENDLOOP.

      CASE gs_adrs-c_date_selection.
        WHEN 'BT'.
** MÜŞTERI AÇıK KALEMLER (BELGE TARIHINE GÖRE)
*          SELECT kunnr belnr gjahr buzei umskz shkzg gsber dmbtr wrbtr
*                 waers xblnr blart saknr hkont bldat budat zfbdt zterm
*                 zbd1t zbd2t zbd3t rebzg sgtxt
*            FROM bsid APPENDING CORRESPONDING FIELDS OF TABLE gt_bsid
*            FOR ALL ENTRIES IN gt_kna1_tax
*            WHERE bldat LE gv_last_date
*            AND   bukrs IN s_bukrs
*            AND   gsber IN s_gsber "hkizilkaya
*            AND   belnr IN lt_belnr
*            AND   blart IN lt_blart
*            AND   kunnr EQ gt_kna1_tax-kunnr
*            AND   umskz IN r_umskz_m
*            AND   waers IN s_waers.


          SELECT
              Customer                AS kunnr,
              AccountingDocument      AS belnr,
              FiscalYear              AS gjahr,
              AccountingDocumentItem  AS buzei,
              SpecialGLCode           AS umskz,
              DebitCreditCode        AS shkzg,
              BusinessArea           AS gsber,
              AbsoluteAmountInCoCodeCrcy  AS dmbtr,
              AbsoluteAmountInTransacCrcy AS wrbtr,
              TransactionCurrency     AS waers,
              OriginalReferenceDocument AS xblnr,
              AccountingDocumentType  AS blart,
              AccountingDocument                 AS saknr,
              AccountingDocument                 AS hkont,
              DocumentDate           AS bldat,
              PostingDate            AS budat,
              DueCalculationBaseDate AS zfbdt,
              PaymentTerms           AS zterm,
              CashDiscount2Days                 AS zbd2t,
              NetPaymentDays                 AS zbd3t,
              CashDiscount1Days      AS zbd1t,
              ClearingJournalEntry   AS rebzg,
              DocumentItemText       AS sgtxt
              " Saknr ve Hkont CDS'te tanımlı değil
              " Saknr                 AS saknr,
              " Hkont                 AS hkont,
              " ZBD2T ve ZBD3T CDS'te tanımlı değil
              " ZBD2T                 AS zbd2t,
              " ZBD3T                 AS zbd3t
          FROM zetr_reco_ddl_bsid
          FOR ALL ENTRIES IN @gt_kna1_tax
          WHERE DocumentDate    LE @gv_last_date
            AND CompanyCode     IN @s_bukrs
            AND BusinessArea    IN @s_gsber  "hkizilkaya
            AND AccountingDocument IN @lt_belnr
            AND AccountingDocumentType IN @lt_blart
            AND Customer        EQ @gt_kna1_tax-kunnr
            AND SpecialGLCode   IN @r_umskz_m
            AND TransactionCurrency IN @s_waers
          APPENDING CORRESPONDING FIELDS OF TABLE @gt_bsid.




** MÜŞTERI DENKLEŞTIRILMIŞ KALEMLER (BELGE TARIHINE GÖRE)
*          SELECT kunnr belnr gjahr buzei umskz shkzg gsber dmbtr wrbtr
*                 waers xblnr blart saknr hkont bldat budat zfbdt zterm
*                 zbd1t zbd2t zbd3t rebzg sgtxt
*            FROM bsad APPENDING CORRESPONDING FIELDS OF TABLE gt_bsid
*            FOR ALL ENTRIES IN gt_kna1_tax
*            WHERE bldat LE gv_last_date
*            AND   augdt GT gv_last_date
*            AND   bukrs IN s_bukrs
*            AND   gsber IN s_gsber "hkizilkaya
*            AND   belnr IN lt_belnr
*            AND   blart IN lt_blart
*            AND   kunnr EQ gt_kna1_tax-kunnr
*            AND   umskz IN r_umskz_m
*            AND   waers IN s_waers.

          SELECT
              Customer                AS kunnr,
              AccountingDocument      AS belnr,
              FiscalYear              AS gjahr,
              AccountingDocumentItem  AS buzei,
              SpecialGLCode           AS umskz,
              DebitCreditCode        AS shkzg,
              BusinessArea           AS gsber,
              AbsoluteAmountInCoCodeCrcy  AS dmbtr,
              AbsoluteAmountInTransacCrcy AS wrbtr,
              TransactionCurrency     AS waers,
              OriginalReferenceDocument AS xblnr,
              AccountingDocumentType  AS blart,
              AccountingDocument                 AS saknr,
              AccountingDocument                 AS hkont,
              DocumentDate           AS bldat,
              PostingDate            AS budat,
              DueCalculationBaseDate AS zfbdt,
              PaymentTerms           AS zterm,
              CashDiscount2Days                 AS zbd2t,
              NetPaymentDays                 AS zbd3t,
              CashDiscount1Days      AS zbd1t,
              ClearingJournalEntry   AS rebzg,
              DocumentItemText       AS sgtxt
              " Saknr ve Hkont CDS'te tanımlı değil
              " Saknr                 AS saknr,
              " Hkont                 AS hkont,
              " ZBD2T ve ZBD3T CDS'te tanımlı değil
              " ZBD2T                 AS zbd2t,
              " ZBD3T                 AS zbd3t
          FROM I_OperationalAcctgDocItem
          FOR ALL ENTRIES IN @gt_kna1_tax
          WHERE DocumentDate    LE @gv_last_date
           AND ClearingDate     GT @gv_last_date  " augdt'nin CDS karşılığı
            AND CompanyCode     IN @s_bukrs
            AND BusinessArea    IN @s_gsber  "hkizilkaya
            AND AccountingDocument IN @lt_belnr
            AND AccountingDocumentType IN @lt_blart
            AND Customer        EQ @gt_kna1_tax-kunnr
            AND SpecialGLCode   IN @r_umskz_m
            AND TransactionCurrency IN @s_waers
            AND FinancialAccountType = 'D'
          APPENDING CORRESPONDING FIELDS OF TABLE @gt_bsid.


        WHEN OTHERS.
** MÜŞTERI AÇıK KALEMLER
*          "BREAK mcelik.

*          SELECT kunnr belnr gjahr buzei umskz shkzg gsber dmbtr wrbtr
*                 waers xblnr blart saknr hkont bldat budat zfbdt zterm
*                 zbd1t zbd2t zbd3t rebzg sgtxt
*            FROM bsid APPENDING CORRESPONDING FIELDS OF TABLE gt_bsid
*            FOR ALL ENTRIES IN gt_kna1_tax
*            WHERE budat LE gv_last_date
*            AND   bukrs IN s_bukrs
*            AND   gsber IN s_gsber "hkizilkaya
*            AND   belnr IN lt_belnr
*            AND   blart IN lt_blart
*            AND   kunnr EQ gt_kna1_tax-kunnr
*            AND   umskz IN r_umskz_m
*            AND   waers IN s_waers.

          SELECT
                        Customer                AS kunnr,
                        AccountingDocument      AS belnr,
                        FiscalYear              AS gjahr,
                        AccountingDocumentItem  AS buzei,
                        SpecialGLCode           AS umskz,
                        DebitCreditCode        AS shkzg,
                        BusinessArea           AS gsber,
                        AbsoluteAmountInCoCodeCrcy  AS dmbtr,
                        AbsoluteAmountInTransacCrcy AS wrbtr,
                        TransactionCurrency     AS waers,
                        OriginalReferenceDocument AS xblnr,
                        AccountingDocumentType  AS blart,
                        AccountingDocument                 AS saknr,
                        AccountingDocument                 AS hkont,
                        DocumentDate           AS bldat,
                        PostingDate            AS budat,
                        DueCalculationBaseDate AS zfbdt,
                        PaymentTerms           AS zterm,
                        CashDiscount2Days                 AS zbd2t,
                        NetPaymentDays                 AS zbd3t,
                        CashDiscount1Days      AS zbd1t,
                        ClearingJournalEntry   AS rebzg,
                        DocumentItemText       AS sgtxt
                        " Saknr ve Hkont CDS'te tanımlı değil
                        " Saknr                 AS saknr,
                        " Hkont                 AS hkont,
                        " ZBD2T ve ZBD3T CDS'te tanımlı değil
                        " ZBD2T                 AS zbd2t,
                        " ZBD3T                 AS zbd3t
          FROM zetr_reco_ddl_bsid
          FOR ALL ENTRIES IN @gt_kna1_tax
          WHERE PostingDate      LE @gv_last_date
            AND CompanyCode      IN @s_bukrs
            AND BusinessArea     IN @s_gsber  "hkizilkaya
            AND AccountingDocument IN @lt_belnr
            AND AccountingDocumentType IN @lt_blart
            AND Customer         EQ @gt_kna1_tax-kunnr
            AND SpecialGLCode    IN @r_umskz_m
            AND TransactionCurrency IN @s_waers
          APPENDING CORRESPONDING FIELDS OF TABLE @gt_bsid.

** MÜŞTERI DENKLEŞTIRILMIŞ KALEMLER

*          SELECT kunnr belnr gjahr buzei umskz shkzg gsber dmbtr wrbtr
*                 waers xblnr blart saknr hkont bldat budat zfbdt zterm
*                 zbd1t zbd2t zbd3t rebzg sgtxt
*            FROM bsad APPENDING CORRESPONDING FIELDS OF TABLE gt_bsid
*            FOR ALL ENTRIES IN gt_kna1_tax
*            WHERE budat LE gv_last_date
*            AND   augdt GT gv_last_date
*            AND   bukrs IN s_bukrs
*            AND   gsber IN s_gsber "hkizilkaya
*            AND   belnr IN lt_belnr
*            AND   blart IN lt_blart
*            AND   kunnr EQ gt_kna1_tax-kunnr
*            AND   umskz IN r_umskz_m
*            AND   waers IN s_waers.

          SELECT
              Customer                AS kunnr,
              AccountingDocument      AS belnr,
              FiscalYear              AS gjahr,
              AccountingDocumentItem  AS buzei,
              SpecialGLCode           AS umskz,
              DebitCreditCode        AS shkzg,
              BusinessArea           AS gsber,
              AbsoluteAmountInCoCodeCrcy  AS dmbtr,
              AbsoluteAmountInTransacCrcy AS wrbtr,
              TransactionCurrency     AS waers,
              OriginalReferenceDocument AS xblnr,
              AccountingDocumentType  AS blart,
              AccountingDocument                 AS saknr,
              AccountingDocument                 AS hkont,
              DocumentDate           AS bldat,
              PostingDate            AS budat,
              DueCalculationBaseDate AS zfbdt,
              PaymentTerms           AS zterm,
              CashDiscount2Days                 AS zbd2t,
              NetPaymentDays                 AS zbd3t,
              CashDiscount1Days      AS zbd1t,
              ClearingJournalEntry   AS rebzg,
              DocumentItemText       AS sgtxt
              " Saknr ve Hkont CDS'te tanımlı değil
              " Saknr                 AS saknr,
              " Hkont                 AS hkont,
              " ZBD2T ve ZBD3T CDS'te tanımlı değil
              " ZBD2T                 AS zbd2t,
              " ZBD3T                 AS zbd3t
          FROM I_OperationalAcctgDocItem
          FOR ALL ENTRIES IN @gt_kna1_tax
          WHERE PostingDate    LE @gv_last_date
           AND ClearingDate     GT @gv_last_date  " augdt'nin CDS karşılığı
            AND CompanyCode     IN @s_bukrs
            AND BusinessArea    IN @s_gsber  "hkizilkaya
            AND AccountingDocument IN @lt_belnr
            AND AccountingDocumentType IN @lt_blart
            AND Customer        EQ @gt_kna1_tax-kunnr
            AND SpecialGLCode   IN @r_umskz_m
            AND TransactionCurrency IN @s_waers
            AND FinancialAccountType = 'D'
          APPENDING CORRESPONDING FIELDS OF TABLE @gt_bsid.

*
      ENDCASE.

*      IF p_verzn IS NOT INITIAL AND gt_bsid[] IS NOT INITIAL. "YiğitcanÖzdemir
* İHTAR IÇIN DIĞER ALANLAR
*        SELECT belnr ,gjahr ,bktxt ,awkey ,xref1_hd ,xref2_hd ,xblnr_alt
*          FROM bkpf
*          FOR ALL ENTRIES IN @gt_bsid
*          WHERE bukrs IN @s_bukrs
*          AND belnr EQ @gt_bsid-belnr
*          AND gjahr EQ @gt_bsid-gjahr
*          INTO TABLE @gt_cform_bkpf.
*      ENDIF.

    ENDIF.

    IF gt_lfa1_tax[] IS NOT INITIAL.
* SATıCı ILETIŞIM BILGILERI
      SELECT lfa1~customer AS kunnr,
             lfa1~supplier AS lifnr,
             lfa1~SupplierAccountGroup AS ktokk,
             lfb1~ReconciliationAccount,
             lfa1~OrganizationBPName1 AS name1,
             lfa1~OrganizationBPName2 AS name2,
             lfa1~Country AS land1,
             lfa1~SupplierLanguage AS spras,
             lfa1~AddressID AS adrnr,
             lfa1~PhoneNumber1 AS telf1,
             lfa1~PhoneNumber2 AS telf2,
             lfa1~FaxNumber AS telfx,
             lfa1~TaxNumber1 AS stcd1,
             lfa1~TaxNumber2 AS stcd2,
             lfa1~TaxNumber3 AS stcd3,
             lfa1~TaxNumber4 AS stcd4,
             lfa1~FiscalAddress AS fiskn,
             lfa1~VATRegistration AS stceg
*             lfb1~erdat,                       "YiğitcanÖzdemir
*             lfb1~xausz                        "YiğitcanÖzdemir
             FROM i_supplier AS lfa1 INNER JOIN i_suppliercompany AS lfb1 ON lfa1~supplier EQ lfb1~supplier
        FOR ALL ENTRIES IN @gt_lfa1_tax
        WHERE lfa1~supplier EQ @gt_lfa1_tax-lifnr
        AND lfb1~companycode IN @s_bukrs
        AND lfa1~postingisblocked IN @r_sperr
        AND lfa1~DeletionIndicator IN @r_loevm
        AND lfb1~SupplierIsBlockedForPosting IN @r_sperr
        AND lfb1~DeletionIndicator IN @r_loevm
        AND lfb1~ReconciliationAccount NE ''
        APPENDING CORRESPONDING FIELDS OF TABLE @gt_account_info.

      gs_account_info-spras = sy-langu.

      MODIFY gt_account_info FROM gs_account_info TRANSPORTING spras WHERE spras EQ ''.

      LOOP AT lt_lifnr INTO ls_lifnr WHERE low IS NOT INITIAL.
        DELETE gt_lfa1_tax WHERE kunnr EQ ls_lifnr-low.
      ENDLOOP.

      LOOP AT lt_umskz INTO ls_umskz WHERE low IS NOT INITIAL.
        MOVE-CORRESPONDING ls_umskz TO ls_umskz_s.
        COLLECT ls_umskz_s INTO r_umskz_s.
      ENDLOOP.


*      CASE gs_adrs-c_date_selection.   "YiğitcanÖzdemir
*        WHEN 'BT'.
** SATıCı AÇıK KALEMLER (BELGE TARIHINE GÖRE)
*          SELECT lifnr belnr gjahr buzei umskz shkzg gsber dmbtr wrbtr
*                 waers xblnr blart saknr hkont bldat budat zfbdt zterm
*                 zbd1t zbd2t zbd3t rebzg sgtxt
*            FROM bsik APPENDING CORRESPONDING FIELDS OF TABLE gt_bsik
*            FOR ALL ENTRIES IN gt_lfa1_tax
*            WHERE bldat LE gv_last_date
*            AND   bukrs IN s_bukrs
*            AND   gsber IN s_gsber "hkizilkaya
*            AND   belnr IN lt_belnr
*            AND   blart IN lt_blart
*            AND   lifnr EQ gt_lfa1_tax-lifnr
*            AND   umskz IN r_umskz_s
*            AND   waers IN s_waers.
** SATıCı DENKLEŞTIRILMIŞ KALEMLER (BELGE TARIHINE GÖRE)
*          SELECT lifnr belnr gjahr buzei umskz shkzg gsber dmbtr wrbtr
*                 waers xblnr blart saknr hkont bldat budat zfbdt zterm
*                 zbd1t zbd2t zbd3t rebzg sgtxt
*            FROM bsak APPENDING CORRESPONDING FIELDS OF TABLE gt_bsik
*            FOR ALL ENTRIES IN gt_lfa1_tax
*            WHERE bldat LE gv_last_date
*            AND   augdt GT gv_last_date
*            AND   bukrs IN s_bukrs
*            AND   gsber IN s_gsber "hkizilkaya
*            AND   belnr IN lt_belnr
*            AND   blart IN lt_blart
*            AND   lifnr EQ gt_lfa1_tax-lifnr
*            AND   umskz IN r_umskz_s
*            AND   waers IN s_waers.
*        WHEN OTHERS.
** SATıCı AÇıK KALEMLER
*          SELECT lifnr belnr gjahr buzei umskz shkzg gsber dmbtr wrbtr
*                 waers xblnr blart saknr hkont bldat budat zfbdt zterm
*                 zbd1t zbd2t zbd3t rebzg sgtxt
*            FROM bsik APPENDING CORRESPONDING FIELDS OF TABLE gt_bsik
*            FOR ALL ENTRIES IN gt_lfa1_tax
*            WHERE budat LE gv_last_date
*            AND   bukrs IN s_bukrs
*            AND   gsber IN s_gsber "hkizilkaya
*            AND   belnr IN lt_belnr
*            AND   blart IN lt_blart
*            AND   lifnr EQ gt_lfa1_tax-lifnr
*            AND   umskz IN r_umskz_s
*            AND   waers IN s_waers.
** SATıCı DENKLEŞTIRILMIŞ KALEMLER
*          SELECT lifnr belnr gjahr buzei umskz shkzg gsber dmbtr wrbtr
*                 waers xblnr blart saknr hkont bldat budat zfbdt zterm
*                 zbd1t zbd2t zbd3t rebzg sgtxt
*            FROM bsak APPENDING CORRESPONDING FIELDS OF TABLE gt_bsik
*            FOR ALL ENTRIES IN gt_lfa1_tax
*            WHERE budat LE gv_last_date
*            AND   augdt GT gv_last_date
*            AND   gsber IN s_gsber "hkizilkaya
*            AND   bukrs IN s_bukrs
*            AND   belnr IN lt_belnr
*            AND   blart IN lt_blart
*            AND   lifnr EQ gt_lfa1_tax-lifnr
*            AND   umskz IN r_umskz_s
*            AND   waers IN s_waers.
*      ENDCASE.
    ENDIF.

    modify_account_group( ).
    modify_cform_data( ).

    SORT gt_out_c BY hesap_tur hesap_no.



  ENDMETHOD.