managed implementation in class zbp_reco_ddl_i_mast unique;
strict ( 2 );

define behavior for zreco_ddl_i_mast //alias <alias_name>
persistent table zreco_mast
lock master
authorization master ( instance )
//etag master <field_name>
{
  create;
  update;
  delete;
  field ( readonly : update ) Bukrs, Kunnr, Lifnr, Mtype, SmtpAddr;

  mapping for zreco_mast{
  Bukrs = Bukrs;
  Kunnr = Kunnr;
  Lifnr = Lifnr;
  Mtype = Mtype;
  SmtpAddr = smtp_addr;
  Name1 = Name1;
  Name2 = Name2;


  }

}