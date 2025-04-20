----------------------------------------------------------------------------------
-- MIT License
--
-- Copyright (c) 2024 A. Dominik (@aubs-dev)
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
----------------------------------------------------------------------------------

-- Sprite Checking
function SpriteExists()
    local spr = app.sprite
    if spr then
        return true
    else
        app.alert { title = scriptName, text = "Select a sprite first." }
        return false
    end
end

-- Input Functions
function InputGetDimensions()
    local data = Dialog { title = "Save grid as sprites:" }
        :entry { label = "Width:", id = "width", text = "16" }
        :entry { label = "Height:", id = "height", text = "16" }
        :separator { id = "separator", text = "(optional)" }
        :entry { label = "File Names:", id = "fileNames", text = "", focus = true }
        :label { id = "info", label = "- comma separated list" }
        :separator { id = "separator" }
        :button { id = "confirm", text = "Confirm" }
        :button { id = "cancel", text = "Cancel" }
        :show().data

    if data.cancel then
        return false, nil, nil, {}
    end

    if data.confirm then
        local width = tonumber(data.width)
        local height = tonumber(data.height)
        local nameList = {}

        for name in string.gmatch(data.fileNames, "([^,]+)") do
            table.insert(nameList, name)
        end

        return true, width, height, nameList
    else
        app.alert { title = scriptName, text = "Script cancelled :]" }
        return false, nil, nil, {}
    end
end

function ExportGrid()
    -- Variables
    local scriptName = "Sprite As Grid"
    local spr = app.sprite
    local success, width, height, fileNames = InputGetDimensions()

    -- Sprite Exporter
    if success then
        if width ~= nil and height ~= nil then
            if width > 0 and height > 0 then
                -- Calculate rows & columns based on grid size
                width = math.floor(width)
                height = math.floor(height)

                local rows = math.floor(spr.height / height)
                local cols = math.floor(spr.width / width)

                -- For each sub-sprite in the grid, save as new file
                local counter = 0
                local baseDirectory = ""

                for y = 0, rows - 1 do
                    for x = 0, cols - 1 do
                        -- Create sprite from crop
                        local copy = Sprite(spr.width, spr.height, spr.colorMode)

                        copy:newCel(copy.layers[1], 1, spr.cels[1].image)
                        copy:crop(x * width, y * height, width, height)

                        if counter == 0 then
                            -- Get base filepath by prompting user to manually save the first file
                            app.activeSprite = copy

                            -- Load file name if provided
                            local outputFileName = "output_0.png"

                            if next(fileNames) ~= nil then
                                outputFileName = string.format("%s.png", fileNames[counter + 1])
                            end

                            -- Save cropped sub-sprite & get it's base filepath
                            app.command.SaveFileAs {
                                filename = outputFileName,
                            }

                            baseDirectory = app.fs.filePath(copy.filename)

                            -- Close sub-sprite file
                            app.command.CloseFile()

                            app.activeSprite = spr
                        else
                            -- Load file name if provided
                            local outputFileName = string.format("%s/output_%d.png", baseDirectory, counter)

                            if next(fileNames) ~= nil then
                                if counter < #fileNames then
                                    outputFileName = string.format("%s/%s.png", baseDirectory, fileNames[counter + 1])
                                end
                            end

                            -- Save cropped sub-sprite
                            copy:saveAs(outputFileName)

                            -- Close sub-sprite file
                            app.command.CloseFile()
                        end

                        counter = counter + 1
                    end
                end

                app.alert { title = scriptName, text = "Export completed! (^_^)" }
            else
                app.alert { title = scriptName, text = "Error: 'width' or 'height' is not a positive integer (T_T)" }
            end
        else
            app.alert { title = scriptName, text = "Error: 'width' or 'height' field was not set correctly (T_T)" }
        end
    end
end

function init(plugin)
    plugin:newCommand {
        id = "export-sprite-grid",
        title = "Export Sprite Grid",
        group = "file_export_1",
        onclick = function()
            ExportGrid()
        end
    }
end

function exit(plugin) end
