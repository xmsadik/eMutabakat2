unmanaged implementation in class zbp_reco_ddl_i_reco_follow_rep unique;
strict ( 1 ); //Uncomment this line in order to enable strict mode 2. The strict mode has two variants (strict(1), strict(2)) and is prerequisite to be future proof regarding syntax and to be able to release your BO.

define behavior for ZRECO_DDL_I_RECO_FOLLOW_REPORT alias follow_report
//late numbering
lock master
authorization master ( instance )
//etag master <field_name>
{
//   create;
//   update;
//   delete;
  field ( readonly : update  ) p_bukrs, p_ftype, s_monat, s_gjahr, s_mnmbr,
  s_hstur, s_hspno, s_kunnr, s_lifnr, s_stcd2, s_outpt, s_mrslt,
  s_ernam, s_erdat, s_erzei, p_daily, p_odk, p_bal, p_del, p_all, p_anwsr,
  p_compl;


  static action show_form parameter zreco_ddl_i_follow_report_form result [1] $self;
  static action analiz result [1] $self;
  static action reminder_mail result [1] $self;
}