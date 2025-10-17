managed implementation in class zbp_reco_ddl_i_cont unique;
strict ( 2 );

define behavior for ZRECO_DDL_I_CONT //alias <alias_name>
persistent table zreco_cont
lock master
authorization master ( instance )
//etag master <field_name>
{
  create;
  update;
  delete;
  field ( readonly : update ) Bukrs, HesapTur, Ktokd, Ktokk, Mtype, Ftype;

    mapping for zreco_cont
    {
//      Uuid     = Uuid;
      Bukrs    = bukrs;
      HesapTur = hesap_tur;
      Ktokd    = ktokd;
      Ktokk    = ktokk;
      Mtype    = mtype;
      Ftype    = ftype;
      MName    = m_name;
      MTelefon = m_telefon;
      MEmail   = m_email;
    }

}