----------------------------------------------------------------------
-- ASEPRITE SCRIPT
-- 
-- Tilemap Map to Json
-- made by ryandvl
----------------------------------------------------------------------

-- API VERSION
if app.apiVersion < 22 then
  return app.alert("This script requires Aseprite v1.3-rc2")
end

-- SPRITE
local sprite = app.activeSprite
if not sprite then
  return app.alert("There is not a active sprite.")
end

-- VARIABLES
local fs = app.fs
local pixelColor = app.pixelColor
local outputPath
local outputFolderPath
local fileTitle
local outputMapFile

local function setPath(filename)
  outputPath = filename
  outputFolderPath = fs.filePathAndTitle(outputPath)
  fileTitle = fs.fileTitle(outputPath)
  outputMapFile = fs.joinPath(outputFolderPath, fileTitle .. ".map")
end

setPath(sprite.filename)

-- LAYERS
local function export_layers(sprite)
  local layers = {}
  
  for _, layer in ipairs(sprite.layers) do
    if layer.isTilemap then
      table.insert(layers, layer)
    end
  end

  return layers
end

-- TILEMAPS
local function export_tilemaps(layers)
  local tilemaps = {}
  
  for _, layer in ipairs(layers) do 
    for _, cell in ipairs(layer.cels) do
      local tilemap = cell.image
      if tilemap.colorMode == ColorMode.TILEMAP then
        table.insert(tilemaps, tilemap)
      end
    end
  end

  return tilemaps
end

-- TILEMAP
local function export_tilemap(tilemap)
  tiles = {}

  for pixel in tilemap:pixels() do
    table.insert(tiles, pixelColor.tileI(pixel()))
  end

  fileContent = ""
  x = 0
  y = 0
  for i, tile in ipairs(tiles) do
    if x == tilemap.width then
      fileContent = fileContent .. "\n"
      x = 0
      y = y + 1
    end

    if i == #tiles then
      fileContent = fileContent .. tile
    else
      fileContent = fileContent .. tile .. ","
    end

    x = x + 1
  end

  local mapFile = io.open(outputMapFile, "w")

  mapFile:write(fileContent)
  mapFile:close()
end

local function export()
  local layers = export_layers(sprite)
  local tilemaps = export_tilemaps(layers)

  for _, tilemap in ipairs(tilemaps) do
    export_tilemap(tilemap)
  end
end

local dialog = Dialog("Tilemap File Export")

local function save()
  fs.makeDirectory(outputFolderPath)

  export()
  dialog:close()
  
  dialog = Dialog("Tilemap File Export")
  dialog:separator {}
  dialog:label {
    id = "tilemap_label_success",
    label = "Success"
  }
  dialog:button {
    id = "tilemap_back",
    text = "Back",
    focus = true
  }
  dialog:show {
    wait = false,
    autoscrollbars = false
  }
end
dialog:separator {}
dialog:file {
  id = "tilemap_file_map_location",
  title = "Select location (.map)",
  label = "File .map",
  filename = fileTitle .. ".map",
  filetypes = { "map" },
  save = true,
  onchange = function(event)
    local data = dialog.data.tilemap_file_map_location
    
    setPath(data)
  end
}

dialog:button {
  id = "tilemap_cancel",
  text = "Cancel",
  focus = false
}
dialog:button {
  id = "tilemap_save",
  text = "Save",
  focus = true,
  onclick = save
}

dialog:show {
  wait = false,
  autoscrollbars = false
}
