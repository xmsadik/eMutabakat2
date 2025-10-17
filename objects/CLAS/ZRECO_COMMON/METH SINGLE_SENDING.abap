  METHOD single_sending.

    DATA : lv_tabix TYPE int4.

    DATA(lt_cform) = it_cform[].

    CLEAR : gt_email, gt_mail_list.

    SELECT *
      FROM zreco_gtout
      FOR ALL ENTRIES IN @lt_cform
      WHERE uuid = @lt_cform-uuid
      INTO TABLE @gt_out_c.


    LOOP AT gt_out_c INTO DATA(ls_out_C).
      MOVE-CORRESPONDING ls_out_C TO gs_cform.
      COLLECT gs_cform INTO gt_cform.
    ENDLOOP.



    LOOP AT gt_out_c ASSIGNING FIELD-SYMBOL(<fs_out_c>).

      lv_tabix = lv_tabix + 1.

      zreco_to_mail_adrs(
        EXPORTING
            i_bukrs      = gs_adrs-bukrs
            i_ucomm      = ''
            i_kunnr      = <fs_out_c>-kunnr
            i_lifnr      = <fs_out_c>-lifnr
            i_abtnr      = ''
            i_pafkt      = ''
            i_remark     = ''
            i_all        = ''
            i_stcd1      = <fs_out_c>-vkn_tckn
            i_no_general = gs_adrs-no_general
            i_mtype      = 'C'
        IMPORTING
           e_mail       = <fs_out_c>-email
           t_receivers  = gt_receivers
      ).
      CLEAR gs_mail_list.

      MOVE-CORRESPONDING <fs_out_c> TO gs_mail_list.
      MOVE-CORRESPONDING gs_receivers TO gs_mail_list.

      gs_mail_list-bukrs = gs_adrs-bukrs.
      gs_mail_list-monat = <fs_out_c>-period.
      gs_mail_list-gjahr = <fs_out_c>-gjahr.
      gs_mail_list-posnr = lv_tabix.

      INSERT gs_mail_list INTO TABLE gt_mail_list.
    ENDLOOP.


    LOOP AT gt_cform INTO DATA(ls_cform).

      LOOP AT gt_mail_list INTO gs_mail_list WHERE kunnr EQ ls_cform-kunnr
                         AND lifnr EQ ls_cform-lifnr.
        gs_email-email = gs_mail_list-receiver.
        APPEND gs_email TO gt_email.
      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.