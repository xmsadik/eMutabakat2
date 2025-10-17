  METHOD zreco_to_mail_adrs.

    TYPES: BEGIN OF ty_kna1,
             kunnr TYPE kunnr,
             adrnr TYPE zreco_adrnr,
           END OF ty_kna1.

    TYPES: BEGIN OF ty_lfa1,
             lifnr TYPE lifnr,
             adrnr TYPE zreco_adrnr,
           END OF ty_lfa1.

    TYPES: BEGIN OF ty_adr6,
             smtp_addr TYPE zreco_ad_smtpadr,
           END OF ty_adr6.

    TYPES: BEGIN OF ty_knvk,
             prsnr TYPE ad_persnum,
           END OF ty_knvk.


    DATA : lt_e003 TYPE SORTED TABLE OF zreco_eate
                WITH NON-UNIQUE KEY smtp_addr.


    DATA : lt_mast TYPE SORTED TABLE OF zreco_mast
                WITH NON-UNIQUE KEY  kunnr lifnr.

    DATA : r_adrnr TYPE RANGE OF kunnr,
           r_mtype TYPE RANGE OF zreco_hdr-mtype.

    DATA : ls_adrnr LIKE LINE OF r_adrnr,
           ls_mtype LIKE LINE OF r_mtype.


    DATA : lt_kna1 TYPE TABLE OF ty_kna1,
           lt_lfa1 TYPE TABLE OF ty_lfa1,
           lt_adr6 TYPE TABLE OF ty_adr6,
           lt_knvk TYPE TABLE OF ty_knvk.

    DATA : ls_kna1 TYPE  ty_kna1,
           ls_lfa1 TYPE  ty_lfa1,
           ls_adr6 TYPE  ty_adr6,
           ls_knvk TYPE  ty_knvk.

    DATA : ls_receivers TYPE zreco_somlreci1.


    ls_mtype-sign = 'I'.
    ls_mtype-option = 'EQ'.
    ls_mtype-low = i_mtype.
    APPEND ls_mtype TO r_mtype .

    IF i_kunnr IS NOT INITIAL.                    "YiğitcanÖ. 27092023
      i_kunnr = |{ i_kunnr ALPHA = IN }|.
    ENDIF.

    IF i_lifnr IS NOT INITIAL.                    "YiğitcanÖ. 27092023
      i_lifnr = |{ i_lifnr ALPHA = IN }|.
    ENDIF.



    IF i_kunnr IS NOT INITIAL.
      IF i_all IS NOT INITIAL.
        SELECT SINGLE COUNT(*)
                 FROM zreco_etax
                WHERE bukrs EQ @i_bukrs
                  AND stcd2 EQ @i_stcd1.
        IF sy-subrc NE 0.
          SELECT *
            FROM zreco_taxm
           WHERE vkn_tckn EQ @i_stcd1
            INTO CORRESPONDING FIELDS OF TABLE @lt_kna1.
        ENDIF.
      ENDIF.

      SELECT customer AS kunnr,
             AddressID AS adrnr
            FROM i_customer
           WHERE customer EQ @i_kunnr
            APPENDING TABLE @lt_kna1.

      DELETE lt_kna1 WHERE kunnr IS INITIAL.

      SORT lt_kna1 BY adrnr.

      DELETE ADJACENT DUPLICATES FROM lt_kna1 COMPARING adrnr.


      SELECT SINGLE COUNT(*)
               FROM zreco_adrs
              WHERE bukrs EQ @i_bukrs
                AND master_data EQ @space.

      IF sy-subrc EQ 0 .

        IF lt_kna1[] IS NOT INITIAL.  "YiğitcanÖ. 26092023.
          SELECT *
            FROM zreco_mast
             FOR ALL ENTRIES IN @lt_kna1
           WHERE bukrs EQ @i_bukrs
             AND kunnr EQ @lt_kna1-kunnr
             AND mtype IN @r_mtype
               INTO TABLE @lt_mast.
        ENDIF.

        IF lt_mast[] IS NOT INITIAL.
          LOOP AT lt_mast INTO DATA(ls_mast).
            READ TABLE lt_e003 TRANSPORTING NO FIELDS WITH KEY smtp_addr = ls_mast-smtp_addr.
            CHECK sy-subrc NE 0.
            IF e_mail IS INITIAL.
              e_mail = ls_mast-smtp_addr.
            ENDIF.

            ls_receivers-receiver = ls_mast-smtp_addr.
            ls_receivers-rec_type = 'U'.
            APPEND ls_receivers TO t_receivers .
            CLEAR  ls_receivers .
          ENDLOOP.
        ELSE.
**adrc
          LOOP AT lt_kna1 INTO ls_kna1.
            SELECT SINGLE COUNT(*)
                     FROM i_customercompany AS knb1
                    WHERE companycode EQ @i_bukrs
                      AND customer EQ @ls_kna1-kunnr.
            IF sy-subrc NE 0.
*            DELETE lt_kna1.
              DELETE lt_kna1 WHERE kunnr EQ ls_kna1-kunnr.
              CONTINUE.
            ENDIF.
            ls_adrnr-sign = 'I'.
            ls_adrnr-option = 'EQ'.
            ls_adrnr-low = ls_kna1-adrnr.
            APPEND ls_adrnr TO r_adrnr.
          ENDLOOP.
          IF lt_kna1[] IS NOT INITIAL.
            SELECT EmailAddress AS smtp_addr
              FROM I_AddressEmailAddress_2 AS adr6
               FOR ALL ENTRIES IN @lt_kna1
             WHERE AddressID EQ @lt_kna1-adrnr
               AND AddressPersonID EQ ''
             INTO TABLE @lt_adr6.
          ENDIF.
        ENDIF.

        LOOP AT lt_adr6 INTO ls_adr6 WHERE smtp_addr IS NOT INITIAL.
          IF e_mail IS INITIAL.
            e_mail = ls_adr6-smtp_addr.
          ENDIF.

          ls_receivers-receiver = ls_adr6-smtp_addr.
          ls_receivers-rec_type = 'U'.
          APPEND ls_receivers TO t_receivers .
          CLEAR  ls_receivers .
        ENDLOOP.


      ELSE.

*İlgili kişiden verileri çek
        IF i_abtnr IS NOT INITIAL.

          IF lt_kna1[] IS NOT INITIAL.
            LOOP AT lt_kna1 INTO DATA(s_kna1).
              SELECT SINGLE COUNT(*)
                       FROM i_customercompany
                      WHERE companycode EQ @i_bukrs
                        AND customer EQ @s_kna1-kunnr.
              IF sy-subrc NE 0.
*              DELETE lt_kna1.
                DELETE lt_kna1 WHERE kunnr EQ s_kna1-kunnr.
                CONTINUE.
              ENDIF.
              ls_adrnr-sign = 'I'.
              ls_adrnr-option = 'EQ'.
              ls_adrnr-low = s_kna1-adrnr.
              APPEND ls_adrnr TO r_adrnr.
            ENDLOOP.

            CHECK lt_kna1[] IS NOT INITIAL.

            SELECT PersonNumber AS prsnr
              FROM i_contactperson AS knvk
               FOR ALL ENTRIES IN @lt_kna1
             WHERE customer EQ @lt_kna1-kunnr
               AND ContactPersonDepartment EQ @i_abtnr
               AND ContactPersonFunction EQ @i_pafkt
              INTO TABLE @lt_knvk.
            IF sy-subrc NE 0.

              IF i_no_general IS INITIAL.
                IF lt_kna1[] IS NOT INITIAL. "Aynı VKN'ye sahip olanlar

                  IF i_remark IS NOT INITIAL.
*                    SELECT EmailAddress AS smtp_addr "YiğitcanÖzdemir2
*                      FROM I_AddressEmailAddress_2 AS a
*                     INNER JOIN i_addresscommunicationremark AS b  ON a~AddressID EQ b~addressid
*                                          AND a~AddressPersonID EQ b~person
**                                        AND a~date_from  EQ b~date_from
*                                          AND a~CommMediumSequenceNumber EQ b~ordinalnumber
*
*                       FOR ALL ENTRIES IN @lt_kna1
*                     WHERE a~AddressID EQ @lt_kna1-adrnr
*                       AND a~AddressPersonID EQ ''
*                       AND b~communicationmediumtype   EQ 'INT'
*                       AND b~addresscommunicationremarktext    EQ @i_remark
*                        INTO CORRESPONDING FIELDS OF TABLE @lt_adr6.
                  ELSE.
                    SELECT EmailAddress AS smtp_addr
                      FROM I_AddressEmailAddress_2 AS adr6
                       FOR ALL ENTRIES IN @lt_kna1
                     WHERE AddressID EQ @lt_kna1-adrnr
                       AND AddressPersonID EQ ''
                      INTO TABLE @lt_adr6.
                  ENDIF.

                  LOOP AT lt_adr6 INTO ls_adr6 WHERE smtp_addr IS NOT INITIAL.

                    IF e_mail IS INITIAL.
                      e_mail = ls_adr6-smtp_addr.
                    ENDIF.

                    ls_receivers-receiver = ls_adr6-smtp_addr.
                    ls_receivers-rec_type = 'U'.
                    APPEND ls_receivers TO t_receivers .
                    CLEAR  ls_receivers .

                  ENDLOOP.

                ELSE.

                  IF i_remark IS NOT INITIAL.
                    IF r_adrnr[] IS NOT INITIAL.
*                      SELECT SINGLE a~smtp_addr "YiğitcanÖzdemir
*                               FROM adr6 AS a
*                              INNER JOIN adrt AS b ON a~addrnumber EQ b~addrnumber
*                                                  AND a~persnumber EQ b~persnumber
*                                                  AND a~date_from  EQ b~date_from
*                                                  AND a~consnumber EQ b~consnumber
*                      WHERE a~addrnumber IN @r_adrnr
*                        AND a~persnumber EQ ''
*                        AND b~comm_type EQ 'INT'
*                        AND b~remark EQ @i_remark
*
*                       INTO @e_mail.
                    ENDIF.
                  ELSE.
                    IF r_adrnr[] IS NOT INITIAL.
                      SELECT SINGLE EmailAddress AS smtp_addr
                               FROM I_AddressEmailAddress_2 AS adr6
                              WHERE AddressID IN @r_adrnr
                                AND AddressPersonID EQ ''

                               INTO @e_mail.
                    ENDIF.
                  ENDIF.

                  IF e_mail IS NOT INITIAL.
                    ls_receivers-receiver = e_mail.
                    ls_receivers-rec_type = 'U'.
                    APPEND ls_receivers TO t_receivers .
                    CLEAR  ls_receivers .
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.

          ELSE.
            SELECT PersonNumber AS prsnr
              FROM i_contactperson AS knvk
             WHERE customer EQ @i_kunnr
               AND ContactPersonDepartment EQ @i_abtnr
               AND ContactPersonFunction EQ @i_pafkt

              INTO TABLE @lt_knvk.
          ENDIF.

          IF lt_knvk[] IS NOT INITIAL.
            IF r_adrnr[] IS NOT INITIAL.
              SELECT  EmailAddress AS smtp_addr
               FROM I_AddressEmailAddress_2 AS adr6
                FOR ALL ENTRIES IN @lt_knvk
                WHERE AddressID IN @r_adrnr
                AND AddressPersonID   EQ @lt_knvk-prsnr
                INTO TABLE @lt_adr6.
            ENDIF.

            LOOP AT lt_adr6 INTO ls_adr6 WHERE smtp_addr IS NOT INITIAL.
              IF e_mail IS INITIAL.
                e_mail = ls_adr6-smtp_addr.
              ENDIF.

              ls_receivers-receiver = ls_adr6-smtp_addr.
              ls_receivers-rec_type = 'U'.
              APPEND ls_receivers TO t_receivers .
              CLEAR  ls_receivers .

              i_no_general = 'X'.

            ENDLOOP.
          ENDIF.

        ELSE.
*endif.
* İlgili kişi yoksa genel verilerden çek
          LOOP AT lt_kna1 INTO ls_kna1.
            SELECT SINGLE COUNT(*)
                     FROM i_customercompany AS knb1
                    WHERE companycode EQ @i_bukrs
                      AND customer EQ @ls_kna1-kunnr.
            IF sy-subrc NE 0.
*            DELETE lt_kna1.
              DELETE lt_kna1 WHERE kunnr EQ ls_kna1-kunnr.
              CONTINUE.
            ENDIF.
            ls_adrnr-sign = 'I'.
            ls_adrnr-option = 'EQ'.
            ls_adrnr-low = ls_kna1-adrnr.
            APPEND ls_adrnr TO r_adrnr.
          ENDLOOP.

          IF i_no_general IS INITIAL.
            IF lt_kna1[] IS NOT INITIAL. "Aynı VKN'ye sahip olanlar

              IF i_remark IS NOT INITIAL.
*                SELECT *                   "YiğitcanÖzdemir
*                  FROM adr6 AS a
*                 INNER JOIN adrt AS b ON a~addrnumber EQ b~addrnumber
*                                     AND a~persnumber EQ b~persnumber
*                                     AND a~date_from  EQ b~date_from
*                                     AND a~consnumber EQ b~consnumber
*
*                   FOR ALL ENTRIES IN @lt_kna1
*                 WHERE a~addrnumber EQ @lt_kna1-adrnr
*                   AND a~persnumber   EQ ''
*                   AND b~comm_type EQ 'INT'
*                   AND b~remark EQ @i_remark
*                   INTO CORRESPONDING FIELDS OF TABLE @lt_adr6.
              ELSE.
                SELECT EmailAddress AS smtp_addr
                  FROM I_AddressEmailAddress_2
                   FOR ALL ENTRIES IN @lt_kna1
                 WHERE AddressID EQ @lt_kna1-adrnr
                   AND AddressPersonID   EQ ''
                  INTO TABLE @lt_adr6.
              ENDIF.

              LOOP AT lt_adr6 INTO ls_adr6 WHERE smtp_addr IS NOT INITIAL.

                IF e_mail IS INITIAL.
                  e_mail = ls_adr6-smtp_addr.
                ENDIF.

*              t_receivers-receiver = lt_adr6-smtp_addr. "YiğitcanÖzdemir2
*              t_receivers-rec_type = 'U'.
*              APPEND t_receivers .
*              CLEAR  t_receivers .
              ENDLOOP.
            ELSE.

              IF i_remark IS NOT INITIAL.
                IF r_adrnr IS NOT INITIAL.
*                  SELECT SINGLE a~smtp_addr "YiğitcanÖzdemir
*                           FROM adr6 AS a
*                          INNER JOIN adrt AS b ON a~addrnumber EQ b~addrnumber
*                                              AND a~persnumber EQ b~persnumber
*                                              AND a~date_from  EQ b~date_from
*                                              AND a~consnumber EQ b~consnumber
*
*                         WHERE a~addrnumber IN @r_adrnr
*                           AND a~persnumber EQ ''
*                           AND b~comm_type EQ 'INT'
*                           AND b~remark EQ @i_remark
*                             INTO @e_mail.
                ENDIF.
              ELSE.
                IF r_adrnr[] IS NOT INITIAL.
                  SELECT SINGLE EmailAddress AS smtp_addr FROM I_AddressEmailAddress_2 AS adr6
                  WHERE AddressID IN @r_adrnr
                   AND AddressPersonID EQ ''
                      INTO @e_mail.
                ENDIF.
              ENDIF.

              IF e_mail IS NOT INITIAL.
*              t_receivers-receiver = e_mail. "YiğitcanOzdemir2
*              t_receivers-rec_type = 'U'.
*              APPEND t_receivers .
*              CLEAR  t_receivers .
              ENDIF.

            ENDIF.
            IF e_mail IS INITIAL AND i_ucomm NE 'FAX'.
              IF r_adrnr[] IS NOT INITIAL.
                SELECT SINGLE EmailAddress AS smtp_addr FROM I_AddressEmailAddress_2 AS adr6
                WHERE AddressID IN @r_adrnr
                 AND AddressPersonID EQ ''
                    INTO @e_mail.
              ENDIF.

              IF e_mail IS NOT INITIAL.
*              t_receivers-receiver = e_mail. "YiğitcanÖzdemir
*              t_receivers-rec_type = 'U'.
*              APPEND t_receivers .
*              CLEAR  t_receivers .
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
      SORT t_receivers BY receiver.

      DELETE ADJACENT DUPLICATES FROM t_receivers COMPARING receiver.

    ENDIF.


    IF i_lifnr IS NOT INITIAL.

      CLEAR r_adrnr.

      IF i_all IS NOT INITIAL.
        SELECT SINGLE COUNT(*)
                 FROM zreco_etax
                WHERE bukrs EQ @i_bukrs
                  AND stcd2 EQ @i_stcd1.
        IF sy-subrc NE 0.
          SELECT *
            FROM zreco_taxm
           WHERE vkn_tckn EQ @i_stcd1
           INTO CORRESPONDING FIELDS OF TABLE @lt_lfa1.
        ENDIF.
      ENDIF.

      SELECT supplier AS lifnr,
             AddressID AS adrnr
        FROM i_supplier AS lfa1
       WHERE supplier EQ @i_lifnr
        APPENDING TABLE @lt_lfa1.

      DELETE lt_lfa1 WHERE lifnr IS INITIAL.

      SORT lt_lfa1 BY adrnr.

      DELETE ADJACENT DUPLICATES FROM lt_lfa1 COMPARING adrnr.

      SELECT SINGLE COUNT(*)
               FROM zreco_adrs
              WHERE bukrs EQ @i_bukrs
                AND master_data EQ @space.
      IF sy-subrc EQ 0.
        IF lt_lfa1[] IS NOT INITIAL.
          SELECT *
            FROM zreco_mast
             FOR ALL ENTRIES IN @lt_lfa1
           WHERE bukrs EQ @i_bukrs
             AND lifnr EQ @lt_lfa1-lifnr
             AND mtype IN @r_mtype
            INTO TABLE @lt_mast.
        ENDIF.
        IF lt_mast[] IS NOT INITIAL.
          LOOP AT lt_mast INTO ls_mast.

            READ TABLE lt_e003 TRANSPORTING NO FIELDS WITH KEY smtp_addr = ls_mast-smtp_addr.

            CHECK sy-subrc NE 0.

            IF e_mail IS INITIAL.
              e_mail = ls_mast-smtp_addr.
            ENDIF.

            ls_receivers-receiver = ls_mast-smtp_addr.
            ls_receivers-rec_type = 'U'.
            APPEND ls_receivers TO t_receivers .
            CLEAR  ls_receivers .

          ENDLOOP.
        ELSE.
**adrc
          LOOP AT lt_lfa1 INTO ls_lfa1.
            SELECT SINGLE COUNT(*)
                     FROM i_suppliercompany
                    WHERE companycode EQ @i_bukrs
                      AND supplier EQ @ls_lfa1-lifnr.
            IF sy-subrc NE 0.
              DELETE lt_lfa1 WHERE lifnr = ls_lfa1-lifnr.
              CONTINUE.
            ENDIF.
            ls_adrnr-sign = 'I'.
            ls_adrnr-option = 'EQ'.
            ls_adrnr-low = ls_lfa1-adrnr.
            APPEND ls_adrnr TO r_adrnr.
          ENDLOOP.

          IF lt_lfa1[] IS NOT INITIAL.


            SELECT  EmailAddress AS smtp_addr
            FROM I_AddressEmailAddress_2 AS adr6
            FOR ALL ENTRIES IN @lt_lfa1
            WHERE AddressID EQ @lt_lfa1-adrnr
            AND AddressPersonID EQ ''
            INTO TABLE @lt_adr6.
          ENDIF.

          LOOP AT lt_adr6 INTO ls_adr6 WHERE smtp_addr IS NOT INITIAL.

            IF e_mail IS INITIAL.
              e_mail = ls_adr6-smtp_addr.
            ENDIF.

            ls_receivers-receiver = ls_adr6-smtp_addr.
            ls_receivers-rec_type = 'U'.
            APPEND ls_receivers TO t_receivers .
            CLEAR  ls_receivers .

          ENDLOOP.
        ENDIF.
      ELSE.

*İlgili kişiden verileri çek
        IF i_abtnr IS NOT INITIAL.
          IF lt_lfa1[] IS NOT INITIAL.

            LOOP AT lt_lfa1 INTO ls_lfa1.
              SELECT SINGLE COUNT(*)
                       FROM i_suppliercompany
                      WHERE companycode EQ @i_bukrs
                       AND supplier EQ @ls_lfa1-lifnr.
              IF sy-subrc NE 0.
                DELETE lt_lfa1 WHERE lifnr = ls_lfa1-lifnr.
                CONTINUE.
              ENDIF.
              ls_adrnr-sign = 'I'.
              ls_adrnr-option = 'EQ'.
              ls_adrnr-low = ls_lfa1-adrnr.
              APPEND ls_adrnr TO r_adrnr.
            ENDLOOP.

            CHECK lt_lfa1[] IS NOT INITIAL.

            SELECT personnumber AS prsnr
              FROM i_contactperson
               FOR ALL ENTRIES IN @lt_lfa1
             WHERE supplier EQ @lt_lfa1-lifnr
               AND ContactPersonDepartment EQ @i_abtnr
               AND ContactPersonFunction EQ @i_pafkt
              INTO TABLE @lt_knvk.

            IF sy-subrc NE 0.
              IF i_no_general IS INITIAL.
                IF lt_lfa1[] IS NOT INITIAL. "Aynı VKN'ye sahip olanlar

                  IF i_remark IS NOT INITIAL.
*                    SELECT *
*                      FROM adr6 AS a
*                     INNER JOIN adrt AS b ON a~addrnumber EQ b~addrnumber
*                                         AND a~persnumber EQ b~persnumber
*                                         AND a~date_from  EQ b~date_from
*                                         AND a~consnumber EQ b~consnumber
*                      INTO CORRESPONDING FIELDS OF TABLE lt_adr6
*                       FOR ALL ENTRIES IN lt_lfa1
*                     WHERE a~addrnumber EQ lt_lfa1-adrnr
*                       AND a~persnumber   EQ ''
*                       AND b~comm_type EQ 'INT'
*                       AND b~remark EQ i_remark.
                  ELSE.
                    SELECT EmailAddress AS smtp_addr
                      FROM I_AddressEmailAddress_2 AS adr6
                       FOR ALL ENTRIES IN @lt_lfa1
                     WHERE AddressID EQ @lt_lfa1-adrnr
                       AND AddressPersonID   EQ ''
                      INTO TABLE @lt_adr6.
                  ENDIF.

                  LOOP AT lt_adr6 INTO ls_adr6 WHERE smtp_addr IS NOT INITIAL.

                    IF e_mail IS INITIAL.
                      e_mail = ls_adr6-smtp_addr.
                    ENDIF.

                    ls_receivers-receiver = ls_adr6-smtp_addr.
                    ls_receivers-rec_type = 'U'.
                    APPEND ls_receivers TO t_receivers .
                    CLEAR  ls_receivers .
                  ENDLOOP.
                ELSE.
                  IF i_remark IS NOT INITIAL.
                    IF r_adrnr[] IS NOT INITIAL.
*                      SELECT SINGLE a~smtp_addr
*                               FROM adr6 AS a
*                         INNER JOIN adrt AS b ON a~addrnumber EQ b~addrnumber
*                                             AND a~persnumber EQ b~persnumber
*                                             AND a~date_from  EQ b~date_from
*                                             AND a~consnumber EQ b~consnumber
*                               INTO e_mail
*                              WHERE a~addrnumber IN r_adrnr
*                                AND a~persnumber EQ ''
*                                AND b~comm_type EQ 'INT'
*                                AND b~remark EQ i_remark.
                    ENDIF.
                  ELSE.
                    IF r_adrnr[] IS NOT INITIAL.
                      SELECT SINGLE EmailAddress AS smtp_addr
                               FROM I_AddressEmailAddress_2 AS adr6

                              WHERE AddressID IN @r_adrnr
                                AND AddressPersonID EQ ''
                                 INTO @e_mail.
                    ENDIF.
                  ENDIF.

                  IF e_mail IS NOT INITIAL.
                    ls_receivers-receiver = e_mail.
                    ls_receivers-rec_type = 'U'.
                    APPEND ls_receivers TO t_receivers .
                    CLEAR  ls_receivers .
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ELSE.


            SELECT personnumber AS prsnr
              FROM i_contactperson
             WHERE supplier EQ @i_lifnr
               AND ContactPersonDepartment EQ @i_abtnr
               AND ContactPersonFunction EQ @i_pafkt
              INTO TABLE @lt_knvk.

          ENDIF.

          IF lt_knvk[] IS NOT INITIAL.

            IF r_adrnr[] IS NOT INITIAL.
              SELECT EmailAddress AS smtp_addr
                FROM I_AddressEmailAddress_2 AS adr6

                 FOR ALL ENTRIES IN @lt_knvk
               WHERE AddressID IN @r_adrnr
                 AND AddressPersonID   EQ @lt_knvk-prsnr
                 INTO TABLE @lt_adr6.



            ENDIF.

            LOOP AT lt_adr6 INTO ls_adr6 WHERE smtp_addr IS NOT INITIAL.

              IF e_mail IS INITIAL.
                e_mail = ls_adr6-smtp_addr.
              ENDIF.

              ls_receivers-receiver = ls_adr6-smtp_addr.
              ls_receivers-rec_type = 'U'.
              APPEND ls_receivers TO  t_receivers .
              CLEAR  t_receivers .

              i_no_general = 'X'.

            ENDLOOP.
          ENDIF.
        ELSE.

          LOOP AT lt_lfa1 INTO ls_lfa1.
            SELECT SINGLE COUNT(*)
                     FROM i_suppliercompany AS lfb1
                    WHERE companycode EQ @i_bukrs
                      AND supplier EQ @ls_lfa1-lifnr.
            IF sy-subrc NE 0.
              DELETE lt_lfa1 WHERE lifnr = ls_lfa1-lifnr.
              CONTINUE.
            ENDIF.
            ls_adrnr-sign = 'I'.
            ls_adrnr-option = 'EQ'.
            ls_adrnr-low = ls_lfa1-adrnr.
            APPEND ls_adrnr TO r_adrnr.
          ENDLOOP.

* İlgili kişi yoksa genel verilerden çek
          IF i_no_general IS INITIAL.

            IF lt_lfa1[] IS NOT INITIAL. "Aynı VKN'ye sahip olanlar

              IF i_remark IS NOT INITIAL.
*                SELECT *
*                  FROM adr6 AS a
*                 INNER JOIN adrt AS b ON a~addrnumber EQ b~addrnumber
*                                     AND a~persnumber EQ b~persnumber
*                                     AND a~date_from  EQ b~date_from
*                                     AND a~consnumber EQ b~consnumber
*                  INTO CORRESPONDING FIELDS OF TABLE lt_adr6
*                   FOR ALL ENTRIES IN lt_lfa1
*                 WHERE a~addrnumber EQ lt_lfa1-adrnr
*                   AND a~persnumber EQ ''
*                   AND b~comm_type EQ 'INT'
*                   AND b~remark EQ i_remark.
              ELSE.
                SELECT EmailAddress AS smtp_Addr
                  FROM I_AddressEmailAddress_2 AS adr6
                   FOR ALL ENTRIES IN @lt_lfa1
                 WHERE AddressID EQ @lt_lfa1-adrnr
                   AND AddressPersonID EQ ''
                 INTO TABLE @lt_adr6.
              ENDIF.

              LOOP AT lt_adr6 INTO ls_adr6 WHERE smtp_addr IS NOT INITIAL.
                IF e_mail IS INITIAL.
                  e_mail = ls_adr6-smtp_addr.
                ENDIF.

                ls_receivers-receiver = ls_adr6-smtp_addr.
                ls_receivers-rec_type = 'U'.
                APPEND ls_receivers TO t_receivers .
                CLEAR  ls_receivers .
              ENDLOOP.

            ELSE.

              IF i_remark IS NOT INITIAL.
                IF r_adrnr[] IS NOT INITIAL.
*                  SELECT SINGLE a~smtp_addr
*                           FROM adr6 AS a
*                          INNER JOIN adrt AS b ON a~addrnumber EQ b~addrnumber
*                                              AND a~persnumber EQ b~persnumber
*                                              AND a~date_from  EQ b~date_from
*                                              AND a~consnumber EQ b~consnumber
*                           INTO e_mail
*                          WHERE a~addrnumber IN r_adrnr
*                            AND a~persnumber EQ ''
*                            AND b~comm_type EQ 'INT'
*                            AND b~remark EQ i_remark.
                ENDIF.
              ELSE.
                IF r_adrnr[] IS NOT INITIAL.
                  SELECT SINGLE EmailAddress AS smtp_addr
                           FROM I_AddressEmailAddress_2 AS adr6
                          WHERE AddressID IN @r_adrnr
                            AND AddressPersonID EQ ''
                             INTO @e_mail.
                ENDIF.
              ENDIF.

              IF e_mail IS NOT INITIAL.
                ls_receivers-receiver = e_mail.
                ls_receivers-rec_type = 'U'.
                APPEND ls_receivers TO t_receivers .
                CLEAR  ls_receivers .
              ENDIF.
            ENDIF.
            IF e_mail IS INITIAL.

              IF i_remark IS NOT INITIAL.
                IF r_adrnr[] IS NOT INITIAL.
*                  SELECT SINGLE a~smtp_addr
*                           FROM adr6 AS a
*                          INNER JOIN adrt AS b ON a~addrnumber EQ b~addrnumber
*                                              AND a~persnumber EQ b~persnumber
*                                              AND a~date_from  EQ b~date_from
*                                              AND a~consnumber EQ b~consnumber
*                          INTO e_mail
*                         WHERE a~addrnumber IN r_adrnr
*                           AND a~persnumber EQ ''
*                           AND b~comm_type EQ 'INT'
*                           AND b~remark EQ i_remark.
                ENDIF.
              ELSE.
                IF r_adrnr[] IS NOT INITIAL.
                  SELECT SINGLE EmailAddress AS smtp_addr
                           FROM I_AddressEmailAddress_2 AS adr6
                          WHERE AddressID IN @r_adrnr
                            AND AddressPersonID EQ ''
                   INTO @e_mail.
                ENDIF.
              ENDIF.

              IF e_mail IS NOT INITIAL.
                ls_receivers-receiver = e_mail.
                ls_receivers-rec_type = 'U'.
                APPEND ls_receivers TO t_receivers .
                CLEAR  ls_receivers .
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      SORT t_receivers BY receiver.

      DELETE ADJACENT DUPLICATES FROM t_receivers COMPARING receiver.

    ENDIF.

    DATA lt_receivers TYPE STANDARD TABLE OF zreco_somlreci1.

*    CALL FUNCTION '/ITETR/RECO_EXIT_013'
*      EXPORTING
*        i_bukrs      = i_bukrs
*        i_ucomm      = i_ucomm
*        i_kunnr      = i_kunnr
*        i_lifnr      = i_lifnr
*        i_abtnr      = i_abtnr
*        i_pafkt      = i_pafkt
*        i_remark     = i_remark
*        i_all        = i_all
*        i_stcd1      = i_stcd1
*        i_no_general = i_no_general
*      TABLES
*        t_receivers  = lt_receivers.

    IF lt_receivers[] IS NOT INITIAL.
      APPEND LINES OF lt_receivers TO t_receivers.
    ENDIF.

    LOOP AT t_receivers INTO ls_receivers.
      READ TABLE lt_e003 TRANSPORTING NO FIELDS  WITH KEY smtp_addr = ls_receivers-receiver.
      IF sy-subrc EQ 0.
        DELETE t_receivers .
      ENDIF.
    ENDLOOP.

    IF e_mail IS NOT INITIAL.
      READ TABLE lt_e003 TRANSPORTING NO FIELDS WITH KEY smtp_addr = e_mail.
      IF sy-subrc EQ 0.
        CLEAR e_mail.
      ENDIF.
    ENDIF.

    """""""""""""""""""YiğitcanÖzdemir""""""""""""""""""


    DATA lv_addressid TYPE c LENGTH 10.

    IF i_kunnr IS NOT INITIAL.

      SELECT SINGLE IndependentAddressID
            FROM i_businesspartner
           WHERE businesspartner EQ @i_kunnr
            INTO @lv_addressid.
*

    ELSEIF i_lifnr IS NOT INITIAL.

      SELECT SINGLE IndependentAddressID
            FROM i_businesspartner
           WHERE businesspartner EQ @i_lifnr
            INTO @lv_addressid.
    ENDIF.


    TRY.
        "create http destination by url; API endpoint for API sandbox
        DATA(lo_http_destination) =
             cl_http_destination_provider=>create_by_url( 'https://my404671-api.s4hana.cloud.sap:443/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_AddressEmailAddress?$select=EmailAddress&$inlinecount=allpages&$top=50' ).
        "alternatively create HTTP destination via destination service
        "cl_http_destination_provider=>create_by_cloud_destination( i_name = '<...>'
        "                            i_service_instance_name = '<...>' )
        "SAP Help: https://help.sap.com/viewer/65de2977205c403bbc107264b8eccf4b/Cloud/en-US/f871712b816943b0ab5e04b60799e518.html

        "create HTTP client by destination
        DATA(lo_web_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

        "adding headers
        DATA(lo_web_http_request) = lo_web_http_client->get_http_request( ).

        DATA(filter) = 'AddressID eq ' && |' { lv_addressid } '|.

        lo_web_http_request->set_form_field(
          EXPORTING
            i_name  = '$filter'
            i_value = filter
        ).

        lo_web_http_request->set_authorization_basic(
      EXPORTING
        i_username = CONV #( 'ozdemiryigit' )
        i_password = CONV #( 'TvczWnffohRvem%WaTXFNqJiEPGcMeWyMyjbuv3Y' )
    ).

        lo_web_http_request->set_header_fields( VALUE #(
*        (  name = 'Authorization' value = 'Basic b3pkZW1pcnlpZ2l0OlR2Y3pXbmZmb2hSdmVtJVdhVFhGTnFKaUVQR2NNZVd5TXlqYnV2M1k=' )
        (  name = 'DataServiceVersion' value = '2.0' )
        (  name = 'Accept' value = 'application/json' )
         ) ).
        "set request method and execute request
        DATA(lo_web_http_response) = lo_web_http_client->execute( if_web_http_client=>get ).
        DATA(lv_response) = lo_web_http_response->get_text( ).

      CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error.
        "error handling
    ENDTRY.

    "uncomment the following line for console output; prerequisite: code snippet is implementation of if_oo_adt_classrun~main
    "out->write( |response:  { lv_response }| ).

*    zinf_regulative_common=>parse_xml(
*          EXPORTING
*            iv_xml_string = lv_response
*          RECEIVING
*            rt_data       = DATA(lt_response_service)
*        ).
*
*    LOOP AT lt_response_service INTO DATA(ls_resp).
*      CASE ls_resp-name .
*        WHEN 'EmailAddress'.
*          e_mail = ls_resp-value.
*      ENDCASE.
*    ENDLOOP.

  ENDMETHOD.