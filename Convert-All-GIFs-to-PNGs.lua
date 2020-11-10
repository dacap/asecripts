local DIR = "."
local INPUT_FORMAT = "gif"
local OUTPUT_SUFFIX = "00.png"

local function processDir(dir)
  for i,fn in pairs(app.fs.listFiles(dir)) do
    local fullFn = app.fs.joinPath(dir, fn)
    if app.fs.isDirectory(fullFn) then
      processDir(fullFn)
    elseif string.lower(app.fs.fileExtension(fullFn)) == INPUT_FORMAT then
      print("Loading " .. fullFn)

      local spr = Sprite{ fromFile=fullFn }
      if spr then
        local path = app.fs.fileTitle(spr.filename)
        local title = app.fs.fileTitle(spr.filename)
        local outputFullFn = app.fs.joinPath(app.fs.joinPath(dir, title),
                                             title .. OUTPUT_SUFFIX)
        print(" -> Saving " .. outputFullFn)
        spr:saveCopyAs(outputFullFn)
      end
    end
  end
end

processDir(DIR)
