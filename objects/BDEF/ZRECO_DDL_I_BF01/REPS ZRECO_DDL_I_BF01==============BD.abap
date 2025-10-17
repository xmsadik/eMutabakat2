managed implementation in class zbp_reco_ddl_i_bf01 unique;
strict ( 2 );

define behavior for ZRECO_DDL_I_BF01 //alias <alias_name>
persistent table zreco_bf01
lock master
authorization master ( instance )
//etag master <field_name>
{
  create;
  update;
  delete;
  field ( readonly : update ) Bukrs, HesapTur, SSign, SOption, BlartLow, BlartHigh;

  mapping for zreco_bf01
    {
      Bukrs     = bukrs;
      HesapTur  = hesap_tur;
      SSign     = s_sign;
      SOption   = s_option;
      BlartLow  = blart_low;
      BlartHigh = blart_high;
    }
}