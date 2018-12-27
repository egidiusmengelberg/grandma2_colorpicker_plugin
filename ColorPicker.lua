--[[
Plugin written by: Egidius Mengelberg

This plugin is based on a plugin originally written by Jason Giaffo.
It is heavily modified to be used as an color picker plugin. (Like Christian Jackson uses)

--]]


--Configuration

--Numbers of Groups you want to use
local grpNum = {1,2,3,4,5,6}

local macStart = 1001
local seqStart = 1001
local startingPg = 500
local startingFader = 101
--layout view config
local layoutView = 1
local spacing = 0.1
--image config
local imgStart = 352
local allImgStart = 512

-- Filed images: list of image pool items with filled images
local filledImages = {304,305,306,307,308,309,310,311,312,313,314,315}

-- Unfiled images: List of image pool items with unfilled images
local unfilledImages = {320,321,322,323,324,325,326,327,328,329,330,331}
--Advanced config

--Do not change the following settings unless you know what you're doing.
--This plugin is designed to use the following colors:
    --White,
    --Red,
    --Orange,
    --Yellow,
    --Green,
    --Sea Green,
    --Cyan,
    --Lavender,
    --Blue,
    --Violet,
    --Magenta,
    --Pink

--Numbers of Color Pool Items
local pNum = {1,2,3,4,5,6,7,8,9,10,11,12}
-- Colors from Swatch Book.
local colSwatchBook = {'White', 'Red', 'Orange', 'Yellow', 'Green', 'Sea Green', 'Cyan', 'Lavender', 'Blue', 'Violet', 'Magenta', 'Pink'}

-- End of config

--From this point forward the plugin will actually do stuff

--Shortcut variables
local cmd = gma.cmd
local getHandle = gma.show.getobj.handle

--Functions
function getLabel(str)
  return gma.show.getobj.label(getHandle(str))
end


function getClass(str)
  return gma.show.getobj.class(getHandle(str))
end

function checkSpace(poolType, start, length, displayMessage) --checks if range of pool spaces is empty
  local finish = start + length - 1 --set our finishing point
  local errorMessage = poolType..' space conflict: please run plugin with a new '..poolType..' start slot'
  local emptyStatus = true
  for i = start, finish do
    if getClass(poolType..' '..tostring(i)) ~= nil then --if space is not empty
    emptyStatus = false
    if displayMessage == true then --return error message if this condition has been set
      gma.feedback(errorMessage)
        gma.echo(errorMessage)
    end
    break
    end
  end
  return emptyStatus
end


function advanceSpace(poolType, start, length)
  finalStart = start
  while checkSpace(poolType, finalStart, length) == false do
    finalStart = finalStart + 1
  end
  
  return finalStart
end


local function advanceExec(page, exec, ct, minExec)
  --check each spot from start until end
  --if there is a collision, function starts over at next available executor on page
  --if the executor number hits 100, 199, or 210, and there still are more to go, then
  --the count restarts on the next page at the minimum executor number.
  --if there is not enough space to pull this off on any page, the function returns nil and an error message
  local function getExecutorStatus(page, executor)  
    local slotStatus = gma.show.getobj.handle('Executor '..page..'.'..executor)
        
    if slotStatus then
    if getHandle('Executor '..page..'.'..executor..' Cue') then
      local c = getClass('Executor '..page..'.'..executor..' Cue')
      if c == "CMD_SEQUENCE" then
        return 'OFF'
      elseif c == "CMD_CUE" then
        return 'ON'
      end
    else
      return 'NON-SEQ'
    end
    else
    return 'EMPTY'
    end
  end
  
  local function checkPass(exec, ct)
    local limits = {100, 199, 210}
  local status_pass = true
  for i = 1, #limits do
    if exec <= limits[i] and (exec+ct-1) > limits[i] then 
    status_pass = false 
    break
    end   
  end
  
  return status_pass
  end
  
  local function checkNum(num)
    local limits = {100, 199, 210}
  local status_pass = true
  for i = 1, #limits do
    if num == limits[i] then status_pass = false; break; end;
  end
  
  return status_pass
  end

  local error_msg = 'Error: minExec set too high'
  
  if not minExec then minExec = 1 end
  if not ct then ct = 1 end
  
  local addPage = true
  if not checkPass(minExec, ct) then addPage = false end
  
  local pageCurrent = page
  local execCurrent = exec
  local pass = false

  while pass == false do
    if checkPass(execCurrent, ct) then
    for i = 1, ct do
      if getExecutorStatus(pageCurrent, execCurrent+i-1) == 'EMPTY' then
      if i == ct then pass = true end
      else
      if checkNum(execCurrent+i) then
        execCurrent = execCurrent + i
        break
      else
        if addPage then
          pageCurrent = pageCurrent + 1
          execCurrent = minExec
          break
        else
          return nil, error_msg
        end
      end
      end
    end
  else
    if addPage then
      pageCurrent = pageCurrent + 1
      execCurrent = minExec
    else
      return nil, error_msg
    end
  end
  end
  
  return pageCurrent, execCurrent
end


--Function to create a macro
function macStore(macroNum, label)
  gma.cmd('Store Macro 1.'..macroNum)
  gma.cmd('Label Macro 1.'..macroNum..' \"'..label..'\"')
end


--Function to add a line to a macro
function macLine (macroNum, lineNum, command, wait) 
  cmd('Store Macro 1.'..macroNum..'.'..lineNum)
  cmd('Assign Macro 1.'..macroNum..'.'..lineNum..'/cmd = \"'..command..'\"')
  if wait then cmd('Assign Macro 1.'..macroNum..'.'..lineNum..'/wait = \"'..wait..'\"') end
end


function match(a, b)            
  if a == b then return true
  elseif type(a) == 'string' and type(b) == 'string' then
    if string.find(string.lower(a), string.lower(b)) ~= nil or
     string.find(string.lower(b), string.lower(a)) ~= nil then
    return true
  else return false
  end
  else return false;
  end
end


function table.find(t, target, i, j)
  if i == nil then i = 1 end
  if j == nil then j = #t end
  for n = i, j do
    if match(t[n], target) == true then
    return n;
  end
  end
  return nil
end

return function()
-----------------------------------------------------------------
--------------------- START OF PLUGIN ---------------------------
-----------------------------------------------------------------

local pName = {}

gma.feedback('Starting to add items to preset list')

-- getting the names of colors based on the pool number
for p = 1, #pNum do
    pName[p] = getLabel('Preset 4.'..pNum[p])
  if (not pName[p]) then pName[p] = 'Color '..pNum[p] end
end

gma.feedback('All color presets are added')

local grpName = {}

gma.feedback('Starting to add items to group list')

-- getting the names of groups based on the group number
for g = 1, #grpNum do
  grpName[g] = getLabel('Group '..grpNum[g])
  if not grpName[g] then grpName[g] = 'Group '..grpNum[g] end
end

gma.feedback('All groups are aded')

gma.echo('Lists are created')
gma.echo('Groups: '..tostring(#grpNum))
gma.echo('colors: '..tostring(#pNum))

--Calculating places to store sequences and cues
local seqLength = #grpNum
seqStart = tonumber(seqStart)
seqStart = advanceSpace('Sequence', seqStart, seqLength)

local macroLength = (#grpNum + 1) * #pNum + 1
macStart = tonumber(macStart)
macStart = advanceSpace('Macro', macStart, macroLength)

local minExec
if startingFader < 100 then minExec = 1
else minExec = 101 end

startingPg, startingFader = advanceExec(startingPg, startingFader, seqLength, minExec)
cmd('Store Page '..startingPg)

--Initiate image pool items
local imageGrid = {}
local allImageGrid = {}

for i = 1, #grpNum do
    for j = 1, #pNum do
        if j == 1 then
            imageGrid[i] = {}
        end
        imageGrid[i][j] = imgStart
        imgStart = imgStart + 1
        cmd('Copy Image '..unfilledImages[j]..' At '..imageGrid[i][j]..' /m')
    end
    imgStart = imgStart + 4
end

for i = 1, #pNum do
    allImageGrid[i] = allImgStart
    allImgStart = allImgStart + 1
    cmd('Copy Image '..unfilledImages[i]..' At '..allImageGrid[i]..' /m')
end


local macCurrent = macStart
local seqCurrent = seqStart
local faderCurrent = startingFader

--clear the programmer
cmd('ClearAll')

--create layout view
cmd('Store Layout '..layoutView..' /o /nc')
cmd('Assign Layout '..layoutView..' /gridX=0')
cmd('Label Layout '..layoutView..' \"Color Picker\"')
cmd('ClearAll')

--initiate some variables
local str_storeOpt = ' /use=active /so=Prog /nc'
local imageCommand = ''
local posX = 0
local posY = 0

--main loop for creating sequences and referencing macros
for g = 1, #grpNum do
  local macGroup = {} 
  macGroup.start = macStart + (#pNum * (g-1))
  macGroup.final = macStart + (#pNum * g) - 1
  
  local execCurrent = tostring(startingPg..'.'..faderCurrent)
  
  for p = 1, #pNum do
      --create commands for image support
      imageCommand = 'Copy Image '..unfilledImages[1]..' Thru '..unfilledImages[#pNum]..' At '..imageGrid[g][1]..' /m; Copy Image '..filledImages[p]..' At '..imageGrid[g][p]..' /m'
    --create cue with color preset
    cmd('Group '..grpNum[g]..' At Preset 4.'..pNum[p]) --group at preset
      cmd('Store Sequence '..seqCurrent..' Cue '..p..str_storeOpt) --store to sequence and cue
      cmd('Assign Sequence '..seqCurrent..' Cue '..p..' /cmd = \"'..imageCommand..'\"')

      --if it is the first cue, assign it to an executor
        if p == 1 then
        cmd('Assign Sequence '..seqCurrent..' At Executor '..execCurrent) --assign sequence to executor
        end 

        --label the sequence and cues
      cmd('Label Sequence '..seqCurrent..' \"'..grpName[g]..' color\"'); 
      cmd('Label Sequence '..seqCurrent..' Cue '..p..' \"'..grpName[g]..' '..pName[p]..'\"');  

      --create macro and label it
      macStore(macCurrent, grpName[g]..' '..pName[p]) 
      macLine(macCurrent, 1, 'Goto Executor '..execCurrent..' Cue '..p)
      macLine(macCurrent, 2, 'Off Macro '..macGroup.start..' Thru '..macGroup.final..' - '..macCurrent)

      
      --change the appearance of the macro
      cmd('Appearance Macro '..macCurrent..' /color='..'"'..colSwatchBook[p]..'"')
      
      --clear your programmer
      cmd('ClearAll'); 

      --calculate positions for layout pool
      posX = (p + 0.5) * (1 + spacing)
      posY = (g + 0.5) * (1 + spacing)

      --add macro to layout pool
      cmd('Assign Macro '..macCurrent..' At Layout '..layoutView..'/x='..posX..' /y='..posY) 
      
      --increment macro counter
      macCurrent = macCurrent + 1
      --To use less processing power
      gma.sleep(0.05)
  end  
  --move to next sequence and fader number
  seqCurrent  = seqCurrent + 1 
  faderCurrent  = faderCurrent + 1
end

local seqEnd = seqCurrent - 1
local execFinal = tostring(startingPg..'.'..(faderCurrent - 1))

--All groups to color macros--
--calculate first free macro spot
local macCurrent = macStart + (#grpNum * #pNum)

for p = 1, #pNum do
  cmd('Store Macro '..macCurrent)
  cmd('Store Macro 1.'..macCurrent..'.1')
  cmd('Store Macro 1.'..macCurrent..'.2')
  cmd('Store Macro 1.'..macCurrent..'.3')
  cmd('Label Macro '..macCurrent..' \"All '..pName[p]..'\"')
  local t = 'Macro '..(macStart+p-1) --command for starting all macros
  
  --adding macro with same color to all command
  if #grpNum > 1 then
    local index = p - 1
    for p = 1, (#grpNum-1) do
      index = index + #pNum
      t = t..' + '..(macStart + index)
      end
  end
  
  cmd('Assign Macro 1.'..macCurrent..'.1 /cmd = \"'..t..'\"')
  cmd('Assign Macro 1.'..macCurrent..'.2 /cmd = \"Copy Image '..allImageGrid[1]..' Thru '..allImageGrid[#pNum]..' At '..allImageGrid[1]..' /m\"')
  cmd('Assign Macro 1.'..macCurrent..'.3 /cmd = \"Copy Image '..filledImages[p]..' At '..allImageGrid[p]..' /m\"')

  -- change the appearance of the macro
    cmd('Appearance Macro '..macCurrent..' /color='..'"'..colSwatchBook[p]..'"')

  --edit positions for layout pool
    posX = (p + 0.5) * (1 + spacing)
    posY = (#grpNum + 1.5) * (1 + spacing)

    --add macro to layout pool
    cmd('Assign Macro '..macCurrent..' At Layout '..layoutView..'/x='..posX..' /y='..posY) 

    --increment macro counter
  macCurrent = macCurrent + 1;
end

local mac_sys_start = macCurrent
local mac_uninstall = mac_sys_start + 2

--create lock uninstall macro
macStore(macCurrent, 'DISABLE Uninstall Color Picker')
macLine(macCurrent, 1, 'Lock Macro '..mac_uninstall)
macCurrent = macCurrent + 1


--create enable uninstall macro
macStore(macCurrent, 'ENABLE Uninstall Color Picker')
macLine(macCurrent, 1, 'Unlock Macro '..mac_uninstall)
macCurrent = macCurrent + 1


--create uninstall macro--
macStore(macCurrent, 'Uninstall Color Picker')
macLine(macCurrent, 1, 'Delete Layout '..layoutView..' /nc')
macLine(macCurrent, 2, 'Delete Sequence '..seqStart..' Thru '..seqEnd..' /nc')
macLine(macCurrent, 3, 'Delete Image '..imageGrid[1][1]..' Thru '..imageGrid[#grpNum][#pNum]..' /nc')
macLine(macCurrent, 4, 'Delete Image '..allImageGrid[1]..' Thru '..allImageGrid[#pNum]..' /nc')
macLine(macCurrent, 5, 'Delete Macro '..macStart..' Thru '..macCurrent..' /nc')

--lock uninstall macro
cmd('Macro '..mac_sys_start)

::EOF::
end
