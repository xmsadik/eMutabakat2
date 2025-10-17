CLASS zcl_reco_assign_user DEFINITION
  PUBLIC

  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider .


    DATA p_bukrs TYPE bukrs.
    DATA p_mtype TYPE zreco_type.
    DATA p_kunnr TYPE kunnr.
    DATA p_lifnr TYPE lifnr.
    DATA p_akont TYPE akont.
    DATA p_ktokd TYPE ktokd.
    DATA p_brsch TYPE brsch.



    DATA: gt_out       TYPE TABLE OF zreco_ddl_i_assign_user,
          gs_out       TYPE zreco_ddl_i_assign_user,
          gt_out_temp  TYPE TABLE OF zreco_ddl_i_assign_user,
          gt_data_temp TYPE TABLE OF zreco_cvua,
          gt_data      TYPE TABLE OF zreco_cvua.
