  METHOD zreco_auth.

    TYPES : r_mtype  TYPE RANGE OF zreco_unam-mtype,
            ty_mtype TYPE LINE OF  r_mtype,
            r_ftype  TYPE RANGE OF zreco_unam-ftype,
            ty_ftype TYPE LINE OF r_ftype.


    DATA  : ls_mtype TYPE ty_mtype,
            it_mtype TYPE r_mtype,
            ls_ftype TYPE ty_ftype,
            it_ftype TYPE r_ftype.

    DATA ls_unam TYPE zreco_unam.

    CLEAR : it_mtype[], it_ftype[].


    ls_mtype-sign   = 'I'.
    ls_mtype-option = 'EQ'.
    ls_mtype-low    = i_mtype.
    APPEND ls_mtype TO it_mtype.

* Henüz bakım yapılmamışsa herkes yetkilidir
    SELECT SINGLE *
             FROM zreco_unam
            WHERE bukrs EQ @i_bukrs
            INTO @ls_unam.
    IF sy-subrc NE 0.
      e_auth = zreco_if_common_types=>mc_select_yes.
      EXIT.
    ELSE.
      ls_mtype-sign   = 'I'.
      ls_mtype-option = 'EQ'.
      ls_mtype-low    = zreco_if_common_types=>mc_select_no.
      APPEND ls_mtype TO it_mtype.
    ENDIF.

    ls_ftype-sign   = 'I'.
    ls_ftype-option = 'EQ'.
    ls_ftype-low    = i_ftype.
    APPEND ls_ftype TO it_ftype.

* Tam yetkili mi?
    SELECT SINGLE *
             FROM zreco_unam
            WHERE bukrs EQ @i_bukrs
              AND uname EQ @sy-uname
              AND mtype IN @it_mtype
              AND ftype IN @it_ftype
                INTO @ls_unam.
    IF sy-subrc EQ 0.
      CASE i_hesap_tur.
        WHEN zreco_if_common_types=>mc_hesap_tur_s.
          SELECT SINGLE Industry
          FROM i_supplier   AS lfa1
           WHERE Supplier = @i_hesap_no
               INTO @i_brsch .
          IF ls_unam-ktokk EQ '*'.
            e_auth = zreco_if_common_types=>mc_select_yes.
            EXIT.
          ELSEIF ls_unam-ktokk EQ ''.
            e_auth = zreco_if_common_types=>mc_select_yes.
            EXIT.
          ELSE.
            IF ls_unam-ktokk EQ i_ktokl.
              e_auth = zreco_if_common_types=>mc_select_yes.
              EXIT.
            ENDIF.
          ENDIF.
          IF ls_unam-s_brsch EQ '*'.
            e_auth = zreco_if_common_types=>mc_select_yes.
            EXIT.
          ELSEIF ls_unam-s_brsch EQ ''.
            e_auth = zreco_if_common_types=>mc_select_yes.
            EXIT.
          ELSE.
            IF ls_unam-s_brsch EQ i_brsch.
              e_auth = zreco_if_common_types=>mc_select_yes.
              EXIT.
            ENDIF.
          ENDIF.
        WHEN zreco_if_common_types=>mc_hesap_tur_m.
          SELECT SINGLE Industry
          FROM i_customer AS kna1
          WHERE Customer = @i_hesap_no
            INTO @i_brsch .
          IF ls_unam-ktokd EQ '*'.
            e_auth = zreco_if_common_types=>mc_select_yes.
            EXIT.
          ELSEIF ls_unam-ktokd EQ ''.
            e_auth = zreco_if_common_types=>mc_select_yes.
            EXIT.
          ELSE.
            IF ls_unam-ktokd EQ i_ktokl.
              e_auth = zreco_if_common_types=>mc_select_yes.
              EXIT.
            ENDIF.
          ENDIF.
          IF ls_unam-m_brsch EQ '*'.
            e_auth = zreco_if_common_types=>mc_select_yes.
            EXIT.
          ELSEIF ls_unam-m_brsch EQ ''.
            e_auth = zreco_if_common_types=>mc_select_yes.
            EXIT.
          ELSE.
            IF ls_unam-m_brsch EQ i_brsch.
              e_auth = zreco_if_common_types=>mc_select_yes.
              EXIT.
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDIF.


* Birebir bir tayin var mı?
    CASE i_hesap_tur.
      WHEN zreco_if_common_types=>mc_hesap_tur_m.
        SELECT SINGLE COUNT(*)
                 FROM zreco_auth
                WHERE bukrs EQ @i_bukrs
                  AND mtype EQ @i_mtype
                  AND kunnr EQ @i_hesap_no
                  AND uname EQ @sy-uname.
        IF sy-subrc EQ 0.
          e_auth = zreco_if_common_types=>mc_select_yes.
          EXIT.
        ENDIF.

      WHEN zreco_if_common_types=>mc_hesap_tur_s.
        SELECT SINGLE COUNT(*)
                 FROM zreco_auth
                WHERE bukrs EQ @i_bukrs
                  AND mtype EQ @i_mtype
                  AND lifnr EQ @i_hesap_no
                  AND uname EQ @sy-uname.
        IF sy-subrc EQ 0.
          e_auth = zreco_if_common_types=>mc_select_yes.
          EXIT.
        ENDIF.
    ENDCASE.

* Sadece kendi mutabakatları
*  SELECT SINGLE *
*           FROM /itetr/reco_unam
*           INTO ls_unam
*          WHERE bukrs EQ i_bukrs
*            AND uname EQ sy-uname
*            AND mtype IN r_mtype
*            AND ftype IN r_ftype
*            AND xuser  EQ /itetr/reco_if_common_types=>mc_select_yes.
*
*  IF sy-subrc EQ 0.
*    CHECK sy-uname EQ i_uname.
*    CASE i_hesap_tur.
*      WHEN /itetr/reco_if_common_types=>mc_hesap_tur_s.
*        IF ls_unam-ktokk EQ '*'.
*          e_auth = /itetr/reco_if_common_types=>mc_select_yes.
*          EXIT.
*        ELSE.
*          IF ls_unam-ktokk EQ i_ktokl.
*            e_auth = /itetr/reco_if_common_types=>mc_select_yes.
*            EXIT.
*          ENDIF.
*        ENDIF.
*      WHEN /itetr/reco_if_common_types=>mc_hesap_tur_m.
*        IF ls_unam-ktokd EQ '*'.
*          e_auth = /itetr/reco_if_common_types=>mc_select_yes.
*          EXIT.
*        ELSE.
*          IF ls_unam-ktokd EQ i_ktokl.
*            e_auth = /itetr/reco_if_common_types=>mc_select_yes.
*            EXIT.
*          ENDIF.
*        ENDIF.
*    ENDCASE.
*  ENDIF.


  ENDMETHOD.