  METHOD zreco_data_json .
    DATA : ls_stru          TYPE REF TO cl_abap_structdescr,
           lt_comp          TYPE STANDARD TABLE OF abap_componentdescr,
           ls_comp          TYPE abap_componentdescr,
           ls_abap          TYPE abap_trans_resbind,
           lt_abap          TYPE abap_trans_resbind_tab,
           lv_json          TYPE string, lo_reader TYPE REF TO if_sxml_reader,
           lo_string_writer TYPE REF TO cl_sxml_string_writer,
           lo_writer        TYPE REF TO if_sxml_writer,
           lo_node          TYPE REF TO if_sxml_node,
           lo_elements      TYPE REF TO if_sxml_open_element,
           lv_response      TYPE string,
           lv_value         TYPE string,
           lv_responsex     TYPE xstring,
           lt_attributes    TYPE if_sxml_attribute=>attributes.

    FIELD-SYMBOLS: <ls_attributes> TYPE REF TO if_sxml_attribute,
                   <data>          TYPE any.

    lv_response = iv_json.

*    CALL FUNCTION 'ECATT_CONV_STRING_TO_XSTRING'
*      EXPORTING
*        im_string   = lv_response
*        im_encoding = 'UTF-8'
*      IMPORTING
*        ex_xstring  = lv_responsex.

    lo_reader = cl_sxml_string_reader=>create( lv_responsex ).
    lo_writer ?= cl_sxml_string_writer=>create( type = if_sxml=>co_xt_json ).

    DO.
      lo_node = lo_reader->read_next_node( ).
      IF lo_node IS INITIAL.
        EXIT.
      ENDIF.
      IF lo_node->type = if_sxml_node=>co_nt_element_open.
        lo_elements ?= lo_node.
        lt_attributes = lo_elements->get_attributes( ).
        LOOP AT lt_attributes ASSIGNING <ls_attributes>.
          IF <ls_attributes>->qname-name = 'name'.
            lv_value = <ls_attributes>->get_value( ).
            TRANSLATE lv_value TO UPPER CASE.
            <ls_attributes>->set_value( lv_value ).
          ENDIF.
        ENDLOOP.
      ENDIF.
      lo_writer->write_node( lo_node ).
    ENDDO.
    lo_string_writer ?= lo_writer.
    lv_responsex = lo_string_writer->get_output( ) .

*    CALL FUNCTION 'ECATT_CONV_XSTRING_TO_STRING'
*      EXPORTING
*        im_xstring  = lv_responsex
*        im_encoding = 'UTF-8'
*      IMPORTING
*        ex_string   = lv_response.

    ls_stru ?= cl_abap_typedescr=>describe_by_data( ev_data ).
    lt_comp = ls_stru->get_components( ).

    LOOP AT lt_comp INTO ls_comp.
      ls_abap-name = ls_comp-name.
      ASSIGN COMPONENT ls_abap-name OF STRUCTURE ev_data TO <data>.
      <data> = ls_abap-value.
*      GET REFERENCE OF <data> INTO ls_abap-value.                                          "D_MBAYEL
      APPEND ls_abap TO lt_abap.
    ENDLOOP.

    CALL TRANSFORMATION id SOURCE XML lv_response
                RESULT (lt_abap).

    LOOP AT lt_abap INTO ls_abap.
      ASSIGN COMPONENT ls_abap-name OF STRUCTURE ev_data TO <data>.
    ENDLOOP.

  ENDMETHOD.