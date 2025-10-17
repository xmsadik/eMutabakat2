  METHOD number_get.
    DATA  nr_not_found TYPE REF TO cx_nr_object_not_found.
    DATA  number_ranges TYPE REF TO cx_number_ranges.

    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr = '01'
            object      = 'ZRECO_NR'
            quantity    = '1'
            subobject   = CONV #( iv_bukrs )
            toyear      = CONV #( iv_gjahr )
          IMPORTING
            number      = ev_number
        ).

        IF ev_number IS NOT INITIAL.
          ev_number = sy-datum+0(4) && sy-datum+4(2) && sy-datum+6(2) && sy-uzeit+0(2) && sy-uzeit+2(2) && sy-uzeit+4(2) && ev_number+14(2).
        ENDIF.
      CATCH cx_nr_object_not_found INTO nr_not_found.
        DATA(not_found_error) = nr_not_found->get_text( ).
      CATCH cx_number_ranges INTO number_ranges.
        DATA(number_ranges_error) = number_ranges->get_text( ).
    ENDTRY.
    "-
    DATA(random_generator) = cl_abap_random=>create( seed = CONV #( sy-uzeit ) ).

*   random_generator->
  ENDMETHOD.