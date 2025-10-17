CLASS lhc_zreco_ddl_i_reco_form DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zreco_ddl_i_reco_form RESULT result.

    METHODS read FOR READ
      IMPORTING keys FOR READ zreco_ddl_i_reco_form RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zreco_ddl_i_reco_form.

    METHODS print FOR MODIFY
      IMPORTING keys FOR ACTION zreco_ddl_i_reco_form~print RESULT result.

    METHODS send FOR MODIFY
      IMPORTING keys FOR ACTION zreco_ddl_i_reco_form~send RESULT result.

ENDCLASS.

CLASS lhc_zreco_ddl_i_reco_form IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD print.

    DATA : lt_cform TYPE TABLE OF zreco_gtout,
           ls_cform TYPE zreco_gtout.

    TRY.
        READ ENTITIES OF zreco_ddl_i_reco_form IN LOCAL MODE
               ENTITY zreco_ddl_i_reco_form
                ALL FIELDS WITH CORRESPONDING #( keys )
               RESULT DATA(found_data).

        LOOP AT keys INTO DATA(ls_keys).
          MOVE-CORRESPONDING ls_keys TO ls_cform.
          APPEND ls_cform TO lt_cform.
        ENDLOOP.

*    LOOP AT lt_cform INTO ls_cform.
*
*      MOVE-CORRESPONDING ls_cform TO gs_cform.
*      COLLECT gs_cform INTO gt_cform.
*
*    ENDLOOP.



    DATA lo_zreco_common  TYPE REF TO zreco_common.
    CREATE OBJECT lo_zreco_common.
    lo_zreco_common->multi_sending(
    it_cform = lt_cform
    iv_output = ''
     ).


      CATCH cx_root INTO DATA(lx_err).



    ENDTRY.

  ENDMETHOD.


  METHOD send.

    DATA : lt_cform TYPE TABLE OF zreco_gtout,
           ls_cform TYPE zreco_gtout.

    TRY.

        READ ENTITIES OF zreco_ddl_i_reco_form IN LOCAL MODE
               ENTITY zreco_ddl_i_reco_form
                ALL FIELDS WITH CORRESPONDING #( keys )
               RESULT DATA(found_data).

        LOOP AT keys INTO DATA(ls_keys).
          MOVE-CORRESPONDING ls_keys TO ls_cform.
          APPEND ls_cform TO lt_cform.
        ENDLOOP.

*    LOOP AT lt_cform INTO ls_cform.
*
*      MOVE-CORRESPONDING ls_cform TO gs_cform.
*      COLLECT gs_cform INTO gt_cform.
*
*    ENDLOOP.

    DATA lo_zreco_common  TYPE REF TO zreco_common.
    CREATE OBJECT lo_zreco_common.
    lo_zreco_common->single_sending(
    it_cform = lt_cform
     ).


    lo_zreco_common->multi_sending(
    it_cform = lt_cform
    iv_output = 'X'
     ).

      CATCH cx_root INTO DATA(lx_err).


    ENDTRY.
  ENDMETHOD.
ENDCLASS.

CLASS lsc_ZRECO_DDL_I_RECO_FORM DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZRECO_DDL_I_RECO_FORM IMPLEMENTATION.

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