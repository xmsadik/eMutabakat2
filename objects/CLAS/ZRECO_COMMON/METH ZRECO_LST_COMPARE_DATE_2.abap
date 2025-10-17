  METHOD zreco_lst_compare_date_2.

    DATA: lv_gjahr   TYPE gjahr,
          lv_monat   TYPE monat,
          lv_version TYPE zreco_version,
          ls_h001    TYPE zreco_hdr,
          ls_chd1    TYPE zreco_chd1,
          ls_chd2    TYPE zreco_chd2,
          ls_bukr    TYPE zreco_chd1,
          lt_cdat    TYPE STANDARD TABLE OF zreco_cdat.

    CLEAR: lv_gjahr, lv_monat, ls_h001, ls_chd1, ls_chd2.

    MOVE-CORRESPONDING is_h001 TO ls_bukr.

* Önceki döneme ait eşleşmeyen kalemleri bul
    SELECT MAX( gjahr ) FROM zreco_hdr
      WHERE bukrs EQ @is_h001-bukrs
      AND hesap_tur EQ @is_h001-hesap_tur
      AND hesap_no EQ @is_h001-hesap_no
      AND mtype IN ('C', 'X')
      AND mnumber NE @is_h001-mnumber
      AND gjahr LE @ls_bukr-gjahr
      AND loekz EQ ''
      INTO @lv_gjahr.

    IF lv_gjahr EQ ls_bukr-gjahr.
      SELECT MAX( monat ) FROM zreco_hdr
        WHERE bukrs EQ @is_h001-bukrs
        AND hesap_tur EQ @is_h001-hesap_tur
        AND hesap_no EQ @is_h001-hesap_no
        AND mtype IN ('C', 'X')
        AND mnumber NE @is_h001-mnumber
        AND gjahr EQ @lv_gjahr
        AND monat LT @ls_bukr-monat
        AND loekz EQ ''
        INTO @lv_monat.

    ELSE.
      IF lv_gjahr IS NOT INITIAL.
        SELECT MAX( monat ) FROM zreco_hdr
          WHERE bukrs EQ @is_h001-bukrs
          AND hesap_tur EQ @is_h001-hesap_tur
          AND hesap_no EQ @is_h001-hesap_no
          AND mtype IN ('C', 'X')
          AND mnumber NE @is_h001-mnumber
          AND gjahr EQ @lv_gjahr
          AND loekz EQ ''
          INTO @lv_monat.
      ENDIF.
    ENDIF.

    IF lv_gjahr IS NOT INITIAL.

      SELECT SINGLE * FROM zreco_hdr
         WHERE bukrs EQ @is_h001-bukrs
         AND hesap_tur EQ @is_h001-hesap_tur
         AND hesap_no EQ @is_h001-hesap_no
         AND mtype IN ('C', 'X')
         AND mnumber NE @is_h001-mnumber
         AND gjahr EQ @lv_gjahr
         AND monat EQ @lv_monat
         AND loekz EQ ''
         INTO @ls_h001.

      IF sy-subrc EQ 0.
        e_last_info-last_mnumber = ls_h001-mnumber.
        e_last_info-last_monat = ls_h001-monat.
        e_last_info-last_gjahr = ls_h001-gjahr.

        IF i_last IS NOT INITIAL.

          CONCATENATE e_last_info-last_gjahr e_last_info-last_monat '01'
          INTO e_last_info-first_date.

*          CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
*            EXPORTING
*              day_in            = e_last_info-first_date
*            IMPORTING
*              last_day_of_month = e_last_info-last_date
*            EXCEPTIONS
*              day_in_no_date    = 1
*              OTHERS            = 2.

          SELECT SINGLE version FROM zreco_vers
              WHERE bukrs EQ @ls_h001-bukrs
              AND gsber EQ @ls_h001-gsber
              AND mnumber EQ @ls_h001-mnumber
              AND monat EQ @ls_h001-monat
              AND gjahr EQ @ls_h001-gjahr
              AND vstatu EQ 'G'
              INTO @lv_version.

          SELECT SINGLE mresult FROM zreco_reia
            WHERE bukrs EQ @ls_h001-bukrs
            AND gsber EQ @ls_h001-gsber
            AND mnumber EQ @ls_h001-mnumber
            AND monat EQ @ls_h001-monat
            AND gjahr EQ @ls_h001-gjahr
            AND version EQ @lv_version
            INTO @e_last_info-mresult.

        ENDIF.

      ENDIF.

    ENDIF.

    CHECK i_last IS INITIAL.

    CLEAR lt_cdat[].

    SELECT * FROM zreco_cdat
      WHERE bukrs EQ @is_h001-bukrs
      AND mnumber EQ @is_h001-mnumber
      AND monat EQ @is_h001-monat
      AND gjahr EQ @is_h001-gjahr
      INTO TABLE @lt_cdat.

    IF sy-subrc NE 0.

      CLEAR lt_cdat[].

      SELECT * FROM zreco_cdat
        WHERE bukrs EQ @is_h001-bukrs
        AND mnumber EQ @ls_h001-mnumber
        AND monat EQ @ls_h001-monat
        AND gjahr EQ @ls_h001-gjahr
        INTO TABLE @lt_cdat.

    ENDIF.

    SORT lt_cdat BY budat_low.

    READ TABLE lt_cdat ASSIGNING FIELD-SYMBOL(<lfs_cdat>) INDEX 1.
    IF sy-subrc EQ 0. "YiğitcanÖzdemir
      e_last_info-first_date = <lfs_cdat>-budat_low.
    ENDIF.
    SORT lt_cdat BY budat_high DESCENDING.

    READ TABLE lt_cdat ASSIGNING <lfs_cdat> INDEX 1.
    IF sy-subrc EQ 0. "YiğitcanÖzdemir
      e_last_info-last_date = <lfs_cdat>-budat_high.
    ENDIF.

  ENDMETHOD.