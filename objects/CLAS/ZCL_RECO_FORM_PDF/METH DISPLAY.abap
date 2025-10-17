  METHOD display.

    TYPES: BEGIN OF ty_table1,
             hesap_turu         TYPE string,
             doviz_bakiye       TYPE string,
             pb                 TYPE string,
             try_bakiye         TYPE string,
             borc_alacak        TYPE string,
             cevap_doviz_bakiye TYPE string,
             pb2                TYPE string,
             cevap_try_bakiye   TYPE string,
             borc_alacak2       TYPE string,
           END OF ty_table1.

    TYPES: BEGIN OF ty_form,
             cevaplama_tarihi TYPE string,
             duzenleme_tarihi TYPE string,
             Cevap            TYPE string,
             sirket_adres     TYPE string,
             cari_adres       TYPE string,
             takip            TYPE string,
             mutabakat_tarihi TYPE string,
             cari_no          TYPE string,
             iletisim         TYPE string,
             Table1           TYPE STANDARD TABLE OF ty_table1 WITH DEFAULT KEY,
             toplam           TYPE string,
           END OF ty_form.

    DATA: ls_req      TYPE zreco_s_pdf_body,
          ls_response TYPE zreco_s_pdf_response,
          ls_data     TYPE zreco_s_pdf_data.

    TRY.
        DATA(lo_dest) = cl_http_destination_provider=>create_by_comm_arrangement(
          comm_scenario  = 'ZETR_RECO_FORM'
          comm_system_id = 'ZETR_RECO_FORM_001'
          service_id     = 'ZETR_RECO_FORM_REST'
        ).
      CATCH cx_http_dest_provider_error INTO DATA(lx_error).
    ENDTRY.

    TRY.
        DATA(lo_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
      CATCH  cx_web_http_client_error INTO DATA(lx_client_error).
    ENDTRY.

    DATA(lo_request) = lo_client->get_http_request( ).
    lo_request->set_header_fields( VALUE #(
      ( name = 'Accept' value = 'application/json, text/plain, */*'  )
      ( name = 'Content-Type' value = 'application/json;charset=utf-8'  )
    ) ).

    ls_data = VALUE #(
      cevaplama_tarihi = '20240730'
      duzenleme_tarihi = '20240731'
      Cevap            = 'Test Cevap'
      sirket_adres     = 'Istanbul, Turkey'
      cari_adres       = 'Ankara, Turkey'
      takip            = 'Takip Notu'
      mutabakat_tarihi = '20240801'
      cari_no          = '1234567890'
      iletisim         = 'info@company.com'
      Table1           = VALUE #( ( hesap_turu = 'Kredi'
                                    doviz_bakiye = '1000'
                                    pb = 'PB1'
                                    try_bakiye = '900'
                                    borc_alacak = 'B'
                                    cevap_doviz_bakiye = '1100'
                                    pb2 = 'PB2'
                                    cevap_try_bakiye = '950'
                                    borc_alacak2 = 'A' )
                                  ( hesap_turu = 'Nakit'
                                    doviz_bakiye = '2000'
                                    pb = 'PB3'
                                    try_bakiye = '1800'
                                    borc_alacak = 'A'
                                    cevap_doviz_bakiye = '2100'
                                    pb2 = 'PB4'
                                    cevap_try_bakiye = '1850'
                                    borc_alacak2 = 'B' ) )
      toplam            = '3000'
    ).

    TRY.
        CALL TRANSFORMATION zreco_form_pdf_takip
        SOURCE form = ls_data
        RESULT XML DATA(lv_xml).

      CATCH cx_root INTO DATA(lo_root).
    ENDTRY.


    DATA(lv_base64_data) = cl_web_http_utility=>encode_x_base64( unencoded = lv_xml ).

    ls_req-xdp_template       = 'zetr_af_reco_form_001/recoform'.
    ls_req-xml_data           = lv_base64_data.
    ls_req-form_type          = 'print'.
    ls_req-form_locale        = 'tr_TR'.
    ls_req-tagged_pdf         = 1.
    ls_req-embed_font         = 0.
    ls_req-change_not_allowed = abap_false.
    ls_req-print_not_allowed  = abap_false.

    TRY.
        CALL METHOD /ui2/cl_json=>serialize
          EXPORTING
            data        = ls_req
            pretty_name = /ui2/cl_json=>pretty_mode-camel_case
          RECEIVING
            r_json      = DATA(lv_body).

      CATCH cx_root INTO DATA(lx_root).
    ENDTRY.

    lo_request->set_text(
      EXPORTING
        i_text = lv_body
    ).

    TRY.
        DATA(lo_response) = lo_client->execute(
          i_method = if_web_http_client=>post
*         i_timeout = 0
        ).
      CATCH  cx_web_http_client_error INTO lx_client_error.
    ENDTRY.
    DATA(lv_response) = lo_response->get_text( ).
    DATA(ls_status)   = lo_response->get_status( ).

    TRY.
        CALL METHOD /ui2/cl_json=>deserialize
          EXPORTING
            json          = lv_response
            assoc_arrays  = abap_true
            name_mappings = VALUE #( ( json = 'fileContent' abap = 'FILECONTENT' ) )
          CHANGING
            data          = ls_response.
      CATCH cx_root INTO lx_root.
    ENDTRY.

    ev_pdf_content =  ls_response-filecontent .

  ENDMETHOD.