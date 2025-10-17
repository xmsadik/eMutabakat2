CLASS lhc_follow_report DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR follow_report RESULT result.
"
*    METHODS create FOR MODIFY
*      IMPORTING entities FOR CREATE follow_report.

*    METHODS update FOR MODIFY
*      IMPORTING entities FOR UPDATE follow_report.
*
*    METHODS delete FOR MODIFY
*      IMPORTING keys FOR DELETE follow_report.

    METHODS read FOR READ
      IMPORTING keys FOR READ follow_report RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK follow_report.

    METHODS analiz FOR MODIFY
      IMPORTING keys FOR ACTION follow_report~analiz RESULT result.

    METHODS reminder_mail FOR MODIFY
      IMPORTING keys FOR ACTION follow_report~reminder_mail RESULT result.

    METHODS show_form FOR MODIFY
      IMPORTING keys FOR ACTION follow_report~show_form RESULT result.

    DATA: lt_h001 TYPE TABLE OF zreco_hdr .
    METHODS send_reminder IMPORTING VALUE(it_h001) LIKE lt_h001 .
    METHODS send_reminder_c IMPORTING VALUE(it_h001) LIKE lt_h001 .

ENDCLASS.

CLASS lhc_follow_report IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

*  METHOD create.
*  ENDMETHOD.

*  METHOD update.
*  ENDMETHOD.

*  METHOD delete.
*  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD analiz.

*    DATA: gt_pie       TYPE TABLE OF zreco_pie,
*          gc_cont_grap TYPE REF TO cl_gui_custom_container,
*          gc_inst      TYPE REF TO lcl_dc_pres,
*          gc_manage    TYPE REF TO if_dc_management,
*          gc_inst_prox TYPE REF TO cl_gui_gp_pres,
*          gv_grup_id   TYPE i,
*          gv_grup_name TYPE gfwgrpid VALUE 'Grafik',
*          retval       TYPE symsgno.
*    DATA: obj      TYPE zreco_gfwdcpres,
*          lv_objid TYPE text40.
*
*
*    CLEAR:gt_pie,gt_pie[],gv_grup_id,retval.
*
*    CLEAR:gc_cont_grap,gc_inst,gc_manage,gc_inst_prox.
*
*
*     CREATE OBJECT gc_inst.
*  gc_manage = gc_inst.
*  CALL METHOD gc_manage->init
*    IMPORTING
*      id     = gv_grup_id
*      retval = retval.
*  IF retval <> cl_gfw=>ok.
*    CALL METHOD cl_gfw=>show_msg
*      EXPORTING
*        msgno = retval.
*    CLEAR gc_inst.
*    CLEAR gc_manage.
*  ELSE.
*    LOOP AT gt_pie.
*      ADD 1 TO lv_objid.
*      obj-objid = lv_objid.
*      obj-grpid = gv_grup_name.
*      obj-x_val = gt_pie-tanim.
*      obj-y_val = gt_pie-oran.
*      IF lv_objid EQ '1'.
*        obj-cu_refobj = '1'.
*      ENDIF.
*      CALL METHOD gc_inst->set_obj_values
*        EXPORTING
*          id     = gv_grup_id
*          obj    = obj
*        IMPORTING
*          retval = retval.
*      IF retval <> cl_gfw=>ok. EXIT. ENDIF.
*      IF lv_objid EQ '1'.
*        CLEAR obj-cu_refobj.
*      ENDIF.
*      ADD 1 TO lv_objid.
*    ENDLOOP.
*
*    IF retval <> cl_gfw=>ok.
*      CALL METHOD cl_gfw=>show_msg
*        EXPORTING
*          msgno = retval.
*    ELSE.
*      CREATE OBJECT gc_cont_grap
*        EXPORTING
*          container_name = 'GRAPH_0300'.
*
*      CREATE OBJECT gc_inst_prox.
*
*      CALL METHOD gc_inst_prox->if_graphic_proxy~init
*        EXPORTING
*          parent     = gc_cont_grap
*          dc         = gc_inst
*          prod_id    = cl_gui_gp_pres=>co_prod_chart
*          force_prod = 'X'
*        IMPORTING
*          retval     = retval.
*      IF retval = cl_gfw=>ok.
*        CALL METHOD gc_inst_prox->set_dc_names
*          EXPORTING
*            obj_id    = 'OBJID'
*            dim1      = 'X_VAL'
*            dim2      = 'Y_VAL'
*            grp_id    = 'GRPID'
*            objref_id = 'CU_REFOBJ'
*          IMPORTING
*            retval    = retval.
*      ENDIF.
*
*      IF retval = cl_gfw=>ok.
*        PERFORM set_customizing_pie.
*      ENDIF.
*
*      IF retval = cl_gfw=>ok.
*        CALL METHOD gc_inst_prox->if_graphic_proxy~activate
*          IMPORTING
*            retval = retval.
*      ENDIF.
*      IF retval <> cl_gfw=>ok.
*        CALL METHOD cl_gfw=>show_msg
*          EXPORTING
*            msgno = retval.
*      ENDIF.
*    ENDIF.
*  ENDIF.

*  CLASS cl_cu_drawing_area DEFINITION LOAD.
*  CLASS cl_cu_values       DEFINITION LOAD.
*  CLASS cl_cu_point        DEFINITION LOAD.
*
*  DATA: groups TYPE gfw_grpid_list,
*        points TYPE gfw_refobj_list,
*        title TYPE gfwcuvac VALUE 'Başlık',
*        bundle_display TYPE REF TO cl_cu_display_context,
*        bundle TYPE REF TO if_customizing.
*
** let the proxy create customizing-bundles
*  APPEND '1' TO points.
*  APPEND gv_grup_name TO groups.
*
**  CONCATENATE p_monat '.' p_gjahr INTO title.
**
**  CONCATENATE 'Mutabakat Dönemi' title INTO title
**  SEPARATED BY space.
*
*
*  title = text-s11.
*
*  CALL METHOD gc_inst_prox->create_customizing
*    EXPORTING
*      instance_id = 'PIE'
*      grpids      = groups
*      pointids    = points
*      title       = title
*    IMPORTING
*      retval      = retval.
*
*  IF retval <> cl_gfw=>ok.
*    CALL METHOD cl_gfw=>show_msg
*      EXPORTING
*        msgno = retval.
*    EXIT.
*  ENDIF.
*
*
** get values and set chart type
*  CALL METHOD gc_inst_prox->if_graphic_proxy~get_cu_bundle
*    EXPORTING
*      port        = if_graphic_proxy=>co_port_chart
*      bundle_type = cl_cu=>co_clsid_values
*      key         = gv_grup_name
*    IMPORTING
*      bundle      = bundle.
*
*  CALL METHOD bundle->set
*    EXPORTING
*      attr_id = cl_cu_values=>co_style
*      value   = 27. " pie
*
** get point and set explosion
*  CALL METHOD gc_inst_prox->if_graphic_proxy~get_cu_bundle
*    EXPORTING
*      port        = if_graphic_proxy=>co_port_chart
*      bundle_type = cl_cu=>co_clsid_point
*      key         = '1'
*    IMPORTING
*      bundle      = bundle.
*
*  CALL METHOD bundle->set
*    EXPORTING
*      attr_id = cl_cu_point=>co_explosion
*      value   = 10.
*
** get drawing area and remove border line
*  CALL METHOD gc_inst_prox->if_graphic_proxy~get_cu_bundle
*    EXPORTING
*      port        = if_graphic_proxy=>co_port_chart
*      bundle_type = cl_cu=>co_clsid_drawing_area
*    IMPORTING
*      bundle      = bundle.
*
*  CALL METHOD bundle->get
*    EXPORTING
*      attr_id = cl_cu_drawing_area=>co_display_context
*    IMPORTING
*      value   = bundle_display.
*
*  CALL METHOD bundle_display->if_customizing~set
*    EXPORTING
*      attr_id = cl_cu_display_context=>co_le_style
*      value   = 1. " none
*
*  CALL METHOD bundle->set
*    EXPORTING
*      attr_id = cl_cu_drawing_area=>co_display_context
*      value   = bundle_display.

  ENDMETHOD.

  METHOD reminder_mail.

    DATA: lv_mnumber TYPE zreco_hdr-mnumber.
    DATA: gt_mnumber TYPE TABLE OF zreco_hdr,
          gs_mnumber TYPE zreco_hdr.

    DATA: gs_out     TYPE zreco_monitor,
          ls_out     TYPE zreco_monitor,
          gs_cdat    TYPE zreco_cdat,
          gv_bukrs   TYPE bukrs,
          gv_gsber   TYPE abap_boolean,
          gv_yes     TYPE abap_boolean, "Mutabıkız
          gv_no      TYPE abap_boolean, "Değiliz
          gv_no_data TYPE abap_boolean, "Kayıt bulunmamaktadır
          gv_wait    TYPE abap_boolean, "Cevap bekleniyor
          gv_name1   TYPE zreco_name80, "Cari Ünvan
          gv_tcode   TYPE c LENGTH 2, "01 Yarat, 02 Değiştir, 03 görüntüle
          gv_click   TYPE abap_boolean, "Çift tıklama ile ekran çağrıldı
          gv_change  TYPE abap_boolean, "Ekranda değişiklik yapıldı
          gv_answer  TYPE c LENGTH 1, "Onay ekranı cevap
          gv_first   TYPE abap_boolean,
          gv_subsc   TYPE abap_boolean, "B formu ve Cari mutabakata göre subscreen
          gv_version TYPE zreco_version,
          gv_try     TYPE abap_boolean,
          gv_pwaers  TYPE waers.

    DATA: gt_out     TYPE TABLE OF zreco_monitor,
          gs_out_tmp LIKE LINE OF gt_out,
          gt_detail  TYPE TABLE OF zreco_user_perf_detail.

    DATA: lt_h001 TYPE TABLE OF zreco_hdr.

    DATA : lv_row    TYPE i,
           lv_answer TYPE c LENGTH 1.

* e-Mail gönderme ekranı
    DATA: gt_email TYPE TABLE OF zreco_mail,
          gs_email TYPE zreco_mail.


    DATA: gt_h001 TYPE SORTED TABLE OF zreco_hdr  WITH UNIQUE KEY bukrs
                               gsber
                               mnumber
                               monat
                               gjahr
                               hesap_tur
                               hesap_no ,
          gs_h001 TYPE zreco_hdr,

          gt_e001 TYPE TABLE OF zreco_refi.

    CLEAR: lv_row, lv_mnumber.

    CLEAR gt_mnumber.

    READ ENTITIES OF zreco_ddl_i_reco_follow_report
     IN LOCAL MODE ENTITY follow_report
     ALL FIELDS WITH CORRESPONDING #( keys )
     RESULT DATA(ls_result)
     FAILED DATA(ls_failed)
     REPORTED DATA(ls_reported).

    DATA(lv_char_lines) = lines( ls_result ).

*    CALL METHOD gv_grid->get_selected_rows             "D_MBAYEL seçili satırda dönme için tekrar kontrol edilecek
*      IMPORTING
*        et_row_no = lt_selrow.
*
*    LOOP AT lt_selrow INTO ls_selrow.
*      lv_row = lv_row + 1.
*    ENDLOOP.



    IF sy-subrc NE 0.
*      MESSAGE s012 DISPLAY LIKE 'W'.
*      EXIT.
    ENDIF.

    LOOP AT ls_result ASSIGNING FIELD-SYMBOL(<lfs_result>).
      CLEAR: gs_out, gt_mnumber, gs_h001.

      READ TABLE gt_out INTO gs_out INDEX lv_char_lines.

      MOVE-CORRESPONDING  gs_out TO gs_mnumber.
    ENDLOOP.

*    LOOP AT lt_selrow INTO ls_selrow.
*
*      CLEAR: gs_out, gt_mnumber, gs_h001.
*
*      READ TABLE gt_out INTO gs_out INDEX ls_selrow-row_id.
*
*      MOVE-CORRESPONDING  gs_out TO gs_mnumber.
**      MOVE-CORRESPONDING gs_out TO gs_h001.            "D_MBAYEL gs_h001 kullanılmadığı için commentlenmiştir.
*
*      APPEND  gs_mnumber TO gt_mnumber .
*
*    ENDLOOP.

    SORT gt_mnumber BY gjahr monat mnumber.
    DELETE ADJACENT DUPLICATES FROM gt_mnumber
    COMPARING gjahr monat mnumber.

    DELETE gt_mnumber WHERE xstatu IS NOT INITIAL.
    DELETE gt_mnumber WHERE moutput NOT BETWEEN 'E' AND 'F'.
*     DESCRIBE TABLE gt_mnumber LINES lv_row.                  "D_MBAYEL commentlendi
    lv_row = lines(  gt_mnumber ).



    IF lv_row GT 1                           "Birden fazla mutabakat var ise koşula gir
    OR lv_row EQ 1 AND gs_h001-mtype EQ 'C'. "Cari form mutabakatlarında Mail Pop-up ekranı kaldırıldıgı için tekli mutabakat da olsa çoklu gibi gönderilecek.
*
      SELECT *
      FROM zreco_hdr
        FOR ALL ENTRIES IN @gt_mnumber
        WHERE bukrs   EQ @gt_mnumber-bukrs
        AND gsber     EQ @gt_mnumber-gsber
        AND mnumber   EQ @gt_mnumber-mnumber
        AND monat     EQ @gt_mnumber-monat
        AND gjahr     EQ @gt_mnumber-gjahr
        AND hesap_tur EQ @gt_mnumber-hesap_tur
        AND hesap_no  EQ @gt_mnumber-hesap_no
        AND loekz     EQ ''
        INTO TABLE @lt_h001.
*
*
      CHECK sy-subrc EQ 0.

      me->send_reminder(
      it_h001 = lt_h001
      ).

    ELSEIF lv_row EQ 1 AND gs_h001-mtype NE 'C'. "Cari değilse ve tekli ise

      CLEAR lv_row.
*
      " <--- hkizilkaya Koşul yukarı taşındı.
*        DELETE gt_mnumber WHERE xstatu IS NOT INITIAL.
*        DELETE gt_mnumber WHERE moutput NOT BETWEEN 'E' AND 'F'.
*        DESCRIBE TABLE gt_mnumber LINES lv_row.
      " hkizilkaya --->
      IF lv_row NE 0.

        CLEAR: gt_e001[], gt_email[].

        SELECT * FROM zreco_refi
        FOR ALL ENTRIES IN @gt_mnumber
        WHERE bukrs EQ @gt_mnumber-bukrs
        AND gsber EQ @gt_mnumber-gsber
        AND mnumber EQ @gt_mnumber-mnumber
        AND monat EQ @gt_mnumber-monat
        AND gjahr EQ @gt_mnumber-gjahr
        AND hesap_tur EQ @gt_mnumber-hesap_tur
        AND hesap_no EQ @gt_mnumber-hesap_no
        INTO TABLE @gt_e001.

        LOOP AT gt_e001 ASSIGNING FIELD-SYMBOL(<lfs_gt_e001>).
          gs_email-email = <lfs_gt_e001>-receiver.
          APPEND gs_email TO gt_email.
        ENDLOOP.

*      CALL SCREEN 0800 STARTING AT 5 5.
*        ELSE.
*          MESSAGE s051 DISPLAY LIKE 'E'. "gerek kalmadı
      ENDIF.

    ELSE. "hkizilkaya
*        MESSAGE s051 DISPLAY LIKE 'E'.
    ENDIF.
*
*
  ENDMETHOD.

  METHOD send_reminder.

    DATA:    zreco_common TYPE REF TO zreco_common.
    CREATE OBJECT zreco_common.

    DATA: gt_graph  TYPE TABLE OF zreco_graph,
          gt_return TYPE TABLE OF zreco_reminder.
*
    CLEAR: gt_return.

    READ TABLE me->lt_h001 ASSIGNING FIELD-SYMBOL(<lfs_h001>) INDEX 1.
    IF <lfs_h001>-mtype NE 'C'. "hkizilkaya

      zreco_common->zreco_pdf_preview(
         EXPORTING
          i_mail_send = 'X'
          i_batch     = sy-batch

          it_h001     = lt_h001
          et_return   = gt_return
      ).


    ELSE.

      me->send_reminder_c(
      it_h001 = lt_h001

      ).

    ENDIF.

*  gs_layout-colwidth_optimize = 'X'.
*  gs_layout-zebra     = 'X'.

*  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
*    EXPORTING
*      i_structure_name = '/ITETR/RECO_REMINDER'
*      is_layout        = gs_layout
*      it_fieldcat      = gt_fieldcatalog
*      i_default        = 'X'
*      i_save           = ' '
*    TABLES
*      t_outtab         = gt_return[]
*    EXCEPTIONS
*      program_error    = 1
*      OTHERS           = 2.

  ENDMETHOD.

  METHOD show_form. "YiğitcanÖzdemir





    DATA: gt_mnumber TYPE TABLE OF zreco_hdr.
    DATA : gs_mnumber TYPE zreco_hdr.
    DATA : lt_mnumber TYPE TABLE OF zreco_hdr.
    DATA(lt_keys) = keys.

    READ TABLE lt_keys INTO DATA(ls_keys) INDEX 1.
    IF sy-subrc EQ 0.
      gs_mnumber-bukrs = 1000."ls_keys-%param-bukrs.
      gs_mnumber-gjahr = ls_keys-%param-gjahr.
      gs_mnumber-monat = ls_keys-%param-monat.
      gs_mnumber-mnumber = ls_keys-%param-mnmbr .
      gs_mnumber-hesap_no = ls_keys-%param-hesap_no.
      gs_mnumber-hesap_tur = ls_keys-%param-hesap_tur.
    ENDIF.

    APPEND gs_mnumber TO gt_mnumber.

    SORT gt_mnumber BY gjahr monat mnumber.
    DELETE ADJACENT DUPLICATES FROM gt_mnumber
    COMPARING gjahr monat mnumber.

    IF gt_mnumber IS NOT INITIAL.

      SELECT * FROM Zreco_hdr
    FOR ALL ENTRIES IN @gt_mnumber
    WHERE bukrs EQ @gt_mnumber-bukrs
*    AND gsber EQ @gt_mnumber-gsber
    AND mnumber EQ @gt_mnumber-mnumber
*    AND monat EQ @gt_mnumber-monat
*    AND gjahr EQ @gt_mnumber-gjahr
*    AND hesap_tur EQ @gt_mnumber-hesap_tur
*    AND hesap_no EQ @gt_mnumber-hesap_no
      INTO TABLE @lt_h001.


    ENDIF.


    DATA:    zreco_object TYPE REF TO zreco_common.
*    CREATE OBJECT zreco_object.
    zreco_object = NEW zreco_common( ).

    zreco_object->zreco_pdf_preview(
 EXPORTING
             i_sort_indicator = 1
            i_down           = ''
            i_fn_number      = 'X'
            i_fn_account     = 'X'
            i_fn_name        = 'X'

            it_h001          = lt_h001
    ).

  ENDMETHOD.

  METHOD send_reminder_c.
    TYPES: BEGIN OF ty_userinfo,
             username TYPE string,
             password TYPE string,
           END OF ty_userinfo.

    DATA: ls_h001         TYPE zreco_hdr,
          ls_v001         TYPE zreco_vers,
          lt_v001         TYPE TABLE OF zreco_vers,
          lt_sending_mail TYPE TABLE OF zreco_refi,
          ls_sending_mail TYPE zreco_refi,
          lt_mailcc       TYPE TABLE OF zreco_mcc,
          ls_mailcc       TYPE zreco_mcc,
          ls_userinfo     TYPE ty_userinfo,
          lt_remd         TYPE TABLE OF zreco_rmd,
          ls_remd         TYPE zreco_rmd,
          lt_remh         TYPE TABLE OF zreco_rmh,
          ls_remh         TYPE zreco_rmh.

    DATA: lv_url        TYPE string,
          lv_username   TYPE string,
          lv_password   TYPE string,
          ls_input_grid TYPE zreco_mtb_header_rmnd_c,
          ls_response   TYPE zreco_resp,
          lv_sjson      TYPE string,
          ls_srvc       TYPE zreco_srvc,
          lr_oref       TYPE REF TO cx_root.
*          lo_http_client TYPE REF TO if_http_client.                       "D_MBAYEL lo_http_client olmadığı için commentlenmiştir

    DATA: lv_sjson_str TYPE string,
          lv_xresponse TYPE xstring,
          lv_response  TYPE string,
          lv_srvhost   TYPE string,
          lv_txlen     TYPE i.

    DATA: gt_graph  TYPE TABLE OF zreco_graph,
          gt_return TYPE TABLE OF zreco_reminder,
          gs_return TYPE zreco_reminder.

*    FREE : lo_http_client.
    CLEAR: ls_srvc, ls_userinfo, lv_sjson, lv_sjson_str, lv_txlen, lv_xresponse, lv_response, ls_response, ls_v001.

    LOOP AT lt_h001 INTO ls_h001.

      SELECT SINGLE *
         FROM zreco_srvc
         WHERE srvid EQ '002'
           AND bukrs EQ @ls_h001-bukrs
            OR bukrs EQ @space
             INTO @ls_srvc.

      lv_url      = ls_srvc-srvurl.
      lv_username = ls_srvc-srvusr.
      lv_password = ls_srvc-srvpsw.

*      cl_http_client=>create_by_url(                            "D_MBAYEL lo_http_client olmadığı için commentlenmiştir
*       EXPORTING
*         url    = lv_url
*       IMPORTING
*         client = lo_http_client
*       EXCEPTIONS
*         argument_not_found = 1
*         plugin_not_active = 2
*         internal_error    = 3
*         OTHERS            = 4 ).

      CHECK sy-subrc = 0.

      SELECT SINGLE username,
                    password
        FROM zreco_t_re
        WHERE companycode EQ @ls_h001-bukrs
        AND   reconciliationnumber EQ @ls_h001-mnumber
        INTO @ls_userinfo.


      ls_input_grid-reconciliationcode = ls_userinfo-username.
      ls_input_grid-reconciliationpasword = ls_userinfo-password.

      TRY .
*          lv_sjson = zreco_cl_json=>data_to_json( i_data = ls_input_grid ).         "D_MBAYEL zreco_cl_json=>data_to_json olmadığı için commentlenmiştir

        CATCH cx_root INTO lr_oref .
      ENDTRY.

      lv_sjson_str = strlen( lv_sjson ). "hkizilkaya

      lv_txlen = lv_sjson_str.


*      lo_http_client->request->set_header_field(                                   "D_MBAYEL lo_http_client olmadığı için commentlenmiştir
*              name  = 'Content-Type'
*              value = 'application/json').

      lv_srvhost = ls_srvc-srvhost. "hkizilkaya

*      lo_http_client->request->set_header_field(                                   "D_MBAYEL Commentlenmiştir
*            name  = 'Host'
*            value = lv_srvhost ).

*      lo_http_client->request->set_method( 'POST' ).                               "D_MBAYEL Commentlenmiştir

*      lo_http_client->propertytype_logon_popup = lo_http_client->co_disabled.      "D_MBAYEL Commentlenmiştir

*      CALL METHOD lo_http_client->request->set_cdata
*        EXPORTING
*          data   = lv_sjson
*          offset = 0
*          length = lv_txlen.
*
*      CALL METHOD lo_http_client->authenticate                                      "D_MBAYEL Commentlenmiştir
*        EXPORTING
*          username = lv_username
*          password = lv_password.
*
*      CALL METHOD lo_http_client->send
*        EXCEPTIONS
*          http_communication_failure = 1
*          http_invalid_state         = 2.
      IF sy-subrc EQ 0.


*  receive response
*        CALL METHOD lo_http_client->receive                       "D_MBAYEL Commentlenmiştir
*          EXCEPTIONS
*            http_communication_failure = 1
*            http_invalid_state         = 2
*            http_processing_failed     = 3.
        IF sy-subrc EQ 0.

*          lv_xresponse = lo_http_client->response->get_data( ).

*          CALL FUNCTION 'ECATT_CONV_XSTRING_TO_STRING'             "D_MBAYEL Commentlenmiştir
*            EXPORTING
*              im_xstring  = lv_xresponse
*              im_encoding = 'UTF-8'
*            IMPORTING
*              ex_string   = lv_response.

          TRY .
*              zreco_cl_json=>json_to_data(
*                EXPORTING
*                  i_json = lv_response
*                CHANGING
*                  c_data = ls_response ).

            CATCH cx_root INTO lr_oref .

          ENDTRY.
        ENDIF.
      ENDIF.

      SELECT *
          FROM zreco_refi
          WHERE bukrs EQ @ls_h001-bukrs
          AND mnumber EQ @ls_h001-mnumber
          INTO TABLE @lt_sending_mail.

      SELECT *
          FROM zreco_mcc
          WHERE bukrs EQ @ls_h001-bukrs
          AND hesap_tur EQ @ls_h001-hesap_tur
          INTO TABLE @lt_mailcc.

      SELECT SINGLE *
          FROM zreco_vers
          WHERE bukrs   EQ @ls_h001-bukrs
            AND gsber   EQ @ls_h001-gsber
            AND mnumber EQ @ls_h001-mnumber
            AND monat   EQ @ls_h001-monat
            AND gjahr   EQ @ls_h001-gjahr
            AND vstatu  EQ 'G'
            INTO @ls_v001.

      IF ls_response-success EQ 'X'.
        MOVE-CORRESPONDING ls_v001 TO ls_remd.
        MOVE-CORRESPONDING ls_h001 TO ls_remd.
      ENDIF.

      LOOP AT lt_sending_mail INTO ls_sending_mail.
        APPEND ls_v001 TO lt_v001.
        MOVE-CORRESPONDING lt_v001 TO gt_return.
        MOVE-CORRESPONDING lt_v001 TO gt_return.
        gs_return-receiver = ls_sending_mail-receiver.
        gs_return-message = ls_response-message.
        APPEND gs_return TO gt_return.
        IF ls_response-success EQ 'X'.
*          WRITE icon_green_light TO gs_return-icon.                                            "D_MBAYEL Commentlenmiştir

          MOVE-CORRESPONDING ls_v001 TO ls_remd.
          MOVE-CORRESPONDING ls_h001 TO ls_remd.
          ls_remd-receiver = ls_sending_mail-receiver.
          ls_remd-datum = cl_abap_context_info=>get_system_date( )."sy-datum.
          ls_remd-uzeit = cl_abap_context_info=>get_system_time( )."sy-uzeit.
          ls_remd-ernam = sy-uname.

          INSERT zreco_rmd FROM @ls_remd.
        ELSE.
*          WRITE icon_red_light TO gt_return-icon.                                               "D_MBAYEL Commentlenmiştir
        ENDIF.
        APPEND gs_return TO gt_return.
        CLEAR  gt_return.
      ENDLOOP.

      IF ls_response-success EQ 'X'.
        MOVE-CORRESPONDING ls_remd TO ls_remh.
        INSERT zreco_rmh FROM @ls_remh.
      ENDIF.

      LOOP AT lt_mailcc INTO ls_mailcc.
        APPEND ls_h001 TO lt_v001.
        MOVE-CORRESPONDING lt_v001 TO gt_return.
        MOVE-CORRESPONDING lt_h001 TO gt_return.
        gs_return-receiver = ls_mailcc-mail.
        gs_return-message = ls_response-message.
        APPEND gs_return TO gt_return.
        IF ls_response-success EQ 'X'.
*          WRITE icon_green_light TO gt_return-icon.                                                    "D_MBAYEL Commentlenmiştir
        ELSE.
*          WRITE icon_red_light TO gt_return-icon.                                                      "D_MBAYEL Commentlenmiştir
        ENDIF.

        APPEND gs_return TO gt_return.
        CLEAR  gt_return.
      ENDLOOP.

    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZRECO_DDL_I_RECO_FOLLOW_RE DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZRECO_DDL_I_RECO_FOLLOW_RE IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.