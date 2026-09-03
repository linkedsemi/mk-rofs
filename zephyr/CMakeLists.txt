if(CONFIG_MK_ROFS)
  set(DEST_DIR "${CMAKE_BINARY_DIR}/rofs_bin")
  set(TOOL_PATH "${CMAKE_CURRENT_SOURCE_DIR}")
  set(FILES_RELATIVE_PATH "${CMAKE_BINARY_DIR}/configure_file/")
  set(FLASH_BLK_SIZE 4096)
  set(FLASH_PAGE_SIZE 256)
  math(EXPR FLASH_IMG_SIZE "2 * 1024 * 1024")

  file(MAKE_DIRECTORY ${FILES_RELATIVE_PATH})
  
  add_custom_command(
    OUTPUT ${DEST_DIR}/file_path.txt
    COMMAND find ${CMAKE_BINARY_DIR}/configure_file -type f 
            -exec realpath --relative-to=${CMAKE_BINARY_DIR}/configure_file {} \; 
            > ${DEST_DIR}/file_path.txt
    DEPENDS ${CMAKE_BINARY_DIR}/zephyr/zephyr.bin
    COMMENT "Generating configure file path."
    VERBATIM
  )

  add_custom_command(
    OUTPUT ${DEST_DIR}/flash_rofs.bin
    COMMAND ${TOOL_PATH}/mklittlefs -c ${FILES_RELATIVE_PATH} -T ${DEST_DIR}/file_path.txt -b ${FLASH_BLK_SIZE} -p ${FLASH_PAGE_SIZE} -s ${FLASH_IMG_SIZE} ${DEST_DIR}/flash_rofs.bin
    DEPENDS ${TOOL_PATH}/mklittlefs
    DEPENDS ${DEST_DIR}/file_path.txt
    COMMENT "Generating filesystem bin in ${DEST_DIR}/flash_rofs.bin."
    VERBATIM
  )

  if(CONFIG_MK_ROFS_BUILD_OUTPUT_ZSTD)
    # Compress the rofs binary with zstd if the tool is available on the system
    # (-k keeps the original .bin, which is still needed by downstream tools)
    find_program(ZSTD_EXECUTABLE zstd)
    if(ZSTD_EXECUTABLE)
      add_custom_command(
        OUTPUT ${DEST_DIR}/flash_rofs.bin.zst
        COMMAND ${ZSTD_EXECUTABLE} -f -22 --ultra --zstd=windowLog=19 --check -k ${DEST_DIR}/flash_rofs.bin
        DEPENDS ${DEST_DIR}/flash_rofs.bin
        COMMENT "Compressing filesystem bin to ${DEST_DIR}/flash_rofs.bin.zst."
        VERBATIM
      )
    else()
      message(WARNING "zstd not found, skip compressing ${DEST_DIR}/flash_rofs.bin")
    endif()
  endif()

  if(CONFIG_MK_ROFS_BUILD_OUTPUT_GZIP)
    # Compress the rofs binary with gzip if the tool is available on the system
    find_program(GZIP_EXECUTABLE gzip)
    if(GZIP_EXECUTABLE)
      add_custom_command(
        OUTPUT ${DEST_DIR}/flash_rofs.bin.gz
        COMMAND ${GZIP_EXECUTABLE} -f -9 -k ${DEST_DIR}/flash_rofs.bin
        DEPENDS ${DEST_DIR}/flash_rofs.bin
        COMMENT "Compressing filesystem bin to ${DEST_DIR}/flash_rofs.bin.gz."
        VERBATIM
      )
    else()
      message(WARNING "gzip not found, skip compressing ${DEST_DIR}/flash_rofs.bin")
    endif()
  endif()

  set(ROFS_COMPRESS_DEPS)
  if(CONFIG_MK_ROFS_BUILD_OUTPUT_ZSTD AND ZSTD_EXECUTABLE)
    list(APPEND ROFS_COMPRESS_DEPS ${DEST_DIR}/flash_rofs.bin.zst)
  endif()
  if(CONFIG_MK_ROFS_BUILD_OUTPUT_GZIP AND GZIP_EXECUTABLE)
    list(APPEND ROFS_COMPRESS_DEPS ${DEST_DIR}/flash_rofs.bin.gz)
  endif()

  add_custom_target(rofs_bin ALL
    DEPENDS
    ${DEST_DIR}/file_path.txt
    ${DEST_DIR}/flash_rofs.bin
    ${ROFS_COMPRESS_DEPS})

endif()
