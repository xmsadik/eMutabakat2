managed implementation in class zbp_reco_ddl_i_srvc unique;
strict ( 2 );

define behavior for ZRECO_DDL_I_SRVC //alias <alias_name>
persistent table zreco_srvc
lock master
authorization master ( instance )
//etag master <field_name>
{
  create;
  update;
  delete;
  field ( readonly : update ) Bukrs, Srvid;

  mapping for zreco_srvc
    {
      Bukrs   = bukrs;
      Srvid   = srvid;
      Srvurl  = srvurl;
      Srvusr  = srvusr;
      Srvpsw  = srvpsw;
      Srvhost = srvhost;
    }
}