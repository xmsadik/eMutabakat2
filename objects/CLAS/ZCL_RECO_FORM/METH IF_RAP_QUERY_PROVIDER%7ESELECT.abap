  METHOD if_rap_query_provider~select.

    TRY.

        DATA(lt_filter) = io_request->get_filter( )->get_as_ranges( ).




        DATA: lt_period_range  TYPE RANGE OF monat,
              lt_gjahr_range   TYPE RANGE OF gjahr,
              lt_daily_range   TYPE RANGE OF abap_boolean,
              lt_p_rdate_range TYPE RANGE OF budat,
              lt_p_gsber_range TYPE RANGE OF abap_boolean,
              lt_p_waers_range TYPE RANGE OF abap_boolean,
              lt_p_seld_range  TYPE RANGE OF abap_boolean,
              LT_p_selk_RANGE  TYPE RANGE OF abap_boolean,
              LT_p_tran_RANGE  TYPE RANGE OF abap_boolean,
              LT_p_all_RANGE   TYPE RANGE OF abap_boolean,
              LT_p_blist_RANGE TYPE RANGE OF abap_boolean,
              LT_p_diff_RANGE  TYPE RANGE OF abap_boolean,

              LT_p_last_RANGE  TYPE RANGE OF abap_boolean,
              LT_p_cred_RANGE  TYPE RANGE OF abap_boolean,
              LT_p_print_RANGE TYPE RANGE OF p_print,
              lt_limit_range   TYPE RANGE OF wrbtr,
              lt_p_shk_range   TYPE RANGE OF abap_boolean,
              lt_p_date_range  TYPE RANGE OF datum,
              lt_p_bli_range   TYPE RANGE OF abap_boolean,
              lt_p_bsiz_range  TYPE RANGE OF abap_boolean,
              lt_p_exch_range  TYPE RANGE OF abap_boolean,
              lt_p_zero_range  TYPE RANGE OF abap_boolean,
              lt_p_sgli_range  TYPE RANGE OF abap_boolean,
              lt_p_novl_range  TYPE RANGE OF abap_boolean,
              lt_p_nolc_range  TYPE RANGE OF abap_boolean,


              lt_output        TYPE TABLE OF zreco_ddl_i_reco_form,
              ls_output        TYPE zreco_ddl_i_reco_form.


        DATA(lt_paging) = io_request->get_paging( ).
*
        LOOP AT lt_filter INTO DATA(ls_filter).
          CASE ls_filter-name.
            WHEN 'PERIOD'.
              lt_period_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'GJAHR'.
              lt_gjahr_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_DAILY'.
              lt_daily_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'BUDAT'.
              lt_p_rdate_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'BUKRS'.
              s_bukrs = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_GSBER'.
              lt_p_gsber_range =  CORRESPONDING #( ls_filter-range ).
            WHEN 'GSBER'.
              s_gsber = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_WAERS'.
              LT_p_waers_RANGE =  CORRESPONDING #( ls_filter-range ).
            WHEN 'WAERS'.
              s_waers = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_SELD'.
              LT_p_seld_RANGE =  CORRESPONDING #( ls_filter-range ).
            WHEN 'KUNNR'.
              s_kunnr = CORRESPONDING #( ls_filter-range ).
            WHEN 'KTOKD'.
              s_ktokd = CORRESPONDING #( ls_filter-range ).
            WHEN 'DKONT'.
              s_dkont = CORRESPONDING #( ls_filter-range ).
            WHEN 'VKN_CR'.
              s_vkn_cr = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_SELK'.
              LT_p_selK_RANGE =  CORRESPONDING #( ls_filter-range ).
            WHEN 'LIFNR'.
              s_lifnr = CORRESPONDING #( ls_filter-range ).
            WHEN 'KTOKK'.
              s_ktokk = CORRESPONDING #( ls_filter-range ).
            WHEN 'KKONT'.
              S_kkont = CORRESPONDING #( ls_filter-range ).
            WHEN 'BRSCH1'.
              S_brsch1 = CORRESPONDING #( ls_filter-range ).
            WHEN 'BRSCH2'.
              S_brsch2 = CORRESPONDING #( ls_filter-range ).
            WHEN 'VKN_VE'.
              s_vkn_ve = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_TRAN'.
              LT_p_tran_RANGE = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_ALL'.
              LT_p_all_RANGE = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_BLIST'.
              LT_p_blist_RANGE = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_DIFF'.
              LT_p_diff_RANGE = CORRESPONDING #( ls_filter-range ).

*Çıktı İşlemleri

            WHEN 'P_LAST'.
              LT_p_last_RANGE = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_CRED'.
              LT_p_cred_RANGE = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_PRINT'.
              LT_p_print_RANGE = CORRESPONDING #( ls_filter-range ).
            WHEN 'LIMIT'.
              lt_limit_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_SHK'.
              lt_p_shk_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_DATE'.
              lt_p_date_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_BLI'.
              lt_p_bli_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_BSIZ'.
              lt_p_bsiz_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_EXCH'.
              lt_p_exch_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_ZERO'.
              lt_p_zero_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_SGLI'.
              lt_p_sgli_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'S_SGLI'.
              s_sgli = CORRESPONDING #( ls_filter-range ).
            WHEN 'S_OG'.
              s_og = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_NOVL'.
              lt_p_novl_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_NOLC'.
              lt_p_nolc_range = CORRESPONDING #( ls_filter-range ).

          ENDCASE.
        ENDLOOP.

        p_period = VALUE #( lt_period_range[ 1 ]-low OPTIONAL ).
        p_gjahr  = VALUE #( lt_gjahr_range[ 1 ]-low OPTIONAL ).
        p_daily  = VALUE #( lt_daily_range[ 1 ]-low OPTIONAL ).
        p_rdate  = VALUE #( lt_p_rdate_range[ 1 ]-low OPTIONAL ).
        p_gsber  = VALUE #( lt_p_gsber_range[ 1 ]-low OPTIONAL ).
        p_waers  = VALUE #( LT_p_waers_RANGE[ 1 ]-low OPTIONAL ).
        p_seld   = VALUE #( LT_p_seld_RANGE[ 1 ]-low OPTIONAL ).
        p_selK   = VALUE #( LT_p_selK_RANGE[ 1 ]-low OPTIONAL ).
        p_print   = VALUE #( LT_p_print_RANGE[ 1 ]-low OPTIONAL ).
        p_limit   = VALUE #( lt_limit_range[ 1 ]-low OPTIONAL ).
        p_shk   = VALUE #( lt_p_shk_range[ 1 ]-low OPTIONAL ).
        p_date   = VALUE #( lt_p_date_range[ 1 ]-low OPTIONAL ).
        p_bli   = VALUE #( lt_p_bli_range[ 1 ]-low OPTIONAL ).
        p_bsiz   = VALUE #( lt_p_bsiz_range[ 1 ]-low OPTIONAL ).
        p_exch   = VALUE #( lt_p_exch_range[ 1 ]-low OPTIONAL ).
        p_zero   = VALUE #( lt_p_zero_range[ 1 ]-low OPTIONAL ).
        p_sgli   = VALUE #( lt_p_sgli_range[ 1 ]-low OPTIONAL ).
        p_novl   = VALUE #( lt_p_novl_range[ 1 ]-low OPTIONAL ).
        p_nolc   = VALUE #( lt_p_nolc_range[ 1 ]-low OPTIONAL ).

*START-OF-SELECTION.
        sos(  ).


        DATA: lv_uuid     TYPE sysuuid_c22,
              ls_prev_key TYPE  zreco_cform.

        SORT gt_out_c BY hesap_tur hesap_no kunnr lifnr.

        LOOP AT gt_out_c ASSIGNING FIELD-SYMBOL(<fs_data>).

          " Eğer key değiştiyse yeni UUID oluştur
          IF <fs_data>-hesap_tur <> ls_prev_key-hesap_tur
             OR <fs_data>-hesap_no  <> ls_prev_key-hesap_no
             OR <fs_data>-kunnr     <> ls_prev_key-kunnr
             OR <fs_data>-lifnr     <> ls_prev_key-lifnr.

            lv_uuid = cl_system_uuid=>create_uuid_c22_static( ).
            ls_prev_key = <fs_data>. " key değerini sakla
          ENDIF.

          <fs_data>-uuid = lv_uuid.
        ENDLOOP.


        DATA : ls_temp TYPE zreco_gtout,
               lt_temp TYPE TABLE OF zreco_gtout.

        LOOP AT gt_out_c INTO DATA(ls_out_c) .
          MOVE-CORRESPONDING ls_out_c TO ls_output.
          ls_output-gjahr = p_gjahr.
          ls_output-period = p_period.
          ls_output-bukrs = gs_adrs-bukrs.
          APPEND ls_output TO lt_output.
          MOVE-CORRESPONDING ls_out_c TO ls_temp.
          ls_temp-gjahr = p_gjahr.
          ls_temp-period = p_period.
          ls_temp-bukrs = gs_adrs-bukrs.
          APPEND ls_temp TO lt_temp.
        ENDLOOP.

*        DATA: lv_uuid     TYPE sysuuid_c22,
*              ls_prev_key TYPE  zreco_cform.
*
*        SORT gt_out_c BY hesap_tur hesap_no kunnr lifnr.
*
*        LOOP AT gt_out_c INTO ls_out_c.
*
*          " Eğer key değiştiyse yeni UUID oluştur
*          IF ls_out_c-hesap_tur <> ls_prev_key-hesap_tur
*             OR ls_out_c-hesap_no  <> ls_prev_key-hesap_no
*             OR ls_out_c-kunnr     <> ls_prev_key-kunnr
*             OR ls_out_c-lifnr     <> ls_prev_key-lifnr.
*
*            lv_uuid = cl_system_uuid=>create_uuid_c22_static( ).
*            ls_prev_key = ls_out_c. " key değerini sakla
*          ENDIF.
*
*          " UUID'yi ata ve temp tabloya ekle
*          MOVE-CORRESPONDING ls_out_c TO ls_temp.
*          ls_temp-uuid = lv_uuid.
*          APPEND ls_temp TO lt_temp.
*
*        ENDLOOP.

        DELETE FROM zreco_gtout.
        IF lt_temp IS NOT INITIAL.
          MODIFY zreco_gtout FROM TABLE @lt_temp.
        ENDIF.

        IF io_request->is_total_numb_of_rec_requested(  ).
          io_response->set_total_number_of_records( iv_total_number_of_records = lines( lt_output ) ).
        ENDIF.


        IF io_request->is_data_requested( ).
          io_response->set_data( it_data = lt_output ).
        ENDIF.


      CATCH cx_rap_query_filter_no_range.
    ENDTRY.


  ENDMETHOD.