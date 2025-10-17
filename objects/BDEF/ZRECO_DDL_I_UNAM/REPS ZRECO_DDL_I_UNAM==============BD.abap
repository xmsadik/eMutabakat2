managed implementation in class zbp_reco_ddl_i_unam unique;
strict ( 2 );

define behavior for ZRECO_DDL_I_UNAM //alias <alias_name>
persistent table zreco_unam
lock master
authorization master ( instance )
//etag master <field_name>
{
  create;
  update;
  delete;
  field ( readonly : update ) Bukrs, Uname, Mtype, Ftype;

  mapping for zreco_unam{
  Bukrs = bukrs;
  Uname = uname;
  Mtype = Mtype;
  Ftype = Ftype;
  Ktokd = ktokd;
  Ktokk = ktokk;
  MBrsch = m_brsch;
  SBrsch = s_brsch;

  }
}