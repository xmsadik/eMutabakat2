managed implementation in class zbp_reco_ddl_i_lang unique;
strict ( 2 );

define behavior for ZRECO_DDL_I_LANG //alias <alias_name>
persistent table zreco_lang
lock master
authorization master ( instance )
//etag master <field_name>
{
  create;
  update;
  delete;
  field ( readonly : update ) Bukrs, Mtype, Ktokd, Ktokk;

  mapping for zreco_lang
    {
      Bukrs   = bukrs;
      Mtype   = mtype;
      Ktokd   = ktokd;
      Ktokk   = ktokk;
      Spras   = spras;
    }

}