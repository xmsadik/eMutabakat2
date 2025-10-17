CLASS lhc_zreco_ddl_i_assign_user DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zreco_ddl_i_assign_user RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE zreco_ddl_i_assign_user.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zreco_ddl_i_assign_user.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zreco_ddl_i_assign_user.

    METHODS read FOR READ
      IMPORTING keys FOR READ zreco_ddl_i_assign_user RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zreco_ddl_i_assign_user.

    METHODS AddUser FOR MODIFY
      IMPORTING keys FOR ACTION zreco_ddl_i_assign_user~AddUser RESULT result.

    METHODS DeleteUser FOR MODIFY
      IMPORTING keys FOR ACTION zreco_ddl_i_assign_user~DeleteUser RESULT result.



ENDCLASS.

CLASS lhc_zreco_ddl_i_assign_user IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD AddUser.


    DATA lt_new_entries TYPE TABLE OF zreco_auth.
    DATA ls_new_entry TYPE zreco_auth.
    READ TABLE keys INTO DATA(ls_key) INDEX 1.
    CHECK sy-subrc = 0.
    ls_new_entry-bukrs = ls_key-%param-bukrs.
    ls_new_entry-kunnr = ls_key-%param-kunnr.
    ls_new_entry-lifnr = ls_key-%param-lifnr.
    ls_new_entry-mtype = ls_key-%param-mtype.
    ls_new_entry-erdat = cl_abap_context_info=>get_system_date( )..
    ls_new_entry-ernam = cl_abap_context_info=>get_user_technical_name( ).
    ls_new_entry-erzeit = cl_abap_context_info=>get_system_time( )..

    APPEND ls_new_entry TO lt_new_entries.

    TRY.


        MODIFY zreco_auth FROM TABLE @lt_new_entries.

*
      CATCH cx_uuid_error.


    ENDTRY.

  ENDMETHOD.

  METHOD DeleteUser.

    READ TABLE keys INTO DATA(ls_key) INDEX 1.
    CHECK sy-subrc = 0.

    TRY.

        DELETE FROM zreco_auth WHERE bukrs = @ls_key-%param-bukrs AND
                                     mtype = @ls_key-%param-mtype AND
                                     kunnr = @ls_key-%param-kunnr AND
                                     lifnr = @ls_key-%param-lifnr .
*
      CATCH cx_uuid_error.

    ENDTRY..

  ENDMETHOD.
ENDCLASS.

CLASS lsc_ZRECO_DDL_I_ASSIGN_USER DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZRECO_DDL_I_ASSIGN_USER IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.