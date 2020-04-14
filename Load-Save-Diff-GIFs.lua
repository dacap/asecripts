local DIR = os.getenv("GIFDIR")
if not DIR then
  print("Define GIFDIR environment variable with the path where .gif files are")
end

function compareSprites(sprA, sprB)
  assert(sprA.width == sprB.width)
  assert(sprA.height == sprB.height)
  assert(#sprA.frames == #sprB.frames)
  assert(#sprA.cels == #sprB.cels)
  for i = 1, #sprA.frames do
    assert(sprA.frames[i].duration == sprB.frames[i].duration)
  end

  local rgba = app.pixelColor.rgba
  local celsA = sprA.cels
  local celsB = sprB.cels
  local saveDiff = false
  for i = 1, #celsA do
    local imgA = celsA[i].image
    local imgB = celsB[i].image

    if sprA.colorMode == ColorMode.RGB and
       sprB.colorMode == ColorMode.INDEXED then
      newImgB = Image(imgA.spec)
      local palB = sprB.palettes[1]
      print("palB size" .. #palB)
      local w = imgB.width
      local h = imgB.height
      for y=0,h-1 do
	for x=0,w-1 do
	  local i = imgB:getPixel(x, y)
	  if i < #palB then
	    newImgB:putPixel(x, y, palB:getColor(i))
	  else
	    newImgB:putPixel(x, y, rgba(0, 0, 255, 255))
	  end
	end
      end
      imgB = newImgB
    elseif sprA.colorMode == ColorMode.INDEXED and
           sprB.colorMode == ColorMode.RGB then
      newImgA = Image(imgB.spec)
      local palA = sprA.palettes[1]
      local w = imgA.width
      local h = imgA.height
      for y=0,h-1 do
	for x=0,w-1 do
	  newImgA:putPixel(x, y, palA:getColor(imgA:getPixel(x, y)))
	end
      end
      imgA = newImgA
    else
      assert(sprA.colorMode == sprB.colorMode)
    end

    if not imgA:isEqual(imgB) then
      saveDiff = true

      local w = imgA.width
      local h = imgA.height

      if imgB.colorMode == ColorMode.INDEXED then
	sprB.palettes[1]:resize(256)
	sprB.palettes[1]:setColor(255, Color(255, 255, 0))
	yellow = 255;
      else
	yellow = rgba(255, 255, 0)
      end

      for y=0,h-1 do
	for x=0,w-1 do
	  if imgA:getPixel(x, y) ~= imgB:getPixel(x, y) then
	    imgB:putPixel(x, y, yellow)
	  end
	end
      end
    end
  end
  if saveDiff then
    local outputFullFn = sprA.filename .. "-OUTPUT-DIFF.gif"
    print("  - Saving DIFFERENCES "..outputFullFn)
    sprB:saveAs(outputFullFn)
  end
end

function processDir(dir)
  for i,fn in pairs(app.fs.listFiles(dir)) do
    local fullFn = app.fs.joinPath(dir, fn)
    if app.fs.isDirectory(fullFn) then
      processDir(fullFn)
    elseif string.lower(app.fs.fileExtension(fullFn)) == "gif" then
      if not string.match(app.fs.fileTitle(fullFn), "OUTPUT") then
	print("Loading "..fullFn)
	local spr = Sprite{ fromFile=fullFn }
	if spr then
	  local outputFullFn = spr.filename .. "-OUTPUT.gif"
	  print("  - Saving "..outputFullFn)
	  spr:saveCopyAs(outputFullFn)

	  local spr2 = Sprite{ fromFile=outputFullFn }
	  compareSprites(spr, spr2)
	end
      end
    end
  end
end

processDir(DIR)
