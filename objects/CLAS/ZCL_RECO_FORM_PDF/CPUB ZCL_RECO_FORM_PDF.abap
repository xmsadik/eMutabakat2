CLASS zcl_reco_form_pdf DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS : display
      IMPORTING is_data        TYPE zreco_s_pdf_data
      EXPORTING ev_pdf_content TYPE xstring.