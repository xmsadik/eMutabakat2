  METHOD modify_cform_data.

    " <-- hkizilkaya
* Müşteri kalem yapısı
*    TYPES : BEGIN OF ty_bsid,
*              kunnr TYPE bsid-kunnr,
*              belnr TYPE bsid-belnr,
*              gjahr TYPE bsid-gjahr,
*              buzei TYPE bsid-buzei,
*              umskz TYPE bsid-umskz,
*              shkzg TYPE bsid-shkzg,
*              gsber TYPE bsid-gsber,
*              dmbtr TYPE bsid-dmbtr,
*              wrbtr TYPE bsid-wrbtr,
*              waers TYPE bsid-waers,
*              xblnr TYPE bsid-xblnr,
*              blart TYPE bsid-blart,
*              saknr TYPE bsid-saknr,
*              hkont TYPE bsid-hkont,
*              bldat TYPE bsid-bldat,
*              budat TYPE bsid-budat,
*              zfbdt TYPE bsid-zfbdt,
*              zterm TYPE bsid-zterm,
*              zbd1t TYPE bsid-zbd1t,
*              zbd2t TYPE bsid-zbd2t,
*              zbd3t TYPE bsid-zbd3t,
*              rebzg TYPE bsid-rebzg,
*              sgtxt TYPE bsid-sgtxt,
*            END OF ty_bsid.

* Satıcı kalem yapısı
*    TYPES : BEGIN OF ty_bsik,
*              lifnr TYPE bsik-lifnr,
*              belnr TYPE bsik-belnr,
*              gjahr TYPE bsik-gjahr,
*              buzei TYPE bsid-buzei,
*              umskz TYPE bsik-umskz,
*              shkzg TYPE bsik-shkzg,
*              gsber TYPE bsik-gsber,
*              dmbtr TYPE bsik-dmbtr,
*              wrbtr TYPE bsik-wrbtr,
*              waers TYPE bsik-waers,
*              xblnr TYPE bsik-xblnr,
*              blart TYPE bsik-blart,
*              saknr TYPE bsik-saknr,
*              hkont TYPE bsik-hkont,
*              bldat TYPE bsik-bldat,
*              budat TYPE bsik-budat,
*              zfbdt TYPE bsik-zfbdt,
*              zterm TYPE bsik-zterm,
*              zbd1t TYPE bsik-zbd1t,
*              zbd2t TYPE bsik-zbd2t,
*              zbd3t TYPE bsik-zbd3t,
*              rebzg TYPE bsik-rebzg,
*              sgtxt TYPE bsik-sgtxt,
*            END OF ty_bsik.

    DATA: ls_bsid TYPE ty_bsid,
          ls_bsik TYPE ty_bsik.

    " hkizilkaya -->

    DATA: lv_text(10) TYPE c,
          lv_wrbtr    TYPE bapicurr_d,
          ls_out_c    LIKE LINE OF gt_out_c,
          lv_tabix    TYPE sy-tabix.

    DATA: lt_kna1_tax TYPE SORTED TABLE OF zreco_kunnr_tax WITH NON-UNIQUE KEY vkn_tckn kunnr lifnr,
          ls_kna1_tax TYPE zreco_kunnr_tax. "hkizilkaya

    DATA: lt_lfa1_tax TYPE SORTED TABLE OF zreco_lifnr_tax WITH NON-UNIQUE KEY vkn_tckn lifnr kunnr,
          ls_lfa1_tax TYPE zreco_lifnr_tax. "hkizilkaya

    DATA: lv_opening_rc LIKE sy-subrc,
          lv_closing_rc LIKE sy-subrc.

    " <-- hkizilkaya
    DATA ls_ifld TYPE zreco_ifld.
    DATA ls_balance TYPE zreco_s_balance.
    DATA ls_ftyp TYPE zreco_ftyp.

    DATA: last_day_of_month TYPE d,
          p_rdate           TYPE d,
          lv_last_date      TYPE c LENGTH 8,
          lv_weekday        TYPE p,
          lv_ukurs          TYPE ukurs_curr,
          lv_conv_date(8)   TYPE c.
    " hkizilkaya -->


    FIELD-SYMBOLS: <fs_cform_temp> TYPE zreco_cform_temp,
                   <fs_out_c>      TYPE zreco_cform.

    lt_kna1_tax[] = gt_kna1_tax[].
    lt_lfa1_tax[] = gt_lfa1_tax[].

    DELETE ADJACENT DUPLICATES FROM lt_kna1_tax COMPARING kunnr.
    DELETE ADJACENT DUPLICATES FROM lt_lfa1_tax COMPARING lifnr.

    CLEAR: gt_bsid_temp.

    LOOP AT lt_kna1_tax INTO ls_kna1_tax.

*      CLEAR: gt_account_info, gv_spras.
      CLEAR: gs_account_info, gv_spras.

      READ TABLE gt_account_info INTO gs_account_info WITH KEY kunnr = ls_kna1_tax-kunnr.

      "gv_spras = gs_account_info-spras.
      " <--- hkizilkaya mutabakat dili ülkeye göre ayarlanıyor.
      IF gs_account_info-land1 IS NOT INITIAL.
        IF gs_account_info-land1 EQ 'TR'.
          gv_spras = 'T'.
        ELSEIF gs_account_info-land1 EQ 'BG'..
          gv_spras = 'W'.
        ELSE.
          gv_spras = 'E'.
        ENDIF.
      ENDIF.
      " hkizilkaya --->

      DELETE FROM zreco_tbsd
      WHERE bukrs EQ @gs_adrs-bukrs
      AND p_monat EQ @p_period
      AND p_gjahr EQ @p_gjahr
      AND hesap_tur EQ 'M'
      AND hesap_no EQ @ls_kna1_tax-hesap_no.

      COMMIT WORK AND WAIT.




      LOOP AT gt_bsid INTO ls_bsid WHERE kunnr EQ ls_kna1_tax-kunnr.

        CLEAR: gs_cform_temp, gs_bsid_temp, gs_cform_bkpf, gs_curr." gs_tcure. "YiğitcanÖzdemir
        MOVE-CORRESPONDING ls_bsid TO gs_bsid.

        gs_cform_temp-gsber = gs_bsid-gsber.

        MOVE-CORRESPONDING ls_kna1_tax TO gs_cform_temp.

        gs_cform_temp-hesap_tur = 'M'.
        gs_cform_temp-hesap_no = ls_bsid-kunnr.
        gs_cform_temp-akont = ls_bsid-hkont.


        IF ls_bsid-umskz IS NOT INITIAL.

          CLEAR gs_odk.

          READ TABLE gt_odk INTO gs_odk
          WITH KEY hesap_tur = 'M'
                       umskz = gs_bsid-umskz
                       spras = gv_spras.
          CHECK sy-subrc EQ 0.
          IF gs_odk-xsum IS NOT INITIAL AND gs_odk-xakont IS INITIAL.
            gs_cform_temp-akont = gs_bsid-saknr.
          ENDIF.
          gs_cform_temp-ltext = gs_odk-ltext.
          gs_cform_temp-xsort = gs_odk-xsort.
          gs_cform_temp-xsum  = gs_odk-xsum.
          gs_cform_temp-umskz = 'X'. "hkizilkaya

        ELSE.
          gs_cform_temp-umskz = ' '. "hkizilkaya

          READ TABLE gt_htxt INTO gs_htxt WITH KEY spras = gv_spras.

          IF sy-subrc EQ 0.
            gs_cform_temp-ltext = gs_htxt-customer_text.
            gs_cform_temp-xsort = 0.

          ENDIF.
          gs_cform_temp-xsum  = 'X'.
        ENDIF.

* SADECE UPB MUTABAKAT YAPıLAN CARILER
        READ TABLE gt_cloc INTO gs_cloc
        WITH KEY hesap_tur = 'M'
                 hesap_no = gs_bsid-kunnr.

        IF sy-subrc EQ 0.
*          gs_bsid-waers = t001-waers. "YiğitcanÖzdemir
          gs_bsid-wrbtr = gs_bsid-dmbtr.
        ENDIF.

* İKAME EDILEN PARA BIRIMLERI
        READ TABLE gt_curr INTO gs_curr
        WITH KEY waers_from = gs_bsid-waers.

        IF sy-subrc EQ 0.
          gs_bsid-waers = gs_curr-waers_to.
*          IF gs_curr-waers_to EQ t001-waers. "YiğitcanÖzdemir
          gs_bsid-wrbtr = gs_bsid-dmbtr.
*          ENDIF.
        ENDIF.

* TEDAVÜLDEN KALKAN PARA BIRIMLERI
*        READ TABLE gt_tcure INTO gs_tcure "YiğitcanÖzdemir
*        WITH KEY curc_old = gs_bsid-waers.

*        IF sy-subrc EQ 0.
*
*          gs_bsid-wrbtr = gs_bsid-wrbtr / 10000.
**          gs_bsid-waers = gs_tcure-curc_new.
*
*        ENDIF. "YiğitcanÖzdemir

* DEĞERLENMIŞ TUTAR
        IF p_exch IS NOT INITIAL.

          IF gs_adrs-kurst IS NOT INITIAL ."AND "YiğitcanÖzdemir
*             gs_bsid-waers NE t001-waers.

            CLEAR gs_exch_rate.

            READ TABLE gt_exch_rate INTO gs_exch_rate
            WITH KEY from_curr = gs_bsid-waers.

            IF sy-subrc NE 0.

              "<-- hkizilkaya kur bilgisi farkli tablodan alındığı için kaldırıldı.
*              CALL FUNCTION 'BAPI_EXCHANGERATE_GETDETAIL'
*                EXPORTING
*                  rate_type  = gs_adrs-kurst
*                  from_curr  = gs_bsid-waers
*                  to_currncy = t001-waers
*                  date       = gv_last_date
*                IMPORTING
*                  exch_rate  = gs_exch_rate.
              " hkizilkaya -->

              "<-- hkizilkaya 'TRCURR' tablosundan ay sonu kur bilgisini al
              CONCATENATE p_gjahr p_period '01' INTO p_rdate. "mali yıl ve dönem bilgisi

*              CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'                                         "YiğitcanÖzdemir
*                EXPORTING
*                  day_in            = p_rdate
*                IMPORTING
*                  last_day_of_month = last_day_of_month. " gelen mali ayın son günü

              DATA lo_zreco_common  TYPE REF TO zreco_common.
              CREATE OBJECT lo_zreco_common.


              lo_zreco_common->rp_last_day_of_months(
                EXPORTING
                  day_in            = p_rdate
                IMPORTING
                  last_day_of_month = last_day_of_month
              ).
*
*              CALL FUNCTION 'DAY_IN_WEEK'                           "YiğitcanÖzdemir
*                EXPORTING
*                  datum = last_day_of_month
*                IMPORTING
*                  wotnr = lv_weekday. "Ayın son günü haftanın hangi gününe denk geliyor
*              " 1 = Pazartesi, 2 = Salı .... 6 = Cumartesi, 7 = Pazar.

              IF ls_bsid-waers EQ 'TRY'. "Dönüştürülecek para birimi TL ise kur 1TL

                gs_exch_rate-rate_type = gs_adrs-kurst.
                gs_exch_rate-from_curr = 'TRY'.
                gs_exch_rate-to_currncy = 'TRY'.
                gs_exch_rate-exch_rate = 1.

              ELSE.
                CONCATENATE last_day_of_month+6(2) last_day_of_month+4(2) last_day_of_month+0(4) INTO last_day_of_month. "tarih formatını gün/ay/yıl olarak değiştirilir.

*                CALL FUNCTION 'CONVERSION_EXIT_INVDT_INPUT'                                  "YiğitcanÖzdemir
*                  EXPORTING
*                    input  = last_day_of_month
*                  IMPORTING
*                    output = lv_conv_date. "ayın son günü tcurr-gdatu tablosu için convert edilir

                IF  lv_weekday EQ 6. "Ayın son günü umartesi günü ise 1 gün geriye gidip cuma gününün kur bilgisi alınır.
                  lv_conv_date = lv_conv_date + 1.

*                  SELECT SINGLE ukurs "YiğitcanÖzdemir
*                    FROM tcurr
*                    WHERE kurst EQ @gs_adrs-kurst
*                    AND fcurr EQ @ls_bsid-waers
*                    AND tcurr EQ 'TRY'
*                    AND gdatu EQ @lv_conv_date
*                      INTO @lv_ukurs.

                  gs_exch_rate-rate_type = gs_adrs-kurst.
                  gs_exch_rate-from_curr = ls_bsid-waers.
                  gs_exch_rate-to_currncy = 'TRY'.
                  gs_exch_rate-exch_rate = lv_ukurs.

                ELSEIF lv_weekday EQ 7. "Ayın son günü pazar ise 2 gün geriye gidip cuma gününün kur bilgisi alınır.
                  lv_conv_date = lv_conv_date + 2.

*                  SELECT SINGLE ukurs "YiğitcanÖzdemir
*                   FROM tcurr
*                   INTO lv_ukurs
*                   WHERE kurst EQ gs_adrs-kurst
*                   AND fcurr EQ ls_bsid-waers
*                   AND tcurr EQ 'TRY'
*                   AND gdatu EQ lv_conv_date.

                  gs_exch_rate-rate_type = gs_adrs-kurst.
                  gs_exch_rate-from_curr = ls_bsid-waers.
                  gs_exch_rate-to_currncy = 'TRY'.
                  gs_exch_rate-exch_rate = lv_ukurs.

                ELSE. "Ayın son günü hafta içine denk gelirse aynı tarih direk alınır.
*                  SELECT SINGLE ukurs "YiğitcanÖzdemir
*                  FROM tcurr
*                  INTO lv_ukurs
*                  WHERE kurst EQ gs_adrs-kurst
*                  AND fcurr EQ ls_bsid-waers
*                  AND tcurr EQ 'TRY'
*                  AND gdatu EQ lv_conv_date.

                  gs_exch_rate-rate_type = gs_adrs-kurst.
                  gs_exch_rate-from_curr = ls_bsid-waers.
                  gs_exch_rate-to_currncy = 'TRY'.
                  gs_exch_rate-exch_rate = lv_ukurs.

                ENDIF.
              ENDIF.
              APPEND gs_exch_rate TO gt_exch_rate.
              CLEAR: last_day_of_month, lv_weekday, lv_ukurs, lv_conv_date.
              " hkizilkaya -->
            ENDIF.
            CLEAR gs_exch_rate.

            READ TABLE gt_exch_rate INTO gs_exch_rate
            WITH KEY from_curr = gs_bsid-waers.

            IF sy-subrc EQ 0.
              IF gs_exch_rate-from_factor EQ 0.
                gs_exch_rate-from_factor = 1.
              ENDIF.

              IF gs_exch_rate-from_factor NE 1.
*                CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL' "YiğitcanÖzdemir
*                  EXPORTING
*                    currency        = gs_bsid-waers
*                    amount_internal = gs_bsid-wrbtr
*                  IMPORTING
*                    amount_external = lv_wrbtr.
              ELSE.
                lv_wrbtr = gs_bsid-wrbtr.
              ENDIF.

              gs_bsid-dmbtr = lv_wrbtr *
                                   abs( gs_exch_rate-exch_rate )
                                   / gs_exch_rate-from_factor.
            ENDIF.

          ENDIF.

        ENDIF.

        MOVE-CORRESPONDING gs_bsid TO gs_bsid_temp.

        CASE gs_bsid-shkzg.
          WHEN 'H'.
            gs_bsid_temp-dmbtr = gs_cform_temp-dmbtr = 0 - gs_bsid-dmbtr.
            gs_bsid_temp-wrbtr = gs_cform_temp-wrbtr = 0 - gs_bsid-wrbtr.
          WHEN OTHERS.
            gs_cform_temp-dmbtr = gs_bsid-dmbtr.
            gs_cform_temp-wrbtr = gs_bsid-wrbtr.
        ENDCASE.

        gs_cform_temp-waers = gs_bsid-waers.

        IF gs_bsid-zfbdt IS INITIAL.
          gs_bsid-zfbdt = gs_bsid-budat.
        ENDIF.

*        CALL FUNCTION 'NET_DUE_DATE_GET' "YiğitcanÖzdemir
*          EXPORTING
*            i_zfbdt = gs_bsid-zfbdt
*            i_zbd1t = gs_bsid-zbd1t
*            i_zbd2t = gs_bsid-zbd2t
*            i_zbd3t = gs_bsid-zbd3t
*            i_shkzg = gs_bsid-shkzg
*            i_rebzg = gs_bsid-rebzg
*            i_koart = 'D'
*          IMPORTING
*            e_faedt = gs_bsid_temp-netdt.

        IF gv_last_date GE gs_bsid_temp-netdt.
          gs_bsid_temp-verzn = gv_last_date - gs_bsid_temp-netdt.
        ELSE.
          gs_bsid_temp-verzn = ( gs_bsid_temp-netdt - gv_last_date ) * -1.
        ENDIF.

        gs_bsid_temp-bukrs = gs_adrs-bukrs.
        gs_bsid_temp-p_monat = p_period.
        gs_bsid_temp-p_gjahr = p_gjahr.
        gs_bsid_temp-hesap_tur = 'M'.
        gs_bsid_temp-hesap_no = ls_kna1_tax-hesap_no.
        gs_bsid_temp-ftype = p_ftype.

*        IF p_verzn IS NOT INITIAL. "İHTAR IÇIN KONTROL   "YiğitcanÖzdemir

*          CHECK p_verzn LE gs_bsid_temp-verzn.

        READ TABLE gt_ifld INTO ls_ifld WITH KEY bukrs = gs_adrs-bukrs
                                    blart = gs_bsid-blart.

        IF sy-subrc EQ 0.

          CLEAR gt_cform_bkpf.

          READ TABLE gt_cform_bkpf INTO gs_cform_bkpf WITH KEY belnr = gs_bsid-belnr
                                            gjahr = gs_bsid-gjahr.

          MOVE-CORRESPONDING gs_cform_bkpf TO gs_bsid_temp.

        ENDIF.

*        ENDIF.

        COLLECT gs_cform_temp INTO gt_cform_temp.

        APPEND gs_bsid_temp TO gt_bsid_temp.

      ENDLOOP.
      " <--- hkizilkaya eşleşen bakiyeleri bozdugu için kosul kaldırıldı.
*      IF sy-subrc NE 0 AND p_zero IS INITIAL AND p_verzn IS INITIAL.
*
*        CLEAR: gt_cform_temp, gt_account_info.
*
*        " <--- hkizilkaya
*        REFRESH gt_cform_temp.
*
*        "MOVE-CORRESPONDING lt_kna1_tax TO gt_cform_temp.
*
*        LOOP AT lt_kna1_tax INTO ls_kna1_tax.
*          CLEAR gs_cform_temp.
*
*          MOVE-CORRESPONDING  ls_kna1_tax TO  gs_cform_temp.
*          APPEND gs_cform_temp TO gt_cform_temp.
*
*        ENDLOOP.
*        " hkizilkaya --->
*
*        READ TABLE gt_account_info INTO gs_account_info
*        WITH KEY kunnr = ls_kna1_tax-kunnr.
*
** EĞER YARATMA TARIHI DÖNEM IÇINDE DEĞILSE
*        IF gs_account_info-erdat GT gv_last_date.
*          DELETE lt_kna1_tax.
*          CONTINUE.
*        ENDIF.
*
*        IF sy-subrc EQ 0.
*          MOVE-CORRESPONDING gs_account_info TO gs_cform_temp.
*        ENDIF.
*
*        READ TABLE gt_htxt INTO gs_htxt WITH KEY spras = gv_spras.
*
*        IF sy-subrc EQ 0.
*          gs_cform_temp-ltext = gs_htxt-customer_text.
*          gs_cform_temp-xsort = 0.
*        ENDIF.
*
*        gs_cform_temp-hesap_tur = 'M'.
*        gs_cform_temp-waers = t001-waers.
*        gs_cform_temp-no_local_curr = gs_adrs-no_local_curr.
*        gs_cform_temp-xsum  = 'X'.
*
*        APPEND gs_cform_temp TO gt_cform_temp.
*
*      ENDIF.
      " eşleşen bakiyeleri bozdugu için kosul kaldırıldı. hkizilkaya --->
    ENDLOOP.


    LOOP AT lt_lfa1_tax INTO ls_lfa1_tax.

      CLEAR: gs_account_info, gv_spras.

      READ TABLE gt_account_info INTO gs_account_info WITH KEY lifnr = ls_lfa1_tax-lifnr.

      "gv_spras = gs_account_info-spras.
      " <--- hkizilkaya mutabakat dili ülkeye göre ayarlanıyor.
      IF gs_account_info-land1 IS NOT INITIAL.
        IF gs_account_info-land1 EQ 'TR'.
          gv_spras = 'T'.
        ELSEIF gs_account_info-land1 EQ 'BG'..
          gv_spras = 'W'.
        ELSE.
          gv_spras = 'E'.
        ENDIF.
      ENDIF.
      " hkizilkaya --->


      DELETE FROM zreco_tbsd
      WHERE bukrs EQ @gs_adrs-bukrs
      AND p_monat EQ @p_period
      AND p_gjahr EQ @p_gjahr
      AND hesap_tur EQ 'S'
      AND hesap_no EQ @ls_lfa1_tax-hesap_no.

      LOOP AT gt_bsik INTO ls_bsik WHERE lifnr EQ ls_lfa1_tax-lifnr.

        CLEAR: gs_cform_temp, gs_bsid_temp, gs_cform_bkpf, gs_curr." gs_tcure. "YiğitcanÖzdemir

        gs_cform_temp-gsber = ls_bsik-gsber.


        MOVE-CORRESPONDING ls_lfa1_tax TO gs_cform_temp.

        gs_cform_temp-hesap_tur = 'S'.
        gs_cform_temp-hesap_no = ls_bsik-lifnr.
        gs_cform_temp-akont = ls_bsik-hkont.
*    GT_CFORM_TEMP-UMSKZ = GT_BSIK-UMSKZ.

        IF ls_bsik-umskz IS NOT INITIAL.

          CLEAR gs_odk.

          READ TABLE gt_odk INTO gs_odk
          WITH KEY hesap_tur = 'S'
                   umskz = ls_bsik-umskz
                   spras = gv_spras.
          CHECK sy-subrc EQ 0.
          IF gs_odk-xsum IS NOT INITIAL AND gs_odk-xakont IS INITIAL.
            gs_cform_temp-akont = ls_bsik-saknr.
          ENDIF.
          gs_cform_temp-ltext = gs_odk-ltext.
          gs_cform_temp-xsort = gs_odk-xsort.
          gs_cform_temp-xsum = gs_odk-xsum.
          gs_cform_temp-umskz = 'X'. "hkizilkaya

        ELSE.
          gs_cform_temp-umskz = ' '. "hkizilkaya

          READ TABLE gt_htxt INTO gs_htxt WITH KEY spras = gv_spras.

          IF sy-subrc EQ 0.
            gs_cform_temp-ltext = gs_htxt-vendor_text.
            gs_cform_temp-xsort = 0.

          ENDIF.
          gs_cform_temp-xsum = 'X'.
        ENDIF.

* SADECE UPB MUTABAKAT YAPıLAN CARILER
        READ TABLE gt_cloc INTO gs_cloc
        WITH KEY hesap_tur = 'S'
                 hesap_no = ls_bsik-lifnr.

        IF sy-subrc EQ 0.
*          ls_bsik-waers = t001-waers.   "YiğitcanÖzdemir
          ls_bsik-wrbtr = ls_bsik-dmbtr.
        ENDIF.

* İKAME EDILEN PARA BIRIMLERI
        READ TABLE gt_curr INTO gs_curr
        WITH KEY waers_from = ls_bsik-waers.

        IF sy-subrc EQ 0.
          ls_bsik-waers = gs_curr-waers_to.
*          IF gs_curr-waers_to EQ t001-waers."YiğitcanÖzdemir
*            ls_bsik-wrbtr = ls_bsik-dmbtr.
*          ENDIF.
        ENDIF.

* TEDAVÜLDEN KALKAN PARA BIRIMLERI
*        READ TABLE gt_tcure INTO gs_tcure  "YiğitcanÖzdemir
*        WITH KEY curc_old = ls_bsik-waers.

        IF sy-subrc EQ 0.

          ls_bsik-wrbtr = ls_bsik-wrbtr / 10000.
*          ls_bsik-waers = gs_tcure-curc_new.  "YiğitcanÖzdemir

        ENDIF.

* DEĞERLENMIŞ TUTAR
        IF p_exch IS NOT INITIAL.

          IF gs_adrs-kurst IS NOT INITIAL ."AND
*             ls_bsik-waers NE t001-waers.   "YiğitcanÖzdemir

            CLEAR gs_exch_rate.

            READ TABLE gt_exch_rate INTO gs_exch_rate
            WITH KEY from_curr = ls_bsik-waers.

            IF sy-subrc NE 0.

              "<-- hkizilkaya kur bilgisi farkli tablodan alındığı için kaldırıldı.
*              CALL FUNCTION 'BAPI_EXCHANGERATE_GETDETAIL'
*                EXPORTING
*                  rate_type  = gs_adrs-kurst
*                  from_curr  = ls_bsik-waers
*                  to_currncy = t001-waers
*                  date       = gv_last_date
*                IMPORTING
*                  exch_rate  = gs_exch_rate.
              " hkizilkaya -->

              "<-- hkizilkaya 'TRCURR' tablosundan ay sonu kur bilgisini al
              CONCATENATE p_gjahr p_period '01' INTO p_rdate. "mali yıl ve dönem bilgisi

*              CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'"YiğitcanÖzdemir
*                EXPORTING
*                  day_in            = p_rdate
*                IMPORTING
*                  last_day_of_month = last_day_of_month. " gelen mali ayın son günü


              lo_zreco_common->rp_last_day_of_months(
                EXPORTING
                  day_in            = p_rdate
                IMPORTING
                  last_day_of_month = last_day_of_month
              ).

*              CALL FUNCTION 'DAY_IN_WEEK'"YiğitcanÖzdemir
*                EXPORTING
*                  datum = last_day_of_month
*                IMPORTING
*                  wotnr = lv_weekday. "Ayın son günü haftanın hangi gününe denk geliyor
              " 1 = Pazartesi, 2 = Salı .... 6 = Cumartesi, 7 = Pazar.

              IF ls_bsik-waers EQ 'TRY'. "Dönüştürülecek para birimi TL ise kur 1TL

                gs_exch_rate-rate_type = gs_adrs-kurst.
                gs_exch_rate-from_curr = 'TRY'.
                gs_exch_rate-to_currncy = 'TRY'.
                gs_exch_rate-exch_rate = 1.

              ELSE.
                CONCATENATE last_day_of_month+6(2) last_day_of_month+4(2) last_day_of_month+0(4) INTO last_day_of_month. "tarih formatını gün/ay/yıl olarak değiştirilir.

*                CALL FUNCTION 'CONVERSION_EXIT_INVDT_INPUT'          "YiğitcanÖzdemir
*                  EXPORTING
*                    input  = last_day_of_month
*                  IMPORTING
*                    output = lv_conv_date. "ayın son günü tcurr-gdatu tablosu için convert edilir

                IF  lv_weekday EQ 6. "Ayın son günü umartesi günü ise 1 gün geriye gidip cuma gününün kur bilgisi alınır.
                  lv_conv_date = lv_conv_date + 1.
*
*                  SELECT SINGLE ukurs "YiğitcanÖzdemir
*                    FROM tcurr
*                    INTO lv_ukurs
*                    WHERE kurst EQ gs_adrs-kurst
*                    AND fcurr EQ ls_bsik-waers
*                    AND tcurr EQ 'TRY'
*                    AND gdatu EQ lv_conv_date.

                  gs_exch_rate-rate_type = gs_adrs-kurst.
                  gs_exch_rate-from_curr = ls_bsik-waers.
                  gs_exch_rate-to_currncy = 'TRY'.
                  gs_exch_rate-exch_rate = lv_ukurs.

                ELSEIF lv_weekday EQ 7. "Ayın son günü pazar ise 2 gün geriye gidip cuma gününün kur bilgisi alınır.
                  lv_conv_date = lv_conv_date + 2.

*                  SELECT SINGLE ukurs   "YiğitcanÖzdemir
*                   FROM tcurr
*                   INTO lv_ukurs
*                   WHERE kurst EQ gs_adrs-kurst
*                   AND fcurr EQ ls_bsik-waers
*                   AND tcurr EQ 'TRY'
*                   AND gdatu EQ lv_conv_date.

                  gs_exch_rate-rate_type = gs_adrs-kurst.
                  gs_exch_rate-from_curr = ls_bsik-waers.
                  gs_exch_rate-to_currncy = 'TRY'.
                  gs_exch_rate-exch_rate = lv_ukurs.

                ELSE. "Ayın son günü hafta içine denk gelirse aynı tarih direk alınır.
*                  SELECT SINGLE ukurs  "YiğitcanÖzdemir
*                  FROM tcurr
*                  INTO lv_ukurs
*                  WHERE kurst EQ gs_adrs-kurst
*                  AND fcurr EQ ls_bsik-waers
*                  AND tcurr EQ 'TRY'
*                  AND gdatu EQ lv_conv_date.

                  gs_exch_rate-rate_type = gs_adrs-kurst.
                  gs_exch_rate-from_curr = ls_bsik-waers.
                  gs_exch_rate-to_currncy = 'TRY'.
                  gs_exch_rate-exch_rate = lv_ukurs.

                ENDIF.
              ENDIF.
              APPEND gs_exch_rate TO gt_exch_rate.
              CLEAR: last_day_of_month, lv_weekday, lv_ukurs, lv_conv_date.
              " hkizilkaya -->


            ENDIF.

            CLEAR gs_exch_rate.

            READ TABLE gt_exch_rate INTO gs_exch_rate
            WITH KEY from_curr = ls_bsik-waers.

            IF sy-subrc EQ 0.
              IF gs_exch_rate-from_factor EQ 0.
                gs_exch_rate-from_factor = 1.
              ENDIF.

              IF gs_exch_rate-from_factor NE 1.
*                CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL' "YiğitcanÖzdemir
*                  EXPORTING
*                    currency        = ls_bsik-waers
*                    amount_internal = ls_bsik-wrbtr
*                  IMPORTING
*                    amount_external = lv_wrbtr.
              ELSE.
                lv_wrbtr = ls_bsik-wrbtr.
              ENDIF.

              ls_bsik-dmbtr = lv_wrbtr *
                                   abs( gs_exch_rate-exch_rate )
                                   / gs_exch_rate-from_factor.
            ENDIF.

          ENDIF.

        ENDIF.

        MOVE-CORRESPONDING ls_bsik TO gs_bsid_temp.

        CASE ls_bsik-shkzg.
          WHEN 'H'.
            gs_bsid_temp-dmbtr = gs_cform_temp-dmbtr = 0 - ls_bsik-dmbtr.
            gs_bsid_temp-wrbtr = gs_cform_temp-wrbtr = 0 - ls_bsik-wrbtr.
          WHEN OTHERS.
            gs_cform_temp-dmbtr = ls_bsik-dmbtr.
            gs_cform_temp-wrbtr = ls_bsik-wrbtr.
        ENDCASE.

        gs_cform_temp-waers = ls_bsik-waers.

        IF ls_bsik-zfbdt IS INITIAL.
          ls_bsik-zfbdt = ls_bsik-budat.
        ENDIF.
*
*        CALL FUNCTION 'NET_DUE_DATE_GET' "YiğitcanÖzdemir
*          EXPORTING
*            i_zfbdt = ls_bsik-zfbdt
*            i_zbd1t = ls_bsik-zbd1t
*            i_zbd2t = ls_bsik-zbd2t
*            i_zbd3t = ls_bsik-zbd3t
*            i_shkzg = ls_bsik-shkzg
*            i_rebzg = ls_bsik-rebzg
*            i_koart = 'K'
*          IMPORTING
*            e_faedt = gs_bsid_temp-netdt.

        IF gv_last_date GE gs_bsid_temp-netdt.
          gs_bsid_temp-verzn = gv_last_date - gs_bsid_temp-netdt.
        ELSE.
          gs_bsid_temp-verzn = ( gs_bsid_temp-netdt - gv_last_date ) * -1.
        ENDIF.

        gs_bsid_temp-bukrs = gs_adrs-bukrs.
        gs_bsid_temp-p_monat = p_period.
        gs_bsid_temp-p_gjahr = p_gjahr.
        gs_bsid_temp-hesap_tur = 'S'.
        gs_bsid_temp-hesap_no = ls_lfa1_tax-hesap_no.
        gs_bsid_temp-ftype = p_ftype.

        COLLECT gs_cform_temp INTO gt_cform_temp.

        APPEND gs_bsid_temp TO gt_bsid_temp.

      ENDLOOP.

      IF sy-subrc NE 0 AND p_zero IS INITIAL.

        CLEAR: gs_cform_temp, gs_account_info.

        MOVE-CORRESPONDING ls_lfa1_tax TO gs_cform_temp.

        READ TABLE gt_account_info INTO gs_account_info
        WITH KEY lifnr = ls_lfa1_tax-lifnr.

* EĞER YARATMA TARIHI DÖNEM IÇINDE DEĞILSE
        IF gs_account_info-erdat GT gv_last_date.
          DELETE lt_lfa1_tax INDEX sy-tabix.
          CONTINUE.
        ENDIF.

        IF sy-subrc EQ 0.
          MOVE-CORRESPONDING gs_account_info TO gs_cform_temp.
        ENDIF.

        READ TABLE gt_htxt INTO gs_htxt WITH KEY spras = gv_spras.

        IF sy-subrc EQ 0.
          gs_cform_temp-ltext = gs_htxt-vendor_text.
          gs_cform_temp-xsort = 0.
        ENDIF.

        gs_cform_temp-hesap_tur = 'S'.
*        gs_cform_temp-waers = t001-waers."YiğitcanÖzdemir
        gs_cform_temp-no_local_curr = gs_adrs-no_local_curr.
        gs_cform_temp-xsum  = 'X'.

        APPEND gs_cform_temp TO gt_cform_temp.

      ENDIF.

    ENDLOOP.

    SORT gt_cform_temp BY xsort hesap_tur .

    IF gs_adrs-zero_splind IS NOT INITIAL.
      DELETE gt_cform_temp WHERE dmbtr EQ 0 AND xsum IS INITIAL.
    ENDIF.


    IF p_all IS NOT INITIAL. "VKN BIRLEŞTIRME VAR ISE

*<--- BIRLEŞTIRILEN CARILER
      CLEAR: lt_kna1_tax, lt_lfa1_tax.

      lt_kna1_tax[] = gt_kna1_tax[].
      lt_lfa1_tax[] = gt_lfa1_tax[].

      DELETE ADJACENT DUPLICATES FROM lt_kna1_tax COMPARING vkn_tckn.
      DELETE ADJACENT DUPLICATES FROM lt_lfa1_tax COMPARING vkn_tckn.

      LOOP AT lt_kna1_tax INTO ls_kna1_tax WHERE merge EQ 'X'.

        CLEAR gs_account_info.

        READ TABLE gt_account_info INTO gs_account_info WITH KEY kunnr = ls_kna1_tax-kunnr.

        LOOP AT gt_cform_temp ASSIGNING <fs_cform_temp>
          WHERE vkn_tckn EQ ls_kna1_tax-vkn_tckn
          AND hesap_tur EQ 'M'.

          CLEAR: gs_out_c, gs_balance.

          MOVE-CORRESPONDING gs_account_info TO gs_out_c.
          MOVE-CORRESPONDING <fs_cform_temp> TO gs_out_c.
          gs_out_c-hesap_no = ls_kna1_tax-hesap_no.

          <fs_cform_temp>-merge = gs_out_c-merge = ls_kna1_tax-merge.

          gs_out_c-hesap_no = ls_kna1_tax-kunnr.
          gs_out_c-kunnr = ls_kna1_tax-kunnr.
          gs_out_c-lifnr = ls_kna1_tax-lifnr.
          gs_out_c-ktokl = gs_account_info-ktokd.

*          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT' "YiğitcanÖzdemir
*            EXPORTING
*              input  = gs_out_c-hesap_no
*            IMPORTING
*              output = lv_text.

          CONCATENATE TEXT-tr1 lv_text '-' gs_out_c-name1
          INTO gs_out_c-name SEPARATED BY space.

          IF gs_adrs-no_general IS NOT INITIAL.
            CLEAR gs_out_c-telfx.
          ENDIF.

          COLLECT gs_out_c INTO gt_out_c.

          MOVE-CORRESPONDING gs_out_c TO gs_balance.
          COLLECT gs_balance INTO gt_balance.

        ENDLOOP.

        IF ls_kna1_tax-lifnr IS NOT INITIAL.

          LOOP AT gt_cform_temp ASSIGNING <fs_cform_temp>
            WHERE vkn_tckn EQ ls_kna1_tax-vkn_tckn
            AND hesap_tur EQ 'S'.

            CLEAR: gs_out_c, gs_balance.

            MOVE-CORRESPONDING gs_account_info TO gs_out_c.
            MOVE-CORRESPONDING <fs_cform_temp> TO gs_out_c.
            gs_out_c-hesap_no = ls_kna1_tax-hesap_no.

            <fs_cform_temp>-merge = gs_out_c-merge = ls_kna1_tax-merge.

            gs_out_c-hesap_no = ls_kna1_tax-lifnr.
            gs_out_c-kunnr = ls_kna1_tax-kunnr.
            gs_out_c-lifnr = ls_kna1_tax-lifnr.
            gs_out_c-ktokl = gs_account_info-ktokk.

*            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT' "YiğitcanÖzdmeir
*              EXPORTING
*                input  = gs_out_c-hesap_no
*              IMPORTING
*                output = lv_text.

            CONCATENATE TEXT-tr2 lv_text '-' gs_out_c-name1
            INTO gs_out_c-name SEPARATED BY space.

            IF gs_adrs-no_general IS NOT INITIAL.
              CLEAR gs_out_c-telfx.
            ENDIF.

            COLLECT gs_out_c INTO gt_out_c.

            MOVE-CORRESPONDING gs_out_c TO gs_balance.
            COLLECT gs_balance INTO gt_balance.

          ENDLOOP.

          DELETE lt_lfa1_tax WHERE vkn_tckn EQ ls_kna1_tax-vkn_tckn.

        ENDIF.

        DELETE lt_kna1_tax.

      ENDLOOP.

      LOOP AT lt_lfa1_tax INTO ls_lfa1_tax WHERE merge EQ 'X'.

        CLEAR gs_account_info.

        READ TABLE gt_account_info INTO gs_account_info WITH KEY lifnr = ls_lfa1_tax-lifnr.

        LOOP AT gt_cform_temp ASSIGNING <fs_cform_temp>
          WHERE vkn_tckn EQ ls_lfa1_tax-vkn_tckn
          AND hesap_tur EQ 'S'.

          CLEAR: gs_out_c, gs_balance.

          MOVE-CORRESPONDING gs_account_info TO gs_out_c.
          MOVE-CORRESPONDING <fs_cform_temp> TO gs_out_c.

          <fs_cform_temp>-merge = gs_out_c-merge = ls_lfa1_tax-merge.

          gs_out_c-hesap_no = ls_lfa1_tax-lifnr.
          gs_out_c-kunnr = ls_lfa1_tax-kunnr.
          gs_out_c-lifnr = ls_lfa1_tax-lifnr.
          gs_out_c-ktokl = gs_account_info-ktokk.

*          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'   "YiğitcanÖzdemir
*            EXPORTING
*              input  = gs_out_c-hesap_no
*            IMPORTING
*              output = lv_text.

          CONCATENATE TEXT-tr2 lv_text '-' gs_out_c-name1
          INTO gs_out_c-name SEPARATED BY space.

          IF gs_adrs-no_general IS NOT INITIAL.
            CLEAR gs_out_c-telfx.
          ENDIF.

          COLLECT gs_out_c INTO gt_out_c.

          MOVE-CORRESPONDING gs_out_c TO gs_balance.
          COLLECT gs_balance INTO gt_balance.

        ENDLOOP.

        IF ls_lfa1_tax-kunnr IS NOT INITIAL.

          LOOP AT gt_cform_temp ASSIGNING <fs_cform_temp>
            WHERE vkn_tckn EQ ls_lfa1_tax-vkn_tckn
            AND hesap_tur EQ 'M'.

            CLEAR: gs_out_c, gs_balance.

            MOVE-CORRESPONDING gs_account_info TO gs_out_c.
            MOVE-CORRESPONDING <fs_cform_temp> TO gs_out_c.

            <fs_cform_temp>-merge = gs_out_c-merge = ls_lfa1_tax-merge.

            gs_out_c-hesap_no = ls_lfa1_tax-kunnr.
            gs_out_c-kunnr = ls_lfa1_tax-kunnr.
            gs_out_c-lifnr = ls_lfa1_tax-lifnr.
            gs_out_c-ktokl = gs_account_info-ktokd.

*            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'  "YiğitcanÖzdemir
*              EXPORTING
*                input  = gs_out_c-hesap_no
*              IMPORTING
*                output = lv_text.

            CONCATENATE TEXT-tr1 lv_text '-' gs_out_c-name1
            INTO gs_out_c-name SEPARATED BY space.

            IF gs_adrs-no_general IS NOT INITIAL.
              CLEAR gs_out_c-telfx.
            ENDIF.

            COLLECT gs_out_c INTO gt_out_c.

            MOVE-CORRESPONDING gs_out_c TO gs_balance.
            COLLECT gs_balance INTO gt_balance.

          ENDLOOP.

          DELETE lt_kna1_tax WHERE vkn_tckn EQ ls_lfa1_tax-vkn_tckn.

        ENDIF.

        DELETE lt_lfa1_tax.

      ENDLOOP.
* BIRLEŞTIRILEN CARILER --->

*<--- BIRLEŞTIRMEDE OLMAYAN CARILER
      CLEAR: lt_kna1_tax, lt_lfa1_tax.

      DELETE ADJACENT DUPLICATES FROM lt_kna1_tax COMPARING kunnr lifnr.
      DELETE ADJACENT DUPLICATES FROM lt_lfa1_tax COMPARING kunnr lifnr.

      DELETE lt_kna1_tax WHERE merge EQ 'X'.
      DELETE lt_lfa1_tax WHERE merge EQ 'X'.

      LOOP AT lt_kna1_tax INTO ls_kna1_tax WHERE merge IS INITIAL.

        CLEAR gs_account_info.

        READ TABLE gt_account_info INTO gs_account_info WITH KEY kunnr = ls_kna1_tax-kunnr.

        LOOP AT gt_cform_temp ASSIGNING <fs_cform_temp>
          WHERE kunnr EQ ls_kna1_tax-kunnr
            AND lifnr EQ ls_kna1_tax-lifnr
            AND hesap_tur EQ 'M'.

          CLEAR: gs_out_c, gs_balance.

          MOVE-CORRESPONDING gs_account_info TO gs_out_c.
          MOVE-CORRESPONDING <fs_cform_temp> TO gs_out_c.
          gs_out_c-hesap_no = ls_kna1_tax-hesap_no.

          <fs_cform_temp>-merge = gs_out_c-merge = ls_kna1_tax-merge.

          gs_out_c-hesap_no = ls_kna1_tax-kunnr.
          gs_out_c-kunnr = ls_kna1_tax-kunnr.
          gs_out_c-lifnr = ls_kna1_tax-lifnr.
          gs_out_c-ktokl = gs_account_info-ktokd.

*          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'    "YiğitcanÖzdemir
*            EXPORTING
*              input  = gs_out_c-hesap_no
*            IMPORTING
*              output = lv_text.

          CONCATENATE TEXT-tr1 lv_text '-' gs_out_c-name1
          INTO gs_out_c-name SEPARATED BY space.

          IF gs_adrs-no_general IS NOT INITIAL.
            CLEAR gs_out_c-telfx.
          ENDIF.

          COLLECT gs_out_c INTO gt_out_c.

          MOVE-CORRESPONDING gs_out_c TO gs_balance.
          COLLECT gs_balance INTO gt_balance.

        ENDLOOP.

        LOOP AT gt_cform_temp ASSIGNING <fs_cform_temp>
          WHERE kunnr EQ ls_kna1_tax-kunnr
            AND lifnr EQ ls_kna1_tax-lifnr
            AND hesap_tur EQ 'S'.

          CLEAR: gs_out_c, gs_balance.

          MOVE-CORRESPONDING gs_account_info TO gs_out_c.
          MOVE-CORRESPONDING <fs_cform_temp> TO gs_out_c.
          gs_out_c-hesap_no = ls_kna1_tax-hesap_no.

          <fs_cform_temp>-merge = gs_out_c-merge = ls_kna1_tax-merge.

          gs_out_c-hesap_no = ls_kna1_tax-lifnr.
          gs_out_c-kunnr = ls_kna1_tax-kunnr.
          gs_out_c-lifnr = ls_kna1_tax-lifnr.
          gs_out_c-ktokl = gs_account_info-ktokk.

*          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'   "YiğitcanÖzdemir
*            EXPORTING
*              input  = gs_out_c-hesap_no
*            IMPORTING
*              output = lv_text.

          CONCATENATE TEXT-tr2 lv_text '-' gs_out_c-name1
          INTO gs_out_c-name SEPARATED BY space.

          IF gs_adrs-no_general IS NOT INITIAL.
            CLEAR gs_out_c-telfx.
          ENDIF.

          COLLECT gs_out_c INTO gt_out_c.

          MOVE-CORRESPONDING gs_out_c TO gs_balance.
          COLLECT gs_balance INTO gt_balance.

        ENDLOOP.

        DELETE lt_lfa1_tax WHERE kunnr EQ ls_kna1_tax-kunnr
                             AND lifnr EQ ls_kna1_tax-lifnr.

        DELETE lt_kna1_tax.

      ENDLOOP.

      LOOP AT lt_lfa1_tax INTO ls_lfa1_tax WHERE merge IS INITIAL.

        CLEAR gs_account_info.

        READ TABLE gt_account_info INTO gs_account_info WITH KEY lifnr = ls_lfa1_tax-lifnr.

        LOOP AT gt_cform_temp ASSIGNING <fs_cform_temp>
          WHERE kunnr EQ ls_lfa1_tax-kunnr
            AND lifnr EQ ls_lfa1_tax-lifnr
            AND hesap_tur EQ 'M'.

          CLEAR: gs_out_c, gs_balance.

          MOVE-CORRESPONDING gs_account_info TO gs_out_c.
          MOVE-CORRESPONDING <fs_cform_temp> TO gs_out_c.

          <fs_cform_temp>-merge = gs_out_c-merge = ls_lfa1_tax-merge.

          gs_out_c-hesap_no = ls_lfa1_tax-kunnr.
          gs_out_c-kunnr = ls_lfa1_tax-kunnr.
          gs_out_c-lifnr = ls_lfa1_tax-lifnr.
          gs_out_c-ktokl = gs_account_info-ktokd.

*          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'   "YiğitcanÖzdemir
*            EXPORTING
*              input  = gs_out_c-hesap_no
*            IMPORTING
*              output = lv_text.

          CONCATENATE TEXT-tr1 lv_text '-' gs_out_c-name1
          INTO gs_out_c-name SEPARATED BY space.

          IF gs_adrs-no_general IS NOT INITIAL.
            CLEAR gs_out_c-telfx.
          ENDIF.

          COLLECT gs_out_c INTO gt_out_c.

          MOVE-CORRESPONDING gs_out_c TO gs_balance.
          COLLECT gs_balance INTO gt_balance.

        ENDLOOP.

        LOOP AT gt_cform_temp ASSIGNING <fs_cform_temp>
          WHERE kunnr EQ ls_lfa1_tax-kunnr
            AND lifnr EQ ls_lfa1_tax-lifnr
          AND hesap_tur EQ 'S'.

          CLEAR: gs_out_c, gs_balance.

          MOVE-CORRESPONDING gs_account_info TO gs_out_c.
          MOVE-CORRESPONDING <fs_cform_temp> TO gs_out_c.

          <fs_cform_temp>-merge = gs_out_c-merge = ls_lfa1_tax-merge.

          gs_out_c-hesap_no = ls_lfa1_tax-lifnr.
          gs_out_c-kunnr = ls_lfa1_tax-kunnr.
          gs_out_c-lifnr = ls_lfa1_tax-lifnr.
          gs_out_c-ktokl = gs_account_info-ktokk.

*          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'   "YiğitcanÖzdemir
*            EXPORTING
*              input  = gs_out_c-hesap_no
*            IMPORTING
*              output = lv_text.

          CONCATENATE TEXT-tr2 lv_text '-' gs_out_c-name1
          INTO gs_out_c-name SEPARATED BY space.

          IF gs_adrs-no_general IS NOT INITIAL.
            CLEAR gs_out_c-telfx.
          ENDIF.

          COLLECT gs_out_c INTO gt_out_c.

          MOVE-CORRESPONDING gs_out_c TO gs_balance.
          COLLECT gs_balance INTO gt_balance.

        ENDLOOP.

        DELETE lt_kna1_tax WHERE kunnr EQ ls_lfa1_tax-kunnr
                             AND lifnr EQ ls_lfa1_tax-lifnr.

        DELETE lt_lfa1_tax.

      ENDLOOP.

* BIRLEŞTIRMEDE OLMAYAN CARILER--->

    ELSE.

* VKN BIRLEŞTIRME YOKSA

      LOOP AT gt_cform_temp ASSIGNING <fs_cform_temp>.

        CLEAR: gs_out_c, gs_account_info, gs_balance.

        CASE <fs_cform_temp>-hesap_tur.
          WHEN 'M'.
            READ TABLE gt_account_info INTO gs_account_info WITH KEY kunnr = <fs_cform_temp>-kunnr.
          WHEN 'S'.
            READ TABLE gt_account_info INTO gs_account_info WITH KEY lifnr = <fs_cform_temp>-lifnr.
          WHEN OTHERS.
        ENDCASE.

        MOVE-CORRESPONDING gs_account_info TO gs_out_c.
        MOVE-CORRESPONDING <fs_cform_temp> TO gs_out_c.

*        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'    "YiğitcanÖzdemir
*          EXPORTING
*            input  = gs_out_c-hesap_no
*          IMPORTING
*            output = lv_text.

        CASE <fs_cform_temp>-hesap_tur.
          WHEN 'M'.

            CONCATENATE TEXT-tr1 lv_text '-' gs_out_c-name1
            INTO gs_out_c-name SEPARATED BY space.

            gs_out_c-ktokl = gs_account_info-ktokd.

          WHEN 'S'.

            CONCATENATE TEXT-tr2 lv_text '-' gs_out_c-name1
            INTO gs_out_c-name SEPARATED BY space.

            gs_out_c-ktokl = gs_account_info-ktokk.

          WHEN OTHERS.
        ENDCASE.

        IF gs_adrs-no_general IS NOT INITIAL.
          CLEAR gs_out_c-telfx.
        ENDIF.

        COLLECT gs_out_c INTO gt_out_c.

        MOVE-CORRESPONDING gs_out_c TO gs_balance.
        COLLECT gs_balance INTO gt_balance.

      ENDLOOP.

    ENDIF.

    IF p_zero IS NOT INITIAL.
      " <-- hkizilkaya
*      LOOP AT gt_balance INTO gs_balance WHERE dmbtr EQ 0.
*        IF gs_balance-kunnr IS NOT INITIAL.
*          CALL METHOD go_log->bal_log_msg_add
*            EXPORTING
*              i_type       = /itetr/reco_if_common_types=>mc_msg_w
*              i_no         = '180'
*              i_id         = /itetr/reco_if_common_types=>mc_msg_class
*              i_v1         = gs_balance-kunnr
*              i_v2         = TEXT-tr1
*              i_v3         = ''
*              i_v4         = ''
*              i_log_handle = gv_log_handle
*            EXCEPTIONS
*              OTHERS       = 1.
*        ELSE.
*          CALL METHOD go_log->bal_log_msg_add
*            EXPORTING
*              i_type       = /itetr/reco_if_common_types=>mc_msg_w
*              i_no         = '180'
*              i_id         = /itetr/reco_if_common_types=>mc_msg_class
*              i_v1         = gs_balance-lifnr
*              i_v2         = TEXT-tr2
*              i_v3         = ''
*              i_v4         = ''
*              i_log_handle = gv_log_handle
*            EXCEPTIONS
*              OTHERS       = 1.
*
*          DELETE gt_out_c WHERE kunnr EQ gs_balance-kunnr
*                         AND lifnr EQ gs_balance-lifnr.
*
*          DELETE gt_balance.
*        ENDIF.
*
*      ENDLOOP.
      " hkizilkaya -->

      "<-- hkizilkaya dmbtr = '0' olan bütün satırları sil.
      LOOP AT gt_out_c INTO gs_out_c WHERE dmbtr EQ 0.
        DELETE gt_out_c WHERE kunnr EQ gs_out_c-kunnr
                        AND   lifnr EQ gs_out_c-lifnr
                        AND   name  EQ gs_out_c-name
                        AND   ltext EQ gs_out_c-ltext
                        AND   waers EQ gs_out_c-waers.
      ENDLOOP.
      " hkizilkaya -->
    ENDIF.


* Kart açılmış ama hiç hareket görmemiş olanları sil
    LOOP AT gt_balance INTO gs_balance WHERE dmbtr EQ 0.

      IF gs_balance-kunnr IS NOT INITIAL.
*      SELECT SINGLE COUNT(*) FROM bsid       "YiğitcanÖzdemir
*             WHERE bukrs IN @s_bukrs AND
*                   kunnr EQ @gs_balance-kunnr AND
*                   umskz IN @r_umskz_m.

        SELECT SINGLE COUNT(*)
        FROM zetr_reco_ddl_bsid
        WHERE CompanyCode IN @s_bukrs  AND
              Customer EQ @gs_balance-kunnr AND
              SpecialGLCode IN @r_umskz_m.

        IF sy-subrc NE 0.


*        SELECT SINGLE COUNT(*) FROM bsad      "YiğitcanÖzdemir
*                 WHERE bukrs IN @s_bukrs AND
*                       kunnr EQ @gs_balance-kunnr AND
*                       umskz IN @r_umskz_m.


          SELECT SINGLE COUNT(*)
          FROM I_OperationalAcctgDocItem
          INNER JOIN I_OplAcctgDocItemClrgHist
          ON I_OperationalAcctgDocItem~CompanyCode = I_OplAcctgDocItemClrgHist~ClearedCompanyCode
          AND I_OperationalAcctgDocItem~AccountingDocument = I_OplAcctgDocItemClrgHist~ClearedAccountingDocument
          AND I_OperationalAcctgDocItem~FiscalYear = I_OplAcctgDocItemClrgHist~ClearedFiscalYear
          AND I_OperationalAcctgDocItem~AccountingDocumentItem = I_OplAcctgDocItemClrgHist~ClearedAccountingDocumentItem
              WHERE I_OperationalAcctgDocItem~CompanyCode IN @s_bukrs  AND
                    I_OperationalAcctgDocItem~Customer EQ @gs_balance-kunnr AND
                        I_OperationalAcctgDocItem~SpecialGLCode IN @r_umskz_m AND
                        I_OplAcctgDocItemClrgHist~FinancialAccountType = 'D'.


          IF sy-subrc NE 0.
            DELETE gt_out_c WHERE kunnr EQ gs_balance-kunnr
                              AND lifnr EQ ''.
          ENDIF.
        ENDIF.
      ENDIF.

      IF gs_balance-lifnr IS NOT INITIAL.
*      SELECT SINGLE COUNT(*) FROM bsik           "YiğitcanÖzdemir
*             WHERE bukrs IN s_bukrs AND
*                   lifnr EQ gs_balance-lifnr AND
*                   umskz IN r_umskz_s.

        SELECT SINGLE COUNT(*)
        FROM zetr_reco_ddl_bsik
        WHERE CompanyCode IN @s_bukrs  AND
              supplier EQ @gs_balance-lifnr AND
              SpecialGLCode IN @r_umskz_m.

        IF sy-subrc NE 0.
*        SELECT SINGLE COUNT(*) FROM bsak          "YiğitcanÖzdemir
*         WHERE bukrs IN s_bukrs AND
*               lifnr EQ gs_balance-lifnr AND
*               umskz IN r_umskz_s.


          SELECT SINGLE COUNT(*)
          FROM I_OperationalAcctgDocItem
          INNER JOIN I_OplAcctgDocItemClrgHist
          ON I_OperationalAcctgDocItem~CompanyCode = I_OplAcctgDocItemClrgHist~ClearedCompanyCode
          AND I_OperationalAcctgDocItem~AccountingDocument = I_OplAcctgDocItemClrgHist~ClearedAccountingDocument
          AND I_OperationalAcctgDocItem~FiscalYear = I_OplAcctgDocItemClrgHist~ClearedFiscalYear
          AND I_OperationalAcctgDocItem~AccountingDocumentItem = I_OplAcctgDocItemClrgHist~ClearedAccountingDocumentItem
              WHERE I_OperationalAcctgDocItem~CompanyCode IN @s_bukrs  AND
                    I_OperationalAcctgDocItem~supplier EQ @gs_balance-lifnr AND
                        I_OperationalAcctgDocItem~SpecialGLCode IN @r_umskz_m AND
                        I_OplAcctgDocItemClrgHist~FinancialAccountType = 'K'.

          IF sy-subrc NE 0.
            DELETE gt_out_c WHERE lifnr EQ gs_balance-lifnr
                              AND kunnr EQ ''.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDLOOP.

    IF p_tran IS NOT INITIAL. "MAHSUPLAŞTıRMA VAR ISE

      DATA: lt_out_c  TYPE TABLE OF zreco_cform,
            ls_out_cx TYPE zreco_cform.

      CLEAR lt_out_c.

      lt_out_c[] = gt_out_c[].

      CLEAR gt_out_c.

      LOOP AT gt_balance INTO gs_balance.

        CLEAR gs_out_c.

        IF gs_balance-dmbtr GE 0 AND  "BAKIYE SıFıRDAN BÜYÜK
           gs_balance-kunnr IS NOT INITIAL. "VE MÜŞTERI HESABı VARSA

          gs_bsid_temp-hesap_tur = 'M'.
          gs_bsid_temp-hesap_no = gs_balance-kunnr.

          IF gs_balance-lifnr IS NOT INITIAL.
            MODIFY gt_bsid_temp FROM gs_bsid_temp TRANSPORTING hesap_tur hesap_no
            WHERE hesap_tur EQ 'S'
            AND hesap_no EQ gs_balance-lifnr.
          ENDIF.

        ENDIF.

        IF gs_balance-dmbtr LT 0 AND  "BAKIYE SıFıRDAN KÜÇÜK
           gs_balance-lifnr IS NOT INITIAL. "VE SATıCı HESABı VARSA

          gs_bsid_temp-hesap_tur = 'S'.
          gs_bsid_temp-hesap_no = gs_balance-lifnr.

          IF gs_balance-kunnr IS NOT INITIAL.
            MODIFY gt_bsid_temp FROM gs_bsid_temp TRANSPORTING hesap_tur hesap_no
            WHERE hesap_tur EQ 'M'
            AND hesap_no EQ gs_balance-kunnr.
          ENDIF.

        ENDIF.

        LOOP AT lt_out_c INTO ls_out_cx WHERE kunnr EQ gs_balance-kunnr
                           AND lifnr EQ gs_balance-lifnr.

          CLEAR gs_out_c.

          MOVE-CORRESPONDING ls_out_cx TO gs_out_c.

          IF gs_balance-dmbtr GE 0 AND  "BAKIYE SıFıRDAN BÜYÜK
             gs_balance-kunnr IS NOT INITIAL. "VE MÜŞTERI HESABı VARSA
            gs_out_c-hesap_tur = 'M'.
            gs_out_c-hesap_no = gs_balance-kunnr.
          ENDIF.

          IF gs_balance-dmbtr LT 0 AND  "BAKIYE SıFıRDAN KÜÇÜK
             gs_balance-lifnr IS NOT INITIAL. "VE SATıCı HESABı VARSA
            gs_out_c-hesap_tur = 'S'.
            gs_out_c-hesap_no = gs_balance-lifnr.
          ENDIF.

          CASE gs_out_c-hesap_tur.
            WHEN 'M'.
              READ TABLE gt_account_info INTO gs_account_info WITH KEY kunnr = ls_out_cx-kunnr.

*              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT' "YiğitcanÖzdemir
*                EXPORTING
*                  input  = gs_out_c-hesap_no
*                IMPORTING
*                  output = lv_text.

              CONCATENATE TEXT-tr1 lv_text '-' gs_account_info-name1
              INTO gs_out_c-name SEPARATED BY space.

              gs_out_c-ktokl = gs_account_info-ktokd.

            WHEN 'S'.

*              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'  "YiğitcanÖzdemir
*                EXPORTING
*                  input  = gs_out_c-hesap_no
*                IMPORTING
*                  output = lv_text.

              READ TABLE gt_account_info INTO gs_account_info  WITH KEY lifnr = ls_out_cx-lifnr.

              CONCATENATE TEXT-tr2 lv_text '-' gs_account_info-name1
              INTO gs_out_c-name SEPARATED BY space.

              gs_out_c-ktokl = gs_account_info-ktokk.

          ENDCASE.

          IF gs_adrs-no_general IS NOT INITIAL.
            CLEAR gs_out_c-telfx.
          ENDIF.

          COLLECT gs_out_c INTO gt_out_c.

        ENDLOOP.

      ENDLOOP.

    ENDIF.

* BELIRTILEN TARIHE GÖRE HAREKET GÖRMEMIŞ CARILERI SIL
* (SADECE BAKIYESIZLER IÇIN)
* p_budat2
    IF p_date IS NOT INITIAL AND p_bsiz IS NOT INITIAL.

      LOOP AT gt_balance INTO ls_balance WHERE dmbtr EQ 0.

        CLEAR: lv_opening_rc, lv_closing_rc.

        READ TABLE gt_out_c INTO gs_out_c WITH KEY kunnr = ls_balance-kunnr
                                                   lifnr = ls_balance-lifnr.

        CASE gs_out_c-hesap_tur.
          WHEN 'M'.

            check_bsid( EXPORTING iv_kunnr      = gs_out_c-hesap_no
                                  iv_budat      = p_date
                        CHANGING  cv_closing_rc = lv_opening_rc ).

            check_bsad( EXPORTING iv_kunnr      = gs_out_c-hesap_no
                                  iv_budat      = p_date
                        CHANGING  cv_closing_rc = lv_closing_rc ).

            IF lv_opening_rc IS NOT INITIAL AND
               lv_closing_rc IS NOT INITIAL.

*              CALL METHOD go_log->bal_log_msg_add   "YiğitcanÖzdemir
*                EXPORTING
*                  i_type       = /itetr/reco_if_common_types=>mc_msg_w
*                  i_no         = '178'
*                  i_id         = /itetr/reco_if_common_types=>mc_msg_class
*                  i_v1         = gs_out_c-hesap_no
*                  i_v2         = TEXT-tr1
*                  i_v3         = p_date
*                  i_v4         = '2'
*                  i_log_handle = gv_log_handle
*                EXCEPTIONS
*                  OTHERS       = 1.

              DELETE gt_out_c WHERE hesap_tur = gs_out_c-hesap_tur
                                AND hesap_no = gs_out_c-hesap_no.

              DELETE gt_balance.

*              CONTINUE.  "YiğitcanÖzdemir
            ENDIF.

          WHEN 'S'.

            check_bsik( EXPORTING iv_lifnr      = gs_out_c-hesap_no
                                  iv_budat      = p_date
                        CHANGING  cv_closing_rc = lv_opening_rc ).

            check_bsak( EXPORTING iv_lifnr      = gs_out_c-hesap_no
                                  iv_budat      = p_date
                        CHANGING  cv_closing_rc = lv_closing_rc ).

            IF lv_opening_rc IS NOT INITIAL AND
               lv_closing_rc IS NOT INITIAL.

*              CALL METHOD go_log->bal_log_msg_add    "YiğitcanÖzdemir
*                EXPORTING
*                  i_type       = /itetr/reco_if_common_types=>mc_msg_w
*                  i_no         = '178'
*                  i_id         = /itetr/reco_if_common_types=>mc_msg_class
*                  i_v1         = gs_out_c-hesap_no
*                  i_v2         = TEXT-tr2
*                  i_v3         = p_date
*                  i_v4         = '2'
*                  i_log_handle = gv_log_handle
*                EXCEPTIONS
*                  OTHERS       = 1.

              DELETE gt_out_c WHERE hesap_tur = gs_out_c-hesap_tur
                                AND hesap_no = gs_out_c-hesap_no.

              DELETE gt_balance.

*              CONTINUE.   "YiğitcanÖzdemir
            ENDIF.
        ENDCASE.
      ENDLOOP.
    ENDIF.

* BELIRTILEN BAKIYEYE GÖRE ALTıNDA KALANLARı SIL
*    IF p_dmbtr IS NOT INITIAL.                                     "YiğitcanÖzdemir
*
*      LOOP AT gt_balance INTO gs_balance WHERE dmbtr NE 0.
*
*        IF abs( gs_balance-dmbtr ) LT p_dmbtr.
*
*          IF gs_balance-kunnr IS NOT INITIAL.
*            CALL METHOD go_log->bal_log_msg_add
*              EXPORTING
*                i_type       = /itetr/reco_if_common_types=>mc_msg_w
*                i_no         = '181'
*                i_id         = /itetr/reco_if_common_types=>mc_msg_class
*                i_v1         = gs_balance-kunnr
*                i_v2         = TEXT-tr1
*                i_v3         = p_dmbtr
*                i_v4         = ''
*                i_log_handle = gv_log_handle
*              EXCEPTIONS
*                OTHERS       = 1.
*          ELSE.
*            CALL METHOD go_log->bal_log_msg_add
*              EXPORTING
*                i_type       = /itetr/reco_if_common_types=>mc_msg_w
*                i_no         = '181'
*                i_id         = /itetr/reco_if_common_types=>mc_msg_class
*                i_v1         = gs_balance-lifnr
*                i_v2         = TEXT-tr2
*                i_v3         = p_dmbtr
*                i_v4         = ''
*                i_log_handle = gv_log_handle
*              EXCEPTIONS
*                OTHERS       = 1.
*          ENDIF.
*
*          DELETE gt_out_c WHERE kunnr = gs_balance-kunnr
*                            AND lifnr = gs_balance-lifnr.
*
*          DELETE gt_balance.
*
*          CONTINUE.
*
*        ENDIF.
*
*      ENDLOOP.
*
*    ENDIF.


* İHTAR VAR ISE 0 VE TERS BAKIYELERI SIL
    SELECT SINGLE * FROM zreco_ftyp
      WHERE ftype EQ @p_ftype
      AND dunning EQ 'X'
                          INTO @ls_ftyp.

    IF sy-subrc EQ 0.

      LOOP AT gt_balance INTO gs_balance WHERE dmbtr LE 0.

        IF gs_balance-kunnr IS NOT INITIAL.
*          CALL METHOD go_log->bal_log_msg_add                    "YiğitcanÖzdemir
*            EXPORTING
*              i_type       = /itetr/reco_if_common_types=>mc_msg_w
*              i_no         = '182'
*              i_id         = /itetr/reco_if_common_types=>mc_msg_class
*              i_v1         = gs_balance-kunnr
*              i_v2         = TEXT-tr1
*              i_v3         = ''
*              i_v4         = ''
*              i_log_handle = gv_log_handle
*            EXCEPTIONS
*              OTHERS       = 1.
        ENDIF.

        DELETE gt_out_c WHERE kunnr = gs_balance-kunnr
                          AND lifnr = gs_balance-lifnr.

        DELETE gt_balance.

        CONTINUE.

      ENDLOOP.

    ENDIF.


* ALACAK BAKIYESI VEREN MÜŞTERILERI SIL
    IF p_cred IS NOT INITIAL.

      LOOP AT gt_balance INTO gs_balance WHERE kunnr IS NOT INITIAL
                           AND dmbtr LE 0.

*        CALL METHOD go_log->bal_log_msg_add             "YiğitcanÖzdemir
*          EXPORTING
*            i_type       = /itetr/reco_if_common_types=>mc_msg_w
*            i_no         = '183'
*            i_id         = /itetr/reco_if_common_types=>mc_msg_class
*            i_v1         = gs_balance-kunnr
*            i_v2         = TEXT-tr1
*            i_v3         = ''
*            i_v4         = ''
*            i_log_handle = gv_log_handle
*          EXCEPTIONS
*            OTHERS       = 1.
        DELETE gt_out_c WHERE kunnr = gs_balance-kunnr
                          AND lifnr = gs_balance-lifnr.

        DELETE gt_balance.

        CONTINUE.

      ENDLOOP.

    ENDIF.

* son mutabakat kontrolü
    IF p_last IS NOT INITIAL.

      LOOP AT gt_out_c INTO gs_out_c.

        CLEAR: gs_h001, gs_last_info, lv_opening_rc, lv_closing_rc.

        MOVE-CORRESPONDING gs_out_c TO gs_h001.

        gs_h001-bukrs = gs_adrs-bukrs.
        gs_h001-monat = p_period.
        gs_h001-gjahr = p_gjahr.

*        CALL FUNCTION '/ITETR/RECO_LST_COMPARE_DATE_2'         "YiğitcanÖzdemir
*          EXPORTING
*            is_h001     = gs_h001
*            i_last      = p_last
*          IMPORTING
*            e_last_info = gs_last_info.

        CHECK gs_last_info-mresult EQ 'E'. "MUTABıK ISE

        IF gs_last_info IS NOT INITIAL.

          CASE gs_out_c-hesap_tur.
            WHEN 'M'.


              check_bsid( EXPORTING iv_kunnr      = gs_out_c-hesap_no
                                    iv_budat      = gs_last_info-last_date
                          CHANGING  cv_closing_rc = lv_opening_rc ).

              check_bsad( EXPORTING iv_kunnr      = gs_out_c-hesap_no
                                    iv_budat      = gs_last_info-last_date
                          CHANGING  cv_closing_rc = lv_closing_rc ).
              IF lv_opening_rc IS NOT INITIAL AND
                 lv_closing_rc IS NOT INITIAL.

*                CALL METHOD go_log->bal_log_msg_add                "YiğitcanÖzdemir
*                  EXPORTING
*                    i_type       = /itetr/reco_if_common_types=>mc_msg_w
*                    i_no         = '184'
*                    i_id         = /itetr/reco_if_common_types=>mc_msg_class
*                    i_v1         = gs_out_c-hesap_no
*                    i_v2         = TEXT-tr1
*                    i_v3         = ''
*                    i_v4         = ''
*                    i_log_handle = gv_log_handle
*                  EXCEPTIONS
*                    OTHERS       = 1.
                DELETE gt_out_c WHERE hesap_tur = gs_out_c-hesap_tur
                                  AND hesap_no = gs_out_c-hesap_no.

                CONTINUE.
              ENDIF.

            WHEN 'S'.


              check_bsik( EXPORTING iv_lifnr      = gs_out_c-hesap_no
                                    iv_budat      = gs_last_info-last_date
                          CHANGING  cv_closing_rc = lv_opening_rc ).

              check_bsak( EXPORTING iv_lifnr      = gs_out_c-hesap_no
                                    iv_budat      = gs_last_info-last_date
                          CHANGING  cv_closing_rc = lv_closing_rc ).

              IF lv_opening_rc IS NOT INITIAL AND
                 lv_closing_rc IS NOT INITIAL.

*                CALL METHOD go_log->bal_log_msg_add "YiğitcanÖzdemir
*                  EXPORTING
*                    i_type       = /itetr/reco_if_common_types=>mc_msg_w
*                    i_no         = '184'
*                    i_id         = /itetr/reco_if_common_types=>mc_msg_class
*                    i_v1         = gs_out_c-hesap_no
*                    i_v2         = TEXT-tr2
*                    i_v3         = ''
*                    i_v4         = ''
*                    i_log_handle = gv_log_handle
*                  EXCEPTIONS
*                    OTHERS       = 1.

                DELETE gt_out_c WHERE hesap_tur = gs_out_c-hesap_tur
                                  AND hesap_no = gs_out_c-hesap_no.


                CONTINUE.
              ENDIF.

          ENDCASE.

        ENDIF.

      ENDLOOP.

    ENDIF.

* liste son hali
    LOOP AT gt_out_c ASSIGNING <fs_out_c>.

      IF p_waers IS NOT INITIAL.
        READ TABLE gt_w001 TRANSPORTING NO FIELDS
        WITH KEY bukrs = gs_adrs-bukrs
                 monat = p_period
                 gjahr = p_gjahr
                 hesap_tur = <fs_out_c>-hesap_tur
                 hesap_no = <fs_out_c>-hesap_no
                 waers = <fs_out_c>-waers.

        IF sy-subrc EQ 0.

          CASE <fs_out_c>-hesap_tur.
            WHEN 'M'.
*            CALL METHOD go_log->bal_log_msg_add         "YiğitcanÖzdemir
*              EXPORTING
*                i_type       = /itetr/reco_if_common_types=>mc_msg_w
*                i_no         = '185'
*                i_id         = /itetr/reco_if_common_types=>mc_msg_class
*                i_v1         = <fs_out_c>-hesap_no
*                i_v2         = TEXT-tr1
*                i_v3         = <fs_out_c>-waers
*                i_v4         = ''
*                i_log_handle = gv_log_handle
*              EXCEPTIONS
*                OTHERS       = 1.

            WHEN 'S'.
*            CALL METHOD go_log->bal_log_msg_add          "YiğitcanÖzdemir
*              EXPORTING
*                i_type       = /itetr/reco_if_common_types=>mc_msg_w
*                i_no         = '185'
*                i_id         = /itetr/reco_if_common_types=>mc_msg_class
*                i_v1         = <fs_out_c>-hesap_no
*                i_v2         = TEXT-tr2
*                i_v3         = <fs_out_c>-waers
*                i_v4         = ''
*                i_log_handle = gv_log_handle
*              EXCEPTIONS
*                OTHERS       = 1.
          ENDCASE.

          DELETE gt_out_c.
          CONTINUE.
        ENDIF.
      ENDIF.

      READ TABLE gt_atxt INTO gs_atxt
      WITH KEY spras = <fs_out_c>-spras
               akont = <fs_out_c>-akont
                xsum = <fs_out_c>-xsum.

      IF sy-subrc EQ 0.
        <fs_out_c>-ltext = gs_atxt-ltext_.

      ENDIF.

      IF p_exch IS NOT INITIAL ."AND <fs_out_c>-waers NE t001-waers. "YiğitcanÖzdemir

        CLEAR gs_exch_rate.

        READ TABLE gt_exch_rate INTO gs_exch_rate
        WITH KEY from_curr = <fs_out_c>-waers.

        IF sy-subrc EQ 0.

          IF gs_exch_rate-from_factor EQ 0.
            gs_exch_rate-from_factor = 1.
          ENDIF.

          <fs_out_c>-kursf = gs_exch_rate-exch_rate /
                             gs_exch_rate-from_factor.
        ENDIF.

      ENDIF.

*    IF p_submit IS INITIAL. "YiğitcanÖzdemir

*      clear gt_receivers.


      READ TABLE gt_added INTO gs_added WITH KEY send_type = 'E'
                                   kunnr = <fs_out_c>-kunnr
                                   lifnr = <fs_out_c>-lifnr.

      IF sy-subrc NE 0.

        DATA lo_zreco_common1  TYPE REF TO zreco_common.
        CREATE OBJECT lo_zreco_common1.

        lo_zreco_common1->zreco_to_mail_adrs(
          EXPORTING
              i_bukrs      = gs_adrs-bukrs
              i_ucomm      = ''
              i_kunnr      = <fs_out_c>-kunnr
              i_lifnr      = <fs_out_c>-lifnr
              i_abtnr      = gv_abtnr
              i_pafkt      = gv_pafkt
              i_remark     = gv_remark
              i_all        = p_all
              i_stcd1      = <fs_out_c>-vkn_tckn
              i_no_general = gs_adrs-no_general
              i_mtype      = gv_mtype
          IMPORTING
             e_mail       = <fs_out_c>-email
             t_receivers  = gt_receivers
        ).


*        CALL FUNCTION '/ITETR/RECO_TO_MAIL_ADRS'
*          EXPORTING
*            i_bukrs      = gs_adrs-bukrs
*            i_kunnr      = <fs_out_c>-kunnr
*            i_lifnr      = <fs_out_c>-lifnr
*            i_abtnr      = gv_abtnr
*            i_pafkt      = gv_pafkt
*            i_remark     = gv_remark
*            i_all        = p_all
*            i_stcd1      = <fs_out_c>-vkn_tckn
*            i_no_general = gs_adrs-no_general
*            i_mtype      = gv_mtype
*          IMPORTING
*            e_mail       = <fs_out_c>-email
*          TABLES
*            t_receivers  = gt_receivers.

        CLEAR lv_tabix.

        LOOP AT gt_receivers INTO gs_receivers.    "YiğitcanÖzdemir

          lv_tabix = lv_tabix + 1.

          READ TABLE gt_e002 TRANSPORTING NO FIELDS
          WITH KEY receiver = gs_receivers-receiver.

          IF sy-subrc EQ 0.
*            CALL METHOD go_log->bal_log_msg_add
*              EXPORTING
*                i_type       = /itetr/reco_if_common_types=>mc_msg_e
*                i_no         = '205'
*                i_id         = /itetr/reco_if_common_types=>mc_msg_class
*                i_v1         = gs_receivers-receiver
*                i_v2         = ''
*                i_v3         = ''
*                i_v4         = ''
*                i_log_handle = gv_log_handle
*              EXCEPTIONS
*                OTHERS       = 1.
            DELETE gt_receivers.
*
            CONTINUE.
*
          ENDIF.

          CLEAR gs_mail_list.

          MOVE-CORRESPONDING <fs_out_c> TO gs_mail_list.
          MOVE-CORRESPONDING gs_receivers TO gs_mail_list.

          gs_mail_list-bukrs = gs_adrs-bukrs.
          gs_mail_list-monat = p_period.
          gs_mail_list-gjahr = p_gjahr.
          gs_mail_list-posnr = lv_tabix.

          INSERT gs_mail_list INTO TABLE gt_mail_list.

        ENDLOOP.

        MOVE-CORRESPONDING <fs_out_c> TO gs_added.

        gs_added-send_type = 'E'.

        APPEND gs_added TO gt_added.
        CLEAR gs_added.

      ELSE.

        READ TABLE gt_mail_list INTO gs_mail_list WITH KEY kunnr = <fs_out_c>-kunnr
                                         lifnr = <fs_out_c>-lifnr.

        IF sy-subrc EQ 0.
          <fs_out_c>-email = gs_mail_list-receiver.
        ENDIF.


      ENDIF.

      CLEAR gt_receivers.

      CLEAR ls_out_c.

*      CALL FUNCTION '/ITETR/RECO_EXIT_004'
*        EXPORTING
*          i_bukrs  = gs_adrs-bukrs
*          i_period = p_period
*          i_gjahr  = p_gjahr
*          is_cform = <fs_out_c>
*        IMPORTING
*          es_cform = ls_out_c.

      IF ls_out_c IS NOT INITIAL.
        <fs_out_c> = ls_out_c.
      ENDIF.

      DELETE FROM zreco_tmpc
      WHERE bukrs EQ @gs_adrs-bukrs
      AND monat EQ @p_period
      AND gjahr EQ @p_gjahr
      AND hesap_tur EQ @<fs_out_c>-hesap_tur
      AND hesap_no EQ @<fs_out_c>-hesap_no
      AND ftype EQ @p_ftype.

      DELETE FROM zreco_tmpe WHERE       bukrs EQ @gs_adrs-bukrs
                                     AND monat EQ @p_period
                                     AND gjahr EQ @p_gjahr
                                     AND kunnr EQ @<fs_out_c>-kunnr
                                     AND lifnr EQ @<fs_out_c>-lifnr.

      CLEAR gs_temp_c.

      MOVE-CORRESPONDING <fs_out_c> TO gs_temp_c.

      gs_temp_c-bukrs = gs_adrs-bukrs.
      gs_temp_c-monat = p_period.
      gs_temp_c-gjahr = p_gjahr.
      gs_temp_c-ftype = p_ftype.

      INSERT gs_temp_c INTO TABLE gt_temp_c.

*    ENDIF.

    ENDLOOP.

    IF sy-subrc EQ 0    ."AND p_verzn IS NOT INITIAL.   "YiğitcanÖzdemir
      SELECT * FROM zreco_cdun
      FOR ALL ENTRIES IN @gt_out_c
        WHERE bukrs EQ @gs_adrs-bukrs
        AND hesap_tur EQ @gt_out_c-hesap_tur
        AND hesap_no EQ @gt_out_c-hesap_no
         INTO TABLE @gt_cdun
        .

      LOOP AT gt_cdun INTO gs_cdun.

        gs_dunning_times-hesap_no = gs_cdun-hesap_no.
        gs_dunning_times-belnr = gs_cdun-belnr.
        gs_dunning_times-buzei = gs_cdun-buzei.
        gs_dunning_times-bldat = gs_cdun-bldat.
        gs_dunning_times-count_dunning = 1.

        COLLECT gs_dunning_times INTO gt_dunning_times.

      ENDLOOP.

    ENDIF.

*    IF p_submit IS INITIAL. "YiğitcanÖzdemir

    COMMIT WORK AND WAIT.

    IF gt_temp_c[] IS NOT INITIAL.
      MODIFY zreco_tmpc FROM TABLE @gt_temp_c.
    ENDIF.

*      DELETE ADJACENT DUPLICATES FROM gt_mail_list           "YiğitcanÖzdemir
*      COMPARING kunnr lifnr receiver.

*      IF gt_mail_list[] IS NOT INITIAL.           "YiğitcanÖzdemir
**        MODIFY /itetr/reco_tmpe FROM TABLE gt_mail_list.
*      ENDIF.

    IF gt_bsid_temp[] IS NOT INITIAL.
      MODIFY zreco_tbsd FROM TABLE @gt_bsid_temp.
    ENDIF.

*    ENDIF.

  ENDMETHOD.