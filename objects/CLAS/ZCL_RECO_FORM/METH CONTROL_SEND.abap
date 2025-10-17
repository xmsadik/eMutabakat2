  METHOD control_send.

    DATA: ls_h001 TYPE zreco_hdr, "hkizilkaya
          ls_reia TYPE zreco_reia. "hkizilkaya

    CLEAR gv_send.

    CHECK gv_master IS INITIAL.
*    CHECK p_submit IS INITIAL. "YiğitcanÖzdemir
    CHECK p_blist IS INITIAL.
*    CHECK p_verzn IS INITIAL.  "YiğitcanÖzdemir
    CHECK p_daily IS INITIAL.

    IF gt_h001[] IS INITIAL.
      EXIT.
    ENDIF.

    IF iv_kunnr IS NOT INITIAL.
      IF p_waers IS NOT INITIAL.
        READ TABLE gt_w001 TRANSPORTING NO FIELDS WITH KEY bukrs     = gs_adrs-bukrs
                                                           gsber     = gs_adrs-gsber
                                                           gjahr     = p_gjahr
                                                           monat     = p_period
                                                           hesap_tur = zreco_if_common_types=>mc_hesap_tur_m
                                                           hesap_no  = iv_kunnr
                                                           ftype     = p_ftype.
        CHECK sy-subrc NE 0.
      ENDIF.


* MÜŞTERI NUMARASINA GÖRE GÖNDERI OLMUŞ MU?
      READ TABLE gt_h001 INTO ls_h001 WITH KEY bukrs     = gs_adrs-bukrs
                                                     gsber     = gs_adrs-gsber
                                                     gjahr     = p_gjahr
                                                     monat     = p_period
                                                     mtype     = gv_mtype
                                                     hesap_tur = zreco_if_common_types=>mc_hesap_tur_m
                                                     hesap_no  = iv_kunnr
                                                     ftype     = p_ftype.
      IF sy-subrc EQ 0.

        READ TABLE gt_reia INTO ls_reia WITH KEY bukrs   = ls_h001-bukrs
                                                       gsber   = ls_h001-gsber
                                                       mnumber = ls_h001-mnumber
                                                       monat   = ls_h001-monat
                                                       gjahr   = ls_h001-gjahr
                                                       BINARY SEARCH.

        IF sy-subrc IS INITIAL AND ( ls_reia-mresult EQ 'H' OR ls_reia-mresult EQ 'T' ).
          RETURN.
        ENDIF.

        c_send = zreco_if_common_types=>mc_select_yes.
        c_mnumber = ls_h001-mnumber.
      ELSE.


        IF iv_vkn_tckn IS NOT INITIAL.
* VERGI NUMARASINA GÖRE GÖNDERI YAPILMIŞ MI
          READ TABLE gt_h001 INTO ls_h001 WITH KEY bukrs    = gs_adrs-bukrs
                                                   gsber    = gs_adrs-gsber
                                                   gjahr    = p_gjahr
                                                   monat    = p_period
                                                   mtype    = gv_mtype
                                                   vkn_tckn = iv_vkn_tckn
                                                   xall     = zreco_if_common_types=>mc_select_yes
                                                   ftype    = p_ftype.

          IF sy-subrc EQ 0.
            c_mnumber = ls_h001-mnumber.

            READ TABLE gt_etax TRANSPORTING NO FIELDS WITH KEY stcd2 = iv_vkn_tckn.
            IF sy-subrc EQ 0.
              CLEAR c_send.
            ELSE.

              CLEAR ls_reia.
              READ TABLE gt_reia INTO ls_reia WITH KEY bukrs   = ls_h001-bukrs
                                                       gsber   = ls_h001-gsber
                                                       mnumber = ls_h001-mnumber
                                                       monat   = ls_h001-monat
                                                       gjahr   = ls_h001-gjahr
                                                       BINARY SEARCH.

              IF sy-subrc IS INITIAL AND ( ls_reia-mresult EQ 'H' OR ls_reia-mresult EQ 'T' ).
                RETURN.
              ENDIF.

              c_send = zreco_if_common_types=>mc_select_yes.
            ENDIF.
          ENDIF.
        ELSE.
          CLEAR c_send.
        ENDIF.

        IF p_all  IS NOT INITIAL AND
           c_send IS INITIAL.

* VERGI NUMARASINA GÖRE BIRLEŞTIRME YAPMADAN GÖNDERI YAPILMIŞ MI
          READ TABLE gt_h001 INTO ls_h001 WITH KEY bukrs = gs_adrs-bukrs
                                                   gsber = gs_adrs-gsber
                                                   gjahr = p_gjahr
                                                   monat = p_period
                                                   mtype = gv_mtype
                                                vkn_tckn = iv_vkn_tckn
                                                   ftype = p_ftype.
          IF sy-subrc EQ 0.

            c_mnumber = ls_h001-mnumber.

            READ TABLE gt_etax TRANSPORTING NO FIELDS WITH KEY stcd2 = iv_vkn_tckn.
            IF sy-subrc EQ 0.
              CLEAR c_send.
            ELSE.

              CLEAR ls_reia.
              READ TABLE gt_reia INTO ls_reia WITH KEY bukrs   = ls_h001-bukrs
                                                       gsber   = ls_h001-gsber
                                                       mnumber = ls_h001-mnumber
                                                       monat   = ls_h001-monat
                                                       gjahr   = ls_h001-gjahr
                                                       BINARY SEARCH.

              IF sy-subrc IS INITIAL AND ( ls_reia-mresult EQ 'H' OR ls_reia-mresult EQ 'T' ).
                RETURN.
              ENDIF.

              c_send = zreco_if_common_types=>mc_select_yes.
            ENDIF.
          ELSE.
            CLEAR c_send.
          ENDIF.
        ENDIF.
      ENDIF.

      IF p_tran IS NOT INITIAL AND
         c_send IS INITIAL.

* MAHSUPLAŞTIRMA YAPILARAK GÖNDERI YAPILMIŞ MI
        READ TABLE gt_h001 INTO ls_h001 WITH KEY bukrs = gs_adrs-bukrs
                                                 gsber = gs_adrs-gsber
                                                 gjahr = p_gjahr
                                                 monat = p_period
                                                 mtype = gv_mtype
                                                 kunnr = iv_kunnr
                                                 ftype = p_ftype.
        IF sy-subrc EQ 0.
          CLEAR ls_reia.
          READ TABLE gt_reia INTO ls_reia WITH KEY bukrs   = ls_h001-bukrs
                                                   gsber   = ls_h001-gsber
                                                   mnumber = ls_h001-mnumber
                                                   monat   = ls_h001-monat
                                                   gjahr   = ls_h001-gjahr
                                                   BINARY SEARCH.

          IF sy-subrc IS INITIAL AND ( ls_reia-mresult EQ 'H' OR ls_reia-mresult EQ 'T' ).
            RETURN.
          ENDIF.

          c_mnumber = ls_h001-mnumber.
          c_send = zreco_if_common_types=>mc_select_yes.
        ELSE.
          CLEAR c_send.
        ENDIF.
      ENDIF.
    ENDIF.

    IF iv_lifnr IS NOT INITIAL.
      IF p_waers IS NOT INITIAL.
        READ TABLE gt_w001 TRANSPORTING NO FIELDS WITH KEY bukrs     = gs_adrs-bukrs
                                                           gsber     = gs_adrs-gsber
                                                           gjahr     = p_gjahr
                                                           monat     = p_period
                                                           hesap_tur = zreco_if_common_types=>mc_hesap_tur_s
                                                           hesap_no  = iv_lifnr
                                                           ftype     = p_ftype.
        CHECK sy-subrc NE 0.
      ENDIF.

* SATICI NUMARASINA GÖRE GÖNDERI OLMUŞ MU?
      READ TABLE gt_h001 INTO ls_h001 WITH KEY bukrs     = gs_adrs-bukrs
                                               gsber     = gs_adrs-gsber
                                               gjahr     = p_gjahr
                                               monat     = p_period
                                               mtype     = gv_mtype
                                               hesap_tur = zreco_if_common_types=>mc_hesap_tur_s
                                               hesap_no  = iv_lifnr
                                               ftype     = p_ftype.
      IF sy-subrc EQ 0.

        CLEAR ls_reia.
        READ TABLE gt_reia INTO ls_reia WITH KEY bukrs   = ls_h001-bukrs
                                                 gsber   = ls_h001-gsber
                                                 mnumber = ls_h001-mnumber
                                                 monat   = ls_h001-monat
                                                 gjahr   = ls_h001-gjahr
                                                 BINARY SEARCH.

        IF sy-subrc IS INITIAL AND ( ls_reia-mresult EQ 'H' OR ls_reia-mresult EQ 'T' ).
          RETURN.
        ENDIF.

        c_mnumber = ls_h001-mnumber.
        c_send = zreco_if_common_types=>mc_select_yes.
      ELSE.

        IF iv_vkn_tckn IS NOT INITIAL.
* VERGI NUMARASINA GÖRE GÖNDERI YAPILMIŞ MI
          READ TABLE gt_h001 INTO ls_h001 WITH KEY bukrs    = gs_adrs-bukrs
                                                   gsber    = gs_adrs-gsber
                                                   gjahr    = p_gjahr
                                                   monat    = p_period
                                                   mtype    = gv_mtype
                                                   vkn_tckn = iv_vkn_tckn
                                                   xall     = zreco_if_common_types=>mc_select_yes
                                                   ftype    = p_ftype.
          IF sy-subrc EQ 0.
            c_mnumber = ls_h001-mnumber.

            READ TABLE gt_etax TRANSPORTING NO FIELDS WITH KEY stcd2 = iv_vkn_tckn.
            IF sy-subrc EQ 0.
              CLEAR c_send.
            ELSE.
              CLEAR ls_reia.
              READ TABLE gt_reia INTO ls_reia WITH KEY bukrs   = ls_h001-bukrs
                                                       gsber   = ls_h001-gsber
                                                       mnumber = ls_h001-mnumber
                                                       monat   = ls_h001-monat
                                                       gjahr   = ls_h001-gjahr
                                                       BINARY SEARCH.

              IF sy-subrc IS INITIAL AND ( ls_reia-mresult EQ 'H' OR ls_reia-mresult EQ 'T' ).
                RETURN.
              ENDIF.

              c_send = zreco_if_common_types=>mc_select_yes.
            ENDIF.
          ELSE.
            CLEAR c_send.
          ENDIF.


          IF p_all IS NOT INITIAL AND
            c_send IS INITIAL.

* VERGI NUMARASINA GÖRE BIRLEŞTIRME YAPMADAN GÖNDERI YAPILMIŞ MI
            READ TABLE gt_h001 INTO ls_h001 WITH KEY bukrs    = gs_adrs-bukrs
                                                     gsber    = gs_adrs-gsber
                                                     gjahr    = p_gjahr
                                                     monat    = p_period
                                                     mtype    = gv_mtype
                                                     vkn_tckn = iv_vkn_tckn
                                                     ftype    = p_ftype.
            IF sy-subrc EQ 0.
              c_mnumber = ls_h001-mnumber.

              READ TABLE gt_etax TRANSPORTING NO FIELDS WITH KEY stcd2 = iv_vkn_tckn.
              IF sy-subrc EQ 0.
                CLEAR c_send.
              ELSE.
                CLEAR ls_reia.
                READ TABLE gt_reia INTO ls_reia WITH KEY bukrs   = ls_h001-bukrs
                                                         gsber   = ls_h001-gsber
                                                         mnumber = ls_h001-mnumber
                                                         monat   = ls_h001-monat
                                                         gjahr   = ls_h001-gjahr
                                                         BINARY SEARCH.

                IF sy-subrc IS INITIAL AND ( ls_reia-mresult EQ 'H' OR ls_reia-mresult EQ 'T' ).
                  RETURN.
                ENDIF.
                c_send = zreco_if_common_types=>mc_select_yes.
              ENDIF.
            ELSE.
              CLEAR c_send.
            ENDIF.

          ENDIF.

        ENDIF.

        IF p_tran IS NOT INITIAL AND
           c_send IS INITIAL.

* MAHSUPLAŞTıRMA YAPıLARAK Mı GÖNDERI YAPıLMıŞ?
          READ TABLE gt_h001 INTO ls_h001 WITH KEY bukrs = gs_adrs-bukrs
                                                   gsber = gs_adrs-gsber
                                                   gjahr = p_gjahr
                                                   monat = p_period
                                                   mtype = gv_mtype
                                                   lifnr = iv_lifnr
                                                   ftype = p_ftype.
          IF sy-subrc EQ 0.

            CLEAR ls_reia.
            READ TABLE gt_reia INTO ls_reia WITH KEY bukrs   = ls_h001-bukrs
                                                     gsber   = ls_h001-gsber
                                                     mnumber = ls_h001-mnumber
                                                     monat   = ls_h001-monat
                                                     gjahr   = ls_h001-gjahr
                                                     BINARY SEARCH.

            IF sy-subrc IS INITIAL AND ( ls_reia-mresult EQ 'H' OR ls_reia-mresult EQ 'T' ).
              RETURN.
            ENDIF.

            c_mnumber = ls_h001-mnumber.
            c_send = zreco_if_common_types=>mc_select_yes.
          ELSE.
            CLEAR c_send.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.