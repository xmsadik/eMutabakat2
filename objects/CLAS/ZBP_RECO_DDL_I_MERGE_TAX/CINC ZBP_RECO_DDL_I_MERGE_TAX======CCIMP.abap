CLASS lhc_zreco_ddl_i_merge_tax DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zreco_ddl_i_merge_tax RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE zreco_ddl_i_merge_tax.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zreco_ddl_i_merge_tax.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zreco_ddl_i_merge_tax.

    METHODS read FOR READ
      IMPORTING keys FOR READ zreco_ddl_i_merge_tax RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zreco_ddl_i_merge_tax.

ENDCLASS.

CLASS lhc_zreco_ddl_i_merge_tax IMPLEMENTATION.

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

ENDCLASS.

CLASS lsc_ZRECO_DDL_I_MERGE_TAX DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZRECO_DDL_I_MERGE_TAX IMPLEMENTATION.

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