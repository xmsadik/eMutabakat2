CLASS zcl_reco_form DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider .



    DATA : p_runty  TYPE c LENGTH 1 VALUE '1', "Önyüz de çalışacak sadece "YiğitcanÖzdemir
           r_mform  TYPE c LENGTH 1 VALUE 'X', "Cari Mutabakat Formu için çalışacak sadece Ba / Bs formu (r_bform) yok "YiğitcanÖzdemir
           p_ftype  TYPE c LENGTH 2 VALUE '01', "Cari Mutabakat Formu için çalışacak  "YiğitcanÖzdemir
           p_period TYPE monat,
           p_gjahr  TYPE gjahr,
           p_daily  TYPE abap_boolean,
           p_rdate  TYPE budat,
           s_bukrs  TYPE RANGE OF bukrs,
           p_gsber  TYPE abap_boolean,
           s_gsber  TYPE RANGE OF gsber,
           p_waers  TYPE abap_boolean,
           s_waers  TYPE RANGE OF waers,
           p_seld   TYPE abap_boolean,
           s_kunnr  TYPE RANGE OF kunnr,
           s_ktokd  TYPE RANGE OF akont,
           s_dkont  TYPE RANGE OF akont,
           s_vkn_cr TYPE RANGE OF zreco_vkn,
           p_selk   TYPE  abap_boolean,
           s_lifnr  TYPE RANGE OF lifnr,
           s_ktokk  TYPE RANGE OF ktokk,
           S_kkont  TYPE RANGE OF akont,
           S_brsch1 TYPE RANGE OF brsch,
           S_brsch2 TYPE RANGE OF brsch,
           s_vkn_ve TYPE RANGE OF zreco_vkn,
           p_tran   TYPE abap_boolean,
           p_all    TYPE abap_boolean,
           p_blist  TYPE abap_boolean,
           p_diff   TYPE abap_boolean,
           "Çıktı İşlemleri
           p_last   TYPE abap_boolean,
           p_cred   TYPE abap_boolean,
           p_print  TYPE c LENGTH 4,
           p_limit  TYPE wrbtr,
           p_shk    TYPE abap_boolean,
           p_date   TYPE datum,
           p_bli    TYPE abap_boolean,
           p_bsiz   TYPE abap_boolean,
           p_exch   TYPE abap_boolean,
           p_zero   TYPE abap_boolean,
           p_sgli   TYPE abap_boolean,
           s_sgli   TYPE RANGE OF zreco_account_type,
           s_og     TYPE RANGE OF zreco_umskz,
           p_novl   TYPE abap_boolean,
           p_nolc   TYPE abap_boolean.

    DATA: gv_b_belnr   TYPE abap_boolean, "B formunu belge bazında özetle
          gv_b_xblnr   TYPE abap_boolean, "B formunda aynı referansları birleştir
          gv_b_decimal TYPE abap_boolean, "B formunda kuruş hanesini sıfırla
          gv_s4hana    TYPE abap_boolean, "HANA
          gv_ledger    TYPE c LENGTH 2. "Defter kodu


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
*      gs_adrc  TYPE zreco_adrc,
*      gt_adrc  TYPE TABLE OF zreco_adrc,
          gt_flds  TYPE TABLE OF zreco_flds,
          gs_flds  TYPE zreco_flds,
          gs_parm  TYPE zreco_parm,
          gt_uname TYPE TABLE OF zreco_unam.


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
*      gt_r002      TYPE SORTED TABLE OF zreco_rbia
*                   WITH NON-UNIQUE KEY mnumber monat gjahr version,
          gt_user      TYPE SORTED TABLE OF zreco_cvua
                       WITH NON-UNIQUE KEY kunnr lifnr,
          gs_user      TYPE zreco_cvua,
*      gs_r002      TYPE /itetr/reco_rbia,
          gv_bukrs     TYPE bukrs, "Şirket kodu
          gv_spras     TYPE spras, "İletişim dili
          gv_langu     TYPE spras VALUE 'TR', "Ekran iletişim dili
          gv_auth      TYPE abap_boolean,  "Yetki kontrolü
          gv_odk       TYPE abap_boolean,  "ÖDK mutabakatı da var
          gv_kur       TYPE abap_boolean,  "Kur var
          gv_loc_dmbtr TYPE p LENGTH 16 DECIMALS 2, "Toplam UPB tutarı @YiğitcanÖzdemir
          gv_spl_dmbtr TYPE p LENGTH 16 DECIMALS 2. "tslxx12. "Toplam ÖDK tutarı @YiğitcanÖzdemir


    DATA: r_sperr TYPE RANGE OF zreco_adrs-sperr, "Blokaj
          r_loevm TYPE RANGE OF zreco_adrs-loevm. "Silme göstergesi


* vkn birleştirmesi yapılacak müşteriler
    DATA : gt_taxm_d TYPE SORTED TABLE OF zreco_taxm
               WITH NON-UNIQUE KEY vkn_tckn,
* VKN birleştirmesi yapılacak satıcılar
           gt_taxm_k TYPE TABLE OF zreco_taxm
                     WITH NON-UNIQUE KEY vkn_tckn,
* VKN birleştirmesi yapılacak tüm cariler
           gt_taxm   TYPE SORTED TABLE OF zreco_taxm
                     WITH NON-UNIQUE KEY kunnr lifnr,
           gs_taxm   TYPE zreco_taxm,
* VKN birleştirmesi yapılmayacak tüm cariler
           gt_taxn   TYPE SORTED TABLE OF zreco_taxn
                     WITH NON-UNIQUE KEY kunnr lifnr,
           gs_taxn   TYPE zreco_taxn,
* VKN birleştirmesi yapılmayacak cariler
           gt_etax   TYPE SORTED TABLE OF zreco_etax
                     WITH UNIQUE KEY bukrs stcd2.


    DATA: gv_mtype     TYPE zreco_type,
          gv_abtnr     TYPE c LENGTH 4, "abtnr,
          gv_pafkt     TYPE c LENGTH 2, "pafkt,
          gv_remark    TYPE c LENGTH 50, "ad_remark2,
*          gs_account    TYPE zreco_account,
          gv_len       TYPE i,
          gv_mail      TYPE zreco_AD_SMTPADR, "adr6-smtp_addr,
          gv_subj      TYPE c LENGTH 50, "so_obj_des,
*          gt_attachment TYPE /itetr/reco_tt_attachments,
*          gt_note       TYPE STANDARD TABLE OF /itetr/reco_note,
*          gs_note       TYPE /itetr/reco_note,
*          gs_thead      TYPE thead,
*          gt_txw_note   TYPE STANDARD TABLE OF txw_note,
*          gv_otf        TYPE flag,
*          gv_mail_send  TYPE flag,
          gv_telnumber TYPE c LENGTH 10.
*          gv_debug      TYPE flag.


    TYPES: BEGIN OF ty_cform,
             hesap_tur TYPE zreco_account_type,
             hesap_no  TYPE zreco_ktonr_av,
             waers     TYPE waers,
             kunnr     TYPE kunnr,
             lifnr     TYPE lifnr,
           END OF ty_cform.

    DATA: gt_out_c         TYPE TABLE OF zreco_cform,
          gs_out_c         TYPE zreco_cform,
* Cari mutabakat geçici veri
          gt_cform_temp    TYPE TABLE OF zreco_cform_temp,
          gs_cform_temp    TYPE zreco_cform_temp,

          gt_cform         TYPE TABLE OF ty_cform  , "Seçim için
          gs_cform         TYPE ty_cform,

*      gt_cform_sf      TYPE TABLE OF zreco_cform_sform,
*      gs_cform_sf      TYPE /itetr/reco_cform_sform,

          gt_exch          TYPE TABLE OF zreco_exch,
          gs_exch          TYPE zreco_exch,
          gt_dunning       TYPE TABLE OF zreco_dunning,
          gs_dunning       TYPE zreco_dunning,
          gt_cdun          TYPE SORTED TABLE OF zreco_cdun WITH NON-UNIQUE KEY bukrs gjahr hesap_no belnr buzei,
          gs_cdun          TYPE zreco_cdun,
          gt_dunning_times TYPE TABLE OF zreco_dunning_times,
          gs_dunning_times TYPE zreco_dunning_times,
          gt_bank          TYPE TABLE OF zreco_bank,
          gt_opening       TYPE TABLE OF zreco_opening,
          gs_opening       TYPE zreco_opening,
          gt_language      TYPE SORTED TABLE OF zreco_lang
                             WITH NON-UNIQUE KEY bukrs  .

* İhtar için kullanılan fatura no alanları
    DATA: gt_ifld TYPE SORTED TABLE OF zreco_ifld
                  WITH NON-UNIQUE KEY blart  .

    DATA  : gv_first_date TYPE d, "Dönem ilk tarih
            gv_last_date  TYPE d, "Dönem son tarih
            gv_send       TYPE abap_boolean, "Gönderim yapılmış
            gv_mnumber    TYPE zreco_number,
            gv_b_sel      TYPE zreco_date_selection,
            "B formu tarih seçimi
            gv_c_sel      TYPE zreco_date_selection.
    "Cari mut. tarih seçimi


*    RANGES: r_xausz FOR lfb1-xausz,  "Hesap özeti hariç tutma
*        r_blart FOR bsid-blart, "Belge türü
*        r_bldat FOR bsid-bldat, "Belge tarihi
*        r_budat FOR bsid-budat, "Kayıt tarihi
*        r_hkont FOR bsis-hkont, "Ana hesap
*        r_mwskz FOR bsis-mwskz. "Vergi göstergesi

    DATA : r_xausz TYPE RANGE OF zreco_xausz,
           r_blart TYPE RANGE OF blart,
           r_bldat TYPE RANGE OF bldat,
           r_budat TYPE RANGE OF budat,
           r_hkont TYPE RANGE OF hkont,
           r_mwskz TYPE RANGE OF mwskz.

    DATA : r_umskz_m TYPE RANGE OF zreco_umskz, "Müşteri ÖDK'ları
           r_umskz_s TYPE RANGE OF zreco_umskz, "Satıcı ÖDK'ları
           r_umskz   TYPE RANGE OF zreco_umskz, "Şüpheli Alacak ÖDK'ları
           r_kunnr   TYPE RANGE OF kunnr, "Müşteri
           r_lifnr   TYPE RANGE OF lifnr. "Satıcı

* Muhataplar için
    TYPES: BEGIN OF ty_kunnr,
             kunnr TYPE kunnr,
           END OF ty_kunnr.

    TYPES: BEGIN OF ty_lifnr,
             lifnr TYPE lifnr,
           END OF ty_lifnr.


    DATA: gt_knvp    TYPE SORTED TABLE OF ty_kunnr
                 WITH NON-UNIQUE KEY kunnr  ,
          gt_wyt3    TYPE SORTED TABLE OF ty_lifnr
                       WITH NON-UNIQUE KEY lifnr  ,
          gt_kunnr_s TYPE SORTED TABLE OF ty_kunnr WITH NON-UNIQUE KEY kunnr,  "Şüpheli alacak müşteri,
          gs_kunnr_s TYPE ty_kunnr,
          gt_lifnr_s TYPE SORTED TABLE OF ty_lifnr WITH NON-UNIQUE KEY lifnr,  "Şüpheli alacak satıcı.
          gs_lifnr_s TYPE ty_lifnr.


    DATA gt_reia TYPE TABLE OF zreco_reia.

    DATA: gv_no_kursf  TYPE abap_boolean,
          gv_no_value  TYPE abap_boolean,
          gv_no_local  TYPE abap_boolean,
          gv_open_item TYPE abap_boolean.

* vkn Birleştirme için
    DATA :  gt_kna1_tax TYPE SORTED TABLE OF zreco_kunnr_tax
                  WITH NON-UNIQUE KEY vkn_tckn hesap_no kunnr,
            gs_kna1_tax TYPE zreco_kunnr_tax.

    DATA :  gt_lfa1_tax TYPE SORTED TABLE OF zreco_lifnr_tax
            WITH NON-UNIQUE KEY vkn_tckn hesap_no lifnr,
            gs_lfa1_tax TYPE zreco_lifnr_tax.

    DATA: gv_master TYPE abap_boolean.

    DATA: "gt_exch_rate TYPE TABLE OF bapi1093_0, "Değerleme
      "gs_exch_rate TYPE bapi1093_0 , "Değerleme
      "gt_tcure TYPE TABLE OF tcure , "Tedavülden kalkan PB
      "gs_tcure TYPE tcure, "Tedavülden kalkan PB
      gt_curr TYPE TABLE OF zreco_ccur, "İkame edilen PB
      gs_curr LIKE LINE OF gt_curr, "İkame edilen PB
      gt_cloc TYPE TABLE OF zreco_cloc, "Sadece UPB mutab.
      gs_cloc TYPE zreco_cloc. "Sadece UPB mutabakat

    DATA: gt_odk     TYPE TABLE OF zreco_odk, "Mutabakat ÖDK'ları
          gs_odk     TYPE zreco_odk, "Mutabakat ÖDK'ları
          gt_odks    TYPE TABLE OF zreco_odks, "Şüpheli alacaklar
          gs_odks    TYPE zreco_odks, "Şüpheli alacaklar
* Müşteri/satıcı mahsuplaştırma için bakiye kontrolü
          gt_balance TYPE TABLE OF zreco_s_balance,
          gs_balance TYPE zreco_s_balance.

    DATA: gt_account_info TYPE SORTED TABLE OF Zreco_account_info  WITH NON-UNIQUE KEY kunnr lifnr, "Müşteri/satıcı bilgileri
          gs_account_info TYPE Zreco_account_info,
          gs_last_info    TYPE Zreco_compare_date.

    TYPES : BEGIN OF ty_bsid,
              kunnr TYPE kunnr,
              belnr TYPE belnr_d,
              gjahr TYPE gjahr,
              buzei TYPE buzei,
              umskz TYPE zreco_umskz,
              shkzg TYPE shkzg,
              gsber TYPE gsber,
              dmbtr TYPE dmbtr,
              wrbtr TYPE wrbtr,
              waers TYPE waers,
              xblnr TYPE xblnr,
              blart TYPE blart,
              saknr TYPE saknr,
              hkont TYPE hkont,
              bldat TYPE bldat,
              budat TYPE budat,
              zfbdt TYPE datum,
              zterm TYPE c LENGTH 4,
              zbd1t TYPE p LENGTH 3 DECIMALS 0,
              zbd2t TYPE p LENGTH 3 DECIMALS 0,
              zbd3t TYPE p LENGTH 3 DECIMALS 0,
              rebzg TYPE belnr_d,
              sgtxt TYPE sgtxt,
            END OF ty_bsid.

    TYPES : BEGIN OF ty_bsik,
              lifnr TYPE lifnr,
              belnr TYPE belnr_d,
              gjahr TYPE gjahr,
              buzei TYPE buzei,
              umskz TYPE zreco_umskz,
              shkzg TYPE shkzg,
              gsber TYPE gsber,
              dmbtr TYPE dmbtr,
              wrbtr TYPE wrbtr,
              waers TYPE waers,
              xblnr TYPE xblnr,
              blart TYPE blart,
              saknr TYPE saknr,
              hkont TYPE hkont,
              bldat TYPE bldat,
              budat TYPE budat,
              zfbdt TYPE datum,
              zterm TYPE c LENGTH 4,
              zbd1t TYPE p LENGTH 3 DECIMALS 0,
              zbd2t TYPE p LENGTH 3 DECIMALS 0,
              zbd3t TYPE p LENGTH 3 DECIMALS 0,
              rebzg TYPE belnr_d,
              sgtxt TYPE sgtxt,
            END OF ty_bsik.

* Mutabakat açık kalemler
    DATA : gt_bsid_temp TYPE TABLE OF zreco_tbsd,
           gs_bsid_temp TYPE zreco_tbsd.
* Müşteri açık ve denkleştirilmiş kalemler
    DATA :  gt_bsid TYPE SORTED TABLE OF ty_bsid  WITH NON-UNIQUE KEY kunnr belnr gjahr  .

    DATA : gs_bsid TYPE ty_bsid.

* Satıcı açık ve denkleştirilmiş kalemler
    DATA : gt_bsik TYPE SORTED TABLE OF ty_bsik
                   WITH NON-UNIQUE KEY lifnr belnr gjahr  .


    TYPES: BEGIN OF ty_bkpf_2,
             belnr     TYPE belnr_D,
             gjahr     TYPE gjahr,
             bktxt     TYPE bktxt,
             awkey     TYPE awkey,
             xref1_hd  TYPE xref1_hd,
             xref2_hd  TYPE xref2_hd,
             xblnr_alt TYPE zreco_xblnr_alt,
           END OF ty_bkpf_2.

    DATA : gt_cform_bkpf TYPE SORTED TABLE OF ty_bkpf_2 WITH UNIQUE KEY belnr gjahr,
           gs_cform_bkpf TYPE ty_bkpf_2.

    TYPES: BEGIN OF ty_BAPI1093_0,
             rate_type     TYPE kurst_curr,   " RATE_TYPE
             from_curr     TYPE fcurr_curr,   " FROM_CURR
             to_currncy    TYPE tcurr_curr,   " TO_CURRNCY
             valid_from    TYPE datum,    " VALID_FROM
             exch_rate     TYPE p LENGTH 9 DECIMALS 5,       " EXCH_RATE
             from_factor   TYPE ffact_curr,   " FROM_FACTOR
             to_factor     TYPE tfact_curr,   " TO_FACTOR
             exch_rate_v   TYPE p LENGTH 9 DECIMALS 5,       " EXCH_RATE_V
             from_factor_v TYPE ffact_curr,   " FROM_FACTOR_V
             to_factor_v   TYPE tfact_curr,   " TO_FACTOR_V
           END OF ty_BAPI1093_0.

    DATA: gt_exch_rate TYPE TABLE OF ty_BAPI1093_0, "Değerleme
          gs_exch_rate TYPE ty_BAPI1093_0.
*          gt_tcure     TYPE TABLE OF tcure , "Tedavülden kalkan PB
*          gs_tcure     TYPE tcure, "Tedavülden kalkan PB
*          gt_curr      TYPE TABLE OF /itetr/reco_ccur, "İkame edilen PB
*          gs_curr      LIKE LINE OF gt_curr, "İkame edilen PB
*          gt_cloc      TYPE TABLE OF /itetr/reco_cloc, "Sadece UPB mutab.
*          gs_cloc      TYPE /itetr/reco_cloc. "Sadece UPB mutabakat

* Cari mutabakat artalan veri
    DATA: gt_temp_c TYPE SORTED TABLE OF zreco_tmpc
                    WITH NON-UNIQUE KEY xsum hesap_tur hesap_no,
          gs_temp_c LIKE LINE OF gt_temp_c.

    TYPES: BEGIN OF ty_account,
             send_type TYPE c LENGTH 1,
             kunnr     TYPE kunnr,
             lifnr     TYPE lifnr,
             waers     TYPE waers,
           END OF ty_account.

    DATA : gt_added TYPE TABLE OF ty_account,
           gs_added TYPE ty_account.

    TYPES: BEGIN OF ty_receivers,
             receiver TYPE zreco_AD_SMTPADR,
             rec_type TYPE char03,
           END OF ty_receivers.

    DATA : gt_receivers TYPE TABLE OF zreco_somlreci1,
           gs_receivers TYPE zreco_somlreci1.

    DATA : gt_mail_list TYPE SORTED TABLE OF zreco_tmpe
                  WITH NON-UNIQUE KEY kunnr lifnr receiver,
           gs_mail_list LIKE LINE OF gt_mail_list.

    METHODS : sos,
      get_general_data,
      control_send IMPORTING VALUE(iv_kunnr)    TYPE zreco_kunnr_tax-kunnr
                             VALUE(iv_lifnr)    TYPE zreco_lifnr_tax-lifnr
                             VALUE(iv_vkn_tckn) TYPE zreco_kunnr_tax-vkn_tckn
                   CHANGING  VALUE(c_send)      TYPE abap_boolean
                             VALUE(c_mnumber)   TYPE zreco_number,
      check_bsid IMPORTING VALUE(iv_kunnr)      TYPE zreco_kunnr_tax-kunnr
                           VALUE(iv_budat)      TYPE budat
                 CHANGING  VALUE(cv_closing_rc) TYPE sy-subrc,
      check_bsik IMPORTING VALUE(iv_lifnr)      TYPE zreco_lifnr_tax-lifnr
                           VALUE(iv_budat)      TYPE budat
                 CHANGING  VALUE(cv_closing_rc) TYPE sy-subrc,
      check_bsad IMPORTING VALUE(iv_kunnr)      TYPE zreco_kunnr_tax-kunnr
                           VALUE(iv_budat)      TYPE budat
                 CHANGING  VALUE(cv_closing_rc) TYPE sy-subrc,
      check_bsak IMPORTING VALUE(iv_lifnr)      TYPE zreco_lifnr_tax-lifnr
                           VALUE(iv_budat)      TYPE budat
                 CHANGING  VALUE(cv_closing_rc) TYPE sy-subrc,
      get_cform_data,
      modify_account_group,
      modify_cform_data,
      partner_selection.