managed implementation in class zbp_reco_ddl_i_htxt unique;
strict ( 2 );

define behavior for ZRECO_DDL_I_HTXT //alias <alias_name>
persistent table zreco_htxt
lock master
authorization master ( instance )
//etag master <field_name>
{
  create;
  update;
  delete;
  field ( readonly : update) Bukrs, Spras, Mtype, Ftype;

    mapping for zreco_htxt{
    Bukrs =  bukrs;
    Spras =  spras;
    Mtype =  mtype;
    Ftype =  ftype;
    Bktxt = bktxt;
    IdateText = idate_text;
    ResponseText = response_text;
    ResponderText = responder_text;
    MtextText = mtext_text;
    MnumberText = mnumber_text;
    MdateText = mdate_text;
    MperiodText = mperiod_text;
    AnumberText = anumber_text;
    McontactText = mcontact_text;
    CallText = call_text;
    Customer = customer;
    Vendor = vendor;
    CustomerText = customer_text;
    VendorText = vendor_text;
    BtotalText = btotal_text;
    DebitText = debit_text;
    CreditText = credit_text;
    TaxofficeText = taxoffice_text;
    TaxnumberText = taxnumber_text;
    BukrsBaText = bukrs_ba_text;
    BukrsBsText = bukrs_bs_text;
    FirmBaText = firm_ba_text;
    FirmBsText = firm_bs_text;
    Subject = subject;
    TypeText = type_text;
    DocText = doc_text;
    LocText = loc_text;
    DocAnsText = doc_ans_text;
    LocAnsText = loc_ans_text;
    DocWaersText = doc_waers_text;
    KurText = kur_text;
    FromMail = from_mail;
    ColorCode = color_code;

  }
}