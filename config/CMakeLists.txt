SET (GSchemaFile "ws.backbone.laview.desktop")
INCLUDE (GSchemaCommonRules)

CONFIGURE_FILE ("${CMAKE_CURRENT_SOURCE_DIR}/config.h.in"
                "${CMAKE_CURRENT_BINARY_DIR}/config.h")
