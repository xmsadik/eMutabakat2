  METHOD tax_info.
    TYPES: BEGIN OF ty_adrs,
             bukrs      TYPE bukrs,
             tax_office TYPE zreco_taxof,
             tax_number TYPE zreco_taxno,
             tax_person TYPE zreco_taxno,
           END OF ty_adrs.

*    TYPES: BEGIN OF ty_kna1,
*             stcd1 TYPE  stcd1,
*             stcd2 TYPE  stcd2,
*             stcd3 TYPE  stcd3,
*             stcd4 TYPE  stcd4,
*             fiskn TYPE  fiskn_d,
*             stceg TYPE  stceg,
*             ktokd TYPE  ktokd,
*           END OF ty_kna1.
*
*    TYPES: BEGIN OF ty_lfa1,
*             stcd1 TYPE  stcd1,
*             stcd2 TYPE  stcd2,
*             stcd3 TYPE  stcd3,
*             stcd4 TYPE  stcd4,
*             fiskn TYPE  fiskn_d,
*             stceg TYPE  stceg,
*             ktokk TYPE  ktokk,
*           END OF ty_lfa1.

    DATA : ls_adrs TYPE  ty_adrs.
*           ls_kna1 TYPE  ty_kna1,
*           ls_lfa1 TYPE ty_lfa1.

    DATA: lv_len TYPE i.


    SELECT SINGLE bukrs,tax_office,tax_number,tax_person
        FROM zreco_adrs
       WHERE bukrs EQ @i_bukrs
        INTO @ls_adrs.


    IF i_kunnr IS NOT INITIAL.
      SELECT SINGLE TaxNumber1, TaxNumber2, TaxNumber3, TaxNumber4, FiscalAddress, VATRegistration, CustomerAccountGroup
               FROM i_customer
              WHERE Customer EQ @i_kunnr
              INTO @DATA(ls_customer).


      IF i_office IS NOT INITIAL.
        CASE ls_adrs-tax_office.
          WHEN 'STCD1'.
            e_tax_office = ls_customer-TaxNumber1.
          WHEN 'STCD2'.
            e_tax_office = ls_customer-TaxNumber2.
          WHEN 'STCD3'.
            e_tax_office = ls_customer-TaxNumber3.
          WHEN 'STCD4'.
            e_tax_office = ls_customer-TaxNumber4.
          WHEN 'FISKN'.
            SELECT SINGLE OrganizationBPName1
                     FROM i_customer
                    WHERE Customer EQ @ls_customer-FiscalAddress
                    INTO @e_tax_office.
          WHEN 'STCEG'.
            e_tax_office = ls_customer-VATRegistration.
        ENDCASE.
      ENDIF.


      "- begin
      IF i_number IS NOT INITIAL.

        CASE ls_adrs-tax_number.
          WHEN 'STCD1'.
            e_tax_number = ls_customer-TaxNumber1.
          WHEN 'STCD2'.
            e_tax_number = ls_customer-TaxNumber2.
          WHEN 'STCD3'.
            e_tax_number = ls_customer-TaxNumber3.
          WHEN 'STCD4'.
            e_tax_number = ls_customer-TaxNumber4.
          WHEN 'FISKN'.

            SELECT SINGLE OrganizationBPName1
                     FROM i_customer
                    WHERE Customer EQ @ls_customer-FiscalAddress
                    INTO @e_tax_number.
          WHEN 'STCEG'.
            e_tax_number = ls_customer-VATRegistration.
        ENDCASE.

        CASE ls_adrs-tax_person.
          WHEN 'STCD1'.
            IF ls_customer-TaxNumber1 IS NOT INITIAL.

              lv_len = strlen( ls_customer-TaxNumber1 ).

              IF lv_len EQ 11.
                e_tax_number = ls_customer-TaxNumber1.
              ENDIF.

            ENDIF.
          WHEN 'STCD2'.
            IF ls_customer-TaxNumber2 IS NOT INITIAL.

              lv_len = strlen( ls_customer-TaxNumber2 ).

              IF lv_len EQ 11.
                e_tax_number = ls_customer-TaxNumber2.
              ENDIF.

            ENDIF.
          WHEN 'STCD3'.
            IF ls_customer-TaxNumber3 IS NOT INITIAL.

              lv_len = strlen( ls_customer-TaxNumber3 ).

              IF lv_len EQ 11.
                e_tax_number = ls_customer-TaxNumber3.
              ENDIF.

            ENDIF.
          WHEN 'STCD4'.
            IF ls_customer-TaxNumber4 IS NOT INITIAL.

              lv_len = strlen( ls_customer-TaxNumber4 ).

              IF lv_len EQ 11.
                e_tax_number = ls_customer-TaxNumber4.
              ENDIF.

            ENDIF.
          WHEN 'FISKN'.
            IF ls_customer-FiscalAddress IS NOT INITIAL.

              lv_len = strlen( ls_customer-FiscalAddress ).

              IF lv_len EQ 11.
                e_tax_number = ls_customer-FiscalAddress.
              ENDIF.

            ENDIF.
          WHEN 'STCEG'.
            IF ls_customer-VATRegistration IS NOT INITIAL.

              lv_len = strlen( ls_customer-VATRegistration ).

              IF lv_len EQ 11.
                e_tax_number = ls_customer-VATRegistration.
              ENDIF.

            ENDIF.
        ENDCASE.

      ENDIF.

      e_ktokl = ls_customer-CustomerAccountGroup.
    ELSE.
      "-
      SELECT SINGLE TaxNumber1, TaxNumber2, TaxNumber3, TaxNumber4, FiscalAddress, VATRegistration, SupplierAccountGroup
             FROM I_Supplier
            WHERE Supplier EQ @i_lifnr
            INTO @DATA(ls_supplier).

      IF i_office IS NOT INITIAL.

        CASE ls_adrs-tax_office.
          WHEN 'STCD1'.
            e_tax_office = ls_supplier-TaxNumber1.
          WHEN 'STCD2'.
            e_tax_office = ls_supplier-TaxNumber2.
          WHEN 'STCD3'.
            e_tax_office = ls_supplier-TaxNumber3.
          WHEN 'STCD4'.
            e_tax_office = ls_supplier-TaxNumber4.
          WHEN 'FISKN'.
            SELECT SINGLE OrganizationBPName1
                     FROM I_Supplier
                    WHERE supplier EQ @ls_supplier-FiscalAddress
                     INTO @e_tax_office.
          WHEN 'STCEG'.
            e_tax_office = ls_supplier-VATRegistration.
        ENDCASE.

      ENDIF.

      IF i_number IS NOT INITIAL.

        CASE ls_adrs-tax_number.
          WHEN 'STCD1'.
            e_tax_number = ls_supplier-TaxNumber1.
          WHEN 'STCD2'.
            e_tax_number = ls_supplier-TaxNumber2.
          WHEN 'STCD3'.
            e_tax_number = ls_supplier-TaxNumber3.
          WHEN 'STCD4'.
            e_tax_number = ls_supplier-TaxNumber4.
          WHEN 'FISKN'.
            SELECT SINGLE OrganizationBPName1
                     FROM I_Supplier
                    WHERE supplier EQ @ls_supplier-FiscalAddress
                    INTO @e_tax_number.
          WHEN 'STCEG'.
            e_tax_number = ls_supplier-VATRegistration.
        ENDCASE.

        CASE ls_adrs-tax_person.
          WHEN 'STCD1'.
            IF ls_supplier-TaxNumber1 IS NOT INITIAL.

              lv_len = strlen( ls_supplier-TaxNumber1 ).

              IF lv_len EQ 11.
                e_tax_number = ls_supplier-TaxNumber1.
              ENDIF.

            ENDIF.
          WHEN 'STCD2'.
            IF ls_supplier-TaxNumber2 IS NOT INITIAL.

              lv_len = strlen( ls_supplier-TaxNumber2 ).

              IF lv_len EQ 11.
                e_tax_number = ls_supplier-TaxNumber2.
              ENDIF.

            ENDIF.
          WHEN 'STCD3'.
            IF ls_supplier-TaxNumber3 IS NOT INITIAL.

              lv_len = strlen( ls_supplier-TaxNumber3 ).

              IF lv_len EQ 11.
                e_tax_number = ls_supplier-TaxNumber3.
              ENDIF.

            ENDIF.
          WHEN 'STCD4'.
            IF ls_supplier-TaxNumber4 IS NOT INITIAL.
              lv_len = strlen( ls_supplier-TaxNumber4 ).

              IF lv_len EQ 11.
                e_tax_number = ls_supplier-TaxNumber4.
              ENDIF.
            ENDIF.
          WHEN 'FISKN'.
            IF ls_supplier-FiscalAddress IS NOT INITIAL.
              lv_len = strlen( ls_supplier-FiscalAddress ).

              IF lv_len EQ 11.
                e_tax_number = ls_supplier-FiscalAddress.
              ENDIF.
            ENDIF.
          WHEN 'STCEG'.
            IF ls_supplier-VATRegistration IS NOT INITIAL.

              lv_len = strlen( ls_supplier-VATRegistration ).

              IF lv_len EQ 11.
                e_tax_number = ls_supplier-VATRegistration.
              ENDIF.

            ENDIF.

        ENDCASE.

      ENDIF.

      e_ktokl = ls_supplier-SupplierAccountGroup.
    ENDIF.

  ENDMETHOD.