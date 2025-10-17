  METHOD send_grid_data_c.
    DATA : lv_partner_id    TYPE string,
           lv_url           TYPE string,
           lv_username      TYPE string,
           lv_password      TYPE string,
           ls_input_grid    TYPE zreco_mtb_header_grid_c,
           lv_mailto        TYPE string,
           lv_mailcc        TYPE string,
           lv_mailreturn    TYPE string,
           lv_sjson         TYPE string,
*           lv_json          TYPE xstring,
           lr_oref          TYPE REF TO cx_root,
           lv_xresponse     TYPE xstring,
           lv_response      TYPE string,
           lv_http_code     TYPE i,
           lv_status        TYPE string,
           ls_out_c         TYPE zreco_cform_sform,
           ls_response_data TYPE zreco_t_re,
           ls_response      TYPE zreco_resp,
*         ls_attachment    TYPE zreco_attachments,
*         lt_list          TYPE TABLE OF abaplist,
*         lt_list_txt      TYPE TABLE OF abaplist,
*         lv_spoolid       TYPE tsp01-rqident,
*         lt_pdf_content   TYPE solix_tab,
*         lv_pdf_size      TYPE so_obj_len,
           lv_exc_length    TYPE i,
           lv_excel_b64     TYPE string,
           lv_data_string   TYPE string.

    DATA ls_srvc TYPE zreco_srvc.

    DATA: lt_email_range TYPE RANGE OF zreco_ad_smtpadr.
*        ls_range       TYPE rsis_s_range.

*  RANGES: r_budat FOR sy-datum.
*  DATA: lr_budat LIKE LINE OF r_budat.

    DATA: lv_begda TYPE sy-datum,
          lv_endda TYPE sy-datum.

    " <-- hkizilkaya
    DATA: lv_waers         TYPE waers,
          lv_wrbtr         TYPE wrbtr,
          lv_wrbtr_eur     TYPE wrbtr,
          lv_wrbtr_usd     TYPE wrbtr,
          lv_wrbtr_gbp     TYPE wrbtr,
          lv_wrbtr_str     TYPE string,
          lv_wrbtr_eur_str TYPE string,
          lv_wrbtr_usd_str TYPE string,
          lv_wrbtr_gbp_str TYPE string,
          lv_period        TYPE c LENGTH 15,
          ls_receivers     TYPE zreco_somlreci1,
          lv_sjson_str     TYPE string,
          lv_srvhost       TYPE string,
          lv_rtm_mail      TYPE zreco_ad_smtpadr,
          lv_mcc_mail      TYPE zreco_ad_smtpadr,
          lt_tole          TYPE TABLE OF zreco_tole,
          ls_tole          TYPE zreco_tole.
*        ls_input         TYPE zreco_mtb_header_m.

    DATA: lv_txlen TYPE int4.
    CONSTANTS lc_success_code TYPE i VALUE 200.
    DATA ls_rece TYPE zreco_somlreci1. "hkizilkaya

    DATA lo_data TYPE REF TO data.

    FIELD-SYMBOLS: <lr_recon> TYPE zreco_mtb_recoitems,
                   <lfs_data> TYPE zreco_mtb_recoitems.
    FIELD-SYMBOLS: <lt_inputdata> TYPE zreco_mtb_inputdata,
*                 <lt_attac>     TYPE /itetr/reco_attachments,
                   <lt_files>     TYPE zreco_files.

    SELECT SINGLE *
        FROM zreco_srvc
        WHERE srvid EQ '001'
        AND bukrs EQ @i_head_c-bukrs OR bukrs EQ ''
              INTO @ls_srvc.


    SELECT SINGLE *
          FROM zreco_adrs
         WHERE bukrs EQ @i_head_c-bukrs
        INTO @DATA(ls_adrs).

    READ TABLE it_out_c INTO ls_out_c INDEX 1.
    IF sy-subrc EQ 0.
      lv_waers = ls_out_c-waers.
    ENDIF.

    SELECT *
  FROM zreco_tole
 WHERE bukrs EQ @i_head_c-bukrs
 AND stcd2 EQ @i_head_c-vkn_tckn
 INTO TABLE @lt_tole.

    IF i_head_c-land1 IS NOT INITIAL .
      IF i_head_c-land1 EQ 'TR'.
        ls_input_grid-cultureinfo = 'tr-TR'.
      ELSE.
        ls_input_grid-cultureinfo = 'en-US'.
      ENDIF.
    ENDIF.

    CONCATENATE i_head_c-hesap_no '-' i_head_c-vkn_tckn INTO lv_partner_id.
    CONCATENATE i_head_c-monat '/' i_head_c-gjahr INTO lv_period.

*  IF ls_adrs-client EQ 'X'.
*    CONCATENATE  i_head_c-bukrs '-' sy-mandt INTO ls_input_grid-code.
*  ELSE.
*    ls_input_grid-code = i_head_c-bukrs.
*  ENDIF.

    ls_input_grid-customervkn = i_head_c-vkn_tckn. "hkizilkaya
    ls_input_grid-partner  = lv_partner_id.
    ls_input_grid-number = i_head_c-mnumber.
    ls_input_grid-period   = lv_period.

    "Müşteri yada satıcı ayrımı var ise false ' ', yok ise true 'X'
    IF i_head_c-xdiff EQ 'X'.
      ls_input_grid-isseller = ' '.
    ELSE.
      ls_input_grid-isseller = 'X'.
    ENDIF.

    IF i_head_c-name1 IS NOT INITIAL.
      ls_input_grid-customername = i_head_c-name1.
    ELSE.
      ls_input_grid-customername = 'Test Verisi'.
    ENDIF.

    "YiğitcanÖzdemiir *Mutabakat Geçerlilik  15092025

*  IF ls_adrs-c_datbi IS NOT INITIAL.
*    ls_input_grid-c_datbi = ls_adrs-c_datbi.
*  ENDIF.
*
*  IF ls_adrs-c_valday IS NOT INITIAL.
*    ls_input_grid-c_valday = ls_adrs-c_valday.
*  ENDIF.
    "YiğitcanÖzdemiir *Mutabakat Geçerlilik

    IF i_head_c-xbli EQ 'X'.
      ls_input_grid-formtype         = '2'.
    ELSE.
      ls_input_grid-formtype         = '3'.
    ENDIF.

*  SELECT SINGLE mail
*    FROM zreco_rtm
*    WHERE bukrs EQ @i_head_c-bukrs
*    AND hesap_tur EQ @i_head_c-hesap_tur
*    INTO @lv_rtm_mail.
*  IF sy-subrc EQ 0.
*    lv_mailreturn = lv_rtm_mail.
*    APPEND lv_mailreturn TO ls_input_grid-mailreturn.
*  ENDIF.

    SELECT SINGLE mail
      FROM zreco_mcc
      WHERE bukrs EQ @i_head_c-bukrs
      AND hesap_tur EQ @i_head_c-hesap_tur
          INTO @lv_mcc_mail.
    IF sy-subrc EQ 0.
      lv_mailcc = lv_mcc_mail.
*    APPEND lv_mailcc TO ls_input_grid-mailcc.
      APPEND INITIAL LINE TO  ls_input_grid-mailcc ASSIGNING FIELD-SYMBOL(<fs_mailcc>).
      <fs_mailcc>-string = lv_mailcc.
    ENDIF.



    LOOP AT it_receivers INTO ls_rece.
      lv_mailto = ls_rece-receiver.
*      APPEND lv_mailto TO ls_input_grid-mailto.
      APPEND INITIAL LINE TO  ls_input_grid-mailto ASSIGNING FIELD-SYMBOL(<fs_mailto>).
      <fs_mailto>-string = lv_mailto.

*      IF ( ls_adrs-opbel EQ 'X' OR ls_adrs-submit EQ 'X' ).
*        CLEAR ls_range.
*        ls_range-sign   = 'I'.
*        ls_range-option = 'EQ'.
*        ls_range-low    = ls_rece-receiver.
*        APPEND ls_range TO lt_email_range.
*      ENDIF.
    ENDLOOP.

    "changed ls_input_grid.
    LOOP AT it_out_c INTO ls_out_c.
      APPEND INITIAL LINE TO ls_input_grid-inputdata ASSIGNING <lt_inputdata>.
      <lt_inputdata>-type = ls_out_c-ltext.
      <lt_inputdata>-currencyunit = ls_out_c-waers.
      <lt_inputdata>-price  = ls_out_c-wrbtr.
      IF ls_out_c-umskz IS NOT INITIAL.
        <lt_inputdata>-isodk  = 'X'.
      ENDIF.
      <lt_inputdata>-accountnumber  = ls_out_c-akont.
      READ TABLE lt_tole INTO ls_tole WITH KEY akont = ls_out_c-akont
                                               waers = ls_out_c-waers.
      IF sy-subrc EQ 0.
        <lt_inputdata>-tolerans = ls_tole-wrbtr.
      ENDIF.
    ENDLOOP.

*    CONDENSE gv_filelength.
    APPEND INITIAL LINE TO ls_input_grid-files ASSIGNING <lt_files>.
    IF i_param IS NOT INITIAL.
      <lt_files>-filename = 'Denetim_Formu'.
    ELSE.
      <lt_files>-filename = 'Cari_Mutabakat_Formu'.
    ENDIF.
    <lt_files>-filetype = '.PDF'.
*    <lt_files>-filelength = gv_filelength.
*    <lt_files>-filebinarydata = gv_binarydata.
    CONDENSE <lt_files>-filelength.

*    IF ls_adrs-opbel EQ 'X' OR ls_adrs-submit EQ 'X'.
*      CONCATENATE i_head_c-gjahr i_head_c-monat '01' INTO lv_begda.
*      CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
*        EXPORTING
*          day_in            = lv_begda
*        IMPORTING
*          last_day_of_month = lv_endda.
*
*      CLEAR lr_budat.
*      lr_budat-sign   = 'I'.
*      lr_budat-option = 'BT'.
*      lr_budat-low    = lv_begda.
*      lr_budat-high   = lv_endda.
*      APPEND lr_budat TO r_budat.
*    ENDIF.

*    IF ls_adrs-opbel EQ 'X' AND i_param IS INITIAL.
*
*      PERFORM send_open_items TABLES it_out_c
*                               USING i_head_c
*                                     it_receivers
*                            CHANGING lv_excel_b64.
*
*      lv_exc_length = strlen( lv_excel_b64 ).
*      APPEND INITIAL LINE TO ls_input_grid-files ASSIGNING <lt_files>.
*      <lt_files>-filename = 'Acik_Kalemler'.
*      <lt_files>-filetype = '.XLS'.
*      <lt_files>-filelength = lv_exc_length.
*      <lt_files>-filebinarydata = lv_excel_b64.
*      CONDENSE <lt_files>-filelength.
*    ENDIF.

*    IF it_srv_attachment[] IS NOT INITIAL.
*      APPEND LINES OF  it_srv_attachment TO ls_input_grid-files.
*    ENDIF.

    select single CompanyCodeName from I_CompanyCode where companycode = @i_head_c-bukrs into @data(lv_comp).

    DATA(lv_json) =  /ui2/cl_json=>serialize( EXPORTING data = ls_input_grid pretty_name = 'X' ).

    TRY.
        DATA(lo_http_destination) = cl_http_destination_provider=>create_by_url( CONV #( ls_srvc-srvurl ) ).
        DATA(lo_web_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .
        DATA(lo_web_http_request) = lo_web_http_client->get_http_request( ).
        lo_web_http_request->set_authorization_basic(
          EXPORTING
            i_username = CONV #( ls_srvc-srvusr )
            i_password = CONV #( ls_srvc-srvpsw )
        ).

        lo_web_http_request->set_header_fields( VALUE #( (  name = 'Accept' value = 'application/json' )
                                                         (  name = 'Content-Type' value = 'application/json' )
                                                         (  name = 'CompanyName' value = |{ lv_comp }| ) ) ).
        lo_web_http_request->set_text(
          EXPORTING
            i_text   = lv_json
        ).

        DATA(lo_web_http_response) = lo_web_http_client->execute( if_web_http_client=>post ).
        lv_response = lo_web_http_response->get_text( ).
*        ev_original_data = lv_response.
        lo_web_http_response->get_status(
          RECEIVING
            r_value = DATA(ls_status)
        ).
        IF ls_status-code = lc_success_code. "success
          .
        ELSE.
*          MESSAGE ID ycl_eho_utils=>mc_message_class
*                  TYPE ycl_eho_utils=>mc_error
*                  NUMBER 017
*                  WITH ls_status-code
*                  INTO DATA(lv_message).
*          APPEND VALUE #( message = lv_message messagetype = ycl_eho_utils=>mc_error ) TO et_error_messages.
*          APPEND VALUE #( message = lv_response messagetype = ycl_eho_utils=>mc_error ) TO et_error_messages.
        ENDIF.
      CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error.
    ENDTRY.



  ENDMETHOD.