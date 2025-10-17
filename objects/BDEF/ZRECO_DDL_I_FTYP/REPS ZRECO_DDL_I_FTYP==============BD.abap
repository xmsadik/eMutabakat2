managed implementation in class zbp_reco_ddl_i_ftyp unique;
strict ( 2 );

define behavior for ZRECO_DDL_I_FTYP //alias <alias_name>
persistent table zreco_ftyp
lock master
authorization master ( instance )
//etag master <field_name>
{
  create;
  update;
  delete;
  field ( readonly : update ) Ftype;


  mapping for zreco_ftyp
    {
      Ftype   = ftype;
      Ktext   = ktext;
      Dunning = dunning;
    }



}