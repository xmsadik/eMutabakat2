  METHOD get_status.

    DATA : lv_url         TYPE string,
           lv_username    TYPE string,
           lv_password    TYPE string,
           lv_sjson       TYPE string,
           lv_json        TYPE xstring,
           lv_xresponse   TYPE xstring,
           lv_response    TYPE string,
           lv_http_code   TYPE i,
           lv_status      TYPE string,
           lo_http_client TYPE REF TO if_web_http_client,
           ls_input_rtn   TYPE zreco_mtb_return,
           lr_oref        TYPE REF TO cx_root,
           ls_response    TYPE zreco_mtb_return_itm_b.

    DATA ls_srvc TYPE zreco_srvc.
    DATA: zreco_cl_json TYPE REF TO zreco_common.
    CREATE OBJECT zreco_cl_json.

    SELECT SINGLE *
    FROM zreco_srvc
    WHERE srvid EQ '003'
      AND bukrs EQ @ls_h001-bukrs
       OR bukrs EQ @space
      INTO @ls_srvc .

    lv_url = ls_srvc-srvurl.
    lv_username = ls_srvc-srvusr.
    lv_password = ls_srvc-srvpsw.

    FREE : lo_http_client.

*    create OBJECT cl_http_client.                                                          "D_MBAYEL

*    cl_http_client=>create_by_url(
*       EXPORTING
*         url    = lv_url
*       IMPORTING
*         client = lo_http_client
*       EXCEPTIONS
*         argument_not_found = 1
*         plugin_not_active = 2
*         internal_error    = 3
*         OTHERS            = 4 ).

*    CHECK sy-subrc = 0.

*  lv_username = 'ETRANSFORMATIONADMIN'.
*  lv_password = '1234'.

*    "ls_input_rtn-reconcilationnumber = ps_h001-mnumber.

*  TRY .

*        lv_sjson = zreco_cl_json=>data_to_json( i_data = ls_input_rtn ).

    zreco_cl_json->zreco_data_json(
    IMPORTING
    ev_data = ls_input_rtn
    ).

    lv_sjson = ls_input_rtn-reconciliationuniqnumber.

*
*      CALL FUNCTION 'ECATT_CONV_STRING_TO_XSTRING'                                               "D_MBAYEL
*        EXPORTING
*          im_string  = lv_sjson
*        IMPORTING
*          ex_xstring = lv_json.
*
*    CATCH cx_root INTO lr_oref .
*  ENDTRY.

*lo_http_client->request->set_data( lv_json ).
*
*  lo_http_client->request->set_header_field(
*          name  = 'Content-Type'
*          value = 'application/json; charset=utf-8').
*
*  lo_http_client->request->set_method( 'GET' ).
*
*  lo_http_client->propertytype_logon_popup = lo_http_client->co_disabled.
*
*  CALL METHOD lo_http_client->authenticate
*    EXPORTING
*      username = lv_username
*      password = lv_password.
*
*  CALL METHOD lo_http_client->send
*    EXCEPTIONS
*      http_communication_failure = 1
*      http_invalid_state         = 2.
*  IF sy-subrc EQ 0.
*
**  receive response
*    CALL METHOD lo_http_client->receive
*      EXCEPTIONS
*        http_communication_failure = 1
*        http_invalid_state         = 2
*        http_processing_failed     = 3.
*    IF sy-subrc EQ 0.
*
*      lv_xresponse = lo_http_client->response->get_data( ).
*
*      CALL FUNCTION 'ECATT_CONV_XSTRING_TO_STRING'
*        EXPORTING
*          im_xstring  = lv_xresponse
*          im_encoding = 'UTF-8'
*        IMPORTING
*          ex_string   = lv_response.
*
*      CLEAR :lv_http_code,
*       lv_status.
*
*      CALL METHOD lo_http_client->response->get_status
*        IMPORTING
*          code   = lv_http_code
*          reason = lv_status.
*
*      IF lv_http_code EQ '200'.
*
*        IF lv_response EQ '[]'.
*        ELSE.
*
*          TRY .
*
*              /itetr/reco_cl_json=>json_to_data(
*                EXPORTING
*                  i_json = lv_response
*                CHANGING
*                  c_data = ls_response ).
*
*              ls_answer = ls_response.
*
**              IF ls_response-item_status_id = '247'.
**                lv_answer = 'Y'.
**              ELSEIF ls_response-item_status_id = '248'.
**                lv_answer = 'N'.
**              ELSEIF ls_response-item_status_id = '249'.
**                lv_answer = 'X'.
**              ENDIF.
*
*            CATCH cx_root INTO lr_oref .
*
*          ENDTRY.
*        ENDIF.
*
*      ELSE.
*
*
*      ENDIF.
*    ENDIF.
*
*    CALL METHOD lo_http_client->close
*      EXCEPTIONS
*        http_invalid_state = 1
*        OTHERS             = 2.
*
*  ENDIF.


  ENDMETHOD.