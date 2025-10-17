  METHOD zreco_excluded_values.

    DATA: lt_exvl TYPE TABLE OF zRECO_exvl,
          ls_exvl LIKE LINE OF  lt_exvl.

    SELECT * FROM zRECO_exvl
      WHERE bukrs EQ @i_bukrs
      INTO TABLE @lt_exvl.


    DATA : ls_kunnr TYPE   ZRECO_RANGE_kunnr.


    CHECK sy-subrc EQ 0.

* Hariç tutulacak müşteriler
    LOOP AT lt_exvl INTO ls_exvl WHERE exclude_type EQ 'M'.

*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT' "YiğitcanÖzdemir
*      EXPORTING
*        input        = ls_exvl-exclude_value
*     IMPORTING
*       output        = ls_exvl-exclude_value .

      ls_exvl-exclude_value = |{ ls_exvl-exclude_value ALPHA = IN }|.

      ls_kunnr-sign = 'E'.

      FIND '*' IN ls_exvl-exclude_value.

      IF sy-subrc EQ 0.
        ls_kunnr-option = 'CP'.
      ELSE.
        ls_kunnr-option = 'EQ'.
      ENDIF.

      ls_kunnr-low = ls_exvl-exclude_value.

*      COLLECT it_kunnr.  "YiğitcanÖzdemir
      APPEND ls_kunnr TO it_kunnr.

    ENDLOOP.

* Hariç tutulacak satıcılar
    LOOP AT lt_exvl INTO ls_exvl WHERE exclude_type EQ 'S'.

*      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT' "YiğitcanÖzdemir
*        EXPORTING
*          input  = ls_exvl-exclude_value
*        IMPORTING
*          output = ls_exvl-exclude_value.

      ls_exvl-exclude_value = |{ ls_exvl-exclude_value ALPHA = IN }|.

      DATA : ls_lifnr TYPE   zreco_range_lifnr.

      ls_lifnr-sign = 'E'.

      FIND '*' IN ls_exvl-exclude_value.

      IF sy-subrc EQ 0.
        ls_lifnr-option = 'CP'.
      ELSE.
        ls_lifnr-option = 'EQ'.
      ENDIF.

      ls_lifnr-low = ls_exvl-exclude_value.

*      COLLECT it_lifnr.
      APPEND ls_lifnr TO it_lifnr.

    ENDLOOP.

* Hariç tutulacak belgeler
    LOOP AT lt_exvl INTO ls_exvl WHERE exclude_type EQ 'MB'.

*      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT' "YiğitcanÖzdemir
*        EXPORTING
*          input  = ls_exvl-exclude_value
*        IMPORTING
*          output = ls_exvl-exclude_value.

      ls_exvl-exclude_value = |{ ls_exvl-exclude_value ALPHA = IN }|.

      DATA : ls_belnr TYPE   zreco_range_belnr.

      ls_belnr-sign = 'E'.

      FIND '*' IN ls_exvl-exclude_value.

      IF sy-subrc EQ 0.
        ls_belnr-option = 'CP'.
      ELSE.
        ls_belnr-option = 'EQ'.
      ENDIF.

      ls_belnr-low = ls_exvl-exclude_value.

*      COLLECT it_belnr. "YiğitcanÖzdemir
      APPEND ls_belnr  TO it_belnr.

    ENDLOOP.

* Hariç tutulacak belge türleri
    LOOP AT lt_exvl INTO ls_exvl WHERE exclude_type EQ 'BT'.

*      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*        EXPORTING
*          input  = ls_exvl-exclude_value
*        IMPORTING
*          output = ls_exvl-exclude_value.

      ls_exvl-exclude_value = |{ ls_exvl-exclude_value ALPHA = IN }|.

      DATA : ls_blart TYPE   zreco_range_blart.

      ls_blart-sign = 'E'.

      FIND '*' IN ls_exvl-exclude_value.

      IF sy-subrc EQ 0.
        ls_blart-option = 'CP'.
      ELSE.
        ls_blart-option = 'EQ'.
      ENDIF.

      ls_blart-low = ls_exvl-exclude_value.

      APPEND ls_blart TO it_blart.

*      COLLECT it_blart.

    ENDLOOP.

* Hariç tutulacak ÖDK'lar
    LOOP AT lt_exvl INTO ls_exvl WHERE exclude_type EQ 'OD'.

*      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*        EXPORTING
*          input  = ls_exvl-exclude_value
*        IMPORTING
*          output = ls_exvl-exclude_value.


      ls_exvl-exclude_value = |{ ls_exvl-exclude_value ALPHA = IN }|.

      DATA : ls_umskz TYPE   zreco_range_umskz.

      ls_umskz-sign = 'E'.

      FIND '*' IN ls_exvl-exclude_value.

      IF sy-subrc EQ 0.
        ls_umskz-option = 'CP'.
      ELSE.
        ls_umskz-option = 'EQ'.
      ENDIF.

      ls_umskz-low = ls_exvl-exclude_value.

      APPEND ls_umskz TO it_umskz.
*      COLLECT it_umskz.

    ENDLOOP.


  ENDMETHOD.