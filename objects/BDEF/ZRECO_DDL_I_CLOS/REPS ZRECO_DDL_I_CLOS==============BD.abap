managed implementation in class zbp_reco_ddl_i_clos unique;
strict ( 2 );

define behavior for ZRECO_DDL_I_CLOS //alias <alias_name>
persistent table zreco_clos
lock master
authorization master ( instance )
//etag master <field_name>
{
  create;
  update;
  delete;
  field ( readonly : update ) Bukrs, Mtype;

  mapping for zreco_clos
    {
      Bukrs   = bukrs;
      Mtype   = mtype;
      Gjahr   = gjahr;
      Monat   = monat;
    }


}