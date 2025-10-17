  METHOD zreco_contact_m.
    DATA: r_mtype TYPE RANGE OF zreco_cont-mtype.

    APPEND VALUE #( sign   = 'I'
                   option  = 'EQ'
                    low    = i_mtype  ) TO r_mtype.

    APPEND VALUE #( sign   = 'I'
                   option  = 'EQ'
                    low    = 'X'  ) TO r_mtype. "Her ikisi birlikte

    CASE i_hesap_tur.
      WHEN 'M'.
* Hesap grubu ve Form tipine göre bak
        SELECT SINGLE m_name,
                      m_telefon,
                      m_email
          FROM zreco_cont
          WHERE bukrs EQ @is_adrs-bukrs
          AND hesap_tur EQ @i_hesap_tur
          AND ktokd EQ @i_ktokl
          AND mtype IN @r_mtype
          AND ftype EQ @i_ftype
          INTO (@e_name, @e_telefon, @e_email).

        IF sy-subrc NE 0.
* Tüm hesap grupları için Form tipine göre bak
          SELECT SINGLE m_name,
                        m_telefon,
                        m_email
          FROM zreco_cont
            WHERE bukrs EQ @is_adrs-bukrs
            AND hesap_tur EQ @i_hesap_tur
            AND ktokd EQ ''
            AND ktokk EQ ''
            AND mtype IN @r_mtype
            AND ftype EQ @i_ftype
            INTO (@e_name, @e_telefon, @e_email).
          IF sy-subrc NE 0.
* Hesap grubuna göre bak
            SELECT SINGLE m_name,
                          m_telefon,
                          m_email
            FROM zreco_cont
              WHERE bukrs EQ @is_adrs-bukrs
              AND hesap_tur EQ @i_hesap_tur
              AND ktokd EQ @i_ktokl
              AND mtype IN @r_mtype
              INTO (@e_name, @e_telefon, @e_email).
            IF sy-subrc NE 0.
* Tüm hesap grupları için bak
              SELECT SINGLE m_name,
                            m_telefon,
                            m_email
              FROM zreco_cont
                WHERE bukrs EQ @is_adrs-bukrs
                AND hesap_tur EQ @i_hesap_tur
                AND ktokd EQ ''
                AND ktokk EQ ''
                AND mtype IN @r_mtype
                INTO (@e_name, @e_telefon, @e_email).
            ENDIF.
          ENDIF.
        ENDIF.

      WHEN 'S'.

* Hesap grubu ve Form tipine göre bak
        SELECT SINGLE m_name, m_telefon, m_email
        FROM zreco_cont
          WHERE bukrs EQ @is_adrs-bukrs
          AND hesap_tur EQ @i_hesap_tur
          AND ktokk EQ @i_ktokl
          AND mtype IN @r_mtype
          AND ftype EQ @i_ftype
          INTO (@e_name, @e_telefon, @e_email).

        IF sy-subrc NE 0.
* Tüm hesap grupları için Form tipine göre bak
          SELECT SINGLE m_name, m_telefon, m_email FROM zreco_cont
            WHERE bukrs EQ @is_adrs-bukrs
            AND hesap_tur EQ @i_hesap_tur
            AND ktokd EQ ''
            AND ktokk EQ ''
            AND mtype IN @r_mtype
            AND ftype EQ @i_ftype
            INTO (@e_name, @e_telefon, @e_email).

          IF sy-subrc NE 0.
* Hesap grubuna göre bak
            SELECT SINGLE m_name, m_telefon, m_email FROM zreco_cont
              WHERE bukrs EQ @is_adrs-bukrs
              AND hesap_tur EQ @i_hesap_tur
              AND ktokk EQ @i_ktokl
              AND mtype IN @r_mtype
              INTO (@e_name, @e_telefon, @e_email).
            IF sy-subrc NE 0.
* Tüm hesap grupları için bak
              SELECT SINGLE m_name, m_telefon, m_email FROM zreco_cont
                WHERE bukrs EQ @is_adrs-bukrs
                AND hesap_tur EQ @i_hesap_tur
                AND ktokd EQ ''
                AND ktokk EQ ''
                AND mtype IN @r_mtype
                INTO (@e_name, @e_telefon, @e_email).
            ENDIF.
          ENDIF.
        ENDIF.

    ENDCASE.

    DATA: lv_persnumber TYPE I_User-AddressPersonID,
          lv_addrnumber TYPE I_User-AddressID,
          lv_tel_number TYPE I_AddressPhoneNumber_2-PhoneAreaCodeSubscriberNumber,
          lv_fax_number TYPE I_AddressFaxNumber_2-FaxAreaCodeSubscriberNumber,
          lv_name1      TYPE zreco_ddl_i_address2-OrganizationName1,
          lv_name2      TYPE zreco_ddl_i_address2-OrganizationName2,
          ls_tpar       TYPE zreco_tpar,
          lv_kunnr      TYPE kunnr,
          lv_lifnr      TYPE lifnr.

    IF lv_addrnumber IS NOT INITIAL.

      SELECT SINGLE OrganizationName1, OrganizationName2, AddressID, AddressID FROM zreco_ddl_i_address2
        WHERE AddressID EQ @lv_addrnumber
        INTO (@lv_name1, @lv_name2, @lv_tel_number, @lv_fax_number).

      CONCATENATE lv_name1 lv_name2 INTO e_name SEPARATED BY space.

      IF lv_tel_number IS NOT INITIAL.
        CONCATENATE 'Tel:' lv_tel_number INTO lv_tel_number SEPARATED BY space.
      ENDIF.

      IF lv_fax_number IS NOT INITIAL.
        CONCATENATE 'Fax:' lv_fax_number INTO lv_fax_number SEPARATED BY space.
      ENDIF.

      CONCATENATE lv_tel_number lv_fax_number INTO e_telefon SEPARATED BY space.

      SELECT SINGLE EmailAddress FROM I_AddressEmailAddress_2
       WHERE AddressID EQ @lv_addrnumber
       INTO @e_email.

    ENDIF.

    IF e_name    IS INITIAL AND
       e_telefon IS INITIAL AND
       e_email   IS INITIAL.

      SELECT SINGLE AddressPersonID, AddressID
      FROM I_User
        WHERE UserID EQ @i_uname
        INTO (@lv_persnumber, @lv_addrnumber ).

      SELECT SINGLE AddressPersonID FROM I_PersonAddress
*        WHERE persnumber EQ @lv_persnumber                                                  "D_MBAYEL commentlenmiştir
        INTO @e_name.

      SELECT SINGLE PhoneAreaCodeSubscriberNumber FROM I_AddressPhoneNumber_2
        WHERE AddressID EQ @lv_addrnumber
        AND AddressPersonID EQ @lv_persnumber
        INTO @lv_tel_number.

      IF lv_tel_number IS NOT INITIAL.
        CONCATENATE 'Tel:' lv_tel_number INTO lv_tel_number SEPARATED BY space.
      ENDIF.

      SELECT SINGLE FaxAreaCodeSubscriberNumber FROM I_AddressFaxNumber_2
        WHERE AddressID EQ @lv_addrnumber
        AND AddressPersonID EQ @lv_persnumber
        INTO @lv_fax_number.

      IF lv_fax_number IS NOT INITIAL.
        CONCATENATE 'Fax:' lv_fax_number INTO lv_fax_number SEPARATED BY space.
      ENDIF.

      CONCATENATE lv_tel_number lv_fax_number INTO e_telefon SEPARATED BY space.

      SELECT SINGLE EmailAddress FROM I_AddressEmailAddress_2
       WHERE AddressID EQ @lv_addrnumber
        AND AddressPersonID EQ @lv_persnumber
        INTO @e_email.

    ENDIF.
  ENDMETHOD.