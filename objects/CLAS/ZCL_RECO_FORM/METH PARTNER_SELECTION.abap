  METHOD partner_selection.

    " <-- hkizilkaya
    TYPES: BEGIN OF ty_dpar,
             bukrs TYPE bukrs,
             parvw TYPE zreco_parvw,
             vkorg TYPE vkorg,
             vtweg TYPE vtweg,
             spart TYPE spart,
           END OF ty_dpar.

    TYPES: BEGIN OF ty_tpar,
             parvw TYPE zreco_parvw,
             nrart TYPE c LENGTH 2,
           END OF ty_tpar.

    TYPES: BEGIN OF ty_kunnr,
             kunnr TYPE kunnr,
           END OF ty_kunnr.

    TYPES: BEGIN OF ty_lifnr,
             lifnr TYPE lifnr,
           END OF ty_lifnr.

    DATA: lt_dpar TYPE TABLE OF ty_dpar,
          ls_dpar TYPE  ty_dpar,
          ls_tpar TYPE  ty_tpar,
          lt_kpar TYPE  TABLE OF zreco_kpar,
          ls_knvp TYPE ty_kunnr,
          ls_wyt3 TYPE ty_lifnr.

    FIELD-SYMBOLS <fs_kunnr> TYPE zreco_s_kunnr.
    FIELD-SYMBOLS <fs_lifnr> TYPE zreco_s_lifnr.
    " hkizilkaya -->

*    IF s_dparw[] IS NOT INITIAL AND "YiğitcanÖzdemir s_dparw  nerde ?
*       p_seld IS NOT INITIAL.

    SELECT bukrs, parvw, vkorg, vtweg, spart
      FROM zreco_dpar
     WHERE bukrs IN @s_bukrs
     INTO TABLE @lt_dpar.

    IF sy-subrc EQ 0.

      LOOP AT lt_dpar INTO ls_dpar.
        SELECT SINGLE PartnerFunction AS parvw, SDDocumentPartnerType AS nrart  "YiğitcanÖzdemir
                 FROM I_PartnerFunction
                WHERE PartnerFunction EQ @ls_dpar-parvw
                INTO @ls_tpar.
        EXIT.
      ENDLOOP.

      CASE ls_tpar-nrart.
        WHEN zreco_if_common_types=>mc_nrart_li.
          SELECT customer AS kunnr
            FROM i_custsalespartnerfunc"knvp
             FOR ALL ENTRIES IN @lt_dpar
           WHERE customer IN @s_kunnr
             AND SalesOrganization EQ @lt_dpar-vkorg
             AND DistributionChannel EQ @lt_dpar-vtweg
             AND Division EQ @lt_dpar-spart
             AND PartnerFunction EQ @lt_dpar-parvw
*               AND lifnr IN @s_dparw   "YiğitcanÖzdemir
              INTO TABLE @gt_knvp.
        WHEN zreco_if_common_types=>mc_nrart_pe.
          SELECT customer AS kunnr
            FROM i_custsalespartnerfunc
             FOR ALL ENTRIES IN @lt_dpar
           WHERE customer IN @s_kunnr
             AND SalesOrganization EQ @lt_dpar-vkorg
             AND DistributionChannel EQ @lt_dpar-vtweg
             AND Division EQ @lt_dpar-spart
             AND PartnerFunction EQ @lt_dpar-parvw
*             AND pernr IN @s_dparw "YiğitcanÖzdemir
               INTO TABLE @gt_knvp.
        WHEN OTHERS.
          SELECT customer
            FROM i_custsalespartnerfunc
             FOR ALL ENTRIES IN @lt_dpar
           WHERE customer IN @s_kunnr
             AND SalesOrganization EQ @lt_dpar-vkorg
             AND DistributionChannel EQ @lt_dpar-vtweg
             AND Division EQ @lt_dpar-spart
             AND PartnerFunction EQ @lt_dpar-parvw
*             AND kunn2 IN @s_dparw       "YiğitcanÖzdemir
             INTO TABLE @gt_knvp.
      ENDCASE.
      LOOP AT gt_knvp INTO ls_knvp.
        APPEND INITIAL LINE TO r_kunnr ASSIGNING <fs_kunnr>.
        <fs_kunnr>-sign   = 'I'.
        <fs_kunnr>-option = 'EQ'.
        <fs_kunnr>-low    = ls_knvp-kunnr.
      ENDLOOP.
    ENDIF.
*    ENDIF.

*    IF s_kparw[] IS NOT INITIAL AND p_selk IS NOT INITIAL.  "YiğitcanÖzdemir

    SELECT bukrs ,parvw ,ekorg
      FROM zreco_kpar
     WHERE bukrs IN @s_bukrs
     INTO TABLE @lt_kpar.

    IF sy-subrc EQ 0.

*      SELECT lifnr                                     "YiğitcanÖzdemir
*        FROM wyt3
*         FOR ALL ENTRIES IN @lt_kpar
*       WHERE lifnr IN @s_lifnr
*         AND ekorg EQ @lt_kpar-ekorg
*         AND parvw EQ @lt_kpar-parvw
**           AND lifn2 IN @s_kparw                     "YiğitcanÖzdemir
*         INTO TABLE @gt_wyt3.

      LOOP AT gt_wyt3 INTO ls_wyt3.
        APPEND INITIAL LINE TO r_lifnr ASSIGNING <fs_lifnr>.
        <fs_lifnr>-sign   = 'I'.
        <fs_lifnr>-option = 'EQ'.
        <fs_lifnr>-low    = ls_wyt3-lifnr.
      ENDLOOP.
    ENDIF.
*    ENDIF.

  ENDMETHOD.