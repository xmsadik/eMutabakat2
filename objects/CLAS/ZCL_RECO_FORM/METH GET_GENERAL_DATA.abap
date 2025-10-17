  METHOD get_general_data.


    DATA: lt_taxm_d   TYPE SORTED TABLE OF zreco_taxm
                       WITH NON-UNIQUE KEY hesap_tur hesap_no vkn_tckn,
          lt_taxm_k   TYPE SORTED TABLE OF zreco_taxm
                       WITH NON-UNIQUE KEY hesap_tur hesap_no vkn_tckn,
*          lt_kna1     TYPE TABLE OF kna1,
*          ls_kna1     TYPE  kna1,
*          lt_lfa1     TYPE TABLE OF lfa1,
*          ls_lfa1     TYPE  lfa1,
          ls_kna1_tax TYPE zreco_kunnr_tax,
          ls_lfa1_tax TYPE zreco_lifnr_tax,
          ls_parm     TYPE zreco_parm.

    DATA: lv_gsber TYPE gsber.

    DATA: ls_taxm_d TYPE zreco_taxm,
          ls_taxm_k TYPE zreco_taxm.

    DATA ls_s_kunnr TYPE zreco_s_kunnr.
    DATA ls_s_lifnr TYPE zreco_s_lifnr.

    FIELD-SYMBOLS: <lr_exc>     TYPE zreco_s_kunnr,
                   <lr_exc_lif> TYPE zreco_s_lifnr.

    FIELD-SYMBOLS <lfs_lang>   TYPE zreco_lang.

    FIELD-SYMBOLS: <lr_kunnr> TYPE zreco_s_kunnr,
                   <lr_lifnr> TYPE zreco_s_lifnr.

    TYPES: r_loevm  TYPE RANGE OF zreco_adrs-loevm,
           ty_loevm TYPE LINE OF r_loevm,
           r_sperr  TYPE RANGE OF zreco_adrs-sperr,
           ty_sperr TYPE LINE OF r_sperr.

    FIELD-SYMBOLS: <lr_loevm> TYPE ty_loevm,
                   <lr_sperr> TYPE ty_sperr.

    TYPES: lr_bldat TYPE RANGE OF bldat,
           ty_bldat TYPE LINE OF lr_bldat.
    FIELD-SYMBOLS <fs_bldat> TYPE ty_bldat.

    TYPES: lr_budat TYPE RANGE OF budat,
           ty_budat TYPE LINE OF lr_budat.
    FIELD-SYMBOLS <fs_budat> TYPE ty_budat.


    TYPES: BEGIN OF ty_kna1_all,
             kunnr TYPE kunnr,
             ktokd TYPE ktokd,
           END OF ty_kna1_all.

    DATA: lt_kna1_all TYPE SORTED TABLE OF ty_kna1_all
                       WITH NON-UNIQUE KEY kunnr,
          ls_kna1_all LIKE LINE OF lt_kna1_all.

    TYPES: BEGIN OF ty_lfa1_all,
             lifnr TYPE lifnr,
             ktokk TYPE ktokk,
           END OF ty_lfa1_all.

    DATA: lt_lfa1_all TYPE SORTED TABLE OF ty_lfa1_all
                       WITH NON-UNIQUE KEY lifnr.


    DATA: lv_auth      TYPE abap_boolean,
          lv_kunnr_all TYPE abap_boolean,
          lv_lifnr_all TYPE abap_boolean.

    DATA : r_exc_kunnr TYPE RANGE OF kunnr,
           r_exc_lifnr TYPE RANGE OF lifnr.

    DATA: ls_unam TYPE zreco_unam.



    SELECT SINGLE COUNT( * )
                   FROM zreco_parm
                  WHERE pname EQ @zreco_if_common_types=>mc_parm_no_merge.
    IF sy-subrc EQ 0.
      IF p_seld IS NOT INITIAL.
        DELETE FROM zreco_taxm
              WHERE hesap_tur EQ @zreco_if_common_types=>mc_hesap_tur_m
               AND hesap_no IN @s_kunnr.
      ENDIF.

      IF p_selk IS NOT INITIAL.
        DELETE FROM zreco_taxm
              WHERE hesap_tur EQ @zreco_if_common_types=>mc_hesap_tur_s
                AND hesap_no IN @s_lifnr.
      ENDIF.

      IF p_seld IS NOT INITIAL.
        DELETE FROM zreco_taxm
              WHERE hesap_tur EQ @zreco_if_common_types=>mc_hesap_tur_m
                AND hesap_no IN @s_kunnr.
      ENDIF.

      IF p_selk IS NOT INITIAL.
        DELETE FROM zreco_taxm
              WHERE hesap_tur EQ @zreco_if_common_types=>mc_hesap_tur_s
                AND hesap_no IN @s_lifnr.
      ENDIF.
    ENDIF.


    SELECT SINGLE COUNT( * )
                   FROM zreco_parm
                  WHERE pname EQ @zreco_if_common_types=>mc_parm_s4hana.
    IF sy-subrc EQ 0.
      gv_s4hana = zreco_if_common_types=>mc_select_yes.
      SELECT SINGLE pvalue
               FROM zreco_parm

              WHERE pname EQ @zreco_if_common_types=>mc_parm_s4hana
                AND pvalue NE @zreco_if_common_types=>mc_select_no
                INTO @ls_parm.
      gv_ledger = ls_parm-pvalue.
    ELSE.
      CLEAR gv_s4hana.
    ENDIF.


* FORM TIPINE GÖRE VADE GÜNÜ KONTROLÜ
    SELECT SINGLE COUNT( * )
             FROM zreco_ftyp
            WHERE ftype EQ @p_ftype
              AND dunning EQ @zreco_if_common_types=>mc_select_yes.
*    IF sy-subrc EQ 0 AND p_verzn LE 0.    "p_verzn alanı selection screen de görmedim @YiğitcanÖzdemir
*      MESSAGE s154 DISPLAY LIKE 'E'.
*      LEAVE LIST-PROCESSING.
*    ENDIF.

* FORMDA KULLANıLAN ALANLAR
    SELECT hesap_tur, name2_x, name2_use
      FROM zreco_flds
      INTO CORRESPONDING FIELDS OF TABLE @gt_flds. "TODO

* TOPLU MAIL/FAKS GÖNDERIMI   @YiğitcanÖzdemir
*    IF p_job IS NOT INITIAL.
*      gv_job = p_job.
*    ENDIF.
*
*    IF p_job2 IS NOT INITIAL.
*      gv_job = p_job2.
*    ENDIF.

* DÖNEM KONTROLÜ
    IF p_period NOT BETWEEN 1 AND 12.
*      MESSAGE s052 DISPLAY LIKE 'E'. "@YiğitcanÖzdemir Yazılacak
*      LEAVE LIST-PROCESSING.
    ENDIF.

* MÜŞTERI NO SEÇILMEDIYSE
    LOOP AT s_kunnr INTO ls_s_kunnr WHERE sign EQ 'E'.
      APPEND INITIAL LINE TO r_exc_kunnr ASSIGNING <lr_exc>.
      <lr_exc> = ls_s_kunnr.
    ENDLOOP.

* HARIÇ TUTULAN MÜŞTERI VARSA
    LOOP AT s_kunnr INTO ls_s_kunnr WHERE option(1) EQ 'N'.
      APPEND INITIAL LINE TO r_exc_kunnr ASSIGNING <lr_exc>.
      <lr_exc> = ls_s_kunnr.
    ENDLOOP.

* SATıCı NO SEÇILMEDIYSE
    LOOP AT s_lifnr INTO ls_s_lifnr WHERE sign EQ 'E'.
      APPEND INITIAL LINE TO r_exc_lifnr ASSIGNING <lr_exc_lif>.
      <lr_exc_lif> = ls_s_lifnr.
    ENDLOOP.

* HARIÇ TUTULAN SATıCı VARSA
    LOOP AT s_lifnr INTO ls_s_lifnr WHERE option(1) EQ 'N'.
      APPEND INITIAL LINE TO r_exc_lifnr ASSIGNING <lr_exc_lif>.
      <lr_exc_lif> = ls_s_lifnr.
    ENDLOOP.

    IF s_gsber IS NOT INITIAL.
      READ TABLE s_gsber INTO DATA(ss_gsber) INDEX 1. "YiğitcanÖzdemir
      IF sy-subrc EQ 0.
        lv_gsber = ss_gsber-low.
      ENDIF.
    ELSE.
      lv_gsber = ' '.
    ENDIF.

    SELECT SINGLE *
             FROM zreco_adrs
            WHERE bukrs IN @s_bukrs
              AND gsber EQ @lv_gsber
              INTO @gs_adrs.

    IF sy-subrc NE 0.
*      MESSAGE s039 WITH s_bukrs-low DISPLAY LIKE 'E'. @YiğitcanÖzdemir Yazılacak
*      LEAVE LIST-PROCESSING.
    ENDIF.

    SELECT *
      FROM zreco_tole
     WHERE bukrs EQ @gs_adrs-bukrs
     INTO TABLE @gt_tole.

* YETKI KONTROLÜ
* HENÜZ BAKıM YAPıLMAMıŞSA HERKES YETKILIDIR
    SELECT SINGLE *
             FROM zreco_unam

            WHERE bukrs EQ @gs_adrs-bukrs
            INTO @ls_unam.
    IF sy-subrc NE 0.
      gv_auth = lv_auth = zreco_if_common_types=>mc_select_yes.
    ENDIF.

    IF p_exch IS NOT INITIAL AND gs_adrs-kurst IS INITIAL.
*      MESSAGE s098 DISPLAY LIKE 'E'. @YiğitcanÖzdemir
*      LEAVE LIST-PROCESSING.
    ENDIF.

* SILME GÖSTERGESI OLANLAR HARIÇ
    IF gs_adrs-loevm IS NOT INITIAL.
      APPEND INITIAL LINE TO r_loevm ASSIGNING <lr_loevm>.
      <lr_loevm>-sign   = 'I'.
      <lr_loevm>-option = 'EQ'.
      <lr_loevm>-low    = zreco_if_common_types=>mc_select_no.
    ENDIF.

* BLOKAJLı OLANLAR HARIÇ
    IF gs_adrs-sperr IS NOT INITIAL.
      APPEND INITIAL LINE TO r_sperr ASSIGNING <lr_sperr>.
      <lr_sperr>-sign   = 'I'.
      <lr_sperr>-option = 'EQ'.
      <lr_sperr>-low    = zreco_if_common_types=>mc_select_no.
    ENDIF.

* VKN BIRLEŞTIRME YAPıLMAYACAK MÜŞTERI/SATıCı
    SELECT bukrs, stcd2
      FROM zreco_etax
     WHERE bukrs IN @s_bukrs
      INTO TABLE @gt_etax.


** VKN BIRLEŞTIRILEN MÜŞTERI
    SELECT *
      FROM zreco_taxm
     INNER JOIN i_customercompany AS knb1 ON knb1~Customer EQ zreco_taxm~hesap_no
     WHERE zreco_taxm~hesap_tur EQ @zreco_if_common_types=>mc_hesap_tur_m
       AND zreco_taxm~vkn_tckn IN @s_vkn_cr
       AND knb1~CompanyCode IN @s_bukrs
       AND knb1~DeletionIndicator IN @r_loevm
       AND knb1~PhysicalInventoryBlockInd IN @r_sperr
       AND knb1~ReconciliationAccount NE ''
       APPENDING CORRESPONDING FIELDS OF TABLE @gt_taxm.
*
* VKN BIRLEŞTIRILEN SATıCı
    SELECT *
      FROM zreco_taxm
     INNER JOIN i_suppliercompany AS lfb1 ON lfb1~supplier EQ zreco_taxm~hesap_no

     WHERE zreco_taxm~hesap_tur EQ @zreco_if_common_types=>mc_hesap_tur_s
       AND zreco_taxm~vkn_tckn IN @s_vkn_ve "hkizilkaya satıcı tckn
       AND lfb1~CompanyCode IN @s_bukrs
       AND lfb1~DeletionIndicator IN @r_loevm
       AND lfb1~SupplierIsBlockedForPosting IN @r_sperr
       AND lfb1~ReconciliationAccount NE ''
        APPENDING CORRESPONDING FIELDS OF TABLE @gt_taxm.
*
** VKN BIRLEŞTIRILMEYEN MÜŞTERI
    IF p_seld IS NOT INITIAL.
      SELECT *
        FROM zreco_taxn
       INNER JOIN i_customercompany AS knb1 ON knb1~Customer EQ zreco_taxn~hesap_no

       WHERE zreco_taxn~hesap_tur EQ @zreco_if_common_types=>mc_hesap_tur_m
         AND zreco_taxn~hesap_no IN @s_kunnr
         AND zreco_taxn~vkn_tckn IN @s_vkn_cr
         AND knb1~CompanyCode IN @s_bukrs
         AND knb1~DeletionIndicator IN @r_loevm
         AND knb1~PhysicalInventoryBlockInd IN @r_sperr
         AND knb1~ReconciliationAccount NE ''
          APPENDING CORRESPONDING FIELDS OF TABLE @gt_taxn.
    ENDIF.
*
*
    IF p_selk IS NOT INITIAL.
* VKN BIRLEŞTIRILMEYEN SATıCı
      SELECT *
        FROM zreco_taxn
       INNER JOIN i_suppliercompany AS lfb1 ON lfb1~supplier EQ zreco_taxn~hesap_no

       WHERE zreco_taxn~hesap_tur EQ @zreco_if_common_types=>mc_hesap_tur_s
         AND zreco_taxn~hesap_no IN @s_lifnr
         AND zreco_taxn~vkn_tckn IN @s_vkn_ve "hkizilkaya satıcı tckn
         AND lfb1~CompanyCode IN @s_bukrs
         AND lfb1~DeletionIndicator IN @r_loevm
         AND lfb1~SupplierIsBlockedForPosting IN @r_sperr
         AND lfb1~ReconciliationAccount NE ''
            APPENDING CORRESPONDING FIELDS OF TABLE @gt_taxn.
    ENDIF.

* IF r_mform IS INITIAL. @YiğircanÖzdemir r_mform boş olma ihtimali yok
*      gv_mtype  = /itetr/reco_if_common_types=>mc_mtype_b.
*      gv_abtnr  = gs_adrs-abtnr_b.
*      gv_pafkt  = gs_adrs-pafkt_b.
*      gv_remark = gs_adrs-remark_b.
*      CLEAR: p_novl.
*    ENDIF.

    IF r_mform IS NOT INITIAL.
      gv_mtype  = zreco_if_common_types=>mc_mtype_c.

*      IF p_verzn IS INITIAL. @YiğitcanÖzdemir net vade tarihine göre gecikme selection screende yok ? tekrar bak
*        gv_abtnr = gs_adrs-abtnr.
*        gv_pafkt = gs_adrs-pafkt.
*        gv_remark = gs_adrs-remark.
*      ELSE.
      gv_abtnr = gs_adrs-abtnr_i.
      gv_pafkt = gs_adrs-pafkt_i.
      gv_remark = gs_adrs-remark_i.
*      ENDIF.
    ENDIF.
*
    IF gv_abtnr IS INITIAL.
      gv_abtnr = gs_adrs-abtnr.
    ENDIF.

    IF gv_pafkt IS INITIAL.
      gv_pafkt = gs_adrs-pafkt.
    ENDIF.

    IF gv_remark IS INITIAL.
      gv_remark = gs_adrs-remark.
    ENDIF.


* İLETIŞIM DILLERI
    SELECT bukrs, mtype, ktokd, ktokk, spras
      FROM zreco_lang

     WHERE bukrs EQ @gs_adrs-bukrs
       AND mtype EQ @gv_mtype
       INTO TABLE @gt_language.

    LOOP AT gt_language ASSIGNING <lfs_lang> WHERE mtype EQ 'X'.
      <lfs_lang>-mtype = gv_mtype.
    ENDLOOP.
* BANKA BILGILERI
    SELECT bukrs, seqno, bank_detail
      FROM zreco_bank
     WHERE bukrs EQ @gs_adrs-bukrs
     INTO CORRESPONDING FIELDS OF TABLE @gt_bank.


* FORM METINLERI
    SELECT *
      FROM zreco_htxt
     WHERE bukrs EQ @gs_adrs-bukrs
       AND mtype EQ @gv_mtype
       AND ftype EQ @p_ftype
       INTO TABLE @gt_htxt.
    IF sy-subrc NE 0.
*      MESSAGE s037 DISPLAY LIKE 'E' WITH gs_adrs-bukrs p_ftype. "YiğitcanÖzdemir
*      LEAVE LIST-PROCESSING.
    ENDIF.


* IHTAR METINLERI
*    IF p_verzn IS NOT INITIAL. "YiğitcanÖzdemir
    SELECT *
      FROM zreco_dtxt
     WHERE bukrs EQ @gs_adrs-bukrs
       AND ftype EQ @p_ftype
    INTO TABLE @gt_dtxt.
    IF sy-subrc NE 0.
*        MESSAGE s155 DISPLAY LIKE 'E' WITH gs_adrs-bukrs p_ftype. "YiğitcanÖzdemir
*        LEAVE LIST-PROCESSING.
    ENDIF.

    SELECT bukrs, blart, xfield
      FROM zreco_ifld
     WHERE bukrs EQ @gs_adrs-bukrs
     INTO TABLE @gt_ifld.
*    ENDIF.

    SELECT *
      FROM zreco_otxt
     WHERE bukrs EQ @gs_adrs-bukrs
       AND ftype EQ @p_ftype
    INTO TABLE @gt_otxt.

    SELECT bukrs, spras, akont, ltext_, xsum
      FROM zreco_atxt
     WHERE bukrs EQ @gs_adrs-bukrs
     INTO TABLE @gt_atxt.

    IF p_gsber IS NOT INITIAL.
      SELECT * FROM zreco_gsbr INTO TABLE @gt_gsbr.
    ENDIF.



* KAPALı DÖN    EM KONTROLÜ
    SELECT SINGLE COUNT( * )
             FROM zreco_clos
            WHERE bukrs EQ @gs_adrs-bukrs
              AND gjahr GE @p_gjahr
              AND monat GE @p_period
              AND mtype IN ( 'X', @gv_mtype ).
    IF sy-subrc EQ 0.
      AUTHORITY-CHECK OBJECT '/ITETR/DEL' "TODO
        ID 'BUKRS' FIELD gs_adrs-bukrs
        ID 'ACTVT' FIELD '70'
        ID 'KOART' FIELD '*'.
      IF sy-subrc NE 0.
*        MESSAGE s110 DISPLAY LIKE 'E'. "YiğitcanÖzdemir
*        LEAVE LIST-PROCESSING.
      ENDIF.
    ENDIF.

    gv_b_sel = gs_adrs-b_date_selection.

    IF gv_b_sel IS INITIAL.
      gv_b_sel = zreco_if_common_types=>mc_date_bt.
    ENDIF.

    gv_c_sel = gs_adrs-c_date_selection.

    IF gv_c_sel IS INITIAL.
      gv_c_sel = zreco_if_common_types=>mc_date_kt.
    ENDIF.

    IF p_seld IS INITIAL.
      APPEND INITIAL LINE TO s_kunnr ASSIGNING <lr_kunnr>.
      <lr_kunnr>-sign   = 'I'.
      <lr_kunnr>-option = 'EQ'.
      <lr_kunnr>-low    = space.
    ENDIF.

    IF p_selk IS INITIAL.
      APPEND INITIAL LINE TO s_lifnr ASSIGNING <lr_lifnr>.
      <lr_lifnr>-sign   = 'I'.
      <lr_lifnr>-option = 'EQ'.
      <lr_lifnr>-low    = space.
    ENDIF.

*    IF p_verzn IS NOT INITIAL.     "YiğitcanÖzdemir
*      gv_last_date = sy-datlo.
*    ELSE.

    IF p_daily IS INITIAL.

      CONCATENATE p_gjahr p_period '01' INTO gv_first_date.

*      CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'    "YiğitcanÖzdemir
*        EXPORTING
*          day_in            = gv_first_date
*        IMPORTING
*          last_day_of_month = gv_last_date
*        EXCEPTIONS
*          day_in_no_date    = 1
*          OTHERS            = 2.

      DATA lo_zreco_common  TYPE REF TO zreco_common.
      CREATE OBJECT lo_zreco_common.


      lo_zreco_common->rp_last_day_of_months(
        EXPORTING
          day_in            = gv_first_date
        IMPORTING
          last_day_of_month = gv_last_date
      ).


    ELSE.
      gv_last_date = p_rdate.
      p_gjahr  = p_rdate(4).
      p_period = p_rdate+4(2).
    ENDIF.

    IF r_mform IS INITIAL.
      CASE gs_adrs-b_date_selection.
        WHEN zreco_if_common_types=>mc_date_bt.
          APPEND INITIAL LINE TO r_bldat ASSIGNING <fs_bldat>.
          <fs_bldat>-sign   = 'I'.
          <fs_bldat>-option = 'BT'.
          <fs_bldat>-low    = gv_first_date.
          <fs_bldat>-high   = gv_last_date.
        WHEN zreco_if_common_types=>mc_date_kt.
          APPEND INITIAL LINE TO r_budat ASSIGNING <fs_budat>.
          <fs_budat>-sign   = 'I'.
          <fs_budat>-option = 'BT'.
          <fs_budat>-low    = gv_first_date.
          <fs_budat>-high   = gv_last_date.
      ENDCASE.
    ENDIF.
*    ENDIF.

    r_kunnr[] = s_kunnr[].
    r_lifnr[] = s_lifnr[].

    partner_selection( ).

    IF p_waers IS NOT INITIAL.
* PB BAZıNDA GÖNDERIMLER
      SELECT *
        FROM zreco_rboc
       WHERE bukrs IN @s_bukrs
         AND gsber IN @s_gsber
         AND monat EQ @p_period
         AND gjahr EQ @p_gjahr
         AND loekz EQ @zreco_if_common_types=>mc_select_no
          INTO TABLE @gt_w001.
    ENDIF.

    IF lines( gt_h001 ) GT 0.

      SELECT *
         FROM zreco_reia
         FOR ALL ENTRIES IN @gt_h001
         WHERE bukrs    EQ @gt_h001-bukrs
           AND gsber    EQ @gt_h001-gsber
           AND mnumber  EQ @gt_h001-mnumber
           AND monat    EQ @gt_h001-monat
           AND gjahr    EQ @gt_h001-gjahr
           INTO TABLE @gt_reia.

      SORT gt_reia BY bukrs
                      gsber
                      mnumber
                      monat
                      gjahr
                      version DESCENDING.

      DELETE ADJACENT DUPLICATES FROM gt_reia COMPARING bukrs
                                                        gsber
                                                        mnumber
                                                        monat
                                                        gjahr
                                                        version.

    ENDIF.



    gv_no_kursf = gs_adrs-no_kursf.
    gv_no_local = p_nolc.
    gv_no_value = p_novl.

* LISTEDEN ÇıKAN E-POSTA ADRESLERI
    SELECT *
      FROM zreco_urei
     WHERE bukrs IN @s_bukrs
       AND fgstu NE @zreco_if_common_types=>mc_unlisted_status_99
       INTO TABLE @gt_e002.

    DELETE ADJACENT DUPLICATES FROM gt_e002 COMPARING receiver.

    CHECK p_runty EQ 1.

    IF p_all IS NOT INITIAL. "VKN BIRLEŞTIR

      IF r_kunnr[] IS INITIAL AND
         s_ktokd[] IS INITIAL AND
         s_dkont[] IS INITIAL AND
         p_seld    IS NOT INITIAL.
        lv_kunnr_all = zreco_if_common_types=>mc_select_yes. "HIÇ BIR KRITER GIRILMEDEN TÜM MÜŞTERILER
      ENDIF.

* B FORMUNDA SADECE IŞLEM GÖRMÜŞ MÜŞTERI/SATıCıLARA BAK    "YiğitcanÖzdemir B formu yok!
*      IF gv_mtype NE 'C'.
*
*        get_bform_accounts( ).
*
*      ENDIF.

*SEÇIM KRITERLERINE GÖRE GIRILMIŞ MÜŞTERILERI BUL
      IF p_seld IS NOT INITIAL.
*        IF gt_knc1[] IS NOT INITIAL.   "YiğitcanÖzdemir gt_knc1 sadece get_bform_accounts methodunda doldurulduğu için yazmadım /B formu yok
*
*          TYPES : BEGIN OF t_knb1,
*                    kunnr TYPE knb1-kunnr,
*                    bukrs TYPE knb1-bukrs,
*                    akont TYPE knb1-akont,
*                    sperr TYPE knb1-sperr,
*                    loevm TYPE knb1-loevm,
*                  END OF t_knb1,
*                  BEGIN OF t_kna1,
*                    kunnr TYPE kna1-kunnr,
*                    brsch TYPE kna1-brsch,
*                    ktokd TYPE kna1-ktokd,
*                    sperr TYPE kna1-sperr,
*                    loevm TYPE kna1-loevm,
*                  END OF t_kna1.
*
*          DATA : lt_knb1_z TYPE SORTED TABLE OF t_knb1
*                                WITH UNIQUE KEY kunnr bukrs,
*                 lt_kna1_z TYPE SORTED TABLE OF t_kna1
*                               WITH UNIQUE KEY kunnr.
*
*          FIELD-SYMBOLS : <fs_knc1>   LIKE LINE OF gt_knc1,
*                          <fs_kna1_z> LIKE LINE OF lt_kna1_z.
*
*          FREE : lt_knb1_z, lt_kna1_z.
*
*          SELECT kunnr bukrs akont sperr loevm
*      INTO TABLE lt_knb1_z
*            FROM knb1
*             FOR ALL ENTRIES IN gt_knc1
*           WHERE kunnr EQ gt_knc1-kunnr
*             AND bukrs EQ gt_knc1-bukrs.
*
*          DELETE lt_knb1_z WHERE akont EQ space.
*          DELETE lt_knb1_z WHERE akont NOT IN s_dkont.
*          DELETE lt_knb1_z WHERE sperr NOT IN r_sperr.
*          DELETE lt_knb1_z WHERE loevm NOT IN r_loevm.
*
*          SELECT kunnr brsch ktokd sperr loevm
*            INTO TABLE lt_kna1_z
*            FROM kna1
*             FOR ALL ENTRIES IN gt_knc1
*           WHERE kunnr EQ gt_knc1-kunnr.
*
*          DELETE lt_kna1_z WHERE ktokd NOT IN s_ktokd.
*          DELETE lt_kna1_z WHERE brsch NOT IN s_brsch1.
*          DELETE lt_kna1_z WHERE sperr NOT IN r_sperr.
*          DELETE lt_kna1_z WHERE loevm NOT IN r_loevm.
*
*          LOOP AT gt_knc1 ASSIGNING <fs_knc1>.
*            FREE : ls_kna1_all.
*
*            READ TABLE lt_knb1_z TRANSPORTING NO FIELDS WITH KEY kunnr = <fs_knc1>-kunnr
*                                                                 bukrs = <fs_knc1>-bukrs.
*            IF sy-subrc NE 0.
*              CONTINUE.
*            ENDIF.
*
*            READ TABLE lt_kna1_z ASSIGNING <fs_kna1_z> WITH KEY kunnr = <fs_knc1>-kunnr.
*            IF sy-subrc NE 0.
*              CONTINUE.
*            ENDIF.
*
*            ls_kna1_all-kunnr = <fs_kna1_z>-kunnr.
*            ls_kna1_all-ktokd = <fs_kna1_z>-ktokd.
*            INSERT ls_kna1_all INTO TABLE lt_kna1_all.
*          ENDLOOP.
*
*          lv_kunnr_all = /itetr/reco_if_common_types=>mc_select_yes.
*
*        ELSE.
        SELECT kna1~customer AS kunnr, kna1~CustomerAccountGroup AS ktokd
          FROM i_customer AS kna1
    INNER JOIN i_customercompany AS knb1 ON kna1~customer EQ knb1~customer

         WHERE knb1~CompanyCode IN @s_bukrs
           AND kna1~customer IN @r_kunnr
           AND kna1~CustomerAccountGroup IN @s_ktokd
           AND kna1~Industry IN @s_brsch1
           AND kna1~PostingIsBlocked IN @r_sperr
           AND kna1~DeletionIndicator IN @r_loevm
           AND knb1~PhysicalInventoryBlockInd IN @r_sperr
           AND knb1~DeletionIndicator IN @r_loevm
           AND knb1~ReconciliationAccount IN @s_dkont
           AND knb1~ReconciliationAccount NE ''
            INTO CORRESPONDING FIELDS OF TABLE @lt_kna1_all.
*        ENDIF.

      ENDIF.


      IF lt_kna1_all[] IS NOT INITIAL AND
         lv_kunnr_all IS INITIAL.
*AYNı VKN'LERI BUL
        SELECT *
          FROM Zreco_taxm
           FOR ALL ENTRIES IN @lt_kna1_all
         WHERE hesap_tur EQ @Zreco_if_common_types=>mc_hesap_tur_m
           AND hesap_no EQ @lt_kna1_all-kunnr
           INTO TABLE @lt_taxm_d.

        IF lt_taxm_d[] IS NOT INITIAL.
          SELECT *
            FROM Zreco_taxm
             FOR ALL ENTRIES IN @lt_taxm_d
           WHERE vkn_tckn EQ @lt_taxm_d-vkn_tckn
              APPENDING TABLE @gt_taxm_d.
        ENDIF.

*MÜŞTERILERE AIT SATıCıLARı BUL
        SELECT lfa1~supplier AS lifnr ,lfa1~SupplierAccountGroup AS ktokk
          FROM i_supplier AS lfa1
    INNER JOIN i_suppliercompany AS lfb1 ON lfa1~supplier EQ lfb1~supplier
           FOR ALL ENTRIES IN @lt_kna1_all
         WHERE lfb1~companycode IN @s_bukrs
           AND lfa1~customer EQ @lt_kna1_all-kunnr
           AND lfa1~customer NE ''
           AND lfa1~PostingIsBlocked IN @r_sperr
           AND lfa1~DeletionIndicator IN @r_loevm
           AND lfb1~SupplierIsBlockedForPosting IN @r_sperr
           AND lfb1~DeletionIndicator IN @r_loevm
           AND lfb1~ReconciliationAccount NE ''
           APPENDING CORRESPONDING FIELDS OF TABLE @lt_lfa1_all.

      ENDIF.


      IF lv_kunnr_all IS NOT INITIAL ."AND gt_knc1[] IS INITIAL."YiğitcanÖzdemir gt_knc1 doldurulmadğı için kapaatıldı

        SELECT *
          FROM zreco_taxm
    INNER JOIN i_customercompany AS knb1 ON knb1~customer EQ zreco_taxm~hesap_no
         WHERE zreco_taxm~hesap_tur EQ @zreco_if_common_types=>mc_hesap_tur_m
           AND zreco_taxm~vkn_tckn IN @s_vkn_cr "müşteri tckn
           AND knb1~companycode IN @s_bukrs
           AND knb1~DeletionIndicator IN @r_loevm
           AND knb1~PhysicalInventoryBlockInd IN @r_sperr
           AND knb1~ReconciliationAccount NE ''
           APPENDING CORRESPONDING FIELDS OF TABLE @gt_kna1_tax.

      ENDIF.

*       IF gt_knc1[] IS NOT INITIAL. "YiğitcanÖzdemir gt_knc1 doldurulmadğı için kapaatıldı
*
*          SELECT SINGLE COUNT( * )
*                   FROM /itetr/reco_parm
*                  WHERE pname EQ /itetr/reco_if_common_types=>mc_parm_no_merge.
*
*          IF sy-subrc EQ 0.
*
*            get_merge_kna1_tax( ).
*
*          ENDIF.
*
*          SELECT *
*            FROM /itetr/reco_taxm
*       APPENDING CORRESPONDING FIELDS OF TABLE gt_kna1_tax
*             FOR ALL ENTRIES IN gt_knc1
*           WHERE hesap_tur EQ /itetr/reco_if_common_types=>mc_hesap_tur_m
*             AND /itetr/reco_taxm~vkn_tckn IN s_vkn_cr "hkizilkaya müşteri tckn
*             AND hesap_no EQ gt_knc1-kunnr.
*
*          SELECT * FROM /itetr/reco_taxm
*            APPENDING CORRESPONDING FIELDS OF TABLE gt_lfa1_tax
*            FOR ALL ENTRIES IN gt_knc1
*            WHERE hesap_tur EQ /itetr/reco_if_common_types=>mc_hesap_tur_s
*            AND /itetr/reco_taxm~vkn_tckn IN s_vkn_ve "hkizilkaya satıcı tckn
*            AND kunnr EQ gt_knc1-kunnr.
*
** ARIZi MÜŞTERILERI SEÇ
*          SELECT *
*            FROM kna1
*       APPENDING CORRESPONDING FIELDS OF TABLE lt_kna1
*             FOR ALL ENTRIES IN gt_knc1
*           WHERE kunnr EQ gt_knc1-kunnr
*             AND xcpdk EQ /itetr/reco_if_common_types=>mc_select_yes.
*
*          LOOP AT lt_kna1 INTO ls_kna1.
*
*            CALL FUNCTION '/ITETR/RECO_TAX_INFO'
*              EXPORTING
*                i_bukrs      = gs_adrs-bukrs
*                i_kunnr      = ls_kna1-kunnr
*                i_number     = 'X'
*                i_office     = ''
*              IMPORTING
*                e_tax_number = gs_kna1_tax-vkn_tckn
*                e_ktokl      = gs_kna1_tax-ktokl
*              EXCEPTIONS
*                other        = 1.
*
*            gs_kna1_tax-hesap_no = ls_kna1-kunnr.
*            gs_kna1_tax-kunnr    = ls_kna1-kunnr.
*            gs_kna1_tax-lifnr    = ls_kna1-lifnr.
*
*            INSERT gs_kna1_tax INTO TABLE gt_kna1_tax. CLEAR gs_kna1_tax.
*          ENDLOOP.

      IF r_lifnr[] IS INITIAL AND
           s_ktokk[] IS INITIAL AND
           s_kkont[] IS INITIAL AND
           p_selk IS NOT INITIAL.
        lv_lifnr_all = zreco_if_common_types=>mc_select_yes. "HIÇ BIR KRITER GIRILMEDEN TÜM SATıCıLAR
      ENDIF.

      IF p_selk IS NOT INITIAL .

*        IF gt_lfc1[] IS NOT INITIAL.       "YiğitcanÖzdemir gt_lfc1 doldurulmadğı için kapaatıldı
*          SELECT lfa1~lifnr lfa1~ktokk
*            FROM lfa1
*           INNER JOIN lfb1 ON lfa1~lifnr EQ lfb1~lifnr
*       APPENDING CORRESPONDING FIELDS OF TABLE lt_lfa1_all
*             FOR ALL ENTRIES IN gt_lfc1
*           WHERE lfb1~bukrs IN s_bukrs
*             AND lfa1~lifnr EQ gt_lfc1-lifnr
*             AND lfa1~ktokk IN s_ktokk
*             AND lfa1~brsch IN s_brsch2
*             AND lfb1~akont IN s_kkont
*             AND lfb1~akont NE ''
*             AND lfa1~sperr IN r_sperr
*             AND lfa1~loevm IN r_loevm
*             AND lfb1~sperr IN r_sperr
*             AND lfb1~loevm IN r_loevm.
*
*          lv_lifnr_all = /itetr/reco_if_common_types=>mc_select_yes.
*
*        ELSE.
        SELECT lfa1~supplier AS lifnr , lfa1~SupplierAccountGroup AS ktokk
          FROM i_supplier AS lfa1
         INNER JOIN i_suppliercompany AS lfb1 ON lfa1~supplier EQ lfb1~supplier
         WHERE lfb1~companycode IN @s_bukrs
           AND lfa1~supplier IN @r_lifnr
           AND lfa1~SupplierAccountGroup IN @s_ktokk
           AND lfa1~Industry IN @s_brsch2
           AND lfb1~ReconciliationAccount IN @s_kkont
           AND lfb1~ReconciliationAccount NE ''
           AND lfa1~PostingIsBlocked IN @r_sperr
           AND lfa1~DeletionIndicator IN @r_loevm
           AND lfb1~SupplierIsBlockedForPosting IN @r_sperr
           AND lfb1~DeletionIndicator IN @r_loevm
     APPENDING CORRESPONDING FIELDS OF TABLE @lt_lfa1_all.
*        ENDIF.

        IF lt_lfa1_all[] IS NOT INITIAL AND
              lv_lifnr_all IS INITIAL.
*AYNı VKN'LERI BUL
          SELECT *
            FROM Zreco_taxm
             FOR ALL ENTRIES IN @lt_lfa1_all
           WHERE hesap_tur EQ @Zreco_if_common_types=>mc_hesap_tur_s
             AND hesap_no EQ @lt_lfa1_all-lifnr
                   INTO TABLE @lt_taxm_k.

          IF lt_taxm_k[] IS NOT INITIAL.
            SELECT *
              FROM Zreco_taxm
               FOR ALL ENTRIES IN @lt_taxm_k
             WHERE vkn_tckn EQ @lt_taxm_k-vkn_tckn
             APPENDING TABLE @gt_taxm_k.
          ENDIF.

*SATıCıLARA AIT MÜŞTERILERI BUL
          SELECT kna1~customer AS kunnr ,kna1~CustomerAccountGroup AS ktokd
            FROM i_customer AS kna1
           INNER JOIN i_customercompany AS knb1 ON kna1~customer EQ knb1~customer
             FOR ALL ENTRIES IN @lt_lfa1_all
           WHERE knb1~companycode IN @s_bukrs
             AND kna1~supplier EQ @lt_lfa1_all-lifnr
             AND kna1~supplier NE ''
             AND kna1~PostingIsBlocked IN @r_sperr
             AND kna1~DeletionIndicator IN @r_loevm
             AND knb1~PhysicalInventoryBlockInd IN @r_sperr
             AND knb1~DeletionIndicator IN @r_loevm
             AND knb1~ReconciliationAccount NE ''
        APPENDING CORRESPONDING FIELDS OF TABLE @lt_kna1_all.
        ENDIF.

        IF lv_lifnr_all IS NOT INITIAL ."AND gt_lfc1[] IS INITIAL. @YiğitcanÖzdemir
          SELECT *
            FROM zreco_taxm
           INNER JOIN i_suppliercompany AS lfb1 ON lfb1~supplier EQ zreco_taxm~hesap_no
             WHERE zreco_taxm~hesap_tur EQ @zreco_if_common_types=>mc_hesap_tur_s
             AND zreco_taxm~vkn_tckn IN @s_vkn_ve " satıcı tckn
             AND lfb1~companycode IN @s_bukrs
             AND lfb1~DeletionIndicator IN @r_loevm
             AND lfb1~SupplierIsBlockedForPosting IN @r_sperr
             AND lfb1~ReconciliationAccount NE ''
             APPENDING CORRESPONDING FIELDS OF TABLE @gt_lfa1_tax.
        ENDIF.


*         IF gt_lfc1[] IS NOT INITIAL. @YiğitcanÖzdemir
*
*          SELECT SINGLE COUNT( * )
*                         FROM /itetr/reco_parm
*                        WHERE pname EQ /itetr/reco_if_common_types=>mc_parm_no_merge.
*
*          IF sy-subrc EQ 0.
*
*            get_merge_lfa1_tax( ).
*
*          ENDIF.
*
*          SELECT *
*            FROM /itetr/reco_taxm
*       APPENDING CORRESPONDING FIELDS OF TABLE gt_lfa1_tax
*             FOR ALL ENTRIES IN gt_lfc1
*           WHERE hesap_tur EQ /itetr/reco_if_common_types=>mc_hesap_tur_s
*             AND /itetr/reco_taxm~vkn_tckn IN s_vkn_ve "hkizilkaya satıcı tckn
*             AND hesap_no EQ gt_lfc1-lifnr.
*
*          SELECT * FROM /itetr/reco_taxm
*            APPENDING CORRESPONDING FIELDS OF TABLE gt_kna1_tax
*            FOR ALL ENTRIES IN gt_lfc1
*            WHERE hesap_tur EQ /itetr/reco_if_common_types=>mc_hesap_tur_m
*            AND /itetr/reco_taxm~vkn_tckn IN s_vkn_cr "hkizilkaya müşteri tckn
*            AND lifnr EQ gt_lfc1-lifnr.
** ARIZi SATıCıLAR SEÇ
*          SELECT *
*            FROM lfa1
*       APPENDING CORRESPONDING FIELDS OF TABLE lt_lfa1
*             FOR ALL ENTRIES IN gt_lfc1
*           WHERE lifnr EQ gt_lfc1-lifnr
*             AND xcpdk EQ /itetr/reco_if_common_types=>mc_select_yes.
*
*          LOOP AT lt_lfa1 INTO ls_lfa1.
*
*            CALL FUNCTION '/ITETR/RECO_TAX_INFO'
*              EXPORTING
*                i_bukrs      = gs_adrs-bukrs
*                i_lifnr      = ls_lfa1-lifnr
*                i_number     = 'X'
*                i_office     = ''
*              IMPORTING
*                e_tax_number = gs_lfa1_tax-vkn_tckn
*                e_ktokl      = gs_lfa1_tax-ktokl
*              EXCEPTIONS
*                other        = 1.
*
*            gs_lfa1_tax-hesap_no = ls_lfa1-lifnr.
*            gs_lfa1_tax-lifnr    = ls_lfa1-lifnr.
*            gs_lfa1_tax-kunnr    = ls_lfa1-kunnr.
*
*            INSERT gs_lfa1_tax INTO TABLE gt_lfa1_tax.CLEAR gs_lfa1_tax.
*          ENDLOOP.
*        ENDIF.
      ENDIF.

      LOOP AT gt_taxm_d INTO ls_taxm_d.

        READ TABLE gt_kna1_tax TRANSPORTING NO FIELDS WITH KEY vkn_tckn = ls_taxm_d-vkn_tckn.
        IF sy-subrc NE 0.
          SELECT hesap_no ,vkn_tckn, ktokl ,kunnr ,lifnr
            FROM zreco_taxm
           WHERE hesap_tur EQ @zreco_if_common_types=>mc_hesap_tur_m
             AND zreco_taxm~vkn_tckn IN @s_vkn_cr " müşteri tckn
             AND hesap_no IN @r_exc_kunnr
             AND vkn_tckn EQ @ls_taxm_d-vkn_tckn
       APPENDING CORRESPONDING FIELDS OF TABLE @gt_kna1_tax.
        ENDIF.

        READ TABLE gt_lfa1_tax TRANSPORTING NO FIELDS WITH KEY vkn_tckn = ls_taxm_d-vkn_tckn.
        IF sy-subrc NE 0.
          SELECT hesap_no ,vkn_tckn ,ktokl ,kunnr ,lifnr
            FROM zreco_taxm
           WHERE hesap_tur EQ @zreco_if_common_types=>mc_hesap_tur_s
             AND zreco_taxm~vkn_tckn IN @s_vkn_ve " satıcı tckn
             AND hesap_no IN @r_exc_lifnr
             AND vkn_tckn EQ @ls_taxm_d-vkn_tckn
                    APPENDING CORRESPONDING FIELDS OF TABLE @gt_lfa1_tax.
        ENDIF.
      ENDLOOP.

      LOOP AT gt_taxm_k INTO ls_taxm_k.

        READ TABLE gt_kna1_tax TRANSPORTING NO FIELDS WITH KEY vkn_tckn = ls_taxm_k-vkn_tckn.
        IF sy-subrc NE 0.
          SELECT hesap_no ,vkn_tckn ,ktokl ,kunnr ,lifnr
            FROM zreco_taxm
           WHERE hesap_tur EQ @zreco_if_common_types=>mc_hesap_tur_m
             AND zreco_taxm~vkn_tckn IN @s_vkn_cr " müşteri tckn
             AND hesap_no IN @r_exc_kunnr
             AND vkn_tckn EQ @ls_taxm_k-vkn_tckn
             APPENDING CORRESPONDING FIELDS OF TABLE @gt_kna1_tax.
        ENDIF.

        READ TABLE gt_lfa1_tax TRANSPORTING NO FIELDS WITH KEY vkn_tckn = ls_taxm_k-vkn_tckn.
        IF sy-subrc NE 0.
          SELECT hesap_no ,vkn_tckn ,ktokl ,kunnr ,lifnr
            FROM zreco_taxm
           WHERE hesap_tur EQ @zreco_if_common_types=>mc_hesap_tur_s
             AND zreco_taxm~vkn_tckn IN @s_vkn_ve " satıcı tckn
             AND hesap_no IN @r_exc_lifnr
             AND vkn_tckn EQ @ls_taxm_k-vkn_tckn
             APPENDING CORRESPONDING FIELDS OF TABLE @gt_lfa1_tax.
        ENDIF.
      ENDLOOP.

      IF gt_kna1_tax[] IS NOT INITIAL AND
        gt_lfa1_tax[] IS INITIAL.
        SELECT *
          FROM zreco_taxm
           FOR ALL ENTRIES IN @gt_kna1_tax
         WHERE hesap_tur EQ @zreco_if_common_types=>mc_hesap_tur_s
           AND zreco_taxm~vkn_tckn IN @s_vkn_ve " satıcı tckn
           AND hesap_no IN @r_exc_lifnr
           AND vkn_tckn EQ @gt_kna1_tax-vkn_tckn
                APPENDING CORRESPONDING FIELDS OF TABLE @gt_lfa1_tax.
      ENDIF.

      IF gt_kna1_tax[] IS INITIAL AND gt_lfa1_tax[] IS NOT INITIAL.
        SELECT *
          FROM zreco_taxm
           FOR ALL ENTRIES IN @gt_lfa1_tax
         WHERE hesap_tur EQ @zreco_if_common_types=>mc_hesap_tur_m
           AND zreco_taxm~vkn_tckn IN @s_vkn_cr "müşteri tckn
           AND hesap_no IN @r_exc_kunnr
           AND vkn_tckn EQ @gt_lfa1_tax-vkn_tckn
     APPENDING CORRESPONDING FIELDS OF TABLE @gt_kna1_tax.
      ENDIF.

*<--- BIRLEŞTIRME YAPıLMAYACAK AMA SEÇIMDE OLAN CARILER
*      IF gt_knc1[] IS NOT INITIAL.
*        SELECT *
*          FROM /itetr/reco_taxn
*     APPENDING CORRESPONDING FIELDS OF TABLE gt_kna1_tax
*           FOR ALL ENTRIES IN gt_knc1
*         WHERE hesap_tur EQ /itetr/reco_if_common_types=>mc_hesap_tur_m
*           AND /itetr/reco_taxn~vkn_tckn IN s_vkn_cr "hkizilkaya müşteri tckn
*           AND hesap_no EQ gt_knc1-kunnr.
*
*        SELECT * FROM /itetr/reco_taxn
*          APPENDING CORRESPONDING FIELDS OF TABLE gt_lfa1_tax
*          FOR ALL ENTRIES IN gt_knc1
*          WHERE hesap_tur EQ /itetr/reco_if_common_types=>mc_hesap_tur_s
*          AND /itetr/reco_taxn~vkn_tckn IN s_vkn_ve "hkizilkaya satıcı tckn
*          AND kunnr EQ gt_knc1-kunnr.
*
*      ELSE.
      SELECT *
        FROM zreco_taxn
       INNER JOIN  i_customercompany AS knb1 ON zreco_taxn~kunnr EQ knb1~customer
       INNER JOIN  i_customer  AS kna1 ON kna1~customer EQ knb1~customer
       WHERE knb1~companycode IN @s_bukrs
         AND zreco_taxn~hesap_tur EQ @zreco_if_common_types=>mc_hesap_tur_m
         AND zreco_taxn~hesap_no IN @r_kunnr
         AND zreco_taxn~vkn_tckn IN @s_vkn_cr " müşteri tckn
         AND kna1~CustomerAccountGroup IN @s_ktokd
         AND kna1~Industry IN @s_brsch1
         AND knb1~ReconciliationAccount IN @s_dkont
         AND knb1~ReconciliationAccount NE ''
         AND kna1~PostingIsBlocked IN @r_sperr
         AND kna1~DeletionIndicator IN @r_loevm
         AND knb1~PhysicalInventoryBlockInd IN @r_sperr
         AND knb1~DeletionIndicator IN @r_loevm
   APPENDING CORRESPONDING FIELDS OF TABLE @gt_kna1_tax.
*      ENDIF.

*      IF gt_lfc1[] IS NOT INITIAL. "YiğitcanÖzdemir
*        SELECT *
*          FROM /itetr/reco_taxn
*     APPENDING CORRESPONDING FIELDS OF TABLE gt_lfa1_tax
*           FOR ALL ENTRIES IN gt_lfc1
*         WHERE hesap_tur EQ /itetr/reco_if_common_types=>mc_hesap_tur_s
*           AND /itetr/reco_taxn~vkn_tckn IN s_vkn_ve "hkizilkaya satıcı tckn
*           AND hesap_no EQ gt_lfc1-lifnr.
*
*        SELECT * FROM /itetr/reco_taxn
*          APPENDING CORRESPONDING FIELDS OF TABLE gt_kna1_tax
*          FOR ALL ENTRIES IN gt_lfc1
*          WHERE hesap_tur EQ /itetr/reco_if_common_types=>mc_hesap_tur_m
*          AND /itetr/reco_taxn~vkn_tckn IN s_vkn_cr "hkizilkaya müşteri tckn
*          AND lifnr EQ gt_lfc1-lifnr.
*      ELSE.
*        IF p_selk IS NOT INITIAL.
*          SELECT *
*            FROM /itetr/reco_taxn
*     INNER JOIN lfb1 ON /itetr/reco_taxn~lifnr EQ lfb1~lifnr
*     INNER JOIN lfa1 ON lfa1~lifnr EQ lfb1~lifnr
*      APPENDING CORRESPONDING FIELDS OF TABLE gt_lfa1_tax
*          WHERE lfb1~bukrs IN s_bukrs
*            AND /itetr/reco_taxn~hesap_tur EQ /itetr/reco_if_common_types=>mc_hesap_tur_s
*            AND /itetr/reco_taxn~hesap_no IN r_lifnr
*            AND lfa1~ktokk IN s_ktokk
*            AND lfa1~brsch IN s_brsch2
*            AND lfb1~akont IN s_kkont
*            AND lfb1~akont NE ''
*            AND lfa1~sperr IN r_sperr
*            AND lfa1~loevm IN r_loevm
*            AND lfb1~sperr IN r_sperr
*            AND lfb1~loevm IN r_loevm.
*        ENDIF.
*      ENDIF.
*BIRLEŞTIRME YAPıLMAYACAK AMA SEÇIMDE OLAN CARILER--->

    ELSE.
*<--- VKN BIRLEŞTIR YOK ISE

* B FORMUNDA SADECE IŞLEM GÖRMÜŞ MÜŞTERI/SATıCıLARA BAK
*      IF gv_mtype NE 'C'.          "YiğitcanÖzdemir
*
*        get_bform_accounts( ).
*
*      ENDIF.

*      IF gt_knc1[] IS NOT INITIAL.             "YiğitcanÖzdemir
*        DATA : ls_taxm TYPE /itetr/reco_taxm,
*               ls_taxn TYPE /itetr/reco_taxn.
*
*        FREE : ls_taxm,ls_taxn.
*        SELECT * INTO ls_taxm FROM /itetr/reco_taxm  UP TO 1 ROWS.
*          EXIT.
*        ENDSELECT.
*        IF sy-subrc EQ 0.
*          SELECT *
*            FROM /itetr/reco_taxm
*       APPENDING CORRESPONDING FIELDS OF TABLE gt_kna1_tax
*             FOR ALL ENTRIES IN gt_knc1
*           WHERE hesap_tur EQ /itetr/reco_if_common_types=>mc_hesap_tur_m
*             AND /itetr/reco_taxm~vkn_tckn IN s_vkn_cr "hkizilkaya müşteri tckn
*             AND hesap_no EQ gt_knc1-kunnr.
*        ENDIF.
*
*        SELECT * INTO ls_taxn FROM /itetr/reco_taxn UP TO 1 ROWS.
*          EXIT.
*        ENDSELECT.
*        IF sy-subrc EQ 0.
*          SELECT *
*            FROM /itetr/reco_taxn
*       APPENDING CORRESPONDING FIELDS OF TABLE gt_kna1_tax
*             FOR ALL ENTRIES IN gt_knc1
*           WHERE hesap_tur EQ /itetr/reco_if_common_types=>mc_hesap_tur_m
*             AND /itetr/reco_taxn~vkn_tckn IN s_vkn_cr "hkizilkaya müşteri tckn
*             AND hesap_no EQ gt_knc1-kunnr.
*        ENDIF.
*
** ARıZI MÜŞTERILERI SEÇ
*        SELECT *
*          FROM kna1
*     APPENDING CORRESPONDING FIELDS OF TABLE lt_kna1
*           FOR ALL ENTRIES IN gt_knc1
*         WHERE kunnr EQ gt_knc1-kunnr
*           AND xcpdk EQ 'X'.
*
*        LOOP AT lt_kna1 INTO ls_kna1.
*
*          CALL FUNCTION '/ITETR/RECO_TAX_INFO'
*            EXPORTING
*              i_bukrs      = gs_adrs-bukrs
*              i_kunnr      = ls_kna1-kunnr
*              i_number     = 'X'
*              i_office     = ''
*            IMPORTING
*              e_tax_number = gs_kna1_tax-vkn_tckn
*              e_ktokl      = gs_kna1_tax-ktokl
*            EXCEPTIONS
*              other        = 1.
*
*          gs_kna1_tax-hesap_no = ls_kna1-kunnr.
*          gs_kna1_tax-kunnr    = ls_kna1-kunnr.
*          gs_kna1_tax-lifnr    = ls_kna1-lifnr.
*
*          INSERT gs_kna1_tax INTO TABLE gt_kna1_tax. CLEAR gs_kna1_tax.
*        ENDLOOP.
*      ELSE.
      SELECT *
        FROM zreco_taxm
  INNER JOIN  i_customercompany AS knb1 ON zreco_taxm~kunnr EQ knb1~customer
  INNER JOIN i_customer AS kna1 ON kna1~customer EQ knb1~customer
       WHERE knb1~companycode IN @s_bukrs
         AND zreco_taxm~hesap_tur EQ @zreco_if_common_types=>mc_hesap_tur_m
         AND zreco_taxm~hesap_no IN @r_kunnr
         AND zreco_taxm~vkn_tckn IN @s_vkn_cr " müşteri tckn
         AND kna1~CustomerAccountGroup IN @s_ktokd
         AND kna1~Industry IN @s_brsch1
         AND knb1~ReconciliationAccount IN @s_dkont
         AND knb1~ReconciliationAccount NE ''
         AND kna1~PostingIsBlocked IN @r_sperr
         AND kna1~DeletionIndicator IN @r_loevm
         AND knb1~PhysicalInventoryBlockInd IN @r_sperr
         AND knb1~DeletionIndicator IN @r_loevm
              APPENDING CORRESPONDING FIELDS OF TABLE @gt_kna1_tax.

      SELECT *
        FROM zreco_taxn
  INNER JOIN  i_customercompany AS knb1 ON zreco_taxn~kunnr EQ knb1~customer
  INNER JOIN i_customer AS kna1 ON kna1~customer EQ knb1~customer
       WHERE knb1~companycode IN @s_bukrs
         AND zreco_taxn~hesap_tur EQ @zreco_if_common_types=>mc_hesap_tur_m
         AND zreco_taxn~hesap_no IN @r_kunnr
         AND zreco_taxn~vkn_tckn IN @s_vkn_cr " müşteri tckn
         AND kna1~CustomerAccountGroup IN @s_ktokd
         AND kna1~Industry IN @s_brsch1
         AND knb1~ReconciliationAccount IN @s_dkont
         AND knb1~ReconciliationAccount NE ''
         AND kna1~PostingIsBlocked IN @r_sperr
         AND kna1~DeletionIndicator IN @r_loevm
         AND knb1~PhysicalInventoryBlockInd IN @r_sperr
         AND knb1~DeletionIndicator IN @r_loevm
              APPENDING CORRESPONDING FIELDS OF TABLE @gt_kna1_tax.
*      ENDIF.

*      IF gt_lfc1[] IS NOT INITIAL.             "YiğitcanÖzdemir
*        SELECT *
*          FROM /itetr/reco_taxm
*     APPENDING CORRESPONDING FIELDS OF TABLE gt_lfa1_tax
*           FOR ALL ENTRIES IN gt_lfc1
*         WHERE hesap_tur EQ /itetr/reco_if_common_types=>mc_hesap_tur_s
*           AND /itetr/reco_taxm~vkn_tckn IN s_vkn_ve "hkizilkaya satıcı tckn
*           AND hesap_no EQ gt_lfc1-lifnr.
*
*        SELECT *
*          FROM /itetr/reco_taxn
*     APPENDING CORRESPONDING FIELDS OF TABLE gt_lfa1_tax
*           FOR ALL ENTRIES IN gt_lfc1
*         WHERE hesap_tur EQ /itetr/reco_if_common_types=>mc_hesap_tur_s
*           AND /itetr/reco_taxn~vkn_tckn IN s_vkn_ve "hkizilkaya satıcı tckn
*           AND hesap_no EQ gt_lfc1-lifnr.
*
** ARıZI MÜŞTERILERI SEÇ
*        SELECT *
*          FROM lfa1
*     APPENDING CORRESPONDING FIELDS OF TABLE lt_lfa1
*           FOR ALL ENTRIES IN gt_lfc1
*         WHERE lifnr EQ gt_lfc1-lifnr
*           AND xcpdk EQ 'X'.
*
*        LOOP AT lt_lfa1 INTO ls_lfa1.
*
*          CALL FUNCTION '/ITETR/RECO_TAX_INFO'
*            EXPORTING
*              i_bukrs      = gs_adrs-bukrs
*              i_lifnr      = ls_lfa1-lifnr
*              i_number     = 'X'
*              i_office     = ''
*            IMPORTING
*              e_tax_number = gs_lfa1_tax-vkn_tckn
*              e_ktokl      = gs_lfa1_tax-ktokl
*            EXCEPTIONS
*              other        = 1.
*
*          gs_lfa1_tax-hesap_no = ls_lfa1-lifnr.
*          gs_lfa1_tax-lifnr = ls_lfa1-lifnr.
*          gs_lfa1_tax-kunnr = ls_lfa1-kunnr.
*
*          INSERT gs_lfa1_tax INTO TABLE gt_lfa1_tax. CLEAR gs_lfa1_tax.
*        ENDLOOP.
*      ELSE.
      IF p_selk IS NOT INITIAL.

        SELECT *
          FROM zreco_taxm
    INNER JOIN i_suppliercompany AS lfb1 ON zreco_taxm~lifnr EQ lfb1~supplier
    INNER JOIN i_supplier AS lfa1 ON lfa1~supplier EQ lfb1~supplier
         WHERE lfb1~companycode IN @s_bukrs
           AND zreco_taxm~hesap_tur EQ @zreco_if_common_types=>mc_hesap_tur_s
           AND zreco_taxm~hesap_no IN @r_lifnr
           AND zreco_taxm~vkn_tckn IN @s_vkn_ve " satıcı tckn
           AND lfa1~SupplierAccountGroup IN @s_ktokk
           AND lfa1~Industry IN @s_brsch2
           AND lfb1~ReconciliationAccount IN @s_kkont
           AND lfb1~ReconciliationAccount NE ''
           AND lfa1~PostingIsBlocked IN @r_sperr
           AND lfa1~DeletionIndicator IN @r_loevm
           AND lfb1~SupplierIsBlockedForPosting IN @r_sperr
           AND lfb1~DeletionIndicator IN @r_loevm
           APPENDING CORRESPONDING FIELDS OF TABLE @gt_lfa1_tax.

        SELECT *
          FROM Zreco_taxn
    INNER JOIN i_suppliercompany AS lfb1 ON Zreco_taxn~lifnr EQ lfb1~supplier
    INNER JOIN i_supplier AS lfa1 ON lfa1~supplier EQ lfb1~supplier
         WHERE lfb1~companycode IN @s_bukrs
           AND Zreco_taxn~hesap_tur EQ @zreco_if_common_types=>mc_hesap_tur_s
           AND Zreco_taxn~hesap_no IN @r_lifnr
           AND Zreco_taxn~vkn_tckn IN @s_vkn_ve " satıcı tckn
           AND lfa1~SupplierAccountGroup IN @s_ktokk
           AND lfa1~Industry IN @s_brsch2
           AND lfb1~ReconciliationAccount IN @s_kkont
           AND lfb1~ReconciliationAccount NE ''
           AND lfa1~PostingIsBlocked IN @r_sperr
           AND lfa1~DeletionIndicator IN @r_loevm
           AND lfb1~SupplierIsBlockedForPosting IN @r_sperr
           AND lfb1~DeletionIndicator IN @r_loevm
           APPENDING CORRESPONDING FIELDS OF TABLE @gt_lfa1_tax.
      ENDIF.
*      ENDIF.


*VKN BIRLEŞTIR YOK ISE --->
    ENDIF.


    IF p_tran IS NOT INITIAL  AND 1 = 2.

      IF gt_kna1_tax[] IS NOT INITIAL.
        SELECT lfa1~customer AS kunnr, lfa1~supplier AS lifnr
          FROM i_supplier AS lfa1
           INNER JOIN  i_suppliercompany AS lfb1 ON lfa1~supplier EQ lfb1~supplier
           FOR ALL ENTRIES IN @gt_kna1_tax
         WHERE lfa1~customer EQ @gt_kna1_tax-kunnr
           AND lfa1~customer NE ''
           AND lfb1~companycode IN @s_bukrs
           AND lfa1~PostingIsBlocked IN @r_sperr
           AND lfa1~DeletionIndicator IN @r_loevm
           AND lfb1~SupplierIsBlockedForPosting IN @r_sperr
           AND lfb1~DeletionIndicator IN @r_loevm
           AND lfb1~ReconciliationAccount NE ''
           APPENDING CORRESPONDING FIELDS OF TABLE @gt_lfa1_tax.
      ENDIF.

      IF gt_lfa1_tax[] IS NOT INITIAL.
        SELECT kna1~customer AS kunnr ,kna1~supplier AS lifnr
          FROM i_customer AS kna1 INNER JOIN i_customercompany AS knb1 ON kna1~customer EQ knb1~customer
           FOR ALL ENTRIES IN @gt_lfa1_tax
         WHERE kna1~supplier EQ @gt_lfa1_tax-lifnr
           AND kna1~supplier NE ''
           AND knb1~companycode IN @s_bukrs
           AND kna1~PostingIsBlocked IN @r_sperr
           AND kna1~DeletionIndicator IN @r_loevm
           AND knb1~PhysicalInventoryBlockInd IN @r_sperr
           AND knb1~DeletionIndicator IN @r_loevm
           AND knb1~ReconciliationAccount NE ''
     APPENDING CORRESPONDING FIELDS OF TABLE @gt_kna1_tax.
      ENDIF.

      LOOP AT gt_kna1_tax INTO gs_kna1_tax WHERE hesap_no IS INITIAL.

        IF gs_kna1_tax-kunnr IS NOT INITIAL.
          CLEAR ls_kna1_tax.
          MOVE-CORRESPONDING gs_kna1_tax TO ls_kna1_tax.

          SELECT SINGLE vkn_tckn, hesap_no, ktokl
                   FROM Zreco_taxm
                  WHERE hesap_tur EQ @Zreco_if_common_types=>mc_hesap_tur_m
                    AND hesap_no EQ @gs_kna1_tax-kunnr
                       INTO (@ls_kna1_tax-vkn_tckn,@ls_kna1_tax-hesap_no,@ls_kna1_tax-ktokl).
          IF sy-subrc NE 0.
            SELECT SINGLE vkn_tckn, hesap_no, ktokl
                     FROM Zreco_taxn
                    WHERE hesap_tur EQ @Zreco_if_common_types=>mc_hesap_tur_m
                      AND hesap_no EQ @Gs_kna1_tax-kunnr
                      INTO (@ls_kna1_tax-vkn_tckn, @ls_kna1_tax-hesap_no, @ls_kna1_tax-ktokl).
          ENDIF.
          IF ls_kna1_tax-hesap_no IS NOT INITIAL.
            MOVE-CORRESPONDING ls_kna1_tax TO gs_kna1_tax.
            INSERT gs_kna1_tax INTO TABLE gt_kna1_tax .
          ENDIF.
        ELSEIF gs_kna1_tax-lifnr IS NOT INITIAL.

          CLEAR ls_kna1_tax.

          SELECT SINGLE vkn_tckn ,hesap_no ,ktokl
                   FROM Zreco_taxm
                  WHERE hesap_tur EQ @Zreco_if_common_types=>mc_hesap_tur_s
                   AND hesap_no EQ @gs_kna1_tax-lifnr
                   INTO (@ls_kna1_tax-vkn_tckn, @ls_kna1_tax-hesap_no, @ls_kna1_tax-ktokl).
          IF sy-subrc NE 0.
            SELECT SINGLE vkn_tckn ,hesap_no ,ktokl
                     FROM Zreco_taxn
                    WHERE hesap_tur EQ @Zreco_if_common_types=>mc_hesap_tur_s
                      AND hesap_no EQ @gs_kna1_tax-lifnr
                      INTO (@ls_kna1_tax-vkn_tckn, @ls_kna1_tax-hesap_no, @ls_kna1_tax-ktokl).
          ENDIF.

          IF ls_kna1_tax-hesap_no IS NOT INITIAL.
            MOVE-CORRESPONDING ls_kna1_tax TO gs_kna1_tax.
            INSERT gs_kna1_tax INTO TABLE gt_kna1_tax .
          ENDIF.
        ENDIF.
        DELETE gt_kna1_tax.
      ENDLOOP.

      LOOP AT gt_lfa1_tax INTO gs_lfa1_tax WHERE hesap_no IS INITIAL.

        IF gs_lfa1_tax-kunnr IS NOT INITIAL.

          CLEAR ls_lfa1_tax.

          MOVE-CORRESPONDING gs_lfa1_tax TO ls_lfa1_tax.

          SELECT SINGLE vkn_tckn ,hesap_no ,ktokl
                   FROM Zreco_taxm
                  WHERE hesap_tur EQ @Zreco_if_common_types=>mc_hesap_tur_m
                    AND hesap_no EQ @gs_lfa1_tax-kunnr
                     INTO (@ls_lfa1_tax-vkn_tckn, @ls_lfa1_tax-hesap_no, @ls_lfa1_tax-ktokl).
          IF sy-subrc NE 0.
            SELECT SINGLE vkn_tckn ,hesap_no ,ktokl
                     FROM Zreco_taxn
                    WHERE hesap_tur EQ @Zreco_if_common_types=>mc_hesap_tur_m
                      AND hesap_no EQ @gs_lfa1_tax-kunnr
            INTO (@ls_lfa1_tax-vkn_tckn, @ls_lfa1_tax-hesap_no, @ls_lfa1_tax-ktokl).
          ENDIF.

          IF ls_lfa1_tax-hesap_no IS NOT INITIAL.
            MOVE-CORRESPONDING ls_lfa1_tax TO gs_lfa1_tax.
            INSERT gs_lfa1_tax INTO TABLE gt_lfa1_tax.
          ENDIF.

        ELSEIF gs_lfa1_tax-lifnr IS NOT INITIAL.

          CLEAR ls_lfa1_tax.
          MOVE-CORRESPONDING gs_lfa1_tax TO ls_lfa1_tax.

          SELECT SINGLE vkn_tckn, hesap_no, ktokl
                   FROM Zreco_taxm
                  WHERE hesap_tur EQ @Zreco_if_common_types=>mc_hesap_tur_s
                    AND hesap_no EQ @gs_lfa1_tax-lifnr
                    INTO (@ls_lfa1_tax-vkn_tckn, @ls_lfa1_tax-hesap_no, @ls_lfa1_tax-ktokl).
          IF sy-subrc NE 0.
            SELECT SINGLE vkn_tckn ,hesap_no, ktokl
                     FROM Zreco_taxn
                    WHERE hesap_tur EQ @Zreco_if_common_types=>mc_hesap_tur_s
                      AND hesap_no EQ @gs_lfa1_tax-lifnr
                      INTO (@ls_lfa1_tax-vkn_tckn, @ls_lfa1_tax-hesap_no, @ls_lfa1_tax-ktokl).
          ENDIF.

          IF ls_lfa1_tax-hesap_no IS NOT INITIAL.
            MOVE-CORRESPONDING ls_lfa1_tax TO gs_lfa1_tax.
            INSERT gs_lfa1_tax INTO TABLE gt_lfa1_tax.
          ENDIF.
        ENDIF.
        DELETE gt_lfa1_tax.
      ENDLOOP.
    ENDIF.


    DELETE ADJACENT DUPLICATES FROM gt_kna1_tax
                   COMPARING vkn_tckn hesap_no kunnr.

    DELETE ADJACENT DUPLICATES FROM gt_lfa1_tax
                          COMPARING vkn_tckn hesap_no lifnr.

    DATA: lt_kna1_tax_srt TYPE SORTED TABLE OF zreco_kunnr_tax
                           WITH NON-UNIQUE KEY kunnr,
          ls_kna1_tax_srt TYPE zreco_kunnr_tax, "hkizilkaya
          lt_lfa1_tax_srt TYPE SORTED TABLE OF zreco_lifnr_tax
                           WITH NON-UNIQUE KEY lifnr, "hkizilkaya
          ls_lfa1_tax_srt TYPE zreco_lifnr_tax.

    CLEAR: lt_kna1_tax_srt, lt_lfa1_tax_srt.

    lt_kna1_tax_srt[] = gt_kna1_tax[].
    lt_lfa1_tax_srt[] = gt_lfa1_tax[] .

    CLEAR: gt_kna1_tax[], gt_lfa1_tax[].

* YETKI VE GÖNDERIM KONTROLÜ
    LOOP AT lt_kna1_tax_srt INTO ls_kna1_tax_srt.

*YETKI KONTROLÜ
*      IF gv_auth IS INITIAL.  "YiğitcanÖzdemir
*
*        CLEAR lv_auth.
*
*        CALL FUNCTION '/ITETR/RECO_AUTH'
*          EXPORTING
*            i_bukrs     = gs_adrs-bukrs
*            i_hesap_tur = 'M'
*            i_hesap_no  = ls_kna1_tax_srt-kunnr
*            i_mtype     = gv_mtype
*            i_uname     = sy-uname
*            i_ftype     = p_ftype
*            i_ktokl     = ls_kna1_tax_srt-ktokl
*          IMPORTING
*            e_auth      = lv_auth.
*
*      ENDIF.

*      IF lv_auth IS INITIAL. "YETKI YOK
*
*        CALL METHOD go_log->bal_log_msg_add
*          EXPORTING
*            i_type       = /itetr/reco_if_common_types=>mc_msg_e
*            i_no         = '173'
*            i_id         = /itetr/reco_if_common_types=>mc_msg_class
*            i_v1         = ls_kna1_tax_srt-kunnr
*            i_v2         = TEXT-tr1
*            i_v3         = ''
*            i_v4         = ''
*            i_log_handle = gv_log_handle
*          EXCEPTIONS
*            OTHERS       = 1.
*
*        CONTINUE.
*      ELSE.

*GÖNDERIM KONTROLÜ
      control_send( EXPORTING iv_kunnr    = ls_kna1_tax_srt-kunnr
                              iv_lifnr    = ''
                              iv_vkn_tckn = ls_kna1_tax_srt-vkn_tckn
                    CHANGING  c_send      = gv_send
                              c_mnumber   = gv_mnumber ).

      IF gv_send IS NOT INITIAL. "DAHA ÖNCE GÖNDERILMIŞ

*          CALL METHOD go_log->bal_log_msg_add      "YİğitcanÖzdemir
*            EXPORTING
*              i_type       = /itetr/reco_if_common_types=>mc_msg_w
*              i_no         = '174'
*              i_id         = /itetr/reco_if_common_types=>mc_msg_class
*              i_v1         = ls_kna1_tax_srt-kunnr
*              i_v2         = TEXT-tr1
*              i_v3         = p_period
*              i_v4         = gv_mnumber
*              i_log_handle = gv_log_handle
*            EXCEPTIONS
*              OTHERS       = 1.

        CONTINUE.
      ELSE.
        MOVE-CORRESPONDING ls_kna1_tax_srt TO gs_kna1_tax.
        READ TABLE gt_taxm INTO DATA(ls_taxm) WITH KEY kunnr = ls_kna1_tax_srt-kunnr.
        IF sy-subrc EQ 0.
          IF p_all IS NOT INITIAL.
            gs_kna1_tax-merge = zreco_if_common_types=>mc_select_yes.
          ENDIF.
        ELSE.
          CLEAR gs_kna1_tax-merge.
        ENDIF.
        INSERT gs_kna1_tax INTO TABLE gt_kna1_tax. CLEAR gs_kna1_tax.
      ENDIF.
*      ENDIF.
    ENDLOOP.

    LOOP AT lt_lfa1_tax_srt INTO ls_lfa1_tax_srt.
      IF gv_auth IS INITIAL.
        CLEAR lv_auth.

*YETKI KONTROLÜ
*        CALL FUNCTION '/ITETR/RECO_AUTH' "YiğitcanÖzdemir
*          EXPORTING
*            i_bukrs     = gs_adrs-bukrs
*            i_hesap_tur = /itetr/reco_if_common_types=>mc_hesap_tur_s
*            i_hesap_no  = ls_lfa1_tax_srt-lifnr
*            i_mtype     = gv_mtype
*            i_uname     = sy-uname
*            i_ftype     = p_ftype
*            i_ktokl     = ls_lfa1_tax_srt-ktokl
*          IMPORTING
*            e_auth      = lv_auth.
      ENDIF.

      IF lv_auth IS INITIAL. "YETKI YOK
*        CALL METHOD go_log->bal_log_msg_add   "YiğitcanÖzdemir
*          EXPORTING
*            i_type       = /itetr/reco_if_common_types=>mc_msg_e
*            i_no         = '173'
*            i_id         = /itetr/reco_if_common_types=>mc_msg_class
*            i_v1         = ls_lfa1_tax_srt-lifnr
*            i_v2         = TEXT-tr2
*            i_v3         = /itetr/reco_if_common_types=>mc_select_no
*            i_v4         = /itetr/reco_if_common_types=>mc_select_no
*            i_log_handle = gv_log_handle
*          EXCEPTIONS
*            OTHERS       = 1.
        CONTINUE.
      ELSE.

*GÖNDERIM KONTROLÜ
        control_send( EXPORTING iv_kunnr    = ''
                                iv_lifnr    = ls_lfa1_tax_srt-lifnr
                                iv_vkn_tckn = ls_lfa1_tax_srt-vkn_tckn
                      CHANGING  c_send      = gv_send
                                c_mnumber   = gv_mnumber ).

        IF gv_send IS NOT INITIAL. "DAHA ÖNCE GÖNDERILMIŞ
*          CALL METHOD go_log->bal_log_msg_add                      "YiğitcanÖzdemir
*            EXPORTING
*              i_type       = /itetr/reco_if_common_types=>mc_msg_w
*              i_no         = '174'
*              i_id         = /itetr/reco_if_common_types=>mc_msg_class
*              i_v1         = ls_lfa1_tax_srt-lifnr
*              i_v2         = TEXT-tr2
*              i_v3         = p_period
*              i_v4         = gv_mnumber
*              i_log_handle = gv_log_handle
*            EXCEPTIONS
*              OTHERS       = 1.
          CONTINUE.
        ELSE.
          MOVE-CORRESPONDING ls_lfa1_tax_srt TO gs_lfa1_tax.
          READ TABLE gt_taxm INTO ls_taxm WITH KEY lifnr = ls_lfa1_tax_srt-lifnr.
          IF sy-subrc EQ 0.
            IF p_all IS NOT INITIAL.
              gs_lfa1_tax-merge = zreco_if_common_types=>mc_select_yes.
            ENDIF.
          ELSE.
            CLEAR gs_lfa1_tax-merge.
          ENDIF.
          INSERT gs_lfa1_tax INTO TABLE gt_lfa1_tax. CLEAR gs_lfa1_tax.
        ENDIF.
      ENDIF.
    ENDLOOP.

    DELETE gt_kna1_tax WHERE kunnr IS INITIAL.
    DELETE gt_lfa1_tax WHERE lifnr IS INITIAL.

    DELETE ADJACENT DUPLICATES FROM gt_kna1_tax
    COMPARING vkn_tckn hesap_no kunnr.

    DELETE ADJACENT DUPLICATES FROM  gt_lfa1_tax
    COMPARING vkn_tckn hesap_no lifnr.

    LOOP AT gt_kna1_tax INTO gs_kna1_tax WHERE lifnr IS NOT INITIAL
                                           AND merge EQ 'X'.

      LOOP AT gt_kna1_tax ASSIGNING FIELD-SYMBOL(<fs_kna1_tax>)
        WHERE vkn_tckn EQ gs_kna1_tax-vkn_tckn
        AND lifnr IS INITIAL
        AND merge EQ 'X'.
        <fs_kna1_tax>-lifnr = gs_kna1_tax-lifnr.
      ENDLOOP.

    ENDLOOP.

    LOOP AT gt_lfa1_tax INTO gs_lfa1_tax WHERE kunnr IS NOT INITIAL
                                           AND merge EQ 'X'.
      LOOP AT gt_lfa1_tax ASSIGNING FIELD-SYMBOL(<fs_lfa1_tax>)
        WHERE vkn_tckn EQ gs_lfa1_tax-vkn_tckn
        AND kunnr IS INITIAL
        AND merge EQ 'X'.
        <fs_lfa1_tax>-kunnr = gs_lfa1_tax-kunnr.
      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.