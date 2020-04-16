local DIR = os.getenv("IMAGESDIR")
if not DIR then
  print("Define IMAGESDIR environment variable with the path where .jpg files are")
end

function processDir(dir)
  for i,fn in pairs(app.fs.listFiles(dir)) do
    local fullFn = app.fs.joinPath(dir, fn)
    if app.fs.isDirectory(fullFn) then
      processDir(fullFn)
    elseif string.lower(app.fs.fileExtension(fullFn)) == "jpg" then
      local spr = Sprite{ fromFile=fullFn }
      if spr and spr.colorMode == ColorMode.RGB then
        app.command.ChangePixelFormat{ format="indexed" }
        assert(spr.colorMode == ColorMode.INDEXED)
      end
    end
  end
end

processDir(DIR)
