CLASS zcl_reco_adres_field_srv DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA: mv_kunnr      TYPE kunnr,
          mv_lifnr      TYPE lifnr,
          mv_kunnr_name TYPE text80,
          mv_lifnr_name TYPE text80,
          mv_telf1      TYPE i_customer-TelephoneNumber1,
          mv_telf2      TYPE i_customer-TelephoneNumber1,
          mv_telfx      TYPE i_customer-FaxNumber,
          mv_tax_office TYPE i_customer-TaxNumber1,
          mv_tax_number TYPE i_customer-TaxNumber2,
          ms_adrc       TYPE zreco_adrc,
          ms_flds       TYPE zreco_flds,
          mo_common     TYPE REF TO  zreco_common,
          mv_json_data  TYPE string.


    TYPES : BEGIN OF mty_radio_button,
              hesap_tur    TYPE zreco_hesap_tur,
              name2_x      TYPE char2,
              name2_use    TYPE char2,
              name3_x      TYPE char2,
              name3_use    TYPE char2,
              name4_x      TYPE  char2,
              name4_use    TYPE char2,
              building_x   TYPE char2,
              roomnumber_x TYPE char2,
              floor_x      TYPE  char2,
              name_co_x    TYPE char2,
              str_suppl1_x TYPE char2,
              str_suppl2_x TYPE char2,
              street_x     TYPE char2,
              house_num1_x TYPE char2,
              house_num2_x TYPE char2,
              str_suppl3_x TYPE char2,
              location_x   TYPE char2,
              city2_x      TYPE char2,
              home_city_x  TYPE char2,
              post_code1_x TYPE char2,
              city1_x      TYPE char2,
              country_x    TYPE char2,
              region_x     TYPE char2,
              telf1_x      TYPE char2,
              telf2_x      TYPE char2,
              telfx_x      TYPE char2,
              tax_office_x TYPE char2,
              tax_number_x TYPE char2,
            END OF mty_radio_button.

    TYPES : BEGIN OF mty_response_service,
              kunnr_name TYPE text80,
              lifnr_name TYPE text80,
              telf1      TYPE i_customer-TelephoneNumber1,
              telf2      TYPE i_customer-TelephoneNumber1,
              telfx      TYPE i_customer-FaxNumber,
              tax_office TYPE i_customer-TaxNumber1,
              tax_number TYPE i_customer-TaxNumber2,
              adrc       TYPE zreco_adrc,
              adrc_radio TYPE mty_radio_button,
            END OF mty_response_service.

    DATA ms_response_service TYPE mty_response_service.
    DATA ms_radio_data      TYPE mty_radio_button.

    METHODS :
      get_data IMPORTING VALUE(iv_hesap_tur) TYPE zreco_hesap_tur
                         VALUE(iv_id)        TYPE kunnr,

      save_data IMPORTING VALUE(iv_data) TYPE string,

      replace_data IMPORTING VALUE(is_radio_data) TYPE mty_radio_button
                   RETURNING VALUE(rs_radio_data) TYPE mty_radio_button.

    INTERFACES if_http_service_extension .
