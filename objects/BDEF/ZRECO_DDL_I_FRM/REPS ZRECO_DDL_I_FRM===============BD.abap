managed implementation in class zbp_reco_ddl_i_frm unique;
strict ( 2 );

define behavior for ZRECO_DDL_I_FRM //alias <alias_name>
persistent table zreco_frm
lock master
authorization master ( instance )
//etag master <field_name>
{
  create;
  update;
  delete;
  field ( readonly : update ) Bukrs, Ftype, Spras;

  mapping for zreco_frm
    {
      Bukrs    = bukrs;
      Ftype    = ftype;
      Spras    = spras;
      Tdsfname = tdsfname;
    }

}