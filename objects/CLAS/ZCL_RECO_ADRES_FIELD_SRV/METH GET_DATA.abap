  METHOD get_data.

    mo_common = NEW #(  ).


    SELECT SINGLE *
        FROM zreco_flds
       WHERE hesap_tur EQ @iv_hesap_tur
        INTO @ms_flds.

    CASE iv_hesap_tur.
      WHEN 'M'.

        DATA lv_customer TYPE i_customer-customer.

        lv_customer = CONV #( iv_id ).

        lv_customer = |{ lv_customer ALPHA = IN }|  .
        SELECT SINGLE *
             FROM i_customer
            WHERE Customer EQ @lv_customer
            INTO @DATA(ls_customer).

        IF sy-subrc IS INITIAL.
          SELECT SINGLE companycode
                   FROM i_customercompany
                   WHERE customer EQ @lv_customer
                   INTO @DATA(lv_customercompany).

          mv_kunnr_name = | { ls_customer-OrganizationBPName1 } | && | { ls_customer-OrganizationBPName2 } | .

          mv_telf1 = ls_customer-TelephoneNumber1.
          mv_telf2 = ls_customer-TelephoneNumber2.
          mv_telfx = ls_customer-FaxNumber.

          SELECT SINGLE *
                   FROM zreco_ddl_i_address2
                  WHERE AddressID EQ @ls_customer-AddressID
                   INTO @DATA(ls_address).

          ms_adrc-name1      = ls_address-OrganizationName1.
          ms_adrc-name2      = ls_address-OrganizationName2.
          ms_adrc-name3      = ls_address-OrganizationName3.
          ms_adrc-name4      = ls_address-OrganizationName4.
          ms_adrc-addrnumber = ls_address-AddressID.
          ms_adrc-streetcode = ls_address-Street.
          ms_adrc-street     = ls_address-StreetName.
          ms_adrc-str_suppl1 = ls_address-StreetPrefixName1.
          ms_adrc-str_suppl2 = ls_address-StreetPrefixName2.
          ms_adrc-str_suppl3 = ls_address-StreetSuffixName1.
          ms_adrc-location   = ls_address-StreetSuffixName2.
          ms_adrc-building   = ls_address-Building.
          ms_adrc-roomnumber = ls_address-RoomNumber.
          ms_adrc-floor      = ls_address-floor.
          ms_adrc-name_co    = ls_address-CareOfName.
          ms_adrc-house_num1 = ls_address-HouseNumber.
          ms_adrc-house_num2 = ls_address-HouseNumberSupplementText.
          ms_adrc-city2      = ls_address-DistrictName.
          ms_adrc-post_code1 = ls_address-PostalCode.
          ms_adrc-city1      = ls_address-CityName.
          ms_adrc-country    = ls_address-Country.
          ms_adrc-region     = ls_address-Region.
          ms_adrc-home_city  = ls_address-VillageName.

          mo_common->tax_info(
            EXPORTING
              i_bukrs      = lv_customercompany
              i_kunnr      = lv_customer
              i_number     = abap_true
              i_office     = abap_true
            IMPORTING
              e_tax_office = mv_tax_office
              e_tax_number = mv_tax_number
          ).
        ENDIF.

      WHEN 'S'.

        DATA lv_supplier TYPE i_supplier-Supplier.

        lv_supplier = iv_id.
        lv_supplier = |{ lv_supplier ALPHA = IN }|.

        SELECT SINGLE *
          FROM i_supplier
          WHERE Supplier EQ @lv_supplier
          INTO @DATA(ls_supplier).

        IF sy-subrc IS INITIAL.

          SELECT SINGLE CompanyCode
            FROM i_suppliercompany
           WHERE Supplier = @lv_supplier
            INTO @DATA(lv_suppliercompany).

          CLEAR ls_address.
          SELECT SINGLE *
                   FROM zreco_ddl_i_address2
                  WHERE AddressID EQ @ls_supplier-AddressID
                   INTO @ls_address.

          mv_lifnr_name = |{ ls_supplier-OrganizationBPName1 }| && |{ ls_supplier-OrganizationBPName2 }|.
          mv_telf1 = ls_supplier-PhoneNumber1.
          mv_telf2 = ls_supplier-PhoneNumber2.
          mv_telfx = ls_supplier-FaxNumber.

          ms_adrc-name1      = ls_address-OrganizationName1.
          ms_adrc-name2      = ls_address-OrganizationName2.
          ms_adrc-name3      = ls_address-OrganizationName3.
          ms_adrc-name4      = ls_address-OrganizationName4.
          ms_adrc-addrnumber = ls_address-AddressID.
          ms_adrc-streetcode = ls_address-Street.
          ms_adrc-street     = ls_address-StreetName.
          ms_adrc-str_suppl1 = ls_address-StreetPrefixName1.
          ms_adrc-str_suppl2 = ls_address-StreetPrefixName2.
          ms_adrc-str_suppl3 = ls_address-StreetSuffixName1.
          ms_adrc-location   = ls_address-StreetSuffixName2.
          ms_adrc-building   = ls_address-Building.
          ms_adrc-roomnumber = ls_address-RoomNumber.
          ms_adrc-floor      = ls_address-floor.
          ms_adrc-name_co    = ls_address-CareOfName.
          ms_adrc-house_num1 = ls_address-HouseNumber.
          ms_adrc-house_num2 = ls_address-HouseNumberSupplementText.
          ms_adrc-city2      = ls_address-DistrictName.
          ms_adrc-post_code1 = ls_address-PostalCode.
          ms_adrc-city1      = ls_address-CityName.
          ms_adrc-country    = ls_address-Country.
          ms_adrc-region     = ls_address-Region.
          ms_adrc-home_city  = ls_address-VillageName.

          mo_common->tax_info(
            EXPORTING
              i_bukrs      = lv_suppliercompany
              i_lifnr      = lv_supplier
              i_number     = abap_true
              i_office     = abap_true
            IMPORTING
              e_tax_office = mv_tax_office
              e_tax_number = mv_tax_number
          ).
        ENDIF.
    ENDCASE.

    IF ls_address-region IS NOT INITIAL.
      SELECT SINGLE RegionName
        FROM I_RegionText
       WHERE country EQ @ls_address-Country
         AND region  EQ @ls_address-region
        INTO @ms_adrc-bezei.
    ENDIF.

    IF ls_address-Country IS NOT INITIAL.
      SELECT SINGLE CountryShortName
        FROM i_countrytext
       WHERE Country EQ @ms_adrc-country
        INTO @ms_adrc-landx.
    ENDIF.

    ms_response_service-adrc       = ms_adrc.
    ms_response_service-kunnr_name = mv_kunnr_name.
    ms_response_service-lifnr_name = mv_lifnr_name.
    ms_response_service-tax_number = mv_tax_number.
    ms_response_service-tax_office = mv_tax_office.
    ms_response_service-telf1      = mv_telf1.
    ms_response_service-telf2      = mv_telf2.
    ms_response_service-telfx      = mv_telfx.

    /ui2/cl_json=>serialize(
      EXPORTING
        data   = ms_response_service
      RECEIVING
        r_json = mv_json_data
    ).
  ENDMETHOD.