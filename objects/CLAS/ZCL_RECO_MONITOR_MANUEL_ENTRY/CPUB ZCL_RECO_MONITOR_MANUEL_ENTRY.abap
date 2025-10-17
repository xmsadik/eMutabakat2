CLASS zcl_reco_monitor_manuel_entry DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_service_extension .

    DATA: mo_common       TYPE REF TO zreco_common,
          mv_service_data TYPE string,
          ms_h001         TYPE zreco_hdr,
          ms_v001         TYPE zreco_vers,
          mv_version      TYPE zreco_version,
          ms_h002         TYPE zreco_hia,
          ms_r000         TYPE zreco_reia,
          mv_wait         TYPE flag, "Cevap bekleniyor
          mv_yes          TYPE flag, "Mutabıkız
          mv_no           TYPE flag, "Değiliz
          mv_no_data      TYPE flag, "Kayıt bulunmamaktadır
          mt_r001         TYPE SORTED TABLE OF zreco_rcar
                          WITH NON-UNIQUE KEY mnumber monat gjahr version,
          ms_r001         TYPE zreco_rcar, "YiğitcanÖzdemir
          ms_r002         TYPE zreco_rbia,
          ms_b001         TYPE zreco_recb,
          mt_c001         TYPE SORTED TABLE OF zreco_rcai
              WITH NON-UNIQUE KEY mnumber monat gjahr version,
          mt_c002         TYPE SORTED TABLE OF zreco_c002
                  WITH NON-UNIQUE KEY mnumber monat gjahr version,
          ms_c001         TYPE zreco_rcai,                  "YiğitcanÖzdemir
          mt_c003         TYPE SORTED TABLE OF zreco_c003
                  WITH NON-UNIQUE KEY mnumber monat gjahr version.

    TYPES : BEGIN OF mty_liste,
              ltext TYPE char2,
              wrbtr TYPE wrbtr,
              waers TYPE waers,
              kursf TYPE wrbtr,
            END OF mty_liste.

    DATA mt_liste TYPE TABLE OF mty_liste.

    TYPES : BEGIN OF mty_json_data,
              bukrs      TYPE bukrs,
              monat      TYPE char2,
              gjahr      TYPE gjahr,
              hesap_tur  TYPE char1,
              hesap_no   TYPE i,
              hesap_desc TYPE char200,
              mtype      TYPE char1,
              ftype      TYPE char2,
              moutput    TYPE char1,
              is_agree   TYPE char2,
              reco_mtext TYPE string,
              liste      LIKE mt_liste,
              spras      TYPE spras,
            END OF mty_json_data.

    DATA ms_json_data TYPE  mty_json_data.

    DATA number TYPE n LENGTH 20.

    METHODS:
      save_data IMPORTING VALUE(service_data) TYPE mty_json_data
                EXPORTING VALUE(ev_message)   TYPE string,

      number_get IMPORTING VALUE(iv_bukrs)  TYPE bukrs
                           VALUE(iv_gjahr)  TYPE gjahr
                 EXPORTING VALUE(ev_number) LIKE number.
