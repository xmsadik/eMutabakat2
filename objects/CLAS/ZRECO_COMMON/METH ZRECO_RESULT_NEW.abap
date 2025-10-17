  METHOD zreco_result_new.

    DATA: ls_result   TYPE zreco_reia, "Sonuçlar
          lt_cform    TYPE TABLE OF zreco_rcar , "Cari mutabakat
          ls_cform    TYPE zreco_rcar,
          ls_bform    TYPE zreco_rbia, "B formu
          ls_head     TYPE zreco_hdr, "Başlık
          lt_head     TYPE TABLE OF zreco_hdr,
          ls_parm     TYPE zreco_parm, "Parametre
          ls_answer   TYPE zreco_hia, "Cevap
          ls_version  TYPE zreco_vers,
          lt_versiyon TYPE TABLE OF zreco_vers,
          lv_versiyon TYPE zreco_version,
          lt_t001     TYPE TABLE OF i_companycode,
          ls_t001     TYPE i_companycode.

    TYPES:BEGIN OF gty_random,
            bukrs     TYPE bukrs,
            mnumber   TYPE zreco_number,
            randomkey TYPE zreco_random,
            datum     TYPE datum,
            uzeit     TYPE uzeit,
          END OF gty_random.

    DATA: ls_random TYPE gty_random.



    SELECT SINGLE * FROM zreco_parm
       WHERE pname EQ 'TEST'
       INTO @ls_parm.

    SELECT SINGLE * FROM zreco_rand
      WHERE randomkey EQ @i_randid
      INTO CORRESPONDING FIELDS OF @ls_random.

    IF sy-subrc EQ 0. "Link geçerli

      SELECT SINGLE * FROM zreco_hdr
        WHERE bukrs   EQ @ls_random-bukrs
        AND mnumber   EQ @ls_random-mnumber
        AND randomkey EQ @i_randid
        AND loekz     EQ ''
        INTO @ls_head.

      IF sy-subrc NE 0.
        e_text = 'Invalid Link/Hatalı Link'.
        EXIT.
      ENDIF.

      SELECT SINGLE * FROM i_companycode
      WHERE CompanyCode EQ @ls_head-bukrs
      INTO @DATA(ls_componycode).


      SELECT SINGLE * FROM zreco_vers
      WHERE bukrs EQ @ls_head-bukrs
      AND gsber EQ @ls_head-gsber
      AND mnumber EQ @ls_head-mnumber
      AND monat EQ @ls_head-monat
      AND gjahr EQ @ls_head-gjahr
      AND vstatu EQ 'G'
      INTO @ls_version.


*    IF ls_version-version GT 1. "Versiyon değişikliği yapılmış ise
*
*      ls_version-version = ls_version-version + 1.
*
*      UPDATE /ITETR/RECO_VERS SET vstatu = 'I'
*         WHERE bukrs EQ ls_head-bukrs
*         AND gsber EQ ls_head-gsber
*         AND mnumber EQ ls_head-mnumber
*         AND monat EQ ls_head-monat
*         AND gjahr EQ ls_head-gjahr
*         AND version EQ lv_version
*         AND vstatu EQ 'G'.
*
*      ls_version-ernam = sy-uname.
*      ls_version-erdat = sy-datum.
*      ls_version-erzei = sy-uzeit.
*
*      INSERT /ITETR/RECO_VERS FROM ls_version.
*
*    ENDIF.

      IF i_no_data EQ abap_true. "Tarafımızda böyle bir bilgi yok demişse


        MOVE-CORRESPONDING ls_head  TO ls_answer.
        MOVE-CORRESPONDING ls_version  TO ls_answer.

        ls_answer-ernam = sy-uname.
        ls_answer-erdat = cl_abap_context_info=>get_system_date( )."sy-datum.
        ls_answer-erzei =  cl_abap_context_info=>get_system_time( )." sy-uzeit.
        ls_answer-wuser = i_user.
        ls_answer-webip = i_ip.
        ls_answer-terminal = i_terminal.
        ls_answer-no_data = i_no_data.
        ls_answer-mailid = i_mailid.

        MOVE-CORRESPONDING ls_head  TO ls_result.
        MOVE-CORRESPONDING ls_version  TO ls_result.

        ls_result-mresult = 'T'. "Tarafımızda kaydınız bulunmamaktadır
        ls_result-mtext = i_text.
        ls_result-ernam = sy-uname.
        ls_result-erdat = cl_abap_context_info=>get_system_date( )."sy-datum.
        ls_result-erzei = cl_abap_context_info=>get_system_time( )."sy-uzeit.

        IF i_file_1 IS NOT INITIAL.
          ls_answer-file_1 = i_file_1.
        ENDIF.

        IF i_file_2 IS NOT INITIAL.
          ls_answer-file_2 = i_file_2.
        ENDIF.

        UPDATE zreco_hdr SET xstatu = 'X'
         WHERE bukrs EQ @ls_head-bukrs
         AND gsber EQ @ls_head-gsber
         AND mnumber EQ @ls_head-mnumber
         AND monat EQ @ls_head-monat
         AND gjahr EQ @ls_head-gjahr
         AND randomkey EQ @i_randid.

        SELECT SINGLE dont_agree_msg FROM zreco_text
          WHERE bukrs EQ @ls_head-bukrs
          AND gsber EQ @ls_head-gsber
          AND spras EQ @ls_head-spras
          AND hesap_tur EQ @ls_head-hesap_tur
          INTO @e_text.

        IF ls_parm IS INITIAL.
          INSERT zreco_reia FROM @ls_result.
          MODIFY zreco_hia FROM @ls_answer.
        ELSE.
          MODIFY zreco_reia FROM @ls_result.
          MODIFY zreco_hia FROM @ls_answer.
        ENDIF.

      ELSE.

        IF i_answer EQ 'Y'. "Mutabık ise

          IF ls_head-mtype NE 'C'. "Cari mutabakat değilse
            SELECT SINGLE * FROM zreco_recb
              WHERE bukrs EQ @ls_version-bukrs
              AND gsber EQ @ls_version-gsber
              AND mnumber EQ @ls_version-mnumber
              AND monat EQ @ls_version-monat
              AND gjahr EQ @ls_version-gjahr
              AND version EQ @ls_version-version
              INTO CORRESPONDING FIELDS OF @ls_bform.

            ls_bform-responder_name = is_bform-responder_name.
            ls_bform-responder_surname = is_bform-responder_surname.
          ENDIF.

          IF ls_head-mtype NE 'B'. "B formu mutabakatı değilse
            SELECT * FROM zreco_rcai
              WHERE bukrs EQ @ls_version-bukrs
              AND gsber EQ @ls_version-gsber
              AND mnumber EQ @ls_version-mnumber
              AND monat EQ @ls_version-monat
              AND gjahr EQ @ls_version-gjahr
              AND version EQ @ls_version-version
              INTO CORRESPONDING FIELDS OF TABLE @lt_cform.
            LOOP AT lt_cform ASSIGNING FIELD-SYMBOL(<lt_cform>).
              LOOP AT et_cform ASSIGNING FIELD-SYMBOL(<et_cform>).
                EXIT.
              ENDLOOP.
              <lt_cform>-responder_name = <et_cform>-responder_name.
              <lt_cform>-responder_surname = <et_cform>-responder_surname.
              "lt_cform-wrbtr = lt_cform-wrbtr * -1.
              "lt_cform-dmbtr = lt_cform-dmbtr * -1.
              <lt_cform>-version = ls_version-version.

            ENDLOOP.
          ENDIF.


          MOVE-CORRESPONDING ls_head  TO ls_answer.
          MOVE-CORRESPONDING ls_version  TO ls_answer.

          ls_answer-ernam = sy-uname.
          ls_answer-erdat = cl_abap_context_info=>get_system_date( )."sy-datum.
          ls_answer-erzei = cl_abap_context_info=>get_system_time( )."sy-uzeit.
          ls_answer-wuser = i_user.
          ls_answer-webip = i_ip.
          ls_answer-terminal = i_terminal.
          ls_answer-no_data = i_no_data.
          ls_answer-mailid = i_mailid.


          MOVE-CORRESPONDING ls_head  TO ls_result.
          MOVE-CORRESPONDING ls_version  TO ls_result.

          ls_result-mresult = 'E'. "Evet
          ls_result-mtext = i_text.
          ls_result-ernam = sy-uname.
          ls_result-erdat = cl_abap_context_info=>get_system_date( )."sy-datum.
          ls_result-erzei = cl_abap_context_info=>get_system_time( )."sy-uzeit.


          IF i_file_1 IS NOT INITIAL.
            ls_answer-file_1 = i_file_1.
          ENDIF.

          IF i_file_2 IS NOT INITIAL.
            ls_answer-file_2 = i_file_2.
          ENDIF.

          UPDATE zreco_hdr SET xstatu = 'X'
            WHERE bukrs EQ @ls_head-bukrs
            AND gsber EQ @ls_head-gsber
            AND mnumber EQ @ls_head-mnumber
            AND monat EQ @ls_head-monat
            AND gjahr EQ @ls_head-gjahr
            AND randomkey EQ @i_randid.

          SELECT SINGLE agree_msg FROM zreco_text
            WHERE bukrs EQ @ls_head-bukrs
            AND gsber EQ @ls_head-gsber
            AND spras EQ @ls_head-spras
            AND hesap_tur EQ @ls_head-hesap_tur
            INTO @e_text.

          IF ls_parm IS INITIAL.
            MODIFY zreco_reia FROM @ls_result.
            MODIFY zreco_rcar FROM TABLE @lt_cform.
            MODIFY zreco_rbia FROM @ls_bform.
            MODIFY zreco_hia FROM @ls_answer.
          ELSE.
            MODIFY zreco_reia FROM @ls_result.
            MODIFY zreco_rcar FROM TABLE @lt_cform.
            MODIFY zreco_rbia FROM @ls_bform.
            MODIFY zreco_hia FROM @ls_answer.
          ENDIF.

        ELSEIF i_answer EQ 'I'. "ilgili kişi ben değilim.
          MOVE-CORRESPONDING ls_head  TO ls_answer.
          MOVE-CORRESPONDING ls_version  TO ls_answer.

          ls_answer-ernam = sy-uname.
          ls_answer-erdat = cl_abap_context_info=>get_system_date( )."sy-datum.
          ls_answer-erzei = cl_abap_context_info=>get_system_time( )."sy-uzeit.
          ls_answer-wuser = i_user.
          ls_answer-webip = i_ip.
          ls_answer-terminal = i_terminal.
          ls_answer-no_data = i_no_data.
          ls_answer-mailid = i_mailid.

          MOVE-CORRESPONDING ls_head  TO ls_result.
          MOVE-CORRESPONDING ls_version  TO ls_result.

          ls_result-mresult = 'I'. "İlgili kişi ben değilim.
          ls_result-mtext = i_text.
          ls_result-ernam = sy-uname.
          ls_result-erdat = cl_abap_context_info=>get_system_date( )."sy-datum.
          ls_result-erzei = cl_abap_context_info=>get_system_time( )."sy-uzeit.

          IF i_file_1 IS NOT INITIAL.
            ls_answer-file_1 = i_file_1.
          ENDIF.

          IF i_file_2 IS NOT INITIAL.
            ls_answer-file_2 = i_file_2.
          ENDIF.

          UPDATE zreco_hdr SET xstatu = 'X'
            WHERE bukrs EQ @ls_head-bukrs
            AND gsber EQ @ls_head-gsber
            AND mnumber EQ @ls_head-mnumber
            AND monat EQ @ls_head-monat
            AND gjahr EQ @ls_head-gjahr
            AND randomkey EQ @i_randid.

          SELECT SINGLE dont_agree_msg FROM zreco_text
            WHERE bukrs EQ @ls_head-bukrs
            AND gsber EQ @ls_head-gsber
            AND spras EQ @ls_head-spras
            AND hesap_tur EQ @ls_head-hesap_tur
            INTO @e_text.

          IF ls_parm IS INITIAL.
            INSERT zreco_reia FROM @ls_result.
            MODIFY zreco_hia FROM @ls_answer.
          ELSE.
            MODIFY zreco_reia FROM @ls_result.
            MODIFY zreco_hia FROM @ls_answer.
          ENDIF.

        ELSEIF i_answer EQ 'N'. "Mutabık değilse

          IF ls_head-mtype NE 'C'. "Cari mutabakat değilse
            MOVE-CORRESPONDING is_bform TO ls_bform.
            MOVE-CORRESPONDING ls_version TO ls_bform.
            MOVE-CORRESPONDING ls_head TO ls_bform.
          ENDIF.

          lv_versiyon = ls_version-version.

          APPEND INITIAL LINE TO lt_head ASSIGNING FIELD-SYMBOL(<lfs_head>).
          MOVE-CORRESPONDING ls_head TO <lfs_head>.

          APPEND INITIAL LINE TO lt_versiyon ASSIGNING FIELD-SYMBOL(<lfs_versiyon>).
          MOVE-CORRESPONDING ls_version TO <lfs_versiyon>.
          <lfs_versiyon>-version = lv_versiyon.

          IF ls_head-mtype NE 'B'. "B formu mutabakatı değilse
            LOOP AT et_cform ASSIGNING FIELD-SYMBOL(<lfs_cform>) WHERE waers_c IS NOT INITIAL.
              CLEAR lt_cform.
              MOVE-CORRESPONDING et_cform TO lt_cform.
              MOVE-CORRESPONDING lt_head TO lt_cform.
              MOVE-CORRESPONDING lt_versiyon TO lt_cform.
*              lt_cform-version = lv_versiyon.
              lv_versiyon = lv_versiyon + 1.
              IF ls_head-xno_local_curr IS INITIAL.
                ls_cform-dmbtr = <lfs_cform>-dmbtr_c .
              ELSE.
                CLEAR ls_cform-dmbtr.
              ENDIF.

              IF <lfs_cform>-waers EQ ls_t001-Currency
              AND <lfs_cform>-wrbtr_c EQ 0.
                <lfs_cform>-wrbtr_c = <lfs_cform>-dmbtr_c.
              ENDIF.
              APPEND INITIAL LINE TO lt_cform ASSIGNING FIELD-SYMBOL(<lft_cform>).
              <lft_cform>-wrbtr = <lfs_cform>-wrbtr_c.
              <lft_cform>-waers = <lfs_cform>-waers_c.
              <lft_cform>-xsum = 'X'.
            ENDLOOP.
          ENDIF.

          MOVE-CORRESPONDING ls_head  TO ls_answer.
          MOVE-CORRESPONDING ls_version  TO ls_answer.

          ls_answer-ernam = sy-uname.
          ls_answer-erdat = cl_abap_context_info=>get_system_date( )."sy-datum.
          ls_answer-erzei = cl_abap_context_info=>get_system_time( )."sy-uzeit.
          ls_answer-wuser = i_user.
          ls_answer-webip = i_ip.
          ls_answer-terminal = i_terminal.
          ls_answer-no_data = i_no_data.
          ls_answer-mailid = i_mailid.

          MOVE-CORRESPONDING ls_head  TO ls_result.
          MOVE-CORRESPONDING ls_version  TO ls_result.

          ls_result-mresult = 'H'. "Hayır
          ls_result-mtext = i_text.
          ls_result-ernam = sy-uname.
          ls_result-erdat = cl_abap_context_info=>get_system_date( )."sy-datum.
          ls_result-erzei = cl_abap_context_info=>get_system_time( )."sy-uzeit.

          IF i_file_1 IS NOT INITIAL.
            ls_answer-file_1 = i_file_1.
          ENDIF.

          IF i_file_2 IS NOT INITIAL.
            ls_answer-file_2 = i_file_2.
          ENDIF.

          UPDATE zreco_hdr SET xstatu = 'X'
          WHERE bukrs   EQ @ls_head-bukrs
            AND gsber   EQ @ls_head-gsber
            AND mnumber EQ @ls_head-mnumber
            AND monat   EQ @ls_head-monat
            AND gjahr   EQ @ls_head-gjahr
            AND randomkey EQ @i_randid.
*        SELECT single MAX( version ) FROM /itetr/reco_rcar
*          FOR ALL ENTRIES IN lt_cform
*          WHERE mnumber EQ lt_cform-mnumber.
          IF ls_parm IS INITIAL.
            MODIFY zreco_reia FROM @ls_result.
            MODIFY zreco_rcar FROM TABLE @lt_cform.
            MODIFY zreco_rbia FROM @ls_bform.
            MODIFY zreco_hia  FROM @ls_answer.
          ELSE.
            MODIFY zreco_reia FROM @ls_result.
            MODIFY zreco_rcar FROM TABLE @lt_cform.
            MODIFY zreco_rbia FROM @ls_bform.
            MODIFY zreco_hia FROM @ls_answer.
          ENDIF.

          SELECT SINGLE dont_agree_msg FROM zreco_text
          WHERE bukrs EQ @ls_head-bukrs
          AND gsber EQ @ls_head-gsber
          AND spras EQ @ls_head-spras
          AND hesap_tur EQ @ls_head-hesap_tur
          INTO @e_text.

        ENDIF.

      ENDIF.

    ELSE.

      SELECT SINGLE * FROM zreco_hdr
        WHERE randomkey EQ @i_randid
        INTO @ls_head.

      IF ls_head-hesap_tur IS NOT INITIAL.
        SELECT SINGLE invalid_msg FROM zreco_text
          WHERE bukrs EQ @ls_head-bukrs
          AND gsber EQ @ls_head-gsber
          AND spras EQ @ls_head-spras
          AND hesap_tur EQ @ls_head-hesap_tur
          INTO @e_text.
      ELSE.
        e_text = 'Invalid Link/Hatalı Link'.
      ENDIF.

    ENDIF.

    IF ls_parm IS INITIAL.
      DELETE FROM zreco_rand WHERE mnumber   EQ @ls_head-mnumber
                               AND randomkey EQ @ls_head-randomkey.
    ENDIF.
  ENDMETHOD.