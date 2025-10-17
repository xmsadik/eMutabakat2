  METHOD if_rap_query_provider~select.

    TRY.

        DATA :
          lt_seld TYPE RANGE OF abap_boolean,
          lt_selk TYPE RANGE OF abap_boolean,
          lt_blk  TYPE RANGE OF abap_boolean,
          lt_del  TYPE RANGE OF abap_boolean.


        DATA(lt_filter) = io_request->get_filter( )->get_as_ranges( ).


        LOOP AT lt_filter INTO DATA(ls_filter).
          CASE ls_filter-name.
            WHEN 'ERDAT'.
              s_erdat = CORRESPONDING #( ls_filter-range ).
            WHEN 'SELD'.
              lt_seld = CORRESPONDING #( ls_filter-range ).
            WHEN 'KUNNR'.
              s_kunnr = CORRESPONDING #( ls_filter-range ).
            WHEN 'SELK'.
              lt_selk = CORRESPONDING #( ls_filter-range ).
            WHEN 'LIFNR'.
              s_lifnr = CORRESPONDING #( ls_filter-range ).
            WHEN 'BLK'.
              lt_blk = CORRESPONDING #( ls_filter-range ).
            WHEN 'DEL'.
              lt_del = CORRESPONDING #( ls_filter-range ).
          ENDCASE.
        ENDLOOP.


        p_seld = VALUE #( lt_seld[ 1 ]-low OPTIONAL ).
        p_selk = VALUE #( lt_selk[ 1 ]-low OPTIONAL ).
        p_blk = VALUE #( lt_blk[ 1 ]-low OPTIONAL ).
        p_del = VALUE #( lt_del[ 1 ]-low OPTIONAL ).


        start_of_selection( ).

      CATCH cx_rap_query_filter_no_range.
    ENDTRY.


  ENDMETHOD.