CLASS lhc_ZRECO_DDL_I_SRVC DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zreco_ddl_i_srvc RESULT result.

ENDCLASS.

CLASS lhc_ZRECO_DDL_I_SRVC IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

ENDCLASS.