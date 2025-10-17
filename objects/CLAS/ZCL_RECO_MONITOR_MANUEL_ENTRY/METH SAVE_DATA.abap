  METHOD save_data.

    DATA: lv_no_update TYPE flag,
          ls_rand      TYPE zreco_rand,
          lv_name1     TYPE name1_gp,
          lv_name2     TYPE name2_gp.

    me->number_get(
      EXPORTING
        iv_bukrs  = service_data-bukrs
        iv_gjahr  = service_data-gjahr
      IMPORTING
        ev_number = DATA(snro_number)
    ).


    SELECT SINGLE * FROM zreco_adrs
            WHERE bukrs EQ @service_data-bukrs
            INTO @DATA(ls_adrs).

    CASE service_data-hesap_tur.
      WHEN 'M'.

        mo_common->tax_info(
          EXPORTING
            i_bukrs      = service_data-bukrs
            i_kunnr      = CONV #( service_data-hesap_no )
            i_number     = 'X'
            i_office     = 'X'
          IMPORTING
            e_tax_office = ms_h001-vd
            e_tax_number = ms_h001-vkn_tckn
*           e_ktokl      =
        ).

        SELECT SINGLE OrganizationBPName1, OrganizationBPName2, Language, Supplier, CustomerAccountGroup, AddressID FROM i_customer
                WHERE customer EQ @service_data-hesap_no
                 INTO (@lv_name1, @lv_name2, @ms_h001-spras, @ms_h001-lifnr, @ms_h001-ktokl, @ms_h001-adrnr).

        ms_h001-kunnr = service_data-hesap_no.

        ms_h001-name1 = lv_name1 && | | && lv_name2.

      WHEN 'S'.

        mo_common->tax_info(
          EXPORTING
            i_bukrs      = service_data-bukrs
            i_lifnr      = CONV #( service_data-hesap_no )
            i_number     = 'X'
            i_office     = 'X'
          IMPORTING
            e_tax_office = ms_h001-vd
            e_tax_number = ms_h001-vkn_tckn
*           e_ktokl      =
        ).

        SELECT SINGLE OrganizationBPName1, OrganizationBPName2, SupplierLanguage, Customer, SupplierAccountGroup, AddressID FROM i_supplier
                 WHERE Supplier EQ @service_data-hesap_no
                  INTO (@lv_name1, @lv_name2, @ms_h001-spras, @ms_h001-kunnr, @ms_h001-ktokl, @ms_h001-adrnr).

        ms_h001-lifnr = service_data-hesap_no.

    ENDCASE.

    IF service_data-spras IS NOT INITIAL.
      ms_h001-spras = service_data-spras.
    ENDIF.


    MOVE-CORRESPONDING ls_adrs TO ms_h001.

    ms_h001-manuel  = 'X'.
    ms_h001-mnumber = snro_number.                  "YiğitcanÖzdemir
    MOVE-CORRESPONDING service_data TO ms_h001.     "YiğitcanÖzdemir
    ms_h001-mnumber = snro_number.                  "YiğitcanÖzdemir
    ms_h001-xstatu = 'X'.                           "YiğitcanÖzdemir
    MOVE-CORRESPONDING ms_h001 TO ms_v001.

    ms_v001-version = mv_version = 1.
    ms_v001-vstatu = 'G'.
    ms_v001-ernam = sy-uname.
    ms_v001-erdat = sy-datum.
    ms_v001-erzei = sy-uzeit.


    MOVE-CORRESPONDING service_data TO ms_h002.
    MOVE-CORRESPONDING ms_v001      TO ms_h002.

    MOVE-CORRESPONDING ms_v001 TO ms_r000.


    CASE service_data-is_agree.
      WHEN '0'.
        mv_wait = abap_true.
      WHEN '1'.
        mv_no = abap_true.
      WHEN '2'.
        mv_no_data = abap_true.
      WHEN '3'.
        mv_wait = abap_true.
    ENDCASE.


    IF mv_wait IS NOT INITIAL.
      CLEAR ms_r000-mresult.
    ELSE.

      IF mv_yes IS NOT INITIAL.
        ms_r000-mresult = 'E'.
      ENDIF.

      IF mv_no IS NOT INITIAL.
        ms_r000-mresult = 'H'.
      ENDIF.

      IF mv_no_data IS NOT INITIAL.
        ms_r000-mresult = 'T'.
      ENDIF.
    ENDIF.


    Ms_r000-mtext = service_data-reco_mtext.                                                  "YiğitcanÖzdemir

    IF mv_wait IS INITIAL.
      ms_h001-xstatu = 'X'.
    ENDIF.


    INSERT zreco_hdr FROM @ms_h001.

    IF lv_no_update IS INITIAL.
      INSERT zreco_hia FROM @ms_h002.
    ENDIF.


* Cari mutabakat şirket bilgileri
    LOOP AT service_data-liste INTO DATA(ls_liste).                              "YiğitcanÖzdemir


      CLEAR ms_c001.

      MOVE-CORRESPONDING ms_h001 TO ms_c001.
      MOVE-CORRESPONDING ms_v001 TO ms_c001.
      MOVE-CORRESPONDING ls_liste TO ms_c001.

      ms_c001-dmbtr = ls_liste-wrbtr.

*      SELECT SINGLE xsum FROM zreco_mtxt
*        WHERE ltext EQ @ms_c001-ltext
*        AND xsum EQ 'X' "Bakiyeye dahil öncelikli
*        INTO @ms_c001-xsum.

      ms_c001-xsum = 'X'. "YiğitcanÖzdemir


      APPEND ms_c001 TO mt_c001.




      CLEAR ms_r001.

      MOVE-CORRESPONDING ms_h001 TO ms_r001.
      MOVE-CORRESPONDING ms_v001 TO ms_r001.
      MOVE-CORRESPONDING ls_liste TO ms_r001.

*    SELECT SINGLE xsum FROM /itetr/reco_mtxt
*      INTO gs_r001-xsum
*      WHERE spras EQ u_out-spras
*      AND ltext EQ gs_r001-ltext
*      AND xsum EQ 'X'. "Bakiyeye dahil öncelikli
      ms_r001-xsum = 'X'. "YiğitcanÖzdemir
      APPEND ms_r001 TO mt_r001.

    ENDLOOP.

    INSERT zreco_vers FROM @ms_v001.
    INSERT zreco_reia FROM @ms_r000.
    INSERT zreco_rcar FROM TABLE @mt_r001.
    INSERT zreco_rbia FROM @ms_r002.
    INSERT zreco_recb FROM @ms_b001.
    INSERT zreco_rcai FROM TABLE @mt_c001.
    INSERT zreco_c002 FROM TABLE @mt_c002.
    INSERT zreco_c003 FROM TABLE @mt_c003.

    DATA mnumber TYPE zreco_number.
    DATA version TYPE zreco_version.

    version = 1.
*    mnumber = snro_number.                     "YiğitcanÖzdemir @zreco_vers i statuyu I olarak değiştirildi bi bak buraya

    UPDATE zreco_vers SET vstatu = 'I'
     WHERE bukrs   EQ @service_data-bukrs
*       AND gsber   EQ u_out-gsber
       AND mnumber EQ @mnumber
       AND monat   EQ @service_data-monat
       AND gjahr   EQ @service_data-gjahr
       AND version EQ @version
       AND vstatu  EQ 'G'.

    IF mv_wait IS INITIAL.
*      DELETE FROM zreco_rand WHERE mnumber   EQ @u_out-mnumber.
**                              AND randomkey EQ u_out-randomkey.
    ELSE.
      " bu kısım kontrol edilmeli. gereksiz görünüyor.
*      ls_rand-bukrs = p_bukrs.
*      ls_rand-mnumber = gs_h001-mnumber.
*      ls_rand-randomkey = gs_h001-randomkey.
*      ls_rand-datum = sy-datum.
*      ls_rand-uzeit = sy-uzeit.
*
*      MODIFY /itetr/reco_rand FROM ls_rand.
    ENDIF.

    MESSAGE s081(zreco) WITH snro_number version INTO ev_message.
  ENDMETHOD.