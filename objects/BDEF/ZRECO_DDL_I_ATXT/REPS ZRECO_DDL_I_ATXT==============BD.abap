managed implementation in class zbp_reco_ddl_i_atxt unique;
strict ( 2 );

define behavior for ZRECO_DDL_I_ATXT //alias <alias_name>
persistent table zreco_atxt
lock master
authorization master ( instance )
//etag master <field_name>
{
  create;
  update;
  delete;
  field ( readonly : update ) Bukrs, Spras, Akont;

  mapping for zreco_atxt{
  Bukrs = bukrs;
  Spras = spras;
  Akont = akont;
  Ltext_ = ltext_;
  Xsum = xsum;


  }

}