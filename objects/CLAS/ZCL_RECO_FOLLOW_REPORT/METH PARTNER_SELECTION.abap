  METHOD partner_selection.

    TYPES: BEGIN OF lty_tur ,
             hesap_tur TYPE zreco_account_type,
           END OF lty_tur.

    DATA: lt_tur TYPE TABLE OF   lty_tur,
          ls_tur TYPE lty_tur.

    DATA: lt_knb1 TYPE TABLE OF i_customercompany,
          lt_lfb1 TYPE TABLE OF i_suppliercompany,
          lt_kna1 TYPE TABLE OF i_customer,
          lt_lfa1 TYPE TABLE OF i_supplier,
          ls_lfa1 TYPE i_supplier,
          lt_dpar TYPE TABLE OF zreco_dpar,
          lt_kpar TYPE TABLE OF zreco_kpar.

    DATA: gt_adrs      TYPE TABLE OF zreco_adrs,
          gs_adrs      TYPE zreco_adrs,
          gs_tpar      TYPE i_partnerfunction,
          gv_partner   TYPE abap_boolean,
          gt_exch_rate TYPE TABLE OF zreco_bapi1093_0,
          gs_exch_rate TYPE zreco_bapi1093_0.


* Muhataplar için
    TYPES: BEGIN OF ty_kunnr,
             kunnr TYPE i_custsalespartnerfunc-customer,
             kunn2 TYPE i_custsalespartnerfunc-BPCustomerNumber,
             lifnr TYPE lifnr,
           END OF ty_kunnr.

    TYPES: BEGIN OF ty_lifnr,
             lifnr TYPE lifnr,
             lifn2 TYPE i_supplier-Supplier,
           END OF ty_lifnr.

    DATA: gt_knvp TYPE TABLE OF ty_kunnr,

          gt_wyt3 TYPE SORTED TABLE OF ty_lifnr
                    WITH NON-UNIQUE KEY lifnr .

    LOOP AT lt_tur ASSIGNING FIELD-SYMBOL(<lfs_tur>).
      <lfs_tur>-hesap_tur = 'M'.
    ENDLOOP.


    LOOP AT lt_tur ASSIGNING FIELD-SYMBOL(<lfs_tur_2>) WHERE hesap_tur IN it_ktonr_av.
      EXIT.
    ENDLOOP.

    IF sy-subrc EQ 0.

      SELECT * FROM zreco_dpar
      WHERE bukrs EQ @iv_bukrs
      INTO TABLE @lt_dpar.

      IF sy-subrc EQ 0.

        gv_partner = 'X'.

        LOOP AT lt_dpar INTO DATA(ls_dpar).
          SELECT SINGLE * FROM i_partnerfunction
          WHERE PartnerFunction EQ @ls_dpar-parvw
          INTO @gs_tpar.
          EXIT.
        ENDLOOP.


        CASE gs_tpar-SDDocumentPartnerType.
          WHEN 'LI'.
            SELECT Customer AS kunnr,
                   BPCustomerNumber AS kunn2,
                   Supplier AS lifnr
              FROM i_custsalespartnerfunc AS knvp
              FOR ALL ENTRIES IN @lt_dpar
              WHERE Customer IN @it_ktonr_av
              AND SalesOrganization EQ @lt_dpar-vkorg
              AND DistributionChannel EQ @lt_dpar-vtweg
              AND Division EQ @lt_dpar-spart
              AND PartnerFunction EQ @lt_dpar-parvw
*              AND lifnr IN s_dparw.                                                    D_MBAYEL
             INTO CORRESPONDING FIELDS OF TABLE @gt_knvp.

            IF sy-subrc EQ 0.
              SELECT * FROM i_supplier
                FOR ALL ENTRIES IN @gt_knvp
                WHERE supplier EQ @gt_knvp-lifnr
                INTO TABLE @lt_lfa1.
            ENDIF.
          WHEN OTHERS.
            SELECT Customer AS kunnr,
                   BPCustomerNumber AS kunn2,
                   Supplier AS lifnr
              FROM i_custsalespartnerfunc AS knvp
              FOR ALL ENTRIES IN @lt_dpar
              WHERE Customer IN @it_ktonr_av
              AND SalesOrganization EQ @lt_dpar-vkorg
              AND DistributionChannel EQ @lt_dpar-vtweg
              AND Division EQ @lt_dpar-spart
              AND PartnerFunction EQ @lt_dpar-parvw
*              AND kunn2 IN s_dparw.          ??
              INTO CORRESPONDING FIELDS OF TABLE @gt_knvp.
            IF sy-subrc EQ 0.
              SELECT * FROM i_customer
                FOR ALL ENTRIES IN @gt_knvp
                WHERE customer EQ @gt_knvp-kunn2
                INTO TABLE @lt_kna1.
            ENDIF.

        ENDCASE.

        LOOP AT gt_knvp ASSIGNING FIELD-SYMBOL(<lfs_knvp>).
          CLEAR: r_hspno, gt_business.
          APPEND VALUE #( sign   = 'I'
                          option = 'EQ'
                          low    = <lfs_knvp>-kunnr ) TO r_hspno.


          CASE gs_tpar-SDDocumentPartnerType.
            WHEN 'LI'.
              gs_business-partner = <lfs_knvp>-lifnr.
              READ TABLE lt_lfa1 ASSIGNING FIELD-SYMBOL(<lfs_lfa1>) WITH KEY  Supplier = <lfs_knvp>-lifnr.
              CONCATENATE <lfs_lfa1>-OrganizationBPName1     <lfs_lfa1>-OrganizationBPName2
              INTO gs_business-name SEPARATED BY space.
            WHEN OTHERS.
              gs_business-partner = <lfs_knvp>-kunn2.
              READ TABLE lt_kna1 ASSIGNING FIELD-SYMBOL(<lfs_kna1>) WITH KEY Customer = <lfs_knvp>-kunn2.
              CONCATENATE <lfs_kna1>-OrganizationBPName1 <lfs_kna1>-OrganizationBPName2
              INTO gs_business-name SEPARATED BY space.
          ENDCASE.
          gs_business-hesap_tur = 'M'.
          gs_business-hesap_no = <lfs_knvp>-kunnr.
          APPEND gs_business TO gt_business .
        ENDLOOP.


        IF sy-subrc EQ 0.
          IF it_account_type[] IS INITIAL.
            APPEND VALUE #( sign   = 'I'
                            option = 'EQ'
                            low    = 'M'
                           ) TO r_hstur.
          ENDIF.
        ELSE.
          APPEND VALUE #(  sign   = 'I'
                           option = 'EQ'
                           low    = 'M'
                           ) TO r_hstur.
          APPEND VALUE #( sign   = 'I'
                          option = 'EQ'
                          low    = ''
                         ) TO r_hspno.
        ENDIF.

      ELSE.

        IF it_account_type[] IS NOT INITIAL.

          SELECT * FROM i_customercompany AS knb1
            WHERE CompanyCode EQ @iv_bukrs
            AND Customer IN @it_account_type
             INTO TABLE @lt_knb1.

          LOOP AT lt_knb1 ASSIGNING FIELD-SYMBOL(<lfs_knb1>).
            CLEAR: r_hspno.
            APPEND VALUE #( sign = 'I'
                           option = 'EQ'
                           low    = <lfs_knb1>-Customer
                           ) TO r_hspno.
          ENDLOOP.

          IF sy-subrc EQ 0.
            APPEND VALUE #( sign = 'I'
                          option = 'EQ'
                          low    = 'M'
                          ) TO r_hstur.

          ENDIF.

        ELSE.
          APPEND VALUE #( sign = 'I'
                    option = 'EQ'
                    low    = 'M'
                    ) TO r_hstur.


          APPEND VALUE #( sign = 'I'
                        option = 'CP'
                        low    = '*'
                        ) TO r_hspno.



        ENDIF.

      ENDIF.

    ENDIF.

    CLEAR lt_tur[].

    ls_tur-hesap_tur = 'S'.
    APPEND ls_tur TO lt_tur.

    LOOP AT lt_tur INTO ls_tur WHERE hesap_tur IN it_account_type.
      EXIT.
    ENDLOOP.

    IF sy-subrc EQ 0.

      SELECT * FROM zreco_kpar
        WHERE bukrs EQ @iv_bukrs
        INTO TABLE @lt_kpar.

      IF sy-subrc EQ 0.

        gv_partner = 'X'.

*          SELECT lifnr,
*                 lifn2
*            FROM wyt3
*            FOR ALL ENTRIES IN @lt_kpar
*            WHERE lifnr IN @it_account_type
*            AND ekorg EQ @lt_kpar-ekorg
*            AND parvw EQ @lt_kpar-parvw
**        AND lifn2 IN s_kparw                                                            D_MBAYEL
*            INTO CORRESPONDING FIELDS OF TABLE @gt_wyt3.
*
        IF sy-subrc EQ 0.
          SELECT * FROM i_supplier  AS lfa1
            FOR ALL ENTRIES IN @gt_wyt3
            WHERE Supplier EQ @gt_wyt3-lifn2
            INTO TABLE @lt_lfa1.
        ENDIF.

        LOOP AT gt_wyt3 ASSIGNING FIELD-SYMBOL(<lfs_wyt3>).
          CLEAR: r_hspno, gt_business.

          APPEND VALUE #( sign = 'I'
                          option = 'EQ'
                           low   = <lfs_wyt3>-lifnr ) TO r_hspno.


          gs_business-partner = <lfs_wyt3>-lifn2.

          READ TABLE lt_lfa1 ASSIGNING <lfs_lfa1> WITH KEY Supplier = <lfs_wyt3>-lifn2.
          CONCATENATE ls_lfa1-OrganizationBPName1 ls_lfa1-OrganizationBPName2
          INTO gs_business-name SEPARATED BY space.

          gs_business-hesap_tur = 'S'.
          gs_business-hesap_no = <lfs_wyt3>-lifnr.
          APPEND gs_business TO gt_business.
        ENDLOOP.
        IF sy-subrc EQ 0.
          IF it_account_type[] IS INITIAL.
            APPEND VALUE #( sign = 'I'
                            option = 'EQ'
                            low    = 'S'
                            ) TO r_hstur.
          ENDIF.
        ELSE.
          APPEND VALUE #( sign = 'I'
                  option = 'EQ'
                  low    = 'S'
                         ) TO r_hstur.
          APPEND VALUE #( sign = 'I'
                          option = 'EQ'
                          low    = ''
                         ) TO r_hspno.
        ENDIF.

      ELSE.

        IF it_account_type[] IS NOT INITIAL.

          SELECT * FROM i_suppliercompany AS lfb1
            WHERE CompanyCode EQ @iv_bukrs
            AND Supplier IN @it_account_type
            INTO TABLE @lt_lfb1.
*
          LOOP AT lt_lfb1 ASSIGNING FIELD-SYMBOL(<lfs_lfb1>).
            CLEAR: r_hspno.
            APPEND VALUE #( sign = 'I'
                  option = 'EQ'
                  low    = <lfs_lfb1>-Supplier
                  ) TO r_hspno.
          ENDLOOP.

          IF sy-subrc EQ 0.
            APPEND VALUE #( sign = 'I'
          option = 'EQ'
          low    = 'S'
                 ) TO r_hstur.
          ENDIF.
*
        ELSE.
          APPEND VALUE #( sign = 'I'
                  option = 'EQ'
                  low    = 'S'
                         ) TO r_hstur.

          APPEND VALUE #( sign   = 'I'
                          option = 'EQ'
                          low    = 'S'
                        ) TO r_hspno.


        ENDIF.

      ENDIF.

    ENDIF.
  ENDMETHOD.