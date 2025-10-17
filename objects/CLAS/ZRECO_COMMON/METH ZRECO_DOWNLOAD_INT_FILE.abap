  METHOD  zreco_download_int_file.

    DATA: lt_files         TYPE zreco_tt_down_files,
          ls_files         TYPE zreco_s_down_files,
          lv_count         TYPE i,
          lv_filename      TYPE string,
          lv_path          TYPE string,
          lv_fullpath      TYPE string,
          lv_folder        TYPE string,
          lv_show_prg      TYPE abap_boolean,
          lv_total_count   TYPE n LENGTH 4,
          lv_current_count TYPE n LENGTH 4,
          lv_progress_mes  TYPE c LENGTH 1000,
          lt_binary        TYPE TABLE OF zreco_x255,
          lv_filex         TYPE xstring.

    FREE : lt_files,ls_files,lv_count,
           lv_filename,lv_path,lv_fullpath,lv_folder.

    CHECK it_files[] IS NOT INITIAL.

    lt_files[] = it_files[].

    DATA(lv_char_lines) = lines( lt_files ).

    IF lv_count > 1.
*      CALL METHOD cl_gui_frontend_services=>directory_browse                               "D_MBAYEL
*        EXPORTING
*          window_title         = 'Kayıt Klasörü Seçiniz!'
*        CHANGING
*          selected_folder      = lv_folder
*        EXCEPTIONS
*          cntl_error           = 1
*          error_no_gui         = 2
*          not_supported_by_gui = 3
*          OTHERS               = 4.
      IF sy-subrc <> 0 OR lv_folder IS INITIAL.
        EXIT.
      ENDIF.

      lv_show_prg = space.

    ELSEIF lv_count EQ 1.
      LOOP AT lt_files INTO ls_files.
        EXIT.
      ENDLOOP.

      lv_filename = ls_files-filename.

*      CALL METHOD cl_gui_frontend_services=>file_save_dialog                               "D_MBAYEL Commentlenmiştir
*        EXPORTING
*          window_title         = 'Dosya Kayıt Yolu'
*          file_filter          = i_filter
*          default_file_name    = lv_filename
*        CHANGING
*          filename             = lv_filename
*          path                 = lv_path
*          fullpath             = lv_fullpath
*        EXCEPTIONS
*          cntl_error           = 1
*          error_no_gui         = 2
*          not_supported_by_gui = 3
*          OTHERS               = 4.
      IF sy-subrc <> 0 OR lv_fullpath IS INITIAL.
        EXIT.
      ENDIF.

      lv_show_prg = 'X'.
    ENDIF.

    CLEAR: lv_total_count,lv_current_count.

    lv_total_count = lines( lt_files ).

    LOOP AT lt_files INTO ls_files.
      CLEAR: lt_binary,lv_filex.

      lv_filex = ls_files-filex.

      IF lv_count > 1.
        CONCATENATE lv_folder '\' ls_files-filename INTO lv_fullpath.

*        ADD 1 TO lv_current_count.
        lv_current_count = lv_current_count + 1.
        CONCATENATE TEXT-003 lv_current_count '/' lv_total_count INTO lv_progress_mes SEPARATED BY space.

*        CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'                                             "D_MBAYEL Commentlenmiştir
*          EXPORTING
*            text = lv_progress_mes.
      ENDIF.

*      CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'                                                   "D_MBAYEL Commentlenmiştir
*        EXPORTING
*          buffer        = lv_filex
*        IMPORTING
*          output_length = ls_files-lenght
*        TABLES
*          binary_tab    = lt_binary[].

*      CALL METHOD cl_gui_frontend_services=>gui_download                                         "D_MBAYEL Commentlenmiştir
*        EXPORTING
*          bin_filesize              = ls_files-lenght
*          filename                  = lv_fullpath
*          filetype                  = 'BIN'
*          append                    = space
*          write_field_separator     = space
*          header                    = '00'
*          trunc_trailing_blanks     = space
*          write_lf                  = 'X'
*          col_select                = space
*          col_select_mask           = space
*          dat_mode                  = space
*          confirm_overwrite         = space
*          no_auth_check             = space
*          codepage                  = space
*          ignore_cerr               = abap_true
*          replacement               = '#'
*          write_bom                 = space
*          trunc_trailing_blanks_eol = 'X'
*          wk1_n_format              = space
*          wk1_n_size                = space
*          wk1_t_format              = space
*          wk1_t_size                = space
*          show_transfer_status      = lv_show_prg
*        CHANGING
*          data_tab                  = lt_binary
*        EXCEPTIONS
*          file_write_error          = 1
*          no_batch                  = 2
*          gui_refuse_filetransfer   = 3
*          invalid_type              = 4
*          no_authority              = 5
*          unknown_error             = 6
*          header_not_allowed        = 7
*          separator_not_allowed     = 8
*          filesize_not_allowed      = 9
*          header_too_long           = 10
*          dp_error_create           = 11
*          dp_error_send             = 12
*          dp_error_write            = 13
*          unknown_dp_error          = 14
*          access_denied             = 15
*          dp_out_of_memory          = 16
*          disk_full                 = 17
*          dp_timeout                = 18
*          file_not_found            = 19
*          dataprovider_exception    = 20
*          control_flush_error       = 21
*          not_supported_by_gui      = 22
*          error_no_gui              = 23
*          OTHERS                    = 24.
      IF sy-subrc NE 0.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.