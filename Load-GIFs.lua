local DIR = os.getenv("GIFDIR")
if not DIR then
  print("Define GIFDIR environment variable with the path where .gif files are")
end

function showSpriteProperties(spr)
  local rgbaA = app.pixelColor.rgbaA

  local str = spr.width .. "x" .. spr.height .. " "
  if spr.colorMode == ColorMode.RGB then str = str .. "RGB"
  elseif spr.colorMode == ColorMode.INDEXED then str = str .. "INDEXED"
  elseif spr.colorMode == ColorMode.GRAYSCALE then str = str .. "GRAYSCALE"
  else str = str .. "UNKNOWN"
  end

  if spr.layers[1].isBackground then
    str = str .. " Background-Layer"
  else
    str = str .. " Transparent-Layer"
  end

  if spr.colorMode == ColorMode.INDEXED then
    str = str .. " (MaskIndex=" .. spr.transparentColor .. ")"
  end

  local hasTransparent = false
  if spr.layers[1].isTransparent then
    local cels = spr.cels
    for i = 1, #cels do
      local img = cels[i].image
      if img.colorMode == ColorMode.RGB then
	for it in img:pixels() do
	  if rgbaA(it()) == 0 then
	    hasTransparent = true
	    break
	  end
	end
      elseif spr.colorMode == ColorMode.INDEXED then
	for it in img:pixels() do
	  if it() == spr.transparentColor then
	    hasTransparent = true
	    break
	  end
	end
      end
      if hasTransparent == true then
	break
      end
    end
  end

  if hasTransparent then
    str = str .. " hasTransparent"
    if spr.layers[1].isBackground then
      str = str .. " (BUT LAYER IS BACKGROUND)"
    end
  else
    str = str .. " isOpaque"
    if spr.layers[1].isTransparent then
      str = str .. " (BUT LAYER IS TRANSPARENT)"
    end
  end

  return str
end

function processDir(dir)
  for i,fn in pairs(app.fs.listFiles(dir)) do
    local fullFn = app.fs.joinPath(dir, fn)
    if app.fs.isDirectory(fullFn) then
      processDir(fullFn)
    elseif string.lower(app.fs.fileExtension(fullFn)) == "gif" then
      if not string.match(app.fs.fileTitle(fullFn), "OUTPUT") then
	print("Loading: " .. fullFn)
	local spr = Sprite{ fromFile=fullFn }
	if spr then
	  print("DESC: " .. showSpriteProperties(spr))
	else
	  print("NIL")
	end
	print("")
      end
    end
  end
end

processDir(DIR)
