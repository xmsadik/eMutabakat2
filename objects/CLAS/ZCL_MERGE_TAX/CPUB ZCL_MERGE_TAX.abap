CLASS zcl_merge_tax DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider .


    DATA :
      s_erdat TYPE RANGE OF erdat,
      p_seld  TYPE abap_boolean,
      s_kunnr TYPE RANGE OF kunnr,
      p_selk  TYPE abap_boolean,
      s_lifnr TYPE RANGE OF lifnr,
      p_blk   TYPE abap_boolean,
      p_del   TYPE abap_boolean.


    TYPES: BEGIN OF ty_kna1,
             kunnr TYPE kunnr,
             adrnr TYPE zreco_adrnr,
             fiskn TYPE kunnr,
             ktokd TYPE ktokd,
             lifnr TYPE lifnr,
             stcd1 TYPE stcd1,
             stcd2 TYPE stcd2,
             stceg TYPE stceg,
             stcd3 TYPE stcd3,
             stcd4 TYPE stcd4,
           END OF ty_kna1.

    TYPES: BEGIN OF ty_lfa1,
             lifnr TYPE kunnr,
             adrnr TYPE zreco_adrnr,
             fiskn TYPE kunnr,
             ktokk TYPE ktokk,
             kunnr TYPE lifnr,
             stcd1 TYPE stcd1,
             stcd2 TYPE stcd2,
             stceg TYPE stceg,
             stcd3 TYPE stcd3,
             stcd4 TYPE stcd4,
           END OF ty_lfa1.

    DATA: lt_kna1    TYPE SORTED TABLE OF ty_kna1 WITH NON-UNIQUE KEY kunnr , "WITH HEADER LINE,
          lt_lfa1    TYPE SORTED TABLE OF ty_lfa1 WITH NON-UNIQUE KEY lifnr , " WITH HEADER LINE,
          lt_adrs    TYPE TABLE OF zreco_adrs,
          ls_adrs    TYPE zreco_adrs,
          lt_taxg    TYPE TABLE OF zreco_taxg , "WITH HEADER LINE,

          lv_count_n TYPE i,
          lv_count_m TYPE i,

          lt_taxm    TYPE TABLE OF zreco_taxm,
          ls_taxm    TYPE zreco_taxm,

          lt_taxn    TYPE TABLE OF zreco_taxn,
          ls_taxn    TYPE zreco_taxn,
          lt_etax    TYPE TABLE OF zreco_etax. " WITH HEADER LINE.

*   data  : r_ktokd TYPE RANGE OF zreco_taxg-ktokd,
*           r_ktokk TYPE RANGE OF zreco_taxg-ktokk,
*           r_sperr TYPE RANGE OF abap_boolean,
*           r_loevm TYPE RANGE OF loevm,
*           r_bukrs TYPE RANGE OF bukrs.


    TYPES: BEGIN OF ty_sperr,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE c LENGTH 1,
             high   TYPE c LENGTH 1,

           END OF ty_sperr.

    TYPES: BEGIN OF ty_loevm,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE loevm,
             high   TYPE loevm,

           END OF ty_loevm.

    TYPES: BEGIN OF ty_bukrs,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE bukrs,
             high   TYPE bukrs,

           END OF ty_bukrs.


    TYPES: BEGIN OF ty_ktokd,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE zreco_taxg-ktokd,
             high   TYPE zreco_taxg-ktokd,

           END OF ty_ktokd.

    TYPES: BEGIN OF ty_ktokk,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE zreco_taxg-ktokk,
             high   TYPE zreco_taxg-ktokk,

           END OF ty_ktokk.

    DATA : r_loevm TYPE TABLE OF ty_loevm.
    DATA : r_bukrs TYPE TABLE OF ty_bukrs.
    DATA : r_ktokd TYPE TABLE OF ty_ktokd.
    DATA : r_sperr TYPE TABLE OF ty_sperr.
    DATA : r_ktokk TYPE TABLE OF ty_ktokk.



    DATA : s_cursor_kna1 TYPE cursor,
           s_cursor_lfa1 TYPE cursor.


    METHODS : start_of_selection.