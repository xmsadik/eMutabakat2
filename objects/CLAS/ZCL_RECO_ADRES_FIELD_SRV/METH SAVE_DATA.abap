  METHOD save_data.
    /ui2/cl_json=>deserialize(
      EXPORTING
        json = iv_data
      CHANGING
        data = ms_radio_data
    ).

    me->replace_data(
      EXPORTING
        is_radio_data = ms_radio_data
      RECEIVING
        rs_radio_data = ms_radio_data
    ).

    DATA ls_flds TYPE zreco_flds.

    DELETE FROM zreco_flds.

    ls_flds = CORRESPONDING #( ms_radio_data ).
    MODIFY zreco_flds FROM @ls_flds.

  ENDMETHOD.