managed implementation in class zbp_reco_ddl_i_odk unique;
strict ( 2 );

define behavior for ZRECO_DDL_I_ODK //alias <alias_name>
persistent table zreco_odk
lock master
authorization master ( instance )
//etag master <field_name>
{
  create;
  update;
  delete;
  field ( readonly : update ) HesapTur, Umskz, Spras;

  mapping for zreco_odk
    {
      HesapTur = hesap_tur;
      Umskz    = umskz;
      Spras    = spras;
      Xsort    = xsort;
      Ltext    = ltext;
      Xsum     = xsum;
      Xakont   = xakont;
    }
}