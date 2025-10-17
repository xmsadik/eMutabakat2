  METHOD if_rap_query_provider~select.

    DATA: company_code TYPE bukrs,
          reco_form    TYPE RANGE OF zreco_form,
          monat        TYPE RANGE OF monat,
          gjahr        TYPE RANGE OF gjahr,
          reco_number  TYPE RANGE OF zreco_number,
          account_type TYPE RANGE OF zreco_account_type,
          ktonr_av     TYPE RANGE OF zreco_ktonr_av,
          kunnr        TYPE RANGE OF kunnr,
          lifnr        TYPE RANGE OF lifnr,
          vkn          TYPE RANGE OF zreco_vkn,
          output       TYPE RANGE OF zreco_output,
          result       TYPE RANGE OF zreco_result,
          uname        TYPE RANGE OF zreco_uname,
          erdat        TYPE RANGE OF zreco_cpudt,
          erzei        TYPE RANGE OF zreco_CPUTM,
          daily        TYPE RANGE OF abap_boolean,
          odk          TYPE RANGE OF abap_boolean,
          bal          TYPE abap_boolean,
          all          TYPE abap_boolean,  "YiğitcanÖzdemir
          del          TYPE RANGE OF abap_boolean.


*    DATA(lt_filter) = io_request->get_filter( )->get_as_ranges( ).
    DATA: lt_output TYPE TABLE OF zreco_ddl_i_reco_follow_report,
          ls_output TYPE zreco_ddl_i_reco_follow_report.
    DATA(lo_page)           = io_request->get_paging( ).
    TRY.
        DATA(filter_conditions) = io_request->get_filter( )->get_as_ranges( ). "  get_filter_conditions( ).


        LOOP AT filter_conditions INTO DATA(condition).
          CASE condition-name.
            WHEN 'P_BUKRS'.
              company_code = VALUE #( condition-range[ 1 ]-low OPTIONAL ).
            WHEN 'P_FTYPE'.
              LOOP AT condition-range INTO DATA(ls_range).
                APPEND VALUE #( sign   = ls_range-sign
                    option = ls_range-option
                    low    = ls_range-low
                    high   = ls_range-high ) TO reco_form.
              ENDLOOP.
            WHEN 'S_MONAT'.
              CLEAR:ls_range.
              LOOP AT condition-range INTO ls_range.
                APPEND VALUE #( sign   = ls_range-sign
                    option = ls_range-option
                    low    = ls_range-low
                    high   = ls_range-high ) TO monat.
              ENDLOOP.
            WHEN 'S_GJAHR'.
              CLEAR:ls_range.
              LOOP AT condition-range INTO ls_range.
                APPEND VALUE #( sign   = ls_range-sign
                    option = ls_range-option
                    low    = ls_range-low
                    high   = ls_range-high ) TO gjahr.
              ENDLOOP.
            WHEN 'S_MNMBR'.
              CLEAR:ls_range.
              LOOP AT condition-range INTO ls_range.
                APPEND VALUE #( sign   = ls_range-sign
                    option = ls_range-option
                    low    = ls_range-low
                    high   = ls_range-high ) TO reco_number.
              ENDLOOP.
            WHEN 'S_HSTUT'.
              CLEAR: ls_range.
              LOOP AT condition-range INTO ls_range.
                APPEND VALUE #( sign   = ls_range-sign
                    option = ls_range-option
                    low    = ls_range-low
                    high   = ls_range-high ) TO account_type.
              ENDLOOP.
            WHEN 'S_HSPNO'.
              CLEAR: ls_range.
              LOOP AT condition-range INTO ls_range.
                APPEND VALUE #( sign   = ls_range-sign
                    option = ls_range-option
                    low    = ls_range-low
                    high   = ls_range-high ) TO ktonr_av.
              ENDLOOP.
            WHEN 'S_KUNNR'.
              CLEAR: ls_range.
              LOOP AT condition-range INTO ls_range.
                APPEND VALUE #( sign   = ls_range-sign
                    option = ls_range-option
                    low    = ls_range-low
                    high   = ls_range-high ) TO kunnr.
              ENDLOOP.
            WHEN 'S_LIFNR'.
              CLEAR: ls_range.
              LOOP AT condition-range INTO ls_range.
                APPEND VALUE #( sign   = ls_range-sign
                    option = ls_range-option
                    low    = ls_range-low
                    high   = ls_range-high ) TO lifnr.
              ENDLOOP.
            WHEN 'S_STCD2'.
              CLEAR: ls_range.
              LOOP AT condition-range INTO ls_range.
                APPEND VALUE #( sign   = ls_range-sign
                    option = ls_range-option
                    low    = ls_range-low
                    high   = ls_range-high ) TO vkn.
              ENDLOOP.
            WHEN 'S_OUTPT'.
              CLEAR: ls_range.
              LOOP AT condition-range INTO ls_range.
                APPEND VALUE #( sign   = ls_range-sign
                    option = ls_range-option
                    low    = ls_range-low
                    high   = ls_range-high ) TO output.
              ENDLOOP.
            WHEN 'S_MRSLT'.
              CLEAR: ls_range.
              LOOP AT condition-range INTO ls_range.
                APPEND VALUE #( sign   = ls_range-sign
                    option = ls_range-option
                    low    = ls_range-low
                    high   = ls_range-high ) TO result.
              ENDLOOP.
            WHEN 'S_ERNAM'.
              CLEAR: ls_range.
              LOOP AT condition-range INTO ls_range.
                APPEND VALUE #( sign   = ls_range-sign
                    option = ls_range-option
                    low    = ls_range-low
                    high   = ls_range-high ) TO uname.
              ENDLOOP.
            WHEN 'S_ERDAT'.
              CLEAR: ls_range.
              LOOP AT condition-range INTO ls_range.
                APPEND VALUE #( sign   = ls_range-sign
                    option = ls_range-option
                    low    = ls_range-low
                    high   = ls_range-high ) TO erdat.
              ENDLOOP.
            WHEN 'S_ERZEI'.
              CLEAR: ls_range.
              LOOP AT condition-range INTO ls_range.
                APPEND VALUE #( sign   = ls_range-sign
                    option = ls_range-option
                    low    = ls_range-low
                    high   = ls_range-high ) TO erzei.
              ENDLOOP.
            WHEN 'P_DAILY'.
              CLEAR: ls_range.
              LOOP AT condition-range INTO ls_range.
                APPEND VALUE #( sign   = ls_range-sign
                    option = ls_range-option
                    low    = ls_range-low
                    high   = ls_range-high ) TO   daily .
              ENDLOOP.
            WHEN 'P_ODK'.
              CLEAR: ls_range.
              LOOP AT condition-range INTO ls_range.
                APPEND VALUE #( sign   = ls_range-sign
                    option = ls_range-option
                    low    = ls_range-low
                    high   = ls_range-high ) TO   odk .
              ENDLOOP.
            WHEN 'P_BAL'.
              bal        = VALUE #( condition-range[ 1 ]-low OPTIONAL ).
            WHEN 'P_DEL'.
              LOOP AT condition-range INTO ls_range.
                APPEND VALUE #( sign   = ls_range-sign
                    option = ls_range-option
                    low    = ls_range-low
                    high   = ls_range-high ) TO del.
              ENDLOOP.

            WHEN 'P_ALL'.   "YiğitcanÖzdemir
              all        = VALUE #( condition-range[ 1 ]-low OPTIONAL ).

          ENDCASE.
        ENDLOOP.
      CATCH cx_rap_query_filter_no_range.
    ENDTRY.
    me->get_data(
    iv_bukrs        = company_code
    it_reco_form    = reco_form
    it_monat        = monat
    it_gjahr        = gjahr
    it_reco_number  = reco_number
    it_account_type = account_type
    it_ktonr_av     = ktonr_av
    it_kunnr        = kunnr
    it_lifnr        = lifnr
    it_vkn          = vkn
    it_output       = output
    it_result       = result
    it_uname        = uname
    it_erdat        = erdat
    it_erzei        = erzei
    it_daily        = daily
    it_odk          = odk
    iv_bal          = bal
    it_del          = del
    iv_all          = all
  ).

*    me->partner_selection(             "YiğitcanÖzdemir ~???
*  iv_bukrs        = company_code
*  it_account_type = account_type
*  it_ktonr_av     = ktonr_av
*  ).

    LOOP AT mt_out INTO DATA(ls_out_c) .  "YiğitcanÖzdemir
      MOVE-CORRESPONDING ls_out_c TO ls_output.
      ls_output-s_outpt = ls_out_c-moutput.
      APPEND ls_output TO lt_output.
    ENDLOOP.

    TRY.
        IF io_request->is_total_numb_of_rec_requested(  ).
          io_response->set_total_number_of_records( iv_total_number_of_records = lines( lt_output ) ).
        ENDIF.
        io_response->set_data( it_data = lt_output ).

      CATCH cx_rap_query_filter_no_range.
    ENDTRY.

  ENDMETHOD.