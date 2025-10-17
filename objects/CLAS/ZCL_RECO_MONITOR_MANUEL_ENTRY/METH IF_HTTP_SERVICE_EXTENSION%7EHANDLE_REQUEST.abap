  METHOD if_http_service_extension~handle_request.

    mo_common = NEW #( ).

    mv_service_data = request->get_text( ) .

    TRY.
        DATA(lo_json) = NEW /ui2/cl_json( ).
        lo_json->deserialize(
          EXPORTING
            json = mv_service_data
          CHANGING
            data = ms_json_data
        ).

        me->save_data(
          EXPORTING
            service_data = ms_json_data
          IMPORTING
            ev_message   = DATA(lv_message)
        ).

      CATCH cx_root INTO DATA(lx_exception).
*        lx_exception->get_text( ).
    ENDTRY.


    response->set_text(
      EXPORTING
        i_text = lv_message
*       i_offset = 0
*       i_length = -1
*      RECEIVING
*       r_value  =
    ).
*    CATCH cx_web_message_error.

  ENDMETHOD.