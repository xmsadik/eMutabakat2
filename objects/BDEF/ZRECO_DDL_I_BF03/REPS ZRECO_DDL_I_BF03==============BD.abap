managed implementation in class zbp_reco_ddl_i_bf03 unique;
strict ( 2 );

define behavior for ZRECO_DDL_I_BF03 //alias <alias_name>
persistent table zreco_bf03
lock master
authorization master ( instance )
//etag master <field_name>
{
  create;
  update;
  delete;
  field ( readonly : update ) Bukrs, SSign, SOption, MwskzLow, MwskzHigh;
  mapping for zreco_bf03
    {
      Bukrs     = bukrs;
      SSign     = s_sign;
      SOption   = s_option;
      MwskzLow  = mwskz_low;
      MwskzHigh = mwskz_high;
    }
}