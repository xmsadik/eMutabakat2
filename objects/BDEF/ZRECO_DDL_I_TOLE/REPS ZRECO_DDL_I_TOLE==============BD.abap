managed implementation in class zbp_reco_ddl_i_tole unique;
strict ( 2 );

define behavior for ZRECO_DDL_I_TOLE //alias <alias_name>
persistent table zreco_tole
lock master
authorization master ( instance )
//etag master <field_name>
{
  create;
  update;
  delete;
  field ( readonly : update ) Bukrs, Stcd2, Waers, Akont;

  mapping for zreco_tole
    {
      Bukrs    = bukrs;
      Stcd2    = stcd2;
      Waers    = waers;
      Akont    = akont;
      Wrbtr    = wrbtr;
      Currency = currency;
    }



}