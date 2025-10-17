  METHOD get_data.

    DATA: r_loekz TYPE RANGE OF zreco_hdr-loekz.


    DATA: lv_auth TYPE abap_boolean.

    DATA: lv_row       TYPE int4,
          lv_balance   TYPE zreco_TSLVT12,
          lv_r_balance TYPE zreco_TSLVT12,
          lv_o_balance TYPE zreco_TSLVT12,
          lv_n_balance TYPE zreco_TSLVT12,
          lv_first     TYPE abap_boolean,
          lt_s_bal     TYPE TABLE OF zreco_bapi3008_3,
          lt_m_bal     TYPE TABLE OF zreco_bapi3007_3.

    DATA: lv_xresult         TYPE zreco_monitor-xresult,
          ls_h001            TYPE zreco_hdr,
          lv_wrbtr           TYPE  wrbtr,
          lv_biggest_mnumber TYPE zreco_number.
    DATA: lt_mail TYPE TABLE OF zreco_refi,
          ls_mail TYPE zreco_refi.

    DATA ls_amount TYPE zreco_mtb_amount_c.
    DATA ls_refi TYPE zreco_refi.

    DATA: "gt_out     TYPE TABLE OF zreco_monitor,
      gs_out_tmp LIKE LINE OF gt_out,
      gt_detail  TYPE TABLE OF zreco_user_perf_detail.

    DATA: gs_out     TYPE zreco_monitor,
          ls_out     TYPE zreco_monitor,
          gs_cdat    TYPE zreco_cdat,
          gv_bukrs   TYPE bukrs,
          gv_gsber   TYPE abap_boolean,
          gv_yes     TYPE abap_boolean,
          gv_no      TYPE abap_boolean,
          gv_no_data TYPE abap_boolean,
          gv_wait    TYPE abap_boolean,
          gv_name1   TYPE zreco_name80,
          gv_tcode   TYPE c LENGTH 2,
          gv_click   TYPE abap_boolean,
          gv_change  TYPE abap_boolean,
          gv_answer  TYPE c LENGTH 1,
          gv_first   TYPE abap_boolean,
          gv_subsc   TYPE abap_boolean,
          gv_version TYPE zreco_version,
          gv_try     TYPE abap_boolean,
          gv_pwaers  TYPE waers.

    TYPES : BEGIN OF mty_custno ,
              hesap_no TYPE kunnr,
            END OF mty_custno.

    TYPES : BEGIN OF mty_vendno ,
              hesap_no TYPE lifnr,
            END OF mty_vendno.


    DATA: gt_custno TYPE TABLE OF mty_custno,
          gt_vendno TYPE TABLE OF mty_vendno.

    DATA: r_mtype TYPE RANGE OF zreco_hdr-mtype,
          r_ftype TYPE RANGE OF zreco_hdr-ftype,
          r_sum   TYPE RANGE OF zreco_rcai-xsum,
          r_hspno TYPE RANGE OF zreco_hdr-hesap_no,
          r_hstur TYPE RANGE OF zreco_hdr-hesap_tur,
          r_daily TYPE RANGE OF zreco_hdr-daily.

*    CONSTANTS gc_yukle TYPE c LENGTH 4 VALUE icon_create.

*    TYPES BEGIN OF gty_t005t.
*    TYPES land1 TYPE  i_countrytext-Country.
*    TYPES spras TYPE  i_countryzreco_lst_compare_date_2Language.
*    TYPES landx50 TYPE  i_countrytext-CountryName.
*    TYPES natio TYPE  i_countrytext-NationalityName.
*    TYPES natio50 TYPE  i_countrytext-NationalityLongName.
*    TYPES landx TYPE  i_countrytext-CountryShortName.
*    TYPES END OF gty_t005t.
*
*    DATA: gt_t005t TYPE TABLE OF gty_t005t.

    DATA: gt_remh  TYPE STANDARD TABLE OF zreco_rmh WITH NON-UNIQUE KEY bukrs mnumber datum uzeit,
          gt_remd  TYPE STANDARD TABLE OF zreco_rmd WITH NON-UNIQUE KEY bukrs mnumber datum uzeit,
          gt_remd2 TYPE STANDARD TABLE OF zreco_rmd WITH NON-UNIQUE KEY bukrs mnumber datum uzeit,
          gt_text  TYPE LINE OF zreco_catsxt_longtext_itab,
          gt_bform TYPE TABLE OF zreco_tmpd,
          gs_bform TYPE zreco_tmpd.

    DATA: gt_balance TYPE TABLE OF zreco_cform_bal,
          gs_balance TYPE zreco_cform_bal,
          gv_dmbtr   TYPE zreco_hslxx12.

    DATA:    zreco_object TYPE REF TO zreco_common.
*    CREATE OBJECT zreco_object.
    zreco_object = NEW zreco_common( ).

    FIELD-SYMBOLS <lfs_cform> TYPE zreco_cform_sf.
    FIELD-SYMBOLS : <fs_out>  LIKE LINE OF gt_out.

    CLEAR : gt_h001[], gt_out[].

    CLEAR gs_out.

    AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
    ID 'BUKRS' FIELD iv_bukrs
    ID 'ACTVT' FIELD '03'.

    IF sy-subrc NE 0.
*    data(lv_msg) = new_message_with_text(  text = 'şirket kodunda görüntüleme yetkiniz yok' severity = cl_abap_behv=>ms-success ).         D_MBAYEL
*       APPEND VALUE #( %msg = lv_msg ) to
*      MESSAGE s100 WITH p_bukrs DISPLAY LIKE 'E'.
*      LEAVE LIST-PROCESSING.
    ENDIF.


*    IF it_reco_form IS NOT INITIAL.

*    AUTHORITY-CHECK OBJECT 'ZFRM'                                                                                                             D_MBAYEL
*    ID 'BUKRS' FIELD p_bukrs
*    ID 'FORMNAME' FIELD p_ftype.
*
*    IF sy-subrc NE 0.
*      MESSAGE s152 WITH p_bukrs p_ftype DISPLAY LIKE 'E'.                                                                                      D_MBAYEL
*      LEAVE LIST-PROCESSING.
*    ENDIF.

**  ENDIF.


*   SELECT SINGLE * FROM  t001 WHERE bukrs EQ p_bukrs.


* Silinenleri de göster
    IF it_del IS INITIAL.
      APPEND VALUE #( sign   = 'E'
                      option = 'EQ'
                      low = 'X'   ) TO r_loekz.
    ENDIF.
*
*    IF r_bform IS NOT INITIAL.     "İptal edildi
*      r_mtype-sign = 'I'.
*      r_mtype-option = ''.
*      r_mtype-low = 'B'.
*      APPEND r_mtype.
*
*      r_mtype-sign = 'I'.
*      r_mtype-option = 'EQ'.
*      r_mtype-low = 'X'.
*      APPEND r_mtype.
*    ENDIF.
*
*    IF r_mform IS NOT INITIAL.     "İptal edildi
*      r_mtype-sign = 'I'.

*      r_mtype-option = 'EQ'.
*      r_mtype-low = 'C'.
*      APPEND r_mtype.
*
*      r_mtype-sign = 'I'.
*      r_mtype-option = 'EQ'.
*      r_mtype-low = 'X'.
*      APPEND r_mtype.
*    ENDIF.
*
*    IF it_reco_number IS NOT INITIAL.
*    IF it_reco_form IS NOT INITIAL."YiğitcanÖzdemir
**      APPEND VALUE #( sign   = 'I'
**                     option  = 'EQ'
**                      low    = 'X'  ) TO r_ftype. "YiğitcanÖzdemir
**                      low    = 'X'  ) TO r_ftype.
*      LOOP AT it_reco_form INTO DATA(ls_form).
*        APPEND VALUE #(
*          sign   = 'I'
*          option = 'EQ'
*          low    = ls_form-low
*        ) TO r_ftype.
*      ENDLOOP.
*    ENDIF.

    "YiğitcanÖzdemir
    IF iv_all IS NOT INITIAL.
      p_all = iv_all.
    ENDIF.

    IF it_odk IS INITIAL.
      APPEND VALUE #( sign   = 'I'
                     option  = 'EQ'
                      low    = 'X'  ) TO r_sum.
    ENDIF.
*
    IF it_daily IS NOT INITIAL.
*      APPEND VALUE #( sign   = 'I'  "YiğitcanÖzdemir
*                     option  = 'EQ'
*                      low    = 'X'  ) TO r_daily.

      LOOP AT it_daily INTO DATA(ls_Daily).
        APPEND VALUE #(
          sign   = 'I'
          option = 'EQ'
          low    = ls_Daily-low
        ) TO r_ftype.
      ENDLOOP.

    ENDIF.

    SELECT  FROM zreco_cust
     FIELDS hesap_no
    WHERE bukrs = @iv_bukrs
    INTO TABLE @gt_custno.


    SELECT FROM zreco_vend
    FIELDS hesap_no
      WHERE bukrs = @iv_bukrs
          INTO TABLE @gt_vendno.

    r_hspno[] = it_ktonr_av[].
    r_hstur[] = it_account_type[].

    partner_selection(  ).

    SELECT * FROM zreco_hdr
    WHERE bukrs EQ @iv_bukrs
    AND monat IN @it_monat
    AND gjahr IN @it_gjahr
    AND mnumber IN @it_reco_number
    AND hesap_tur IN @it_account_type
    AND hesap_no  IN @it_ktonr_av
    AND mtype IN @r_mtype
    AND moutput IN @it_output
*    AND loekz IN @r_loekz                     "YiğitcanÖzdemir x olmasına rağmen gelmiyor bi bak
    AND vkn_tckn IN @it_vkn
    AND kunnr IN @it_kunnr
    AND lifnr IN @it_lifnr
    AND ftype EQ '01' "@it_reco_form           "YiğitcanÖzdemir
    AND daily IN @r_daily
    INTO CORRESPONDING FIELDS OF TABLE @gt_h001.

*    CHECK sy-subrc EQ 0.


    LOOP AT  gt_h001 INTO ls_h001 WHERE xstatu IS INITIAL.
      CLEAR : lv_answer, lv_text.
      IF ls_h001-mtype = 'B'.

        me->get_status(  ).

*      PERFORM get_status USING ls_h001
*                         CHANGING ls_answer.

        CHECK ls_answer-b_form_result-item_status_id IS NOT INITIAL.

        IF ls_answer-b_form_result-item_status_id = '247'.
          lv_answer = 'Y'.
        ELSEIF ls_answer-b_form_result-item_status_id = '248'.
          lv_answer = 'N'.
        ELSEIF ls_answer-b_form_result-item_status_id = '253'.
          lv_answer = 'I'.
        ELSEIF ls_answer-b_form_result-item_status_id = '249'.
          lv_answer = 'X'.
        ELSE.
          CONTINUE.
        ENDIF.

        lv_text           = ls_answer-b_form_result-note.
        ls_bform-base_ba  = ls_answer-b_form_result-customer_ba_amount.
        ls_bform-base_bs  = ls_answer-b_form_result-customer_bs_amount.
        ls_bform-count_ba = ls_answer-b_form_result-customer_ba_count.
        ls_bform-count_bs = ls_answer-b_form_result-customer_bs_count.
        ls_bform-responder_name = ls_answer-b_form_result-name.
        ls_bform-responder_surname = ls_answer-b_form_result-surname.

      ELSEIF ls_h001-mtype = 'C'.
        CLEAR ls_answer_c.

        me->get_status(  ).

        CHECK ls_answer_c-data-status IS NOT INITIAL.

        IF ls_answer_c-data-status = '1'.
          lv_answer = 'Y'.
        ELSEIF ls_answer_c-data-status = '2'.
          lv_answer = 'N'.
        ELSEIF ls_answer_c-data-status = '3'. "
          lv_answer = 'I'.
        ELSEIF ls_answer_c-data-status = '5'.
          lv_answer = 'X'.
        ELSE.
          CONTINUE.
*        lv_answer = ' '.
        ENDIF.
        lv_text           = ls_answer_c-data-note.

        SELECT *
          FROM zreco_htxt
         WHERE bukrs EQ @ls_h001-bukrs
           AND mtype EQ @ls_h001-mtype
           AND ftype IN @it_reco_form
            INTO TABLE @gt_htxt.

        READ TABLE gt_htxt INTO ls_htxt WITH KEY spras = sy-langu.

        LOOP AT ls_answer_c-data-amount INTO ls_amount.
          APPEND INITIAL LINE TO lt_cform ASSIGNING <lfs_cform>.
          <lfs_cform>-wrbtr_c = ls_amount-customeramount.
          <lfs_cform>-waers_c = ls_amount-customercurrency.
          <lfs_cform>-akont   = ls_amount-accountnumber.
          <lfs_cform>-ltext   = ls_htxt-customer_text.
          <lfs_cform>-responder_name = ls_answer_c-data-name.
          <lfs_cform>-responder_surname = ls_answer_c-data-surname.
        ENDLOOP.

      ENDIF.

      SELECT SINGLE *
          FROM zreco_refi
          WHERE bukrs EQ @ls_h001-bukrs
                AND gsber EQ @ls_h001-gsber
                AND mnumber EQ @ls_h001-mnumber
                AND monat EQ @ls_h001-monat
                AND gjahr EQ @ls_h001-gjahr
                AND hesap_tur EQ @ls_h001-hesap_tur
                AND hesap_no EQ @ls_h001-hesap_no
                INTO @ls_refi.

      zreco_object->zreco_result_new(
       EXPORTING
        i_randid   = ls_h001-randomkey
        i_mailid  = ls_refi-mailid
        i_answer  = lv_answer
        i_text    = lv_text
        i_no_data = lv_answer
        is_bform  = ls_bform
        IMPORTING
         et_cform  = lt_cform
       ).

    ENDLOOP.

* Mutabakat sorumluları
    SELECT * FROM zreco_cvua
      FOR ALL ENTRIES IN @gt_h001
      WHERE bukrs EQ @gt_h001-bukrs
      AND mtype IN @r_mtype
      AND kunnr EQ @gt_h001-hesap_no
      AND kunnr NE ''
      INTO TABLE @gt_user.

    SELECT * FROM zreco_cvua
      FOR ALL ENTRIES IN @gt_h001
      WHERE bukrs EQ @gt_h001-bukrs
      AND mtype IN @r_mtype
      AND lifnr EQ @gt_h001-hesap_no
      AND lifnr NE ''
      APPENDING TABLE @gt_user.

* Güncel versiyonu çek
    SELECT * FROM zreco_vers
      FOR ALL ENTRIES IN @gt_h001
      WHERE bukrs EQ @gt_h001-bukrs
      AND gsber EQ @gt_h001-gsber
      AND mnumber EQ @gt_h001-mnumber
      AND monat EQ @gt_h001-monat
      AND gjahr EQ @gt_h001-gjahr
      AND ernam IN @it_uname
      AND erdat IN @it_erdat
      AND erzei IN @it_erzei
      AND vstatu EQ 'G'
      INTO TABLE @gt_v001.

    CHECK sy-subrc EQ 0.

    CLEAR:gt_chat,gt_chat[].
    SELECT *
      FROM zreco_chat
       FOR ALL ENTRIES IN @gt_h001
     WHERE bukrs EQ @gt_h001-bukrs
       AND gsber EQ @gt_h001-gsber
       AND mnumber EQ @gt_h001-mnumber
       AND monat EQ @gt_h001-monat
       AND gjahr EQ @gt_h001-gjahr
       INTO TABLE @gt_chat.

*    CHECK sy-subrc EQ 0.                     "YiğitcanÖzdemir Fazla kod
*
*    CLEAR:gt_chat,gt_chat[].
*    SELECT *
*      FROM zreco_chat
*       FOR ALL ENTRIES IN @gt_h001
*     WHERE bukrs EQ @gt_h001-bukrs
*       AND gsber EQ @gt_h001-gsber
*       AND mnumber EQ @gt_h001-mnumber
*       AND monat EQ @gt_h001-monat
*       AND gjahr EQ @gt_h001-gjahr
*        INTO TABLE @gt_chat.

    IF p_all IS NOT INITIAL OR p_anwsr IS NOT INITIAL .

      SELECT * FROM zreco_reia
        FOR ALL ENTRIES IN @gt_v001
        WHERE bukrs EQ @gt_v001-bukrs
        AND gsber EQ @gt_v001-gsber
        AND mnumber EQ @gt_v001-mnumber
        AND monat EQ @gt_v001-monat
        AND gjahr EQ @gt_v001-gjahr
        AND version EQ @gt_v001-version
        AND mresult IN @it_result
        INTO TABLE @gt_r000.

      SELECT * FROM zreco_rcar
        FOR ALL ENTRIES IN @gt_v001
        WHERE bukrs EQ @gt_v001-bukrs
        AND gsber EQ @gt_v001-gsber
        AND mnumber EQ @gt_v001-mnumber
        AND monat EQ @gt_v001-monat
        AND gjahr EQ @gt_v001-gjahr
        INTO TABLE @gt_r001.
*      AND version EQ gt_v001-version. bütün versiyonların çekilebilmesi için
      SELECT * FROM zreco_rbia
            FOR ALL ENTRIES IN @gt_v001
            WHERE bukrs EQ @gt_v001-bukrs
            AND gsber EQ @gt_v001-gsber
            AND mnumber EQ @gt_v001-mnumber
            AND monat EQ @gt_v001-monat
            AND gjahr EQ @gt_v001-gjahr
            AND version EQ @gt_v001-version
            INTO TABLE @gt_r002.

      SELECT * FROM zreco_hia
        FOR ALL ENTRIES IN @gt_h001
        WHERE bukrs EQ @gt_h001-bukrs
        AND gsber EQ @gt_h001-gsber
        AND mnumber EQ @gt_h001-mnumber
        AND monat EQ @gt_h001-monat
        AND gjahr EQ @gt_h001-gjahr
        AND hesap_tur EQ @gt_h001-hesap_tur
        AND hesap_no EQ @gt_h001-hesap_no
        INTO TABLE @gt_h002.

    ENDIF.

* B formu bilgileri
    SELECT * FROM zreco_recb
        FOR ALL ENTRIES IN @gt_v001
        WHERE bukrs EQ @gt_v001-bukrs
        AND gsber EQ @gt_v001-gsber
        AND mnumber EQ @gt_v001-mnumber
        AND monat EQ @gt_v001-monat
        AND gjahr EQ @gt_v001-gjahr
        AND version EQ @gt_v001-version
        INTO TABLE @gt_b001.

* Cari Mutabakat bilgileri
    SELECT * FROM zreco_rcai
        FOR ALL ENTRIES IN @gt_v001
        WHERE bukrs EQ @gt_v001-bukrs
        AND gsber EQ @gt_v001-gsber
        AND mnumber EQ @gt_v001-mnumber
        AND monat EQ @gt_v001-monat
        AND gjahr EQ @gt_v001-gjahr
        AND version EQ @gt_v001-version
        AND xsum IN @r_sum
        INTO TABLE @gt_c001.

* Sonraki dönem şirket bilgileri
    SELECT * FROM zreco_c002
        FOR ALL ENTRIES IN @gt_v001
        WHERE bukrs EQ @gt_v001-bukrs
        AND gsber EQ @gt_v001-gsber
        AND mnumber EQ @gt_v001-mnumber
        AND monat EQ @gt_v001-monat
        AND gjahr EQ @gt_v001-gjahr
        AND version EQ @gt_v001-version
        AND xsum IN @r_sum
        INTO TABLE @gt_c002.

* Sonraki dönem firma bilgileri
    SELECT * FROM zreco_c003
        FOR ALL ENTRIES IN @gt_v001
        WHERE bukrs EQ @gt_v001-bukrs
        AND gsber EQ @gt_v001-gsber
        AND mnumber EQ @gt_v001-mnumber
        AND monat EQ @gt_v001-monat
        AND gjahr EQ @gt_v001-gjahr
        AND version EQ @gt_v001-version
        AND xsum IN @r_sum
        INTO TABLE @gt_c003.

* Mutabakat tamamlanmış mı
    SELECT * FROM zreco_chd1
      FOR ALL ENTRIES IN @gt_h001
      WHERE bukrs EQ @gt_h001-bukrs
      AND gsber EQ @gt_h001-gsber
      AND mnumber EQ @gt_h001-mnumber
      AND monat EQ @gt_h001-monat
      AND gjahr EQ @gt_h001-gjahr
      AND hesap_tur EQ @gt_h001-hesap_tur
      AND hesap_no EQ @gt_h001-hesap_no
      INTO TABLE @gt_chd1.


    IF gt_h001[] IS NOT INITIAL.
      SELECT * FROM i_customer AS kna1
        FOR ALL ENTRIES IN @gt_h001
        WHERE Customer EQ @gt_h001-hesap_no
        INTO TABLE @gt_kna1.

      SELECT * FROM i_supplier  AS lfa1
        FOR ALL ENTRIES IN @gt_h001
        WHERE Supplier EQ @gt_h001-hesap_no
        INTO TABLE @gt_lfa1.

      SELECT * FROM i_countrytext AS t005t
        WHERE Language EQ 'T'
        INTO TABLE @gt_t005t.
    ENDIF.

* Hatırlatma sayısı
    SELECT * FROM zeco_rmh
        FOR ALL ENTRIES IN @gt_v001
        WHERE bukrs EQ @gt_v001-bukrs
        AND gsber EQ @gt_v001-gsber
        AND mnumber EQ @gt_v001-mnumber
        AND monat EQ @gt_v001-monat
        AND gjahr EQ @gt_v001-gjahr
        INTO TABLE @gt_remh.

    SELECT * FROM zreco_rmd
        FOR ALL ENTRIES IN @gt_v001
        WHERE bukrs EQ @gt_v001-bukrs
        AND gsber EQ @gt_v001-gsber
        AND mnumber EQ @gt_v001-mnumber
        AND monat EQ @gt_v001-monat
        AND gjahr EQ @gt_v001-gjahr
        AND version EQ @gt_v001-version
        INTO TABLE @gt_remd.

    gt_remd2[] = gt_remd[].

    DELETE ADJACENT DUPLICATES FROM gt_remd
    COMPARING bukrs mnumber datum uzeit.

* Mutabakat Gönderilen Mail
    SELECT *
      FROM zreco_refi
      WHERE bukrs EQ @iv_bukrs
      AND mnumber IN @it_reco_number
      AND monat IN @it_monat
      AND gjahr IN @it_gjahr
      AND hesap_tur IN @r_hstur
      AND hesap_no IN @r_hspno
      INTO TABLE @lt_mail.

    LOOP AT gt_h001 INTO gs_h001.

      CLEAR: lv_auth, gs_v001, gs_b001, gs_c001, gs_h002, gs_r000,
             gs_r001, gs_r002.

      READ TABLE gt_v001 INTO gs_v001 WITH KEY bukrs = gs_h001-bukrs
                                             gsber = gs_h001-gsber
                                             mnumber = gs_h001-mnumber
                                             monat = gs_h001-monat
                                             gjahr = gs_h001-gjahr.


      IF sy-subrc EQ 0.
        READ TABLE gt_r000 INTO gs_r000 WITH KEY bukrs = gs_h001-bukrs
                                                 mnumber = gs_h001-mnumber
                                                 gsber = gs_h001-gsber
                                                 monat = gs_h001-monat
                                                 gjahr = gs_h001-gjahr
                                                 version = gs_v001-version.
        IF ( gs_r000-mresult NE 'V' AND sy-subrc EQ 0 ) OR ( gs_r000-mresult NE 'V' AND it_result IS INITIAL ). "Seçim ekranından gelen belgenin statü'sü hükmsüz mü?
          "daha önce gönderilmiş farklı mutabakat no'lu belgelerin en yenisi.
          SELECT SINGLE MAX( mnumber )
            FROM zreco_hdr
            WHERE bukrs   EQ @gs_h001-bukrs
            AND gsber     EQ @gs_h001-gsber
            AND monat     EQ @gs_h001-monat
            AND gjahr     EQ @gs_h001-gjahr
            AND hesap_tur EQ @gs_h001-hesap_tur
            AND hesap_no  EQ @gs_h001-hesap_no
            AND mtype     EQ @gs_h001-mtype
            AND moutput   EQ @gs_h001-moutput
            AND loekz     EQ @gs_h001-loekz
            AND vkn_tckn  EQ @gs_h001-vkn_tckn
            AND lifnr     EQ @gs_h001-lifnr
            AND kunnr     EQ @gs_h001-kunnr
            AND ftype     EQ @gs_h001-ftype
            AND daily     EQ @gs_h001-daily
            INTO @lv_biggest_mnumber.

          IF lv_biggest_mnumber GT gs_h001-mnumber. "seçim ekranından gelen mutabakat'ı karşılaştır.
            IF gs_r000-mresult NE 'V'. "seçim elranından gelen mutabakat belgesi bir kere hükümsüz olduktan sonra aynı işlemi tekrar uygulama.
              IF gs_r000 IS INITIAL. "cevap verilmeyi bekliyor olan eski tarihli mutabakatlar hükümsüz statü olarak gelen yanıtlar tablosuna ekleniyor.
                MOVE-CORRESPONDING gs_h001 TO gs_r000.
                MOVE-CORRESPONDING gs_v001 TO gs_r000.
                gs_r000-mresult = 'V'.
                MODIFY zreco_reia FROM @gs_r000.
                IF sy-subrc EQ 0.
                  COMMIT WORK.
                  INSERT gs_r000 INTO TABLE gt_r000.
                  gs_h001-xstatu = 'X'. "cevap verilmeyi bekliyor olan eski tarihli mutabakatların header tablosundaki statü alanını işaretle'X'.
                  MODIFY zreco_hdr FROM @gs_h001.
                  IF sy-subrc EQ 0.
                    COMMIT WORK.
                  ENDIF.
                ENDIF.
              ELSE.
                gs_r000-mresult = 'V'.
                MODIFY zreco_reia FROM @gs_r000.
                IF sy-subrc EQ 0.
                  COMMIT WORK.
                  LOOP AT gt_r000 INTO gs_r000 WHERE bukrs = gs_h001-bukrs
                                               AND mnumber = gs_h001-mnumber
                                               AND gsber   = gs_h001-gsber
                                               AND monat   = gs_h001-monat
                                               AND gjahr   = gs_h001-gjahr
                                               AND version = gs_v001-version.
                    gs_r000-mresult = 'V'.
                    MODIFY gt_r000 FROM gs_r000.
                  ENDLOOP.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
        CLEAR: gs_r000, gs_v001, lv_biggest_mnumber.
      ENDIF.

      IF p_bal IS NOT INITIAL.

        CLEAR gt_balance[].

        CLEAR gv_dmbtr.

        CASE gs_h001-hesap_tur.
          WHEN 'M'.

            zreco_object->zreco_get_balance(
            EXPORTING
              i_bukrs  = gs_h001-bukrs
              i_kunnr  = gs_h001-hesap_no
              i_monat  = gs_h001-monat
              i_gjahr  = gs_h001-gjahr
              i_all    = gs_h001-xall
              i_tran   = gs_h001-xtran
              i_kurst  = gs_h001-kurst
            IMPORTING
              e_dmbtr  = gv_dmbtr
              et_cform = gt_balance
             ).

          WHEN 'S'.

            zreco_object->zreco_get_balance(
                EXPORTING
                  i_bukrs  = gs_h001-bukrs
                  i_kunnr  = gs_h001-hesap_no
                  i_monat  = gs_h001-monat
                  i_gjahr  = gs_h001-gjahr
                  i_all    = gs_h001-xall
                  i_tran   = gs_h001-xtran
                  i_kurst  = gs_h001-kurst
                IMPORTING
                  e_dmbtr  = gv_dmbtr
                  et_cform = gt_balance
                 ).

        ENDCASE.
      ENDIF.


      READ TABLE gt_v001 INTO gs_v001 WITH KEY bukrs = gs_h001-bukrs
           gsber = gs_h001-gsber
           mnumber = gs_h001-mnumber
           monat = gs_h001-monat
           gjahr = gs_h001-gjahr.

      CHECK sy-subrc EQ 0.

      zreco_object->zreco_auth(
      EXPORTING
        i_bukrs     = gs_h001-bukrs
        i_hesap_tur = gs_h001-hesap_tur
        i_hesap_no  = gs_h001-hesap_no
        i_mtype     = gs_h001-mtype
        i_uname     = gs_v001-ernam
        i_ftype     = gs_h001-ftype
        i_ktokl     = gs_h001-ktokl
      IMPORTING
        e_auth      = lv_auth
       ).

      IF lv_auth IS INITIAL.
        DELETE gt_h001.
        CONTINUE.
      ENDIF.

      lv_row = lv_row + 1.

      IF p_all IS INITIAL.
        IF p_compl IS NOT INITIAL.
          CHECK gs_h001-xstatu EQ ''.
        ENDIF.
        IF p_anwsr IS NOT INITIAL.
          CHECK gs_h001-xstatu EQ 'X'.
        ENDIF.
      ENDIF.


      IF gs_h001-gsber IS NOT INITIAL.
        gv_gsber = 'X'.
      ENDIF.

      MOVE-CORRESPONDING gs_h001 TO gs_out.
      MOVE-CORRESPONDING gs_v001 TO gs_out.

      READ TABLE gt_chat ASSIGNING FIELD-SYMBOL(<lfs_chat>) WITH KEY bukrs = gs_out-bukrs
                                                                     gsber = gs_out-gsber
                                                                   mnumber = gs_out-mnumber
                                                                     monat = gs_out-monat
                                                                     gjahr = gs_out-gjahr
                                                                 hesap_tur = gs_out-hesap_tur
                                                                  hesap_no = gs_out-hesap_no.
      IF sy-subrc EQ 0.
        IF gs_chat-readflag IS NOT INITIAL.
*          gs_out-chat = icon_display_note.
        ELSE.
*          gs_out-chat = icon_text_ina.
        ENDIF.
      ELSE.
        gs_out-chat = space.
      ENDIF.

      READ TABLE gt_chd1 INTO gs_chd1
                         WITH KEY bukrs = gs_h001-bukrs
                                  gsber = gs_h001-gsber
                                  mnumber = gs_h001-mnumber
                                  monat = gs_h001-monat
                                  gjahr = gs_h001-gjahr.

      IF sy-subrc EQ 0.
        gs_out-fgnam = gs_chd1-fgnam.
        IF gs_chd1-fgnam IS NOT INITIAL.
          gs_out-complete = 'X'.
        ENDIF.
        gs_out-sdate = gs_chd1-erdat.
        gs_out-fdate = gs_chd1-fgdat.
        gs_out-stime = gs_chd1-erzeit.
        gs_out-ftime = gs_chd1-fguhr.
      ENDIF.

      lv_mod = lv_row MOD 2.

      IF lv_mod NE 0.
        lv_color = 'C100'.
      ELSE.
        lv_color = 'C500'.
      ENDIF.

      me->get_name_text( EXPORTING is_out = gs_out CHANGING cs_out = gs_out ).

      IF gs_out-hesap_tur = 'M'.
        READ TABLE gt_custno ASSIGNING FIELD-SYMBOL(<lfs_custno>) WITH KEY hesap_no = gs_out-hesap_no.
        IF sy-subrc = 0.
*          WRITE icon_status_ok AS ICON TO gs_out-kars_alan.
        ELSE.
*          WRITE icon_bw_apd_column_to_row AS ICON TO gs_out-kars_alan.
        ENDIF.
      ELSEIF gs_out-hesap_tur = 'S'.
        READ TABLE gt_vendno ASSIGNING FIELD-SYMBOL(<lfs_vendo>) WITH KEY hesap_no = gs_out-hesap_no.
        IF sy-subrc = 0.
*          WRITE icon_status_ok AS ICON TO gs_out-kars_alan.
        ELSE.
*          WRITE icon_bw_apd_column_to_row AS ICON TO gs_out-kars_alan.
        ENDIF.
      ENDIF.


* Cevap bilgileri
      CLEAR gs_r000.
      READ TABLE gt_r000 INTO gs_r000 WITH KEY bukrs = gs_h001-bukrs
                                               gsber = gs_h001-gsber
                                               mnumber = gs_h001-mnumber
                                               monat = gs_h001-monat
                                               gjahr = gs_h001-gjahr
                                               version = gs_v001-version.

      IF it_result[] IS NOT INITIAL.
*      CHECK sy-subrc EQ 0.
        CHECK gs_r000-mresult IN it_result.
      ENDIF.

      IF sy-subrc EQ 0.

        CASE gs_r000-mresult.
          WHEN 'H'.
*          WRITE icon_incomplete AS ICON TO gs_out-xresult.

            CONCATENATE gs_out-xresult 'Mutabık değil' "TEXT-s03 "Yiğitcan Özdemir
            INTO gs_out-xresult SEPARATED BY space.
          WHEN 'E'.
*          WRITE icon_checked AS ICON TO gs_out-xresult.

            CONCATENATE gs_out-xresult 'Mutabık'"TEXT-s02
            INTO gs_out-xresult SEPARATED BY space.
          WHEN 'T'.
*          WRITE icon_information AS ICON TO gs_out-xresult.

            CONCATENATE gs_out-xresult 'Kayıt bulunmamakta'"TEXT-s25
            INTO gs_out-xresult SEPARATED BY space.
          WHEN 'I'. "
*          WRITE icon_message_warning AS ICON TO gs_out-xresult.

            CONCATENATE gs_out-xresult 'İlgili kişi ben değilim'"TEXT-s30
            INTO gs_out-xresult SEPARATED BY space.

          WHEN 'V'.
*          WRITE icon_led_red AS ICON TO gs_out-xresult.

            CONCATENATE gs_out-xresult 'Hükümsüz'"TEXT-s31
            INTO gs_out-xresult SEPARATED BY space.

          WHEN OTHERS.
*          WRITE icon_time AS ICON TO gs_out-xresult.

            CONCATENATE gs_out-xresult 'Cevap Bekleniyor'"TEXT-s01
            INTO gs_out-xresult SEPARATED BY space.
        ENDCASE.

        gs_out-mresult = gs_r000-mresult.
        gs_out-mtext = gs_r000-mtext.


      ELSE.

*      WRITE icon_time AS ICON TO gs_out-xresult.

        CONCATENATE gs_out-xresult 'Cevap Bekleniyor'"TEXT-s01
        INTO gs_out-xresult SEPARATED BY space.

      ENDIF.

      lv_xresult = gs_out-xresult.


      CASE gs_h001-mtype.
        WHEN 'B'.

* B formu bilgileri
          LOOP AT gt_b001 INTO gs_b001 WHERE bukrs EQ gs_v001-bukrs
                                         AND gsber EQ gs_v001-gsber
                                         AND mnumber EQ gs_v001-mnumber
                                         AND monat EQ gs_v001-monat
                                         AND gjahr EQ gs_v001-gjahr
                                         AND version EQ gs_v001-version.

*-mutabakat sonuç bilgisi
            READ TABLE gt_r000 INTO gs_r000 WITH KEY bukrs = gs_b001-bukrs
                                                     gsber = gs_b001-gsber
                                                     mnumber = gs_b001-mnumber
                                                     monat = gs_b001-monat
                                                     gjahr = gs_b001-gjahr
                                                     version = gs_b001-version.

            IF sy-subrc EQ 0.
              gs_out-mresult = gs_r000-mresult.
            ENDIF.
            gs_out-xresult =  lv_xresult.


            MOVE-CORRESPONDING gs_h001 TO gs_out.
            MOVE-CORRESPONDING gs_v001 TO gs_out.
            MOVE-CORRESPONDING gs_b001 TO gs_out.

            READ TABLE gt_chat ASSIGNING <lfs_chat> WITH KEY bukrs = gs_out-bukrs
                                                            gsber = gs_out-gsber
                                                            mnumber = gs_out-mnumber
                                                            monat = gs_out-monat
                                                            gjahr = gs_out-gjahr
                                                            hesap_tur = gs_out-hesap_tur
                                                            hesap_no = gs_out-hesap_no.

            IF sy-subrc EQ 0.
              IF gs_chat-readflag IS NOT INITIAL.
*                gs_out-chat = icon_display_note.
              ELSE.
*                gs_out-chat = icon_text_ina.
              ENDIF.
            ELSE.
              gs_out-chat = space.
            ENDIF.

            IF gs_out-xfirst IS INITIAL.
              gs_out-xfirst = 'X'.
            ENDIF.


* B Formu Cevap bilgileri
            READ TABLE gt_r002 INTO gs_r002 WITH KEY bukrs = gs_v001-bukrs
                                                     gsber = gs_v001-gsber
                                                 mnumber = gs_v001-mnumber
                                                 monat = gs_v001-monat
                                                 gjahr = gs_v001-gjahr
                                                version = gs_v001-version.


            IF sy-subrc EQ 0.
              gs_out-r_count_bs = gs_r002-count_bs.
              gs_out-r_base_bs =  gs_r002-base_bs.
              gs_out-r_count_ba = gs_r002-count_ba.
              gs_out-r_base_ba = gs_r002-base_ba.
              gs_out-r_tvbas = gs_r002-tvbas.
              gs_out-r_tvste = gs_r002-tvste.
              gs_out-responder_name = gs_r002-responder_name.
              gs_out-responder_surname = gs_r002-responder_surname.
            ENDIF.

* Cevap başlık bilgileri
            READ TABLE gt_h002 INTO gs_h002
            WITH KEY bukrs = gs_out-bukrs
                     gsber = gs_out-gsber
                     mnumber = gs_out-mnumber
                     monat = gs_out-monat
                     gjahr = gs_out-gjahr
                     hesap_tur = gs_out-hesap_tur
                     hesap_no = gs_out-hesap_no.

            IF gs_out-xfirst IS NOT INITIAL.

              IF gs_h002-file_1 IS NOT INITIAL.
                gs_out-file_1  = gs_h002-file_1.
*                gs_out-ifile_1 = icon_xls.
              ELSE.
*                gs_out-ifile_1 = gc_yukle.
              ENDIF.
              gs_out-file_2 = gs_h002-file_2.
              IF gs_h002-file_2 IS NOT INITIAL.
                gs_out-file_2  = gs_h002-file_2.
*                gs_out-ifile_2 = icon_pdf.
              ELSE.
*                gs_out-ifile_2 = gc_yukle.
              ENDIF.
              IF gs_h002-file_3 IS NOT INITIAL.
                gs_out-file_3  = gs_h002-file_3.
*                gs_out-ifile_3 = icon_qualify.
              ELSE.
*                gs_out-ifile_3 = gc_yukle.
              ENDIF.

              gs_out-r_ernam = gs_h002-ernam.
              gs_out-r_erdat = gs_h002-erdat.
              gs_out-r_erzei = gs_h002-erzei.
              gs_out-wuser = gs_h002-wuser.
              gs_out-webip = gs_h002-webip.
              gs_out-terminal = gs_h002-terminal.
              gs_out-no_data = gs_h002-no_data.

              gs_out-xcount = 1.

            ENDIF.

* Hatırlatma sayısı
            LOOP AT gt_remh ASSIGNING FIELD-SYMBOL(<lfs_remh>) WHERE bukrs EQ gs_out-bukrs
              AND mnumber EQ gs_out-mnumber
              AND monat EQ gs_out-monat
              AND gjahr EQ gs_out-gjahr.
              gs_out-reminder = gs_out-reminder + 1.
            ENDLOOP.

            IF sy-subrc NE 0.
              LOOP AT gt_remd ASSIGNING FIELD-SYMBOL(<lfs_remd>) WHERE bukrs EQ gs_out-bukrs
                AND mnumber EQ gs_out-mnumber
                AND monat EQ gs_out-monat
                AND gjahr EQ gs_out-gjahr.

              ENDLOOP.
            ENDIF.

*            me->get_name_text(  ).
            me->get_name_text( EXPORTING is_out = gs_out CHANGING cs_out = gs_out ). "YiğitcanÖzdemir

* Muhataplar
            READ TABLE gt_business INTO gs_business WITH KEY hesap_no = gs_out-hesap_no
                     hesap_tur = gs_out-hesap_tur.

            IF sy-subrc EQ 0.
              gs_out-parvw = gs_business-partner.
              gs_out-parvw_name = gs_business-name.
            ENDIF.

* Mutabakat sorumlusu
            CASE gs_out-hesap_tur.
              WHEN 'S'.
                READ TABLE gt_user ASSIGNING FIELD-SYMBOL(<lfs_user>) WITH KEY bukrs = iv_bukrs
                                                                               lifnr = gs_out-hesap_no.
                IF sy-subrc EQ 0.
                  gs_out-uname1 = <lfs_user>-uname1.
                  gs_out-uname2 = <lfs_user>-uname2.
                  gs_out-uname3 = <lfs_user>-uname3.
                ENDIF.
              WHEN 'M'.
                READ TABLE gt_user ASSIGNING <lfs_user> WITH KEY bukrs = iv_bukrs
                                                                 kunnr = gs_out-hesap_no.
                IF sy-subrc EQ 0.
                  gs_out-uname1 = <lfs_user>-uname1.
                  gs_out-uname2 = <lfs_user>-uname2.
                  gs_out-uname3 = <lfs_user>-uname3.
                ENDIF.
            ENDCASE.

            APPEND gs_out TO gt_out.

            CLEAR: gs_out, gt_out.

          ENDLOOP.


        WHEN 'C' OR 'X'.

          CLEAR: lv_balance, lv_r_balance, lv_o_balance, lv_n_balance,
                 lv_first.

          READ TABLE gt_c001 TRANSPORTING NO FIELDS
          WITH KEY  bukrs = gs_v001-bukrs
                    gsber = gs_v001-gsber
                    mnumber = gs_v001-mnumber
                    monat = gs_v001-monat
                    gjahr = gs_v001-gjahr
                    version = gs_v001-version
                    xsum = 'X'.

          IF sy-subrc EQ 0.

            lv_tabix = sy-tabix.

* Cari mutabakat bilgileri
            LOOP AT gt_c001 INTO gs_c001 FROM lv_tabix
                                        WHERE xsum EQ 'X'.

              "<--- hkizilkaya -mutabakat sonuç bilgisi
              READ TABLE gt_r000 INTO gs_r000 WITH KEY bukrs = gs_c001-bukrs
                                                       gsber = gs_c001-gsber
                                                       mnumber = gs_c001-mnumber
                                                       monat = gs_c001-monat
                                                       gjahr = gs_c001-gjahr
                                                       version = gs_c001-version.
              IF sy-subrc EQ 0.
                gs_out-mresult = gs_r000-mresult.
                gs_out-mtext = gs_r000-mtext.
              ENDIF.
              gs_out-xresult =  lv_xresult.

              "Mutabakat mail bilgisi
              READ TABLE lt_mail INTO ls_mail WITH KEY  bukrs   =  gs_h001-bukrs
                                                        gsber   =  gs_h001-gsber
                                                        mnumber =  gs_h001-mnumber
                                                        monat   =  gs_h001-monat
                                                        gjahr   =  gs_h001-gjahr.
              gs_out-receiver = ls_mail-receiver.


              IF gs_c001-mnumber NE gs_v001-mnumber.
                EXIT.
              ENDIF.

              gs_out-xcolor = lv_color.

              MOVE-CORRESPONDING gs_h001 TO gs_out.
              MOVE-CORRESPONDING gs_v001 TO gs_out.
              MOVE-CORRESPONDING gs_c001 TO gs_out.

              READ TABLE gt_chat ASSIGNING <lfs_chat> WITH KEY bukrs = gs_out-bukrs
                                                               gsber = gs_out-gsber
                                                               mnumber = gs_out-mnumber
                                                               monat = gs_out-monat
                                                               gjahr = gs_out-gjahr
                                                               hesap_tur = gs_out-hesap_tur
                                                               hesap_no = gs_out-hesap_no.
              IF sy-subrc EQ 0.
                IF <lfs_chat>-readflag IS NOT INITIAL.
**                  gs_out-chat = icon_display_note.
                ELSE.
*                  gs_out-chat = icon_text_ina.
                ENDIF.
              ELSE.
                gs_out-chat = space.
              ENDIF.

* UPB Bakiye
              lv_balance = lv_balance + gs_c001-dmbtr.


* Cevap tutarları
              READ TABLE gt_r001 INTO gs_r001 WITH KEY bukrs = gs_c001-bukrs
                                                       gsber = gs_c001-gsber
                                                       mnumber = gs_c001-mnumber
                                                       monat = gs_c001-monat
                                                       gjahr = gs_c001-gjahr
                                                       waers = gs_c001-waers
                                                       xsum = gs_c001-xsum.

              IF sy-subrc EQ 0.
                IF gs_r001-waers NE 'TRY'.


*                  cl_exchange_rates=>convert_to_local_currency(
*                     EXPORTING
*                         date             = sy-datum
*                         foreign_amount   = gs_r001-wrbtr
*                         foreign_currency = gs_r001-waers
*                         local_currency   = 'TRY'
*                       IMPORTING
*                         local_amount     = lv_wrbtr
*                         ).


                  gs_out-r_dmbtr = lv_wrbtr.
                ELSE.
                  lv_wrbtr = gs_r001-wrbtr.
                  gs_out-r_dmbtr = gs_r001-wrbtr.
                ENDIF.

                lv_r_balance = lv_r_balance + lv_wrbtr.
                gs_out-r_wrbtr = gs_r001-wrbtr.
                gs_out-r_waers = gs_r001-waers.
                gs_out-responder_name = gs_r001-responder_name.
                gs_out-responder_surname = gs_r001-responder_surname.
              ENDIF.

              READ TABLE gt_c002 INTO gs_c002 WITH KEY bukrs = gs_c001-bukrs
                                                       gsber = gs_c001-gsber
                                                     mnumber =  gs_c001-mnumber
                                                       monat = gs_c001-monat
                                                       gjahr = gs_c001-gjahr
                                                       waers = gs_c001-waers
                                                        xsum = gs_c001-xsum
                                                       ltext = gs_c001-ltext
                                                     version =  gs_v001-version.


              IF sy-subrc EQ 0.
                lv_o_balance = lv_o_balance + gs_c002-dmbtr.
                gs_out-o_dmbtr = gs_c002-dmbtr.
                gs_out-o_wrbtr = gs_c002-wrbtr.
              ENDIF.

* Sonraki dönem tutarları (firma)
              READ TABLE gt_c003 INTO gs_c003 WITH KEY bukrs = gs_c001-bukrs
                                                       gsber = gs_c001-gsber
                                                     mnumber = gs_c001-mnumber
                                                       monat = gs_c001-monat
                                                       gjahr = gs_c001-gjahr
                                                       waers = gs_c001-waers
                                                        xsum = gs_c001-xsum
                                                       ltext = gs_c001-ltext
                                                     version = gs_v001-version.

              IF sy-subrc EQ 0.
                lv_o_balance = lv_o_balance + gs_c003-dmbtr.
                gs_out-o_dmbtr = gs_out-o_dmbtr + gs_c003-dmbtr.
                gs_out-o_wrbtr = gs_out-o_wrbtr + gs_c003-wrbtr.
              ENDIF.

              READ TABLE gt_h002 INTO gs_h002
              WITH KEY bukrs = gs_out-bukrs
                       gsber = gs_out-gsber
                       mnumber = gs_out-mnumber
                       monat = gs_out-monat
                       gjahr = gs_out-gjahr
                       hesap_tur = gs_out-hesap_tur
                       hesap_no = gs_out-hesap_no.


              IF lv_first IS INITIAL.

                gs_out-xfirst = 'X'.

                IF gs_h002-file_1 IS NOT INITIAL.
                  gs_out-file_1  = gs_h002-file_1.
*                  gs_out-ifile_1 = icon_xls.
                ELSE.
*                  gs_out-ifile_1 = gc_yukle.
                ENDIF.
                gs_out-file_2 = gs_h002-file_2.
                IF gs_h002-file_2 IS NOT INITIAL.
                  gs_out-file_2  = gs_h002-file_2.
*                  gs_out-ifile_2 = icon_pdf.
                ELSE.
*                  gs_out-ifile_2 = gc_yukle.
                ENDIF.
                IF gs_h002-file_3 IS NOT INITIAL.
                  gs_out-file_3  = gs_h002-file_3.
*                  gs_out-ifile_3 = icon_qualify.
                ELSE.
*                  gs_out-ifile_3 = gc_yukle.
                ENDIF.

                gs_out-r_ernam = gs_h002-ernam.
                gs_out-r_erdat = gs_h002-erdat.
                gs_out-r_erzei = gs_h002-erzei.
                gs_out-wuser = gs_h002-wuser.
                gs_out-webip = gs_h002-webip.
                gs_out-terminal = gs_h002-terminal.
                gs_out-no_data = gs_h002-no_data.

                gs_out-xcount = 1.

                gs_out-balance = lv_balance.
                gs_out-r_balance = lv_r_balance.
                gs_out-o_balance = lv_o_balance.

* Hatırlatma sayısı
                LOOP AT gt_remh ASSIGNING <lfs_remh> WHERE bukrs EQ gs_out-bukrs
                  AND mnumber EQ gs_out-mnumber
                  AND monat EQ gs_out-monat
                  AND gjahr EQ gs_out-gjahr.
                  gs_out-reminder = gs_out-reminder + 1.
                ENDLOOP.

                IF sy-subrc NE 0.
                  LOOP AT gt_remd ASSIGNING <lfs_remd> WHERE bukrs EQ gs_out-bukrs
                    AND mnumber EQ gs_out-mnumber
                    AND monat EQ gs_out-monat
                    AND gjahr EQ gs_out-gjahr.
                    gs_out-reminder = gs_out-reminder + 1.
                  ENDLOOP.
                ENDIF.
              ELSE.

                gs_out-xrow = 1.

              ENDIF.

*              me->get_name_text(  )."YiğitcanÖzdemir
              me->get_name_text( EXPORTING is_out = gs_out CHANGING cs_out = gs_out ).

              IF gs_out-xno_value IS INITIAL.
*              IF gs_out-xno_local_curr IS INITIAL.
                gs_out-d_balance = gs_out-balance - gs_out-r_balance.
                gs_out-d_dmbtr = gs_out-dmbtr - gs_out-r_dmbtr.
*              ENDIF.

                gs_out-d_wrbtr = gs_out-wrbtr - gs_out-r_wrbtr.

*              gs_color-fname = 'D_BALANCE'.
*              gs_color-color-col = 6.
*              gs_color-color-inv = 1.
*              APPEND gs_color TO gs_out-xcolorc.

*              gs_color-fname = 'D_DMBTR'.
*              gs_color-color-col = 6.
*              gs_color-color-inv = 1.
*              APPEND gs_color TO gs_out-xcolorc.

*              gs_color-fname = 'D_WRBTR'.
*              gs_color-color-col = 6.
*              gs_color-color-inv = 1.
*              APPEND gs_color TO gs_out-xcolorc.

*              gs_color-fname = 'O_BALANCE'.
*              gs_color-color-col = 4.
*              gs_color-color-inv = 1.
*              APPEND gs_color TO gs_out-xcolorc.

*              gs_color-fname = 'O_DMBTR'.
*              gs_color-color-col = 4.
*              gs_color-color-inv = 1.
*              APPEND gs_color TO gs_out-xcolorc.

*              gs_color-fname = 'O_WRBTR'.
*              gs_color-color-col = 4.
*              gs_color-color-inv = 1.
*              APPEND gs_color TO gs_out-xcolorc.
*
*              gs_color-fname = 'N_BALANCE'.
*              gs_color-color-col = 3.
*              gs_color-color-inv = 0.
*              APPEND gs_color TO gs_out-xcolorc.
*
*              gs_color-fname = 'N_DMBTR'.
*              gs_color-color-col = 3.
*              gs_color-color-inv = 0.
*              APPEND gs_color TO gs_out-xcolorc.
*
*              gs_color-fname = 'N_WRBTR'.
*              gs_color-color-col = 3.
*              gs_color-color-inv = 0.
*              APPEND gs_color TO gs_out-xcolorc.

              ENDIF.

              IF p_bal IS NOT INITIAL.

*              gs_color-fname = 'C_BALANCE'.
*              gs_color-color-col = 3.
*              gs_color-color-inv = 0.
*              APPEND gs_color TO gs_out-xcolorc.
*
*              gs_color-fname = 'C_DMBTR'.
*              gs_color-color-col = 3.
*              gs_color-color-inv = 0.
*              APPEND gs_color TO gs_out-xcolorc.
*
*              gs_color-fname = 'C_WRBTR'.
*              gs_color-color-col = 3.
*              gs_color-color-inv = 0.
*              APPEND gs_color TO gs_out-xcolorc.

                CLEAR gs_balance.

                READ TABLE gt_balance INTO gs_balance
                WITH KEY xsum = gs_out-xsum
                        ltext = gs_out-ltext
                        akont = gs_out-akont
                        waers = gs_out-waers.

                IF sy-subrc EQ 0.
                  gs_out-c_dmbtr = gs_balance-dmbtr.
                  gs_out-c_wrbtr = gs_balance-wrbtr.
                  IF lv_first IS INITIAL.
                    gs_out-c_balance = gv_dmbtr.
                  ENDIF.
                ENDIF.

                IF gs_out-balance NE gv_dmbtr.
                  gs_out-bal_change = 'X'.
                ELSE.
                  CLEAR gs_out-bal_change .
                ENDIF.

              ENDIF.


              gs_out-n_dmbtr = gs_out-d_dmbtr + gs_out-o_dmbtr.
              gs_out-n_wrbtr = gs_out-d_wrbtr + gs_out-o_wrbtr.

              lv_n_balance = lv_n_balance + gs_out-n_dmbtr.

              IF lv_first IS INITIAL.
                gs_out-n_balance = lv_n_balance.
              ENDIF.

              CLEAR ls_date.

*            CALL FUNCTION '/ITETR/RECO_LST_COMPARE_DATE_2'
*              EXPORTING
*                is_h001     = gs_h001
*              IMPORTING
*                e_last_info = ls_date.

              zreco_object->zreco_lst_compare_date_2(
                EXPORTING
                  is_h001     = gs_h001
                IMPORTING
                  e_last_info = ls_date
              ).


              gs_out-first_date   = ls_date-first_date .
              gs_out-last_date    = ls_date-last_date  .
              gs_out-last_mnumber = ls_date-last_mnumber.
              gs_out-last_monat   = ls_date-last_monat.
              gs_out-last_gjahr   = ls_date-last_gjahr.

* Muhataplar
              READ TABLE gt_business INTO gs_business
              WITH KEY hesap_no = gs_out-hesap_no
                       hesap_tur = gs_out-hesap_tur.

              IF sy-subrc EQ 0.
                gs_out-parvw = gs_business-partner.
                gs_out-parvw_name = gs_business-name.
              ENDIF.

* Mutabakat sorumlusu
              CASE gs_out-hesap_tur.
                WHEN 'S'.
                  READ TABLE gt_user ASSIGNING <lfs_user> WITH KEY bukrs = iv_bukrs
                                                                   lifnr = gs_out-hesap_no.
                  IF sy-subrc EQ 0.
                    gs_out-uname1 = <lfs_user>-uname1.
                    gs_out-uname2 = <lfs_user>-uname2.
                    gs_out-uname3 = <lfs_user>-uname3.
                  ENDIF.
                WHEN 'M'.
                  READ TABLE gt_user ASSIGNING <lfs_user> WITH KEY bukrs = iv_bukrs
                                              kunnr = gs_out-hesap_no.
                  IF sy-subrc EQ 0.
                    gs_out-uname1 = <lfs_user>-uname1.
                    gs_out-uname2 = <lfs_user>-uname2.
                    gs_out-uname3 = <lfs_user>-uname3.
                  ENDIF.
              ENDCASE.

              APPEND gs_out TO gt_out.

              CLEAR gs_out-xresult.

              IF lv_first IS INITIAL.

                lv_first = 'X'.

              ELSE.

                gs_out-r_balance = lv_r_balance.

                gs_out-o_balance = lv_o_balance.

                gs_out-n_balance = lv_n_balance.

                gs_out-balance = lv_balance.

                gs_out-d_balance = gs_out-balance - gs_out-r_balance.

                IF p_bal IS NOT INITIAL.

                  IF gs_out-balance NE gv_dmbtr.
                    gs_out-bal_change = 'X'.
                  ELSE.
                    CLEAR gs_out-bal_change .
                  ENDIF.

                ENDIF.

                MODIFY gt_out FROM gs_out
                TRANSPORTING balance r_balance d_balance o_balance
                             n_balance bal_change
                WHERE bukrs EQ gs_out-bukrs
                AND monat EQ gs_out-monat
                AND gjahr EQ gs_out-gjahr
                AND mnumber EQ gs_out-mnumber
                AND xfirst EQ 'X'.

              ENDIF.

              CLEAR gs_out.

            ENDLOOP.

          ENDIF.

          MOVE-CORRESPONDING gs_h001 TO gs_out.

          READ TABLE gt_chat ASSIGNING <lfs_chat> WITH KEY bukrs = gs_out-bukrs
                                                           gsber = gs_out-gsber
                                                         mnumber = gs_out-mnumber
                                                           monat = gs_out-monat
                                                           gjahr = gs_out-gjahr
                                                       hesap_tur = gs_out-hesap_tur
                                                        hesap_no = gs_out-hesap_no.
          IF sy-subrc EQ 0.
            IF gs_chat-readflag IS NOT INITIAL.
*              gs_out-chat = icon_display_note.
            ELSE.
*              gs_out-chat = icon_text_ina.
            ENDIF.
          ELSE.
            gs_out-chat = space.
          ENDIF.

          IF p_odk IS NOT INITIAL.

            READ TABLE gt_c001 TRANSPORTING NO FIELDS
            WITH KEY  bukrs = gs_v001-bukrs
                      gsber = gs_v001-gsber
                      mnumber = gs_v001-mnumber
                      monat = gs_v001-monat
                      gjahr = gs_v001-gjahr
                      version = gs_v001-version
                      xsum = ''.

            IF sy-subrc EQ 0.

              lv_tabix = sy-tabix.

* Cari mutabakat istatiksel ÖDK bilgileri
              LOOP AT gt_c001 INTO gs_c001 FROM lv_tabix
                                          WHERE xsum EQ ''.


                READ TABLE gt_r000 INTO gs_r000 WITH KEY bukrs = gs_c001-bukrs
                                                         gsber = gs_c001-gsber
                                                         mnumber = gs_c001-mnumber
                                                         monat = gs_c001-monat
                                                         gjahr = gs_c001-gjahr
                                                         version = gs_c001-version.
                IF sy-subrc EQ 0.
                  gs_out-mresult = gs_r000-mresult.
                ENDIF.
                gs_out-xresult =  lv_xresult.


                IF gs_c001-mnumber NE gs_v001-mnumber.
                  EXIT.
                ENDIF.

                gs_out-xcolor = lv_color.

                MOVE-CORRESPONDING gs_c001 TO gs_out.

                READ TABLE gt_chat ASSIGNING <lfs_chat> WITH KEY bukrs = gs_out-bukrs
                                                                gsber = gs_out-gsber
                                                                mnumber = gs_out-mnumber
                                                                monat = gs_out-monat
                                                                gjahr = gs_out-gjahr
                                                                hesap_tur = gs_out-hesap_tur
                                                                hesap_no = gs_out-hesap_no.
                IF sy-subrc EQ 0.
                  IF gs_chat-readflag IS NOT INITIAL.
*                    gs_out-chat = icon_display_note.
                  ELSE.
*                    gs_out-chat = icon_text_ina.
                  ENDIF.
                ELSE.
                  gs_out-chat = space.
                ENDIF.

                READ TABLE gt_balance INTO gs_balance
                WITH KEY xsum = gs_out-xsum
                        ltext = gs_out-ltext
                        akont = gs_out-akont
                        waers = gs_out-waers.

                IF sy-subrc EQ 0.
                  gs_out-c_dmbtr = gs_balance-dmbtr.
                  gs_out-c_wrbtr = gs_balance-wrbtr.
                ENDIF.

* Muhataplar
                READ TABLE gt_business INTO gs_business
                WITH KEY hesap_no = gs_out-hesap_no
                         hesap_tur = gs_out-hesap_tur.

                IF sy-subrc EQ 0.
                  gs_out-parvw = gs_business-partner.
                  gs_out-parvw_name = gs_business-name.
                ENDIF.

* Mutabakat sorumlusu
                CASE gs_out-hesap_tur.
                  WHEN 'S'.
                    READ TABLE gt_user ASSIGNING <lfs_user> WITH KEY bukrs = iv_bukrs
                                                lifnr = gs_out-hesap_no.
                    IF sy-subrc EQ 0.
                      gs_out-uname1 = <lfs_user>-uname1.
                      gs_out-uname2 = <lfs_user>-uname2.
                      gs_out-uname3 = <lfs_user>-uname3.
                    ENDIF.
                  WHEN 'M'.
                    READ TABLE gt_user ASSIGNING <lfs_user> WITH KEY bukrs = iv_bukrs
                                                                     kunnr = gs_out-hesap_no.
                    IF sy-subrc EQ 0.
                      gs_out-uname1 = <lfs_user>-uname1.
                      gs_out-uname2 = <lfs_user>-uname2.
                      gs_out-uname3 = <lfs_user>-uname3.
                    ENDIF.
                ENDCASE.

                APPEND gs_out TO gt_out.

                CLEAR gs_out.

              ENDLOOP.

            ENDIF.

          ENDIF.

          IF gs_h001-xold IS NOT INITIAL AND
             gs_r000 IS NOT INITIAL AND
             gs_c001 IS INITIAL.
            APPEND gs_out TO gt_out.
          ENDIF.

* B Formu bilgileri (Her ikisi birlikte gönderilmiş ise
          READ TABLE gt_b001 INTO gs_b001
          WITH KEY bukrs = gs_v001-bukrs
                   gsber = gs_v001-gsber
                   mnumber = gs_v001-mnumber
                   monat = gs_v001-monat
                   gjahr = gs_v001-gjahr
                   version = gs_v001-version.

          IF sy-subrc EQ 0.
            MOVE-CORRESPONDING gs_b001 TO gs_out.

* B Formu Cevap bilgileri
            READ TABLE gt_r002 INTO gs_r002
            WITH KEY bukrs = gs_v001-bukrs
                     gsber = gs_v001-gsber
                     mnumber = gs_v001-mnumber
                     monat = gs_v001-monat
                     gjahr = gs_v001-gjahr
                     version = gs_v001-version.


            IF sy-subrc EQ 0.
              gs_out-r_count_bs = gs_r002-count_bs.
              gs_out-r_base_bs =  gs_r002-base_bs.
              gs_out-r_count_ba = gs_r002-count_ba.
              gs_out-r_base_ba = gs_r002-base_ba.
              gs_out-r_tvbas = gs_r002-tvbas.
              gs_out-r_tvste = gs_r002-tvste.
              gs_out-responder_name = gs_r002-responder_name.
              gs_out-responder_surname = gs_r002-responder_surname.
            ENDIF.


            MODIFY gt_out FROM gs_out
            TRANSPORTING count_bs base_bs count_ba base_ba tvbas tvste
                         r_count_bs r_base_bs r_count_ba r_base_ba
                         r_tvbas r_tvste
            WHERE bukrs EQ gs_out-bukrs
            AND monat EQ gs_out-monat
            AND gjahr EQ gs_out-gjahr
            AND mnumber EQ gs_out-mnumber
            AND xfirst EQ 'X'.

          ENDIF.

      ENDCASE.

      CLEAR: gs_h001,
             lv_xresult.

    ENDLOOP.

    SORT gt_out BY gjahr monat mnumber xrow .

    MOVE-CORRESPONDING gt_out TO mt_out.

  ENDMETHOD.