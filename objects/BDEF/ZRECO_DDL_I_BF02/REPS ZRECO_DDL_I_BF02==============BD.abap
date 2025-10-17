managed implementation in class zbp_reco_ddl_i_bf02 unique;
strict ( 2 );

define behavior for ZRECO_DDL_I_BF02 //alias <alias_name>
persistent table zreco_bf02
lock master
authorization master ( instance )
//etag master <field_name>
{
  create;
  update;
  delete;
  field ( readonly : update ) Bukrs, HesapTur, SSign, SOption, HkontLow, HkontHigh;

  mapping for zreco_bf02
    {
      Bukrs     = bukrs;
      HesapTur  = hesap_tur;
      SSign     = s_sign;
      SOption   = s_option;
      HkontLow  = hkont_low;
      HkontHigh = hkont_high;
    }
}