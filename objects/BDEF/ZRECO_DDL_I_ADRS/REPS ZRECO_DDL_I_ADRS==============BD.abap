managed implementation in class zbp_reco_ddl_i_adrs unique;
strict ( 2 );

define behavior for zreco_ddl_i_adrs //alias <alias_name>
persistent table zreco_adrs
lock master
authorization master ( instance )
//etag master <field_name>
{
  create;
  update;
  delete;
  field ( readonly : update ) Bukrs, Gsber;

  mapping for zreco_adrs{
    bukrs = Bukrs;
    gsber = Gsber;
    CusBalanceS = cus_balance_s;
    VenBalanceS = ven_balance_s;
    xprod = Xprod;
    name = Name;
    butxt = Butxt;
    adres1 = Adres1;
    adres2 = Adres2;
    semt = Semt;
    kent = Kent;
    pkod = Pkod;
    telefon = Telefon;
    faks = Faks;
    web = Web;
    vergidairesi = Vergidairesi;
    verginumarasi = Verginumarasi;
    ticaretsicil = Ticaretsicil;
    mersisno = Mersisno;
    TaxNumber = tax_number;
    TaxOffice = tax_office;
    TaxPerson = tax_person;
    ImzaLogo = imza_logo;
    SapLogo = sap_logo;
    WebLogo = web_logo;
    WebServer = web_server;
    FilePath = file_path;
    Xsign = xsign;
    YBfile1 = y_bfile_1;
    YBfile2 = y_bfile_2;
    NBfile1 = n_bfile_1;
    NBfile2 = n_bfile_2;
    YCfile1 = y_cfile_1;
    YCfile2 = y_cfile_2;
    NCfile1 = n_cfile_1;
    NCfile2 = n_cfile_2;
    XyBfile1 = xy_bfile_1;
    XyBfile2 = xy_bfile_2;
    XnBfile1 = xn_bfile_1;
    XnBfile2 = xn_bfile_2;
    XyCfile1 = xy_cfile_1;
    XyCfile2 = xy_cfile_2;
    XnCfile1 = xn_cfile_1;
    XnCfile2 = xn_cfile_2;
    Xzero = xzero;
    Xexcel = xexcel;
    Xbform = xbform;
    Abtnr = abtnr;
    Pafkt = pafkt;
    AbtnrB = abtnr_b;
    PafktB = pafkt_b;
    AbtnrI = abtnr_i;
    PafktI = pafkt_i;
    Remark = remark;
    RemarkB = remark_b;
    RemarkI = remark_i;
    KepAdr = kep_adr;
    NoGeneral = no_general;
    MName = m_name;
    MTelefon = m_telefon;
    MEmail = m_email;
    MGun = m_gun;
    MTekrar = m_tekrar;
    FGun = f_gun;
    FTekrar = f_tekrar;
    Vari = vari;
    VariBform = vari_bform;
    Limit = limit;
    BDateSelection = b_date_selection;
    CDateSelection = c_date_selection;
    FromMail = from_mail;
    InfoMail = info_mail;
    SendInfo = send_info;
    SendInfoH = send_info_h;
    Kurst = kurst;
    NoKursf = no_kursf;
    DosAkTur = dos_ak_tur;
    FtpHost = ftp_host;
    Muser = muser;
    Pass = pass;
    EPath = e_path;
    MPath = m_path;
    DPath = d_path;
    Padest = padest;
    Rfcdest = rfcdest;
    FaxExtension = fax_extension;
    Sperr = sperr;
    Loevm = loevm;
    YearCount = year_count;
    Xausz = xausz;
    CDatbi = c_datbi;
    BDatbi = b_datbi;
    CValday = c_valday;
    BValday = b_valday;
    Xstamp = xstamp;
    ZeroWrbt = zero_wrbt;
    NoLocalCurr = no_local_curr;
    ZeroSplind = zero_splind;
    MasterData = master_data;
    Waers = waers;

    }



















}