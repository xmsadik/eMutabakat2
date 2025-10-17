  METHOD replace_data.

    DATA: field_name  TYPE string,
          field_value TYPE string.

    FIELD-SYMBOLS: <field> TYPE any.

    DATA: ref_structure TYPE REF TO cl_abap_structdescr,
          lt_components TYPE cl_abap_structdescr=>component_table.


    ref_structure ?= cl_abap_typedescr=>describe_by_data( is_radio_data ).
    lt_components = ref_structure->get_components( ).

    LOOP AT lt_components INTO DATA(component).
      field_name = component-name.


      ASSIGN COMPONENT field_name OF STRUCTURE is_radio_data TO <field>.
      IF sy-subrc = 0.
        CASE <field>.
          WHEN '0'.
            <field> = abap_true.
          WHEN '1'.
            <field> = abap_false.
        ENDCASE.
      ENDIF.
    ENDLOOP.

    rs_radio_data = is_radio_data.

  ENDMETHOD.