  METHOD zreco_pdf_preview.

    DATA: ls_h001       TYPE zreco_hdr,
          lt_h001       TYPE TABLE OF zreco_hdr,
          lv_only_loc   TYPE abap_boolean,
          lv_line       TYPE int2,
          lv_repeat     TYPE int2,
          lc_repeat     TYPE char05,
          lv_screen     TYPE abap_boolean,
          lv_subject    TYPE string,
          ls_result     TYPE zreco_soodk,
          ls_remd       TYPE zreco_rmd,
          lt_remd       TYPE TABLE OF zreco_rmd,
          lt_cform      TYPE TABLE OF zreco_rcai,
          lt_cdun       TYPE TABLE OF zreco_cdun,
          ls_cdun       TYPE zreco_cdun,
          lv_tcount     TYPE int4,
          lv_count      TYPE int4,
          lt_save_files TYPE zreco_tt_down_files,
          ls_save_files TYPE zreco_s_down_files,
          lv_xstring    TYPE xstring,
          lv_lenght     TYPE i,
          lt_lines      TYPE TABLE OF zreco_tline,
          lt_line       TYPE TABLE OF zreco_tline,
          lv_tdname     TYPE char72.

    DATA: BEGIN OF lt_temp,
            ltext TYPE text100,
          END OF lt_temp.


    DATA: gs_doc_info        TYPE zreco_ssfcrespd,                           "DMBAYEL commentlenmiştir
          gs_job_info        TYPE zreco_ssfcrescl,
*          gs_job_options    TYPE ssfcresop,
          gs_control_options TYPE zreco_ssfctrlop,
          gs_output_options  TYPE zreco_ssfcompop,
          gv_sf_name         TYPE char72,   "Smartform adı
          gv_fm_name         TYPE char72. "Fonksiyon adı
*          gv_otf            TYPE abap_boolean.

    DATA: gs_adrs  TYPE zreco_adrs, "Şirket adres bilgileri
          gt_tole  TYPE TABLE OF zreco_tole, "Vkn bazında tolerason
          gt_text  TYPE TABLE OF zreco_text, "Başlık metinleri
          gs_text  TYPE zreco_text, "Mutabakat web iletileri
          gs_htxt  TYPE zreco_htxt, "Mutabakat form metinleri
          gt_htxt  TYPE TABLE OF zreco_htxt, "Başlık metinleri
          gs_dtxt  TYPE zreco_dtxt, "Ihtar form metinleri
          gt_dtxt  TYPE TABLE OF zreco_dtxt, "Ihtar form metinleri
          gs_otxt  TYPE zreco_otxt, "Açık kalem metinleri
          gt_otxt  TYPE TABLE OF zreco_otxt, "Açık kalem metinleri
          gt_atxt  TYPE TABLE OF zreco_atxt, "Hesap metinleri
          gt_gsbr  TYPE SORTED TABLE OF zreco_gsbr
                   WITH NON-UNIQUE KEY gsber, "İş alanı tanımları
          gs_gsbr  TYPE zreco_gsbr,
          gs_atxt  TYPE zreco_atxt,
          gs_adrc  TYPE zreco_adrc,
          gt_adrc  TYPE TABLE OF zreco_adrc,
          gt_flds  TYPE TABLE OF zreco_flds,
          gs_flds  TYPE zreco_flds,
          gs_parm  TYPE zreco_parm,
          gt_uname TYPE TABLE OF zreco_unam.

    DATA: gt_bank TYPE TABLE OF zreco_bank.

    DATA: gt_h001      TYPE SORTED TABLE OF zreco_hdr
                     WITH NON-UNIQUE KEY bukrs mnumber monat gjahr
                                     hesap_tur hesap_no
          , "Gönderim başlık verisi
          gs_h001      TYPE zreco_hdr,
          gt_h002      TYPE SORTED TABLE OF zreco_hia
                       WITH NON-UNIQUE KEY bukrs mnumber monat gjahr
                                       hesap_tur hesap_no
          , "Cevap başlık verisi
          gs_h002      TYPE zreco_hia,
          gt_w001      TYPE SORTED TABLE OF zreco_rboc
                       WITH NON-UNIQUE KEY bukrs mnumber monat gjahr
                                       hesap_tur hesap_no
          , "Gönderim PB bazında bilgiler
          gs_w001      TYPE zreco_rboc,
          gt_v001      TYPE SORTED TABLE OF zreco_vers
                       WITH NON-UNIQUE KEY bukrs mnumber monat gjahr,
          gs_v001      TYPE zreco_vers, "Versiyon
          gt_b001      TYPE SORTED TABLE OF zreco_recb
                       WITH NON-UNIQUE KEY bukrs mnumber monat gjahr
                                           kunnr lifnr
          ,
          gs_b001      TYPE zreco_recb,
          gt_c001      TYPE SORTED TABLE OF zreco_rcai
                       WITH NON-UNIQUE KEY bukrs mnumber monat gjahr
                                           kunnr lifnr waers
          ,
          gs_c001      TYPE zreco_rcai,
          gt_e001      TYPE SORTED TABLE OF zreco_refi
                       WITH NON-UNIQUE KEY bukrs mnumber monat gjahr
                                           hesap_tur hesap_no
          ,
          gs_e001      TYPE zreco_refi,
          gt_e002      TYPE SORTED TABLE OF zreco_urei
                       WITH NON-UNIQUE KEY receiver
          ,
          gt_e003      TYPE SORTED TABLE OF zreco_eate
                       WITH NON-UNIQUE KEY smtp_addr
          ,
          gs_e002      TYPE zreco_urei,
          gs_d002      TYPE zreco_dsdr, "Şüpheli alacaklar
          gt_r000      TYPE SORTED TABLE OF zreco_reia
                       WITH NON-UNIQUE KEY mnumber monat gjahr version,
          gs_r000      TYPE zreco_reia,
          gt_r001      TYPE SORTED TABLE OF zreco_rcar
                       WITH NON-UNIQUE KEY mnumber monat gjahr version,
          gs_r001      TYPE zreco_rcar,
          gt_r002      TYPE SORTED TABLE OF zreco_rbia
                       WITH NON-UNIQUE KEY mnumber monat gjahr version,
          gt_user      TYPE SORTED TABLE OF zreco_cvua
                       WITH NON-UNIQUE KEY kunnr lifnr,
          gs_user      TYPE zreco_cvua,
          gs_r002      TYPE zreco_rbia,
          gv_bukrs     TYPE bukrs, "Şirket kodu
          gv_spras     TYPE spras, "İletişim dili
          gv_langu     TYPE spras VALUE 'T', "Ekran iletişim dili
          gv_auth      TYPE abap_boolean,  "Yetki kontrolü
          gv_odk       TYPE abap_boolean,  "ÖDK mutabakatı da var
          gv_kur       TYPE abap_boolean,  "Kur var
          gv_loc_dmbtr TYPE zreco_tslxx12, "Toplam UPB tutarı
          gv_spl_dmbtr TYPE zreco_tslxx12. "Toplam ÖDK tutarı

    DATA:  gt_taxm TYPE SORTED TABLE OF zreco_taxm
                   WITH NON-UNIQUE KEY kunnr lifnr,
           gs_taxm TYPE zreco_taxm.

    DATA:  gv_mail_send  TYPE abap_boolean.

    DATA  : gv_first_date TYPE d, "Dönem ilk tarih
            gv_last_date  TYPE d, "Dönem son tarih
            gv_send       TYPE abap_boolean, "Gönderim yapılmış
            gv_mnumber    TYPE zreco_number,
            gv_b_sel      TYPE zreco_date_selection,
            "B formu tarih seçimi
            gv_c_sel      TYPE zreco_date_selection.

    DATA: gt_cform_sf TYPE TABLE OF zreco_cform_sform,
          gs_cform_sf TYPE zreco_cform_sform.

*<--- E-mail gereki tanımlamalar
    DATA: gt_receivers           TYPE TABLE OF zreco_somlreci1,
          gs_receivers           TYPE zreco_somlreci1,
          gt_mail_list           TYPE SORTED TABLE OF zreco_tmpe
                                 WITH NON-UNIQUE KEY kunnr lifnr receiver,
          gs_mail_list           LIKE LINE OF gt_mail_list,
          gt_body                TYPE TABLE OF zreco_solisti1,
          gv_subject             TYPE string, "Mail konusu
          gv_obj_descr           TYPE char72, "SOST doküman adı
          gv_attach_name         TYPE char72, "Ek adı
          gv_sender_name         TYPE char256, "Gönderen adı
          gv_sender_address      TYPE zreco_ad_smtpadr, "Gönderen adresi
          gv_from_adress         TYPE char256,
          gv_sender_address_type TYPE char05,
          gs_return              TYPE bapiret2.

    TYPES: BEGIN OF ty_cform,
             hesap_tur TYPE zreco_account_type,
             hesap_no  TYPE zreco_ktonr_av,
             waers     TYPE waers,
             kunnr     TYPE kunnr,
             lifnr     TYPE lifnr,
           END OF ty_cform.

* Cari mutabakat ALV veri
    DATA: gt_out_c         TYPE TABLE OF zreco_cform,
          gs_out_c         TYPE zreco_cform,
* Cari mutabakat geçici veri
          gt_cform_temp    TYPE TABLE OF zreco_cform_temp,
          gs_cform_temp    TYPE zreco_cform_temp,

          gt_cform         TYPE TABLE OF ty_cform  , "Seçim için
          gs_cform         TYPE ty_cform,

          gt_exch          TYPE TABLE OF zreco_exch,
          gs_exch          TYPE zreco_exch,
          gt_dunning       TYPE TABLE OF zreco_dunning,
          gs_dunning       TYPE zreco_dunning,
          gt_cdun          TYPE SORTED TABLE OF zreco_cdun WITH NON-UNIQUE KEY bukrs gjahr hesap_no belnr buzei,
          gs_cdun          TYPE zreco_cdun,
          gt_dunning_times TYPE TABLE OF zreco_dunning_times,
          gs_dunning_times TYPE zreco_dunning_times,
          gt_opening       TYPE TABLE OF zreco_opening,
          gs_opening       TYPE zreco_opening,
          gt_language      TYPE SORTED TABLE OF zreco_lang
                             WITH NON-UNIQUE KEY bukrs  .

* Mutabakat açık kalemler
    DATA : gt_bsid_temp TYPE TABLE OF zreco_tbsd,
           gs_bsid_temp TYPE zreco_tbsd.

    DATA: gt_note TYPE STANDARD TABLE OF zreco_note,
          gs_note TYPE zreco_note.

    DATA:gs_account TYPE zreco_account.
    DATA:gv_otf  TYPE abap_boolean.

    CLEAR:gs_output_options, gs_control_options, gs_job_info, gv_otf.

    CASE i_sort_indicator.
      WHEN '1'.
        SORT it_h001 BY mnumber.
      WHEN '2'.
        SORT it_h001 BY hesap_tur hesap_no.
      WHEN '3'.
        SORT it_h001 BY name1 AS TEXT.
      WHEN OTHERS.
    ENDCASE.

    READ TABLE it_h001 INTO ls_h001 INDEX 1.

    SELECT SINGLE * FROM i_companycode
    WHERE CompanyCode  EQ @ls_h001-bukrs
    INTO @DATA(ls_t001).

    SELECT SINGLE * FROM zreco_adrs
      WHERE bukrs EQ @ls_h001-bukrs
        AND gsber EQ @ls_h001-gsber
       INTO @gs_adrs.

* Form tipine göre özel form belirlenmiş mi?
    SELECT SINGLE tdsfname FROM zreco_frm
      WHERE bukrs EQ @ls_h001-bukrs
      AND ftype EQ @ls_h001-ftype
      AND spras EQ @ls_h001-spras
      INTO @gv_sf_name.

    IF sy-subrc NE 0.

* Form tipine göre özel form belirlenmiş mi?
      SELECT SINGLE tdsfname FROM zreco_frm
        WHERE bukrs EQ @ls_h001-bukrs
        AND ftype EQ @ls_h001-ftype
        INTO @gv_sf_name.

      IF sy-subrc NE 0.
*        gv_sf_name = '/ITETR/RECO_SF_FORM_001'.                                "D_MBAYEL commentlenmiştir.
      ENDIF.

    ENDIF.

    IF i_mail_send IS INITIAL.

      IF i_down IS INITIAL.
        gs_output_options-tddest     = ls_h001-padest.
        gs_control_options-preview   = 'X'.
        gs_control_options-no_dialog = 'X'.
        gs_control_options-no_open   = 'X'.
        gs_control_options-no_close  = 'X'.

*        CALL FUNCTION 'SSF_OPEN'                                                "D_MBAYEL commentlenmiştir.
*          EXPORTING
*            user_settings      = space
*            output_options     = gs_output_options
*            control_parameters = gs_control_options
*          EXCEPTIONS
*            formatting_error   = 1
*            internal_error     = 2
*            send_error         = 3
*            user_canceled      = 4
*            OTHERS             = 5.

      ELSE.
        gs_output_options-tddest = ls_h001-padest.

        gs_control_options-no_open   = space.
        gs_control_options-no_close  = 'X'.
        gs_control_options-getotf    = 'X'.
        gs_control_options-no_dialog = 'X'.

      ENDIF.
    ELSE.

      gv_otf = 'X'.

      lv_screen = 'X'.

      gs_control_options-device    = 'PRINTER'.
      gs_control_options-preview   = space.
      gs_control_options-no_dialog = 'X'.
      gs_output_options-tddest     = ls_h001-padest.
      gs_control_options-getotf    = 'X'.

    ENDIF.


*    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'                                                "D_MBAYEL commentlenmiştir.
*      EXPORTING
*        formname           = gv_sf_name
*      IMPORTING
*        fm_name            = gv_fm_name
*      EXCEPTIONS
*        no_form            = 1
*        no_function_module = 2
*        OTHERS             = 3.

    IF it_h001[] IS NOT INITIAL.

      CLEAR: gt_flds[], gt_htxt[], gt_dtxt[], gt_otxt[], gt_text[], gt_adrc[],
             gt_v001[], gt_c001[], gt_b001[], gt_r000[], gt_r001[], gt_r002[],
             gt_bank[], gt_e001[], gt_e002[], gt_e003[], gt_h002[].

      SELECT * FROM zreco_flds
        FOR ALL ENTRIES IN @it_h001
        WHERE hesap_tur EQ @it_h001-hesap_tur
        INTO TABLE @gt_flds.

      SELECT * FROM zreco_htxt
        FOR ALL ENTRIES IN @it_h001
        WHERE bukrs EQ @it_h001-bukrs
        AND spras   EQ @it_h001-spras
        AND mtype   EQ @it_h001-mtype
        AND ftype   EQ @it_h001-ftype
        INTO TABLE @gt_htxt.

      SELECT * FROM zreco_dtxt
        FOR ALL ENTRIES IN @it_h001
        WHERE bukrs EQ @it_h001-bukrs
        AND spras EQ @it_h001-spras
        AND ftype EQ @it_h001-ftype
        INTO TABLE @gt_dtxt.

      SELECT * FROM zreco_otxt
        FOR ALL ENTRIES IN @it_h001
        WHERE bukrs EQ @it_h001-bukrs
          AND spras EQ @it_h001-spras
          AND ftype EQ @it_h001-ftype
        INTO TABLE @gt_otxt.

      SELECT * FROM zreco_text
        FOR ALL ENTRIES IN @it_h001
        WHERE bukrs EQ @it_h001-bukrs
          AND gsber EQ @it_h001-gsber
          AND spras EQ @it_h001-spras
          AND hesap_tur EQ @it_h001-hesap_tur
        INTO TABLE @gt_text.

      SELECT * FROM zreco_ddl_i_address2
        FOR ALL ENTRIES IN @it_h001
        WHERE AddressID EQ @it_h001-adrnr
        INTO CORRESPONDING FIELDS OF TABLE @gt_adrc.

      SELECT * FROM zreco_hia
        FOR ALL ENTRIES IN @it_h001
          WHERE bukrs EQ @it_h001-bukrs
          AND gsber EQ @it_h001-gsber
          AND mnumber EQ @it_h001-mnumber
          AND monat EQ @it_h001-monat
          AND gjahr EQ @it_h001-gjahr
          AND hesap_tur EQ @it_h001-hesap_tur
          AND hesap_no EQ @it_h001-hesap_no
          INTO TABLE @gt_h002.

      SELECT * FROM zreco_vers
        FOR ALL ENTRIES IN @it_h001
        WHERE bukrs EQ @it_h001-bukrs
          AND gsber EQ @it_h001-gsber
          AND mnumber EQ @it_h001-mnumber
          AND monat  EQ @it_h001-monat
          AND gjahr  EQ @it_h001-gjahr
          AND vstatu EQ 'G'
        INTO TABLE @gt_v001.

      IF gt_v001[] IS NOT INITIAL.
        SELECT * FROM zreco_rcai
          FOR ALL ENTRIES IN @gt_v001
          WHERE bukrs EQ @gt_v001-bukrs
            AND gsber EQ @gt_v001-gsber
            AND mnumber EQ @gt_v001-mnumber
            AND monat EQ @gt_v001-monat
            AND gjahr EQ @gt_v001-gjahr
            AND version EQ @gt_v001-version
          INTO TABLE @gt_c001.

        SELECT * FROM zreco_recb
          FOR ALL ENTRIES IN @gt_v001
          WHERE bukrs EQ @gt_v001-bukrs
            AND gsber EQ @gt_v001-gsber
            AND mnumber EQ @gt_v001-mnumber
            AND monat EQ @gt_v001-monat
            AND gjahr EQ @gt_v001-gjahr
            AND version EQ @gt_v001-version
          INTO TABLE @gt_b001.

        SELECT * FROM zreco_reia
          FOR ALL ENTRIES IN @gt_v001
          WHERE bukrs EQ @gt_v001-bukrs
            AND gsber EQ @gt_v001-gsber
            AND mnumber EQ @gt_v001-mnumber
            AND monat EQ @gt_v001-monat
            AND gjahr EQ @gt_v001-gjahr
            AND version EQ @gt_v001-version
          INTO TABLE @gt_r000.

        SELECT * FROM zreco_rcar
          FOR ALL ENTRIES IN @gt_v001
          WHERE bukrs EQ @gt_v001-bukrs
            AND gsber EQ @gt_v001-gsber
            AND mnumber EQ @gt_v001-mnumber
            AND monat EQ @gt_v001-monat
            AND gjahr EQ @gt_v001-gjahr
            AND version EQ @gt_v001-version
          INTO TABLE @gt_r001.

        SELECT * FROM zreco_rbia
          FOR ALL ENTRIES IN @gt_v001
          WHERE bukrs EQ @gt_v001-bukrs
            AND gsber EQ @gt_v001-gsber
            AND mnumber EQ @gt_v001-mnumber
            AND monat EQ @gt_v001-monat
            AND gjahr EQ @gt_v001-gjahr
            AND version EQ @gt_v001-version
          INTO TABLE @gt_r002.

      ENDIF.

      IF i_mail_send IS NOT INITIAL.
        SELECT * FROM zreco_refi
          FOR ALL ENTRIES IN @it_h001
          WHERE bukrs EQ @it_h001-bukrs
            AND gsber EQ @it_h001-gsber
            AND mnumber EQ @it_h001-mnumber
            AND monat EQ @it_h001-monat
            AND gjahr EQ @it_h001-gjahr
            AND hesap_tur EQ @it_h001-hesap_tur
            AND hesap_no EQ @it_h001-hesap_no
            AND unsubscribe EQ ''
          INTO TABLE @gt_e001.

        SELECT * FROM zreco_urei
          FOR ALL ENTRIES IN @it_h001
          WHERE bukrs EQ @it_h001-bukrs
          AND gsber EQ @it_h001-gsber
          INTO TABLE @gt_e002.

        SELECT * FROM zreco_eate
          FOR ALL ENTRIES IN @it_h001
          WHERE bukrs EQ @it_h001-bukrs
          INTO TABLE @gt_e003.
      ENDIF.

    ENDIF.

* Banka bilgileri
    SELECT * FROM zreco_bank
      WHERE bukrs EQ @gs_adrs-bukrs
      INTO TABLE @gt_bank.

    lv_count = lines( it_h001 ).
    lv_count = 0.

    LOOP AT it_h001 INTO ls_h001.

      CLEAR: gs_flds, gs_htxt, gs_dtxt, gs_taxm, gs_adrc,
             gs_v001, et_return, gv_mail_send.

      lv_count = lv_count + 1.

      CONCATENATE ls_h001-gjahr ls_h001-monat '01' INTO gv_first_date.

      me->rp_last_day_of_months(
       EXPORTING
          day_in            = gv_first_date
        IMPORTING
          last_day_of_month = gv_last_date
*       EXCEPTIONS
*          day_in_no_date    = 1
      ).

* Versiyon
      READ TABLE gt_v001 INTO gs_v001
      WITH KEY bukrs = ls_h001-bukrs
               gsber = ls_h001-gsber
               mnumber = ls_h001-mnumber
               monat = ls_h001-monat
               gjahr = ls_h001-gjahr
               vstatu = 'G'.

* Form için kullanılan alanlar
      READ TABLE gt_flds INTO gs_flds
      WITH KEY hesap_tur = ls_h001-hesap_tur.

* Form metinleri
      READ TABLE gt_htxt INTO gs_htxt
      WITH KEY bukrs = ls_h001-bukrs
               spras = ls_h001-spras
               mtype = ls_h001-mtype
               ftype = ls_h001-ftype.

* İhtar metinleri
      READ TABLE gt_dtxt INTO gs_dtxt
      WITH KEY bukrs = ls_h001-bukrs
               spras = ls_h001-spras
               ftype = ls_h001-ftype.

* Açık kalem metinleri
      READ TABLE gt_otxt INTO gs_otxt
      WITH KEY bukrs = ls_h001-bukrs
               spras = ls_h001-spras
               ftype = ls_h001-ftype.

* Web ekran iletileri
      READ TABLE gt_text INTO gs_text
      WITH KEY bukrs = ls_h001-bukrs
               gsber = ls_h001-gsber
               spras = ls_h001-spras
               hesap_tur = ls_h001-hesap_tur.

* Web ekran iletileri

* Adres ve iletişim alanları
      MOVE-CORRESPONDING ls_h001 TO gs_adrc.

      READ TABLE gt_adrc INTO gs_adrc
      WITH KEY addrnumber = ls_h001-adrnr.

*      CLEAR gs_bform.                                                                              "D_MBAYEL B formu olmadığı için commentlenmiştir

* B Formu bilgileri
*      LOOP AT gt_b001 INTO gs_b001 WHERE bukrs EQ gs_v001-bukrs
*                                     AND gsber EQ gs_v001-gsber
*                                     AND mnumber EQ gs_v001-mnumber
*                                     AND monat EQ gs_v001-monat
*                                     AND gjahr EQ gs_v001-gjahr
*                                     AND version EQ gs_v001-version.
*
*        MOVE-CORRESPONDING gs_b001 TO gs_bform.
*
*      ENDLOOP.
*
*      LOOP AT gt_r002 INTO gs_r002 WHERE bukrs EQ gs_v001-bukrs
*                                     AND gsber EQ gs_v001-gsber
*                                     AND mnumber EQ gs_v001-mnumber
*                                     AND monat EQ gs_v001-monat
*                                     AND gjahr EQ gs_v001-gjahr
*                                     AND version EQ gs_v001-version.
*
*        gs_bform-count_bs_c = gs_r002-count_bs.
*        gs_bform-base_bs_c  = gs_r002-base_bs.
*        gs_bform-count_ba_c = gs_r002-count_ba.
*        gs_bform-base_ba_c  = gs_r002-base_ba.
*
*      ENDLOOP.
*
*      REFRESH: gt_exch, lt_cform.
*
*      CLEAR: gv_loc_dmbtr, gv_spl_dmbtr, gv_kur.

* Cari mutabakat bilgileri

      DATA: gs_temp TYPE  zreco_rcai. "YiğitcanÖzdemir

      LOOP AT gt_c001 INTO gs_c001 WHERE bukrs EQ gs_v001-bukrs
                                     AND gsber EQ gs_v001-gsber
                                     AND mnumber EQ gs_v001-mnumber
                                     AND monat EQ gs_v001-monat
                                     AND gjahr EQ gs_v001-gjahr
                                     AND version EQ gs_v001-version.

        CLEAR: lt_cform, gs_cform_sf.

        MOVE-CORRESPONDING ls_h001 TO gs_cform_sf.

        MOVE-CORRESPONDING gs_c001 TO gs_cform_sf.

        IF gs_cform_sf-wrbtr GE 0.
          gs_cform_sf-debit_credit = gs_htxt-debit_text.
        ENDIF.

        IF gs_cform_sf-wrbtr LT 0.
          gs_cform_sf-debit_credit = gs_htxt-credit_text.
        ENDIF.

        IF gs_c001-xsum IS NOT INITIAL.
          gv_loc_dmbtr = gv_loc_dmbtr + gs_cform_sf-dmbtr.
        ENDIF.

        IF gs_c001-xsum IS INITIAL.
          gv_spl_dmbtr = gv_spl_dmbtr + gs_cform_sf-dmbtr.
        ENDIF.

        IF gs_c001-kursf NE 0.
          READ TABLE gt_exch INTO gs_exch WITH KEY waers = gs_c001-waers.
          IF sy-subrc NE 0.
            gs_exch-buzei = 1.
*            gs_exch-hwaer = t001-waers.                                                "D_MBAYEL commentlenmiştir
            gs_exch-kursf = gs_c001-kursf.
            gs_exch-waers = gs_c001-waers.
            gv_kur = 'X'.
            APPEND gs_exch TO gt_exch.
          ENDIF.
        ENDIF.

        APPEND gs_c001 TO lt_cform. "YiğitcanÖzdemir
        MOVE-CORRESPONDING gt_c001 TO lt_cform.

        APPEND: gs_cform_sf TO gt_cform_sf.


        MOVE-CORRESPONDING gs_cform_sf TO gs_temp.
        APPEND gs_temp TO lt_cform.

      ENDLOOP.

      LOOP AT gt_r001 INTO gs_r001 WHERE bukrs EQ gs_v001-bukrs
                                     AND gsber EQ gs_v001-gsber
                                     AND mnumber EQ gs_v001-mnumber
                                     AND monat EQ gs_v001-monat
                                     AND gjahr EQ gs_v001-gjahr.

        LOOP AT gt_cform_sf INTO gs_cform_sf WHERE waers EQ gs_r001-waers AND xsum EQ 'X'.

          gs_cform_sf-dmbtr_c = gs_r001-dmbtr.
          gs_cform_sf-wrbtr_c = gs_r001-wrbtr.
          gs_cform_sf-waers_c = gs_r001-waers.

          IF gs_cform_sf-wrbtr_c GE 0.
            gs_cform_sf-debit_credit_c = gs_htxt-debit_text.
          ENDIF.

          IF gs_cform_sf-wrbtr_c LT 0.
            gs_cform_sf-debit_credit_c = gs_htxt-credit_text.
          ENDIF.

          MODIFY gt_cform_sf FROM gs_cform_sf.

        ENDLOOP.
      ENDLOOP.

      SORT gt_cform_sf BY ltext waers wrbtr .

* Cevap bilgileri
      LOOP AT gt_h002 INTO gs_h002 WHERE bukrs EQ gs_v001-bukrs
                                     AND gsber EQ gs_v001-gsber
                                     AND mnumber EQ gs_v001-mnumber
                                     AND monat EQ gs_v001-monat
                                     AND gjahr EQ gs_v001-gjahr.

        EXIT.

      ENDLOOP.

* İhtar kalemleri
      IF ls_h001-verzn IS NOT INITIAL.

        CLEAR: gt_bsid_temp[], gt_dunning[], gt_dunning_times ,
                 gt_cdun, lt_cdun.

        SELECT * FROM zreco_cdun
          WHERE bukrs EQ @ls_h001-bukrs
          AND hesap_tur EQ @ls_h001-hesap_tur
          AND hesap_no EQ @ls_h001-hesap_no
          INTO TABLE @gt_cdun.

        LOOP AT gt_cdun INTO gs_cdun.

          gs_dunning_times-hesap_no = gs_cdun-hesap_no.
          gs_dunning_times-belnr = gs_cdun-belnr.
          gs_dunning_times-buzei = gs_cdun-buzei.
          gs_dunning_times-bldat = gs_cdun-bldat.
          gs_dunning_times-count_dunning = 1.

          COLLECT gs_dunning_times INTO gt_dunning_times.

        ENDLOOP.

        SELECT * FROM zreco_tbsd
        WHERE bukrs EQ @ls_h001-bukrs
        AND p_monat EQ @ls_h001-monat
        AND p_gjahr EQ @ls_h001-gjahr
        AND hesap_tur EQ @ls_h001-hesap_tur
        AND hesap_no EQ @ls_h001-hesap_no
        AND ftype EQ @ls_h001-ftype
        INTO TABLE @gt_bsid_temp.

        LOOP AT gt_bsid_temp INTO gs_bsid_temp WHERE hesap_no EQ ls_h001-hesap_no.

          CLEAR: lt_cdun, gt_dunning.

          APPEND gs_bsid_temp TO gt_bsid_temp.
          APPEND ls_h001 TO lt_h001.
          MOVE-CORRESPONDING gt_bsid_temp TO lt_cdun.
          MOVE-CORRESPONDING lt_h001 TO lt_cdun.

          ls_cdun-gjahr_b = gs_bsid_temp-gjahr.
          ls_cdun-verzn = gs_bsid_temp-verzn.
          ls_cdun-mdatum = cl_abap_context_info=>get_system_date( ).

          MOVE-CORRESPONDING gs_cdun TO gs_dunning.

          COLLECT: gs_cdun INTO lt_cdun,
                   gs_dunning INTO gt_dunning.

        ENDLOOP.

        LOOP AT gt_dunning INTO gs_dunning.

          CLEAR gs_dunning_times.

          READ TABLE gt_dunning_times INTO gs_dunning_times
          WITH KEY hesap_no = ls_h001-hesap_no
                   belnr    = gs_dunning-belnr
                   bldat    = gs_dunning-bldat.

          gs_dunning-count_dunning = gs_dunning_times-count_dunning + 1.

          MODIFY gt_dunning FROM gs_dunning.

        ENDLOOP.

        SORT gt_dunning BY verzn DESCENDING.

      ENDIF.

      IF ls_h001-xopen IS NOT INITIAL.

        CLEAR: gt_bsid_temp[], gt_opening[].

        SELECT * FROM zreco_tbsd
          WHERE bukrs EQ @ls_h001-bukrs
          AND p_monat EQ @ls_h001-monat
          AND p_gjahr EQ @ls_h001-gjahr
          AND hesap_tur EQ @ls_h001-hesap_tur
          AND hesap_no EQ @ls_h001-hesap_no
          AND ftype EQ @ls_h001-ftype
          INTO TABLE @gt_bsid_temp.

        LOOP AT gt_bsid_temp INTO gs_bsid_temp WHERE hesap_no EQ ls_h001-hesap_no.

          CLEAR gt_opening.

          MOVE-CORRESPONDING gs_bsid_temp TO gs_opening.
          MOVE-CORRESPONDING ls_h001 TO gs_opening.

          IF gs_bsid_temp-verzn GT 0.
            gs_opening-verzn = gs_bsid_temp-verzn.
          ENDIF.

          COLLECT gs_opening INTO gt_opening.

        ENDLOOP.

        SORT gt_opening BY budat netdt.

      ENDIF.

      CLEAR: gv_odk, lv_only_loc.

* Gönderen iletişim bilgileri

      me->zreco_contact_m(
      EXPORTING
           is_adrs     = gs_adrs
          i_hesap_tur = ls_h001-hesap_tur
          i_hesap_no  = ls_h001-hesap_no
          i_ktokl     = ls_h001-ktokl
          i_mtype     = ls_h001-mtype
          i_ftype     = ls_h001-ftype
          i_uname     = gs_v001-ernam
      IMPORTING
          e_name      = gs_adrs-m_name
          e_telefon   = gs_adrs-m_telefon
          e_email     = gs_adrs-m_email
        ).

      IF gv_spl_dmbtr NE 0.
        gv_odk = 'X'.
      ENDIF.

      LOOP AT gt_cform_sf INTO gs_cform_sf WHERE xsum EQ 'X'.
*                           AND waers EQ t001-waers.                                    "D_MBAYEL commentlenmiştir
        lv_only_loc = 'X'.
        EXIT.
      ENDLOOP.

      LOOP AT gt_cform_sf INTO gs_cform_sf WHERE xsum EQ 'X'.                            "D_MBAYEL commentlenmiştir
*                           AND waers NE t001-waers.
        CLEAR lv_only_loc .
        EXIT.
      ENDLOOP.

      CLEAR: lt_line[], gt_note[].

      CLEAR lv_tdname.

      CONCATENATE 'ZRECO' ls_h001-bukrs ls_h001-mnumber
      INTO lv_tdname.

*      CALL FUNCTION 'READ_TEXT'                                                    "D_MBAYEL commentlenmiştir
*        EXPORTING
*          client                  = sy-mandt
*          id                      = 'ST'
*          language                = ls_h001-spras
*          name                    = lv_tdname
*          object                  = 'TEXT'
*        TABLES
*          lines                   = lt_line
*        EXCEPTIONS
*          id                      = 1
*          language                = 2
*          name                    = 3
*          not_found               = 4
*          object                  = 5
*          reference_check         = 6
*          wrong_access_to_archive = 7
*          OTHERS                  = 8.

      IF sy-subrc EQ 0.
        LOOP AT lt_line ASSIGNING FIELD-SYMBOL(<lfs_line>).
          gs_note-line = <lfs_line>-tdline.
          APPEND gs_note TO gt_note.
        ENDLOOP.
      ENDIF.

      CLEAR: gs_r000, gs_job_info.

      READ TABLE gt_r000 INTO gs_r000 WITH KEY bukrs = ls_h001-bukrs
                                               gsber = ls_h001-gsber
                                               mnumber = ls_h001-mnumber
                                               monat = ls_h001-monat
                                               gjahr = ls_h001-gjahr
                                              version = gs_v001-version.

      IF i_down IS NOT INITIAL.
        "Ayrı dosya indirecek veya çoklu dosyada son dosya ise KAPAT
        IF lv_count EQ lv_tcount OR i_down EQ 'S'.
          gs_control_options-no_close = space.
        ENDIF.

        "Birleşik dosya indirirken 1. den sonrakile için AÇMA
        IF i_down EQ 'P' AND lv_count > 1.
          gs_control_options-no_open = 'X'.
        ENDIF.
      ENDIF.

      "YiğitcanÖzdemir
      DATA : ls_Data TYPE zreco_s_pdf_data.
      DATA : lv_pdf_content TYPE xstring.
      DATA:    zreco_form TYPE REF TO zcl_reco_form_pdf.
*    CREATE OBJECT zreco_object.
      zreco_form = NEW zcl_reco_form_pdf( ).

      zreco_form->display(
   EXPORTING
               is_data = ls_Data
               IMPORTING
               ev_pdf_content =  lv_pdf_content
      ).

*      CALL FUNCTION gv_fm_name
*        EXPORTING
*          control_parameters = gs_control_options
*          output_options     = gs_output_options
*          user_settings      = space
*          i_bukrs            = gs_adrs-bukrs
*          i_gsber            = gs_adrs-gsber
*          i_budat            = gv_last_date
*          i_mnumber          = ls_h001-mnumber
*          i_langu            = ls_h001-spras
*          i_mtype            = ls_h001-mtype
*          i_ftype            = ls_h001-ftype
**         i_waers            = t001-waers                                  "D_MBAYEL commentlenmiştir
*          i_hesap_tur        = ls_h001-hesap_tur
*          i_hesap_no         = ls_h001-hesap_no
**         i_bform            = gs_bform                                    "D_MBAYEL commentlenmiştir
*          i_vkn_tckn         = ls_h001-vkn_tckn
*          i_vd               = ls_h001-vd
*          i_odk              = gv_odk
*          i_kur              = gv_kur
*          i_cevap_tarihi     = gs_r000-erdat
*          i_mresult          = gs_r000-mresult
*          i_wuser            = gs_h002-wuser
*          i_webip            = gs_h002-webip
*          i_mtext            = gs_r000-mtext
*          is_htxt            = gs_htxt
*          is_dtxt            = gs_dtxt
*          is_otxt            = gs_otxt
*          is_adrs            = gs_adrs
*          is_adrc            = gs_adrc
*          is_flds            = gs_flds
*          i_edit_date        = gs_v001-erdat
*          i_loc_dmbtr        = gv_loc_dmbtr
*          i_spl_dmbtr        = gv_spl_dmbtr
*          i_no_kursf         = gs_adrs-no_kursf
*          i_only_local       = lv_only_loc
*          i_no_local         = ls_h001-xno_local_curr
*          i_no_value         = ls_h001-xno_value
*          i_open             = ls_h001-xopen
*        IMPORTING
*          job_output_info    = gs_job_info
*        TABLES
*          it_note            = gt_note
*          it_cform           = gt_cform_sf
*          it_exch            = gt_exch
*          it_dunning         = gt_dunning
*          it_bank            = gt_bank
*          it_opening         = gt_opening
*        EXCEPTIONS
*          formatting_error   = 1
*          internal_error     = 2
*          send_error         = 3
*          user_canceled      = 4
*          OTHERS             = 5.

      IF sy-subrc NE 0.

        APPEND ls_remd TO lt_remd.
        APPEND gs_v001 TO gt_v001.
        APPEND ls_h001 TO lt_h001.

        MOVE-CORRESPONDING lt_remd TO et_return.
        MOVE-CORRESPONDING gt_v001 TO et_return.
        MOVE-CORRESPONDING lt_h001 TO et_return.

        LOOP AT et_return ASSIGNING FIELD-SYMBOL(<lfs_return>).
*          CALL FUNCTION 'FORMAT_MESSAGE'                                       "D_MBAYEL Commentlenmiştir
*            EXPORTING
*              id        = sy-msgid
*              lang      = sy-langu
*              no        = sy-msgno
*              v1        = sy-msgv1
*              v2        = sy-msgv2
*              v3        = sy-msgv3
*              v4        = sy-msgv4
*            IMPORTING
*              msg       = <lfs_return>-message
*            EXCEPTIONS
*              not_found = 1
*              OTHERS    = 2.

*        WRITE icon_red_light TO et_return-icon.                                    "D_MBAYEL Commentlenmiştir

          APPEND <lfs_return> TO et_return.

          CONTINUE.
        ENDLOOP.
      ENDIF.

      "Tekli dosya indirirken dosyaları ayrı ayrı topla
      IF i_down EQ 'S' AND gs_job_info-otfdata[] IS NOT INITIAL.
        CLEAR: lv_lenght, lv_xstring, lt_lines[], ls_save_files.

*        CALL FUNCTION 'CONVERT_OTF'                                        "D_MBAYEL Commentlenmiştir
*          EXPORTING
*            format                = 'PDF'
*          IMPORTING
*            bin_filesize          = lv_lenght
*            bin_file              = lv_xstring
*          TABLES
*            otf                   = gs_job_info-otfdata[]
*            lines                 = lt_lines[]
*          EXCEPTIONS
*            err_max_linewidth     = 1
*            err_format            = 2
*            err_conv_not_possible = 3
*            err_bad_otf           = 4
*            OTHERS                = 5.
*        IF sy-subrc <> 0.
*        ENDIF.

        IF i_fn_number IS INITIAL AND i_fn_account IS INITIAL AND i_fn_name IS INITIAL.
          CONCATENATE ls_h001-mnumber '.pdf' INTO ls_save_files-filename.

        ELSE.

          IF i_fn_number IS NOT INITIAL.
            ls_save_files-filename = ls_h001-mnumber.
          ENDIF.

          IF i_fn_account IS NOT INITIAL.

            ls_h001-hesap_no = | { gv_attach_name ALPHA = OUT } |.

            IF ls_save_files-filename IS NOT INITIAL.
              CONCATENATE ls_save_files-filename gv_attach_name INTO ls_save_files-filename SEPARATED BY '_'.
            ELSE.
              ls_save_files-filename = gv_attach_name.
            ENDIF.
          ENDIF.

          IF i_fn_name IS NOT INITIAL.
            IF ls_save_files-filename IS NOT INITIAL.
              CONCATENATE ls_save_files-filename ls_h001-name1(20) INTO ls_save_files-filename SEPARATED BY '_'.
            ELSE.
              ls_save_files-filename = ls_h001-name1(20).
            ENDIF.
          ENDIF.

          REPLACE ALL OCCURRENCES OF '.' IN ls_save_files-filename WITH space.
          REPLACE ALL OCCURRENCES OF '?' IN ls_save_files-filename WITH space.
          REPLACE ALL OCCURRENCES OF '"' IN ls_save_files-filename WITH space.
          REPLACE ALL OCCURRENCES OF '\' IN ls_save_files-filename WITH space.
          REPLACE ALL OCCURRENCES OF '/' IN ls_save_files-filename WITH space.
          REPLACE ALL OCCURRENCES OF ':' IN ls_save_files-filename WITH space.
          REPLACE ALL OCCURRENCES OF '>' IN ls_save_files-filename WITH space.
          REPLACE ALL OCCURRENCES OF '<' IN ls_save_files-filename WITH space.
          REPLACE ALL OCCURRENCES OF '|' IN ls_save_files-filename WITH space.

          CONCATENATE ls_save_files-filename '.pdf' INTO ls_save_files-filename.

        ENDIF.

        ls_save_files-filex  = lv_xstring.
        ls_save_files-lenght = lv_lenght.
        APPEND ls_save_files TO lt_save_files.CLEAR ls_save_files.
      ENDIF.

      IF i_mail_send IS NOT INITIAL.

        IF gs_r000-mresult IS NOT INITIAL.

          APPEND gs_v001 TO gt_v001.
          APPEND ls_h001 TO lt_h001.

          MOVE-CORRESPONDING gt_v001 TO et_return.
          MOVE-CORRESPONDING lt_h001 TO et_return.

          LOOP AT et_return ASSIGNING <lfs_return>.
*            CALL FUNCTION 'FORMAT_MESSAGE'                                         "D_MBAYEL Commentlenmiştir
*              EXPORTING
*                id        = 'ZRECO'
*                lang      = sy-langu
*                no        = '137'
*              IMPORTING
*                msg       = <lfs_return>-message
*              EXCEPTIONS
*                not_found = 1
*                OTHERS    = 2.

*          WRITE icon_red_light TO et_return-icon.                                  "D_MBAYEL commentlenmiştir.

            APPEND <lfs_return> TO et_return.

            CONTINUE.
          ENDLOOP.
        ENDIF.

        IF ls_h001-moutput NOT BETWEEN 'E' AND 'F'.

          APPEND gs_v001 TO gt_v001.
          APPEND ls_h001 TO lt_h001.

          MOVE-CORRESPONDING gt_v001 TO et_return.
          MOVE-CORRESPONDING lt_h001 TO et_return.

          LOOP AT et_return ASSIGNING <lfs_return>.
*            CALL FUNCTION 'FORMAT_MESSAGE'                                   "D_MBAYEL commentlenmiştir.
*              EXPORTING
*                id        = 'ZRECO'
*                lang      = sy-langu
*                no        = '137'
*              IMPORTING
*                msg       = <lfs_return>-message
*              EXCEPTIONS
*                not_found = 1
*                OTHERS    = 2.

*          WRITE icon_red_light TO et_return-icon.                                   "D_MBAYEL commentlenmiştir.
          ENDLOOP.
          CONTINUE.
        ENDIF.


        MOVE-CORRESPONDING ls_h001 TO gs_account.

* Yasaklı ve listeden çıkan adres kontrolü
        LOOP AT gt_e001 INTO gs_e001 WHERE bukrs EQ ls_h001-bukrs
                                       AND gsber EQ ls_h001-gsber
                                       AND mnumber EQ ls_h001-mnumber
                                       AND monat EQ ls_h001-monat
                                       AND gjahr EQ ls_h001-gjahr
                                       AND hesap_tur EQ ls_h001-hesap_tur
                                       AND hesap_no EQ ls_h001-hesap_no.

          READ TABLE gt_e003 TRANSPORTING NO FIELDS
          WITH KEY smtp_addr = gs_e001-receiver.

          IF sy-subrc EQ 0.

            APPEND gs_e001 TO gt_e001.
            APPEND gs_v001 TO gt_v001.
            APPEND ls_h001 TO lt_h001.

            MOVE-CORRESPONDING gt_e001 TO et_return.
            MOVE-CORRESPONDING gt_v001 TO et_return.
            MOVE-CORRESPONDING lt_h001 TO et_return.

            LOOP AT et_return ASSIGNING <lfs_return>.
*              CALL FUNCTION 'FORMAT_MESSAGE'                                                      "D_MBAYEL commentlenmiştir.
*                EXPORTING
*                  id        = 'ZRECO'
*                  lang      = sy-langu
*                  no        = '214'
*                  v1        = gs_e001-receiver
*                IMPORTING
*                  msg       = <lfs_return>-message
*                EXCEPTIONS
*                  not_found = 1
*                  OTHERS    = 2.

*            WRITE icon_red_light TO et_return-icon.                                                "D_MBAYEL commentlenmiştir.

              APPEND <lfs_return> TO et_return.
            ENDLOOP.
            DELETE gt_e001.

            CONTINUE.

          ENDIF.

          READ TABLE gt_e002 TRANSPORTING NO FIELDS
          WITH KEY receiver = gs_e001-receiver.

          IF sy-subrc EQ 0.

            MOVE-CORRESPONDING gt_e001 TO et_return.
            MOVE-CORRESPONDING gt_v001 TO et_return.
            MOVE-CORRESPONDING lt_h001 TO et_return.

            LOOP AT et_return ASSIGNING <lfs_return>.
*              CALL FUNCTION 'FORMAT_MESSAGE'                                                          "D_MBAYEL commentlenmiştir.
*                EXPORTING
*                  id        = 'ZRECO'
*                  lang      = sy-langu
*                  no        = '205'
*                  v1        = gs_e001-receiver
*                IMPORTING
*                  msg       = <lfs_return>-message
*                EXCEPTIONS
*                  not_found = 1
*                  OTHERS    = 2.

*              WRITE icon_red_light TO et_return-icon.                                                  "D_MBAYEL commentlenmiştir.

              APPEND <lfs_return> TO et_return.
            ENDLOOP.
            DELETE gt_e001.

            CONTINUE.
          ENDIF.

          EXIT.

        ENDLOOP.

        LOOP AT gt_e001 INTO gs_e001 WHERE bukrs EQ ls_h001-bukrs
                                       AND gsber EQ ls_h001-gsber
                                       AND mnumber EQ ls_h001-mnumber
                                       AND monat EQ ls_h001-monat
                                       AND gjahr EQ ls_h001-gjahr
                                       AND hesap_tur EQ ls_h001-hesap_tur
                                       AND hesap_no EQ ls_h001-hesap_no.

          EXIT.

        ENDLOOP.

        IF sy-subrc NE 0.

          APPEND gs_v001 TO gt_v001.
          APPEND ls_h001 TO lt_h001.

          MOVE-CORRESPONDING gt_v001 TO et_return.
          MOVE-CORRESPONDING lt_h001 TO et_return.

          LOOP AT et_return ASSIGNING <lfs_return>.
*            CALL FUNCTION 'FORMAT_MESSAGE'                                                                "D_MBAYEL commentlenmiştir.
*              EXPORTING
*                id        = 'ZRECO'
*                lang      = sy-langu
*                no        = '127'
*                v1        = ls_h001-mnumber
*              IMPORTING
*                msg       = <lfs_return>-message
*              EXCEPTIONS
*                not_found = 1
*                OTHERS    = 2.

*            WRITE icon_red_light TO et_return-icon.                                                     "D_MBAYEL commentlenmiştir.

            APPEND <lfs_return> TO et_return.
          ENDLOOP.
          CONTINUE.

        ELSE.

          gv_mail_send = 'X'.

        ENDIF.

        IF gv_otf EQ 'X'.

          IF ls_h001-moutput NE 'F'.
*              PERFORM set_mail_body(/itetr/reco_form)                                                              "DMBAYEL commentlenmiştir.
*              TABLES gt_body lt_cform
*              USING ls_h001-mnumber
*                    ls_h001-randomkey
*                    ''
*                    ls_h001-monat
*                    ls_h001-gjahr
*                    ls_h001-mtype
*                    ls_h001-ftype
*                    gs_account
*                    gs_bform
*                    gs_adrs
*                    gs_adrc
*                    gs_text
*                    gs_htxt
*                    lv_only_loc
*                    CHANGING gv_subject gv_subrc gv_sender_name.
          ELSE.
            CLEAR gt_body[].
          ENDIF.

          CLEAR gv_sender_address.

          CASE gs_account-hesap_tur.
            WHEN 'M'.
              me->zreco_from_mail_adrs(
               EXPORTING
                  i_bukrs = ls_h001-bukrs
                  i_gsber = ls_h001-gsber
                  i_kunnr = ls_h001-hesap_no
                  i_mtype = ls_h001-mtype
                  i_uname = gs_v001-ernam
                IMPORTING
                  e_mail  = gv_sender_address
              ).

            WHEN 'S'.

              me->zreco_from_mail_adrs(
             EXPORTING
                i_bukrs = ls_h001-bukrs
                i_gsber = ls_h001-gsber
                i_lifnr = ls_h001-hesap_no
                i_mtype = ls_h001-mtype
                i_uname = gs_v001-ernam
              IMPORTING
                e_mail  = gv_sender_address
              ).

          ENDCASE.

          gv_from_adress = gv_sender_address.
          gv_sender_address_type = 'SMTP'.

          IF gs_job_info-otfdata[] IS NOT INITIAL.

            CLEAR gs_return.

            ls_h001-hesap_no = | { gv_attach_name ALPHA = OUT } |.

            CONCATENATE gs_htxt-bktxt ls_h001-mnumber '-' gv_attach_name
            INTO gv_obj_descr SEPARATED BY space.

            lv_subject = gv_subject.

            IF ls_h001-moutput NE 'F' AND
               gv_mail_send    IS NOT INITIAL.

              LOOP AT gt_e001 INTO gs_e001 WHERE bukrs EQ ls_h001-bukrs
                                       AND gsber EQ ls_h001-gsber
                                       AND mnumber EQ ls_h001-mnumber
                                       AND monat EQ ls_h001-monat
                                       AND gjahr EQ ls_h001-gjahr
                                       AND hesap_tur EQ ls_h001-hesap_tur
                                       AND hesap_no EQ ls_h001-hesap_no.

                CLEAR: gt_receivers, gt_receivers[].

                gs_receivers-receiver = gs_e001-receiver.
                gs_receivers-rec_type = 'U'.
                APPEND gs_receivers TO gt_receivers .

*                PERFORM set_mail_body(/itetr/reco_form)        "D_MBAYEL commentlenmiştir
*                TABLES gt_body lt_cform
*                USING ls_h001-mnumber
*                      ls_h001-randomkey
*                      gs_e001-mailid
*                      ls_h001-monat
*                      ls_h001-gjahr
*                      ls_h001-mtype
*                      ls_h001-ftype
*                      gs_account
*                      gs_bform
*                      gs_adrs
*                      gs_adrc
*                      gs_text
*                      gs_htxt
*                      lv_only_loc
*             CHANGING gv_subject
*                      gv_subrc
*                      gv_sender_name.

*                CALL FUNCTION 'ZECO_PDF_MAIL_NEW'                          "D_MBAYEL commentlenmiştir.
*                  EXPORTING
*                    it_pdf          = gs_job_info-otfdata
*                    i_subject       = lv_subject
*                    i_sender_name   = gv_sender_name
*                    i_sender_adress = gv_from_adress
*                    i_obj_descr     = gv_obj_descr
*                    i_attach_name   = gv_attach_name
*                    i_head          = ls_h001
*                    it_receivers    = gt_receivers
*                  IMPORTING
*                    es_return       = gs_return
*                    es_result       = ls_result
*                  TABLES
*                    ti_body         = gt_body.
*                  it_receivers    = gt_receivers.


                IF gs_return-type EQ 'S'.

                  LOOP AT gt_receivers INTO gs_receivers.

                    CLEAR ls_remd.

                    MOVE-CORRESPONDING gs_v001 TO ls_remd.
                    MOVE-CORRESPONDING ls_h001 TO ls_remd.

                    ls_remd-receiver = gs_receivers-receiver.
                    ls_remd-datum = cl_abap_context_info=>get_system_date( )."sy-datum.
                    ls_remd-uzeit = cl_abap_context_info=>get_system_time( )."sy-uzeit.
                    ls_remd-ernam = sy-uname.
                    ls_remd-objtp = ls_result-objtp.
                    ls_remd-objyr = ls_result-objyr.
                    ls_remd-objno = ls_result-objno.

*                    INSERT zreco_chat FROM @ls_remd.   "YiğitcanOzdemir10052025

                    APPEND ls_remd TO lt_remd.
                    APPEND gs_v001 TO gt_v001.
                    APPEND ls_h001 TO lt_h001.

                    MOVE-CORRESPONDING lt_remd TO et_return.
                    MOVE-CORRESPONDING gt_v001 TO et_return.
                    MOVE-CORRESPONDING lt_h001 TO et_return.

                    LOOP AT et_return ASSIGNING <lfs_return>.
*                      CALL FUNCTION 'FORMAT_MESSAGE'                             "D_MBAYEL commentlenmiştir.
*                        EXPORTING
*                          id        = 'ZRECO'
*                          lang      = sy-langu
*                          no        = '131'
*                        IMPORTING
*                          msg       = <lfs_return>-message
*                        EXCEPTIONS
*                          not_found = 1
*                          OTHERS    = 2.

*                    WRITE icon_green_light TO et_return-icon.                  "D_MBAYEL commentlenmiştir.

                      APPEND <lfs_return> TO et_return.
                    ENDLOOP.
                  ENDLOOP.

                  IF ls_h001-verzn IS NOT INITIAL.
                    INSERT zreco_cdun FROM TABLE @lt_cdun.
                  ENDIF.

                ELSE.

                  APPEND ls_remd TO lt_remd.
                  APPEND gs_v001 TO gt_v001.
                  APPEND ls_h001 TO lt_h001.

                  MOVE-CORRESPONDING lt_remd TO et_return.
                  MOVE-CORRESPONDING gt_v001 TO et_return.
                  MOVE-CORRESPONDING lt_h001 TO et_return.
                  LOOP AT et_return ASSIGNING <lfs_return>.
*                    CALL FUNCTION 'FORMAT_MESSAGE'                               "D_MBAYEL commentlenmiştir.
*                      EXPORTING
*                        id        = gs_return-id
*                        lang      = sy-langu
*                        no        = gs_return-number
*                        v1        = gs_return-message_v1
*                        v2        = gs_return-message_v2
*                        v3        = gs_return-message_v3
*                        v4        = gs_return-message_v4
*                      IMPORTING
*                        msg       = <lfs_return>-message
*                      EXCEPTIONS
*                        not_found = 1
*                        OTHERS    = 2.

*                  WRITE icon_red_light TO et_return-icon.

                    APPEND <lfs_return> TO et_return.
                  ENDLOOP..
                ENDIF.

              ENDLOOP.

            ELSEIF ls_h001-moutput EQ 'F'.

              LOOP AT gt_e001 INTO gs_e001 WHERE bukrs EQ ls_h001-bukrs
                                       AND gsber EQ ls_h001-gsber
                                       AND mnumber EQ ls_h001-mnumber
                                       AND monat EQ ls_h001-monat
                                       AND gjahr EQ ls_h001-gjahr
                                       AND hesap_tur EQ ls_h001-hesap_tur
                                       AND hesap_no EQ ls_h001-hesap_no.

                CLEAR: gt_receivers, gt_receivers[].

                gs_receivers-receiver = gs_e001-receiver.
                gs_receivers-rec_type = 'U'.
                APPEND gs_receivers TO gt_receivers .

*                CALL FUNCTION 'ZRECO_PDF_MAIL_NEW'                                     "D_MBAYEL
*                  EXPORTING
*                    it_pdf          = gs_job_info-otfdata
*                    i_subject       = lv_subject
*                    i_sender_name   = gv_sender_name
*                    i_sender_adress = gv_from_adress
*                    i_obj_descr     = gv_obj_descr
*                    i_attach_name   = gv_attach_name
*                    i_head          = ls_h001
*                    it_receivers    = gt_receivers
*                  IMPORTING
*                    es_return       = gs_return
*                    es_result       = ls_result
*                  TABLES
*                    ti_body         = gt_body.
**                  it_receivers    = gt_receivers.


                IF gs_return-type EQ 'S'.

                  LOOP AT gt_receivers INTO gs_receivers.

                    CLEAR ls_remd.

                    MOVE-CORRESPONDING gs_v001 TO ls_remd.
                    MOVE-CORRESPONDING ls_h001 TO ls_remd.

                    ls_remd-receiver = gs_receivers-receiver.
                    ls_remd-datum = cl_abap_context_info=>get_system_date( )."sy-datum.
                    ls_remd-uzeit = cl_abap_context_info=>get_system_time( )."sy-uzeit.
                    ls_remd-ernam = sy-uname.
                    ls_remd-objtp = ls_result-objtp.
                    ls_remd-objyr = ls_result-objyr.
                    ls_remd-objno = ls_result-objno.

*                    INSERT zreco_chat FROM @ls_remd. "YiğitcanOzdemir10052025

                    APPEND ls_remd TO lt_remd.
                    APPEND gs_v001 TO gt_v001.
                    APPEND ls_h001 TO lt_h001.

                    MOVE-CORRESPONDING lt_remd TO et_return.
                    MOVE-CORRESPONDING gt_v001 TO et_return.
                    MOVE-CORRESPONDING lt_h001 TO et_return.

                    LOOP AT et_return ASSIGNING <lfs_return>.
*                      CALL FUNCTION 'FORMAT_MESSAGE'                             "D_MBAYEL commentlenmiştir.
*                        EXPORTING
*                          id        = 'ZRECO'
*                          lang      = sy-langu
*                          no        = '131'
*                        IMPORTING
*                          msg       = <lfs_return>-message
*                        EXCEPTIONS
*                          not_found = 1
*                          OTHERS    = 2.

*                    WRITE icon_green_light TO et_return-icon.

                      APPEND <lfs_return> TO et_return.
                    ENDLOOP.
                  ENDLOOP.

                  IF ls_h001-verzn IS NOT INITIAL.
                    INSERT zreco_cdun FROM TABLE @lt_cdun.
                  ENDIF.

                ELSE.

                  APPEND ls_remd TO lt_remd.
                  APPEND gs_v001 TO gt_v001.
                  APPEND ls_h001 TO lt_h001.


                  MOVE-CORRESPONDING lt_remd TO et_return.
                  MOVE-CORRESPONDING gt_v001 TO et_return.
                  MOVE-CORRESPONDING lt_h001 TO et_return.

                  LOOP AT et_return ASSIGNING <lfs_return>.
*                    CALL FUNCTION 'FORMAT_MESSAGE'                   "D_MBAYEL commentlenmiştir.
*                      EXPORTING
*                        id        = gs_return-id
*                        lang      = sy-langu
*                        no        = gs_return-number
*                        v1        = gs_return-message_v1
*                        v2        = gs_return-message_v2
*                        v3        = gs_return-message_v3
*                        v4        = gs_return-message_v4
*                      IMPORTING
*                        msg       = <lfs_return>-message
*                      EXCEPTIONS
*                        not_found = 1
*                        OTHERS    = 2.

*                  WRITE icon_red_light TO et_return-icon.               "D_MBAYEL commentlenmiştir

                    APPEND <lfs_return> TO et_return.
                  ENDLOOP.
                ENDIF.

              ENDLOOP.

            ENDIF.

          ENDIF.

        ENDIF.

      ENDIF.

    ENDLOOP.

    IF i_mail_send IS INITIAL.
      IF i_down IS INITIAL.
*        CALL FUNCTION 'SSF_CLOSE'                                                            "D_MBAYEL commentlenmiştir.
*          IMPORTING
*            job_output_info  = gs_job_info
*          EXCEPTIONS
*            formatting_error = 1
*            internal_error   = 2
*            send_error       = 3
*            OTHERS           = 4.

      ELSE.
        "Birleşik dosyayı dönüştür
        IF i_down EQ 'P' AND gs_job_info-otfdata[] IS NOT INITIAL.
          CLEAR: lv_lenght, lv_xstring, lt_lines[], ls_save_files.

*          CALL FUNCTION 'CONVERT_OTF'                                                "D_MBAYEL commentlenmiştir.
*            EXPORTING
*              format                = 'PDF'
*            IMPORTING
*              bin_filesize          = lv_lenght
*              bin_file              = lv_xstring
*            TABLES
*              otf                   = gs_job_info-otfdata[]
*              lines                 = lt_lines[]
*            EXCEPTIONS
*              err_max_linewidth     = 1
*              err_format            = 2
*              err_conv_not_possible = 3
*              err_bad_otf           = 4
*              OTHERS                = 5.
*          IF sy-subrc <> 0.
*          ENDIF.

          ls_save_files-filex  = lv_xstring.
          ls_save_files-lenght = lv_lenght.
          APPEND ls_save_files TO lt_save_files.CLEAR ls_save_files.
        ENDIF.

*        IF lt_save_files[] IS NOT INITIAL.
*
*          me->zreco_download_int_file(
*            EXPORTING
*                i_filter = 'PDF File (*.PDF)|*.PDF'
*                it_files = lt_save_files[]
*          ).
*
*
*        ENDIF.
      ENDIF.

    ENDIF.
  ENDMETHOD.