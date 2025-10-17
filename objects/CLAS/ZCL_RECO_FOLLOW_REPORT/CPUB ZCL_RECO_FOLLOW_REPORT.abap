CLASS zcl_reco_follow_report DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider .

    DATA: p_daily TYPE RANGE OF zreco_daily,
          p_odk   TYPE RANGE OF abap_boolean,
          p_bal   TYPE abap_boolean,
          p_del   TYPE abap_boolean.

    DATA: p_all   TYPE abap_boolean,
          p_anwsr TYPE abap_boolean,
          p_compl TYPE abap_boolean.

    DATA: mt_range_del          TYPE RANGE OF abap_boolean,
          mt_del                TYPE TABLE OF abap_boolean,
          mt_range_ktonr        TYPE RANGE OF zreco_ktonr_av,
          mt_range_account_type TYPE RANGE OF zreco_account_type,
          mt_range_monat        TYPE RANGE OF monat,
          mt_range_gjahr        TYPE RANGE OF gjahr,
          mt_range_reco_number  TYPE RANGE OF zreco_number,
          mt_range_output       TYPE RANGE OF zreco_output,
          mt_range_vkn          TYPE RANGE OF zreco_vkn,
          mt_range_kunnr        TYPE RANGE OF kunnr,
          mt_range_lifnr        TYPE RANGE OF lifnr,
          mt_range_zreco_form   TYPE RANGE OF zreco_form,
          mt_range_zreco_uname  TYPE RANGE OF zreco_uname,
          mt_range_zreco_cpudt  TYPE RANGE OF zreco_cpudt,
          mt_range_zreco_cputm  TYPE RANGE OF zreco_cputm,
          mt_range_zreco_result TYPE RANGE OF zreco_result,
          mt_range_daily        TYPE RANGE OF abap_boolean,
          mt_range_odk          TYPE RANGE OF abap_boolean,
          mt_out                TYPE TABLE OF zreco_monitor.

    DATA: r_mtype TYPE RANGE OF zreco_hdr-mtype,
          r_ftype TYPE RANGE OF zreco_hdr-ftype,
          r_sum   TYPE RANGE OF zreco_rcai-xsum,
          r_hspno TYPE RANGE OF zreco_hdr-hesap_no,
          r_hstur TYPE RANGE OF zreco_hdr-hesap_tur,
          r_daily TYPE RANGE OF zreco_hdr-daily.

    DATA: ls_date     TYPE zreco_compare_data,
          lv_mod      TYPE i,
          lv_color    TYPE c LENGTH 4,
          lv_tabix    TYPE sy-tabix,
          ls_answer   TYPE zreco_mtb_return_itm_b,
          ls_answer_c TYPE zreco_mtb_return_itm_c,
          lv_answer   TYPE c LENGTH 1,
          lv_text     TYPE string,
          lt_cform    TYPE STANDARD TABLE OF zreco_cform_sf,
          ls_cform    TYPE zreco_cform_sf,
          ls_bform    TYPE zreco_bform_sf,
          gt_htxt     TYPE TABLE OF zreco_htxt,
          ls_htxt     TYPE zreco_htxt.



    DATA: gt_t005t TYPE TABLE OF i_countrytext .
    DATA: gt_kna1 TYPE TABLE OF i_customer,
          gt_lfa1 TYPE TABLE OF i_supplier.

    TYPES: BEGIN OF gty_business,
             hesap_tur TYPE zreco_account_type,
             hesap_no  TYPE zreco_ktonr_av,
             partner   TYPE zreco_ktonr_av,
             name      TYPE c LENGTH 80,
           END OF gty_business.

    DATA: gt_business TYPE TABLE OF gty_business,
          gs_business TYPE gty_business.


*     Mutabakat gönderim başlık bilgileri
    DATA: gt_h001 TYPE SORTED TABLE OF zreco_hdr
                  WITH UNIQUE KEY bukrs
                                  gsber
                                  mnumber
                                  monat
                                  gjahr
                                  hesap_tur
                                  hesap_no ,
          gs_h001 TYPE zreco_hdr,
          "Mutabakat cevap başlık bilgileri
          gt_h002 TYPE SORTED TABLE OF zreco_hia
                  WITH NON-UNIQUE KEY mnumber monat gjahr
                                      hesap_tur hesap_no,
          gs_h002 TYPE zreco_hia,
          "Mutabakat versiyonlar
          gt_v001 TYPE SORTED TABLE OF zreco_vers
                  WITH NON-UNIQUE KEY mnumber monat gjahr version,
          gs_v001 TYPE zreco_vers,
          "B formu bilgileri
          gt_b001 TYPE SORTED TABLE OF zreco_recb
                  WITH NON-UNIQUE KEY mnumber monat gjahr version,
          gs_b001 TYPE zreco_recb,
          "Cari mutabakat bilgileri
          gt_c001 TYPE SORTED TABLE OF zreco_rcai
                  WITH NON-UNIQUE KEY mnumber monat gjahr version,
          gs_c001 TYPE zreco_rcai,
          "Mutabakat gelen cevaplar
          gt_r000 TYPE SORTED TABLE OF zreco_reia
                  WITH NON-UNIQUE KEY mnumber monat gjahr version,
          gs_r000 TYPE zreco_reia,
          "Mutabakat Cari Hesap Gelen Cevaplar
          gt_r001 TYPE SORTED TABLE OF zreco_rcar
                  WITH NON-UNIQUE KEY mnumber monat gjahr version,
          gs_r001 TYPE zreco_rcar,
          "Mutabakat B Formu Gelen Cevaplar
          gt_r002 TYPE SORTED TABLE OF zreco_rbia
                  WITH NON-UNIQUE KEY mnumber monat gjahr version,
          gs_r002 TYPE zreco_rbia,
          gt_chd1 TYPE SORTED TABLE OF zreco_chd1
                  WITH NON-UNIQUE KEY bukrs gsber mnumber
                  monat gjahr hesap_tur hesap_no waers,

          gs_chd1 TYPE zreco_chd1,
          gt_e001 TYPE TABLE OF zreco_refi,
          "Sonraki dönem mutabakat bilgileri
          gt_c002 TYPE SORTED TABLE OF zreco_c002
                  WITH NON-UNIQUE KEY mnumber monat gjahr version,
          gs_c002 TYPE zreco_c002,
          "Sonraki dönem mutabakat bilgileri
          gt_c003 TYPE SORTED TABLE OF zreco_c003
                  WITH NON-UNIQUE KEY mnumber monat gjahr version,
          gs_c003 TYPE zreco_c003,

          gt_user TYPE TABLE OF zreco_cvua,
          gs_parm TYPE zreco_parm,
          gt_chat TYPE SORTED TABLE OF zreco_chat
                  WITH UNIQUE KEY bukrs gsber mnumber monat gjahr hesap_tur
                  hesap_no,
          gs_chat TYPE zreco_chat.

    DATA ls_amount TYPE zreco_mtb_amount_c.
    DATA ls_refi TYPE zreco_refi.

    METHODS:
      get_data IMPORTING VALUE(iv_bukrs)        TYPE bukrs OPTIONAL
                         VALUE(it_reco_form)    LIKE mt_range_zreco_form OPTIONAL
                         VALUE(it_monat)        LIKE mt_range_monat OPTIONAL
                         VALUE(it_gjahr)        LIKE mt_range_gjahr OPTIONAL
                         VALUE(it_reco_number)  LIKE mt_range_reco_number OPTIONAL
                         VALUE(it_account_type) LIKE mt_range_account_type OPTIONAL
                         VALUE(it_ktonr_av)     LIKE mt_range_ktonr OPTIONAL
                         VALUE(it_kunnr)        LIKE mt_range_kunnr OPTIONAL
                         VALUE(it_lifnr)        LIKE mt_range_lifnr OPTIONAL
                         VALUE(it_vkn)          LIKE mt_range_vkn OPTIONAL
                         VALUE(it_output)       LIKE mt_range_output OPTIONAL
                         VALUE(it_result)       LIKE mt_range_zreco_result OPTIONAL
                         VALUE(it_uname)        LIKE mt_range_zreco_uname OPTIONAL
                         VALUE(it_erdat)        LIKE mt_range_zreco_cpudt OPTIONAL
                         VALUE(it_erzei)        LIKE mt_range_zreco_cputm OPTIONAL
                         VALUE(it_daily)        LIKE mt_range_daily OPTIONAL
                         VALUE(it_odk)          LIKE mt_range_odk OPTIONAL
                         VALUE(iv_bal)          TYPE abap_boolean OPTIONAL
                         VALUE(it_del)          LIKE mt_range_del OPTIONAL
                         VALUE(iv_all)          TYPE abap_boolean OPTIONAL "YiğitcanÖzdemir
               EXPORTING VALUE(gt_out)          LIKE mt_out ,

      partner_selection IMPORTING VALUE(iv_bukrs)        TYPE bukrs OPTIONAL
                                  VALUE(it_account_type) LIKE mt_range_account_type OPTIONAL
                                  VALUE(it_ktonr_av)     LIKE mt_range_ktonr OPTIONAL,

      get_status IMPORTING VALUE(ls_h001)   TYPE zreco_hdr OPTIONAL
                 EXPORTING VALUE(ls_ansver) TYPE zreco_mtb_return_itm_b ,

      get_status_c IMPORTING VALUE(ls_h001)     TYPE  zreco_hdr OPTIONAL
                   EXPORTING VALUE(ls_answer_c) TYPE zreco_mtb_return_itm_c,

      get_name_text IMPORTING VALUE(is_out) TYPE zreco_monitor OPTIONAL "YiğitcanÖzdemir
                    CHANGING  VALUE(cs_out) TYPE zreco_monitor .


