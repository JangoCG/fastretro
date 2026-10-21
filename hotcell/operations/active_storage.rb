require "active_storage/hot_cell/server/transformers/image/vips"
require "active_storage/hot_cell/server/analyzers/image/vips"

Vips.block "VipsForeignLoadOpenslide", true
Vips.block "VipsForeignLoadTiff", true
