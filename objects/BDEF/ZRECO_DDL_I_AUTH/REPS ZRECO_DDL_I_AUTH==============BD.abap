managed implementation in class zbp_reco_ddl_i_auth unique;
strict ( 2 );

define behavior for zreco_ddl_i_auth //alias <alias_name>
persistent table zreco_auth
lock master
authorization master ( instance )
//etag master <field_name>
{
  create;
  update;
  delete;
  field ( readonly ) Bukrs, Mtype, Kunnr, Lifnr, Uname;
}