  METHOD zreco_get_balance.

    DATA: gt_out_c TYPE TABLE OF zreco_cform,
          gs_out_c TYPE zreco_cform.

*    DATA : r_bukrs TYPE RANGE OF bsid_view,
*           r_kunnr TYPE RANGE OF bsid-kunnr,
*           r_lifnr TYPE RANGE OF bsik-lifnr.

    DATA: lv_seld TYPE abap_boolean,
          lv_selk TYPE abap_boolean,
          lv_exch TYPE abap_boolean.

    CHECK i_bukrs IS NOT INITIAL.

    CLEAR: gt_out_c[], et_cform[]. "r_kunnr[], r_lifnr[].

    IF i_bukrs IS NOT INITIAL.
*      r_bukrs-sign = 'I'.
*      r_bukrs-option = 'EQ'.
*      r_bukrs-low = i_bukrs.
*      APPEND r_bukrs.
    ENDIF.

    IF i_kunnr IS NOT INITIAL.
*      r_kunnr-sign = 'I'.
*      r_kunnr-option = 'EQ'.
*      r_kunnr-low = i_kunnr.
*      APPEND r_kunnr.
      lv_seld = 'X'.
    ENDIF.

    IF i_lifnr IS NOT INITIAL.
*      r_lifnr-sign = 'I'.
*      r_lifnr-option = 'EQ'.
*      r_lifnr-low = i_lifnr.
*      APPEND r_lifnr.
      lv_selk = 'X'.
    ENDIF.

    IF i_kurst IS NOT INITIAL.
      lv_exch = 'X'.
    ENDIF.

*    SUBMIT zreco_form     WITH p_runty EQ 1
*                                WITH s_bukrs IN r_bukrs
*                                WITH p_period EQ i_monat
*                                WITH p_gjahr EQ i_gjahr
*                                WITH p_seld EQ lv_seld
*                                WITH s_kunnr IN r_kunnr
*                                WITH p_selk EQ lv_selk
*                                WITH s_lifnr IN r_lifnr
*                                WITH p_exch EQ lv_exch
*                                WITH p_tran EQ i_tran
*                                WITH p_all EQ i_all
*                                WITH r_bform EQ ''
*                                WITH r_mform EQ 'X'
*                                WITH r_all EQ ''
*                                WITH p_ftype EQ i_ftype
*                                WITH p_submit EQ 'X'
*                                WITH p_dtest EQ 'LP01'
*                                AND RETURN.

*    IMPORT gt_out_c FROM MEMORY ID 'GT_OUT_C'.

    LOOP AT gt_out_c INTO gs_out_c.

      APPEND INITIAL LINE TO et_cform ASSIGNING FIELD-SYMBOL(<lfs_cform>).

      MOVE-CORRESPONDING gs_out_c TO <lfs_cform>.

      IF gs_out_c-xsum IS NOT INITIAL.
        e_dmbtr = e_dmbtr + gs_out_c-dmbtr.
      ENDIF.

*      APPEND et_cform.

      CLEAR: gs_out_c, et_cform.

    ENDLOOP.
  ENDMETHOD.