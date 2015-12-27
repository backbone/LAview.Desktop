INCLUDE (PkgConfigCommonRules)

CONFIGURE_FILE (
  "${CMAKE_SOURCE_DIR}/cmake/backbone/templates/pkg-config.pc.in"
  "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_LOWERCASE_NAME}-${MAJOR}.pc"
)
