if(CONFIG_MK_ROFS)
  set(DEST_DIR "${CMAKE_BINARY_DIR}/rofs_bin")
  set(TOOL_PATH "${CMAKE_BINARY_DIR}/tools")
  set(FILES_RELATIVE_PATH "${CMAKE_BINARY_DIR}/configure_file/")
  set(FLASH_BLK_SIZE 4096)
  set(FLASH_PAGE_SIZE 256)
  math(EXPR FLASH_IMG_SIZE "3 * 1024 * 1024")

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
    DEPENDS ${TOOL_PATH}/mklittlefs.bin
    DEPENDS ${DEST_DIR}/file_path.txt
    COMMENT "Generating filesystem bin in ${DEST_DIR}/flash_rofs.bin."
    VERBATIM
  )

  add_custom_target(rofs_bin ALL
    DEPENDS 
    ${DEST_DIR}/file_path.txt
    ${DEST_DIR}/flash_rofs.bin)

endif()