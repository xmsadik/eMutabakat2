  METHOD zreco_from_mail_adrs.
    DATA: lv_uname1 TYPE sy-uname,
          lv_uname2 TYPE sy-uname,
          lv_uname3 TYPE sy-uname.

    DATA: ls_kna1 TYPE i_customer . "kizilkaya

    DATA:r_mtype TYPE RANGE OF zreco_rmil-mtype.

    CLEAR: r_mtype,r_mtype[].


    APPEND VALUE #( sign   = 'I'
                   option  = 'EQ'
                    low    = 'X'  ) TO r_mtype.

    SELECT SINGLE from_mail FROM zreco_adrs
      WHERE bukrs EQ @i_bukrs
      AND gsber EQ @i_gsber
      INTO @e_mail.

    CHECK e_mail IS INITIAL.

    IF i_kunnr IS NOT INITIAL.
* Kullanıcıya özgü müşteri tayini yapılmış mı?
      SELECT SINGLE uname1, uname2, uname3 FROM zreco_cvua
        WHERE bukrs EQ @i_bukrs
          AND mtype IN @r_mtype
          AND kunnr EQ @i_kunnr
          INTO (@lv_uname1, @lv_uname2, @lv_uname3).

      CASE lv_uname1.
        WHEN space.

          SELECT SINGLE *
                   FROM i_customer
                  WHERE Customer EQ @i_kunnr
                  INTO @ls_kna1.

          SELECT SINGLE from_mail FROM zreco_rmil
            WHERE bukrs EQ @i_bukrs
            AND gsber EQ @i_gsber
            AND mtype IN @r_mtype
            AND ktokd EQ @ls_kna1-CustomerAccountGroup
            INTO @e_mail.

          IF sy-subrc NE 0.
            SELECT SINGLE from_mail FROM zreco_rmil
              WHERE bukrs EQ @i_bukrs
              AND gsber EQ @i_gsber
              AND mtype IN @r_mtype
              AND ktokd EQ ''
              INTO @e_mail.
          ENDIF.

        WHEN OTHERS.
* Kullanıcının e-posta adresine bak
          DATA: ls_usr21 TYPE I_User,
                ls_lfa1  TYPE i_supplier.

          SELECT SINGLE *
                   FROM I_User
                  WHERE UserID EQ @lv_uname1
                  INTO @ls_usr21.

          SELECT SINGLE EmailAddress FROM I_AddressEmailAddress_2
            WHERE AddressID EQ @ls_usr21-AddressID
            AND AddressPersonID  EQ @ls_usr21-AddressPersonID
            INTO @e_mail.

      ENDCASE.


    ENDIF.

    IF i_lifnr IS NOT INITIAL.
* Kullanıcıya özgü satıcı tayini yapılmış mı?
      SELECT SINGLE uname1, uname2, uname3 FROM zreco_cvua
        WHERE bukrs EQ @i_bukrs
          AND mtype IN @r_mtype
          AND lifnr EQ @i_kunnr
           INTO (@lv_uname1, @lv_uname2, @lv_uname3).

      CASE lv_uname1.
        WHEN space.

          SELECT SINGLE *
                   FROM i_supplier
                  WHERE Supplier EQ @i_lifnr
                    INTO @ls_lfa1.

          SELECT SINGLE from_mail FROM zreco_rmil
            WHERE bukrs EQ @i_bukrs
            AND gsber EQ @i_gsber
            AND mtype IN @r_mtype
            AND ktokk EQ @ls_lfa1-SupplierAccountGroup
              INTO @e_mail.

          IF sy-subrc NE 0.
            SELECT SINGLE from_mail FROM zreco_rmil
              WHERE bukrs EQ @i_bukrs
              AND gsber EQ @i_gsber
              AND mtype IN @r_mtype
              AND ktokk EQ ''
              INTO @e_mail.
          ENDIF.

        WHEN OTHERS.
* Kullanıcının e-posta adresine bak
          SELECT SINGLE *
                   FROM I_User
            WHERE UserID EQ @lv_uname1
            INTO @ls_usr21.

*          SELECT SINGLE smtp_addr FROM adr6                                "D_MBAYEL Commentlenmiştir
*            WHERE addrnumber EQ @ls_usr21-AddressID
*            AND persnumber  EQ @ls_usr21-AddressPersonID
*            INTO @e_mail.

      ENDCASE.

    ENDIF.

    IF e_mail IS INITIAL.
      SELECT SINGLE *
               FROM I_User
        WHERE UserID EQ @i_uname
           INTO @ls_usr21.

*      SELECT SINGLE smtp_addr FROM adr6                                            "D_MBAYEL Commentlenmiştir
*        WHERE AddressID EQ @ls_usr21-AddressID
*        AND AddressPersonID  EQ @ls_usr21-AddressPersonID
*        INTO @e_mail.

    ENDIF.
  ENDMETHOD.