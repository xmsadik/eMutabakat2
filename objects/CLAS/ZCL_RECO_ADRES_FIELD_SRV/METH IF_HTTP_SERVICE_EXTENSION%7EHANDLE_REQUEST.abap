  METHOD if_http_service_extension~handle_request.

    DATA(lv_hesap_tur) =  request->get_form_field( i_name = 'IV_HESAP_TUR' ).
    DATA(lv_id) = request->get_form_field( i_name = 'IV_ID' ).
    DATA(lv_process) = request->get_form_field( i_name = 'IV_PROCESS' ).

    CASE lv_process.
      WHEN 'G'.
        me->get_data(
          iv_hesap_tur = CONV #( lv_hesap_tur )
          iv_id        = CONV #( lv_id )
        ).

        response->set_text(
          EXPORTING
            i_text = mv_json_data
        ).

      WHEN 'S'.
        me->save_data(
          iv_data = request->get_text( )
        ).


        response->set_text(
          EXPORTING
            i_text = 'Kayıt atıldı !'
        ).
    ENDCASE.

  ENDMETHOD.