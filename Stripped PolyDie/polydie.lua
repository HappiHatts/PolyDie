-- PolyDie Module 1.0.0
Internal = {}
Screens = {}
Internal.breakup = function(s, delimiter)
  local result = {}
    local from = 1
    local delimFrom, delimTo = string.find(s, delimiter, from)

    while delimFrom do
        table.insert(result, string.sub(s, from, delimFrom - 1))
        from = delimTo + 1
        delimFrom, delimTo = string.find(s, delimiter, from)
    end
    table.insert(result, string.sub(s, from))
    return result
end
Internal.getIndex = function(tbl,val)
  local nmm
  for i = 1,#tbl do
    if tbl[i] == val then
      nmm = i
      break
    end
  end
  return nmm
end
Internal.ToBoolean = function(str)
  if str == "true" then
    return true
  elseif str == "false" then
    return false
  else
    return nil
  end
end
Internal.checkExists = function(nme)
  local fiwle = love.filesystem.read(nme)
  if fiwle ~= nil then
    return true
  else
      return false
  end
end
Internal.CheckNumber = function(str)
  local test = tonumber(str)
  if test ~= nil then
    return true
  else
    return false
  end
end
Internal.CheckBoolean = function(str)
  local test = Internal.ToBoolean(str)
  if test ~= nil then
    return true
  else
    return false
  end
end
Internal.loadAsset = function(fle, Astyp, fold, Loop)
  --How to use:
  -- For Images: fle = Filename.type / type = "s" / fold = Folder name where fle is stored in Assets/Sprites / Char = "N/A" (it won't be read)
  -- For Scripts: fle = Filename (No .type)/ type = "lua" / fold and Char "N/A"
  -- For Audio:  fle = Filename.type / type = "a" / fold = Folder name where fle is stored in Assets/Audio / Char = Char where lines are stored (VaLib Only) / Loop = Boolean if you want it to loop.
  if Astyp == "a" then
		if fold then
			if Internal.checkExists("Assets/Audio/"..fold.."/"..fle) then
	      return love.audio.newSource("Assets/Audio/"..fold.."/"..fle, "static")
	    end
		else
			if Internal.checkExists("Assets/Audio/"..fle) then
	      return love.audio.newSource("Assets/Audio/"..fle, "static")
	    end
		end
  elseif Astyp == "s" then
		if fold then
			if Internal.checkExists("Assets/Sprites/"..fold.."/"..fle) then
	      return love.graphics.newImage("Assets/Sprites/"..fold.."/"..fle)
	    end
		else
			if Internal.checkExists("Assets/Sprites/"..fle) then
	      return love.graphics.newImage("Assets/Sprites/"..fle)
	    end
		end
  elseif Astyp == "lua" then
		if fold then
			if Internal.checkExists("Assets/Scripts/"..fold.."/"..fle) then
	      return love.filesystem.load("Assets/Scripts/"..fold.."/"..fle)
	    end
		else
			if Internal.checkExists("Assets/Scripts/"..fle) then
	      return love.filesystem.load("Assets/Scripts/"..fle)
	    end
		end
  else
    return nil
  end

end
Internal.deloadAsset = function(fle,Astyp)
  fle:release()
end
ActiveAssets = {}
ActiveAssets.S = {} -- Each Addition is a table in itself, 1 = loaded file, 2 = table with addons [x,y,r,sx,sy,ox,oy,kx,ky]
ActiveAssets.A = {} -- no table needed, Just loaded file
Internal.AddActiveAsset = function(fle,Astyp,Sheet,x,y,r,sx,sy,ox,oy,kx,ky)
  if Astyp == "a" then
    table.insert(ActiveAssets.A,#ActiveAssets.A+1,fle)
  elseif Astyp == "s" then
    if Sheet then
      table.insert(ActiveAssets.S,#ActiveAssets.S+1,{fle,{x,y,r,sx,sy,ox,oy,kx,ky},Sheet})
    else
      table.insert(ActiveAssets.S,#ActiveAssets.S+1,{fle,{x,y,r,sx,sy,ox,oy,kx,ky}})
    end
  end
end
Internal.RemoveActiveAsset = function(fle,Astyp,delod)
  if Astyp == "a" then
    table.remove(ActiveAssets.A, Internal.getIndex(ActiveAssets.A,fle))
  elseif Astyp == "s" then
		for i = 1,#ActiveAssets.S do
			if ActiveAssets.S[i][1] == fle then
				table.remove(ActiveAssets.S,i)
				break
			end
		end
  end
  if delod == true then
    Internal.deloadAsset(fle,Astyp)
  end
end
Internal.AudioSilence = function()
	for i = 1,#ActiveAssets.A do
		love.audio.stop(ActiveAssets.A)
		table.remove(ActiveAssets.A,i)
	end
end
Internal.SpriteSilence = function()
	for i = 1,#ActiveAssets.S do
		table.remove(ActiveAssets.S,i)
	end
end
Internal.ReadyAnimations = function(TxtFle,AstFle)
  local Anims = love.filesystem.read(TxtFle)
  local ImpAnims = Internal.breakup(Anims, "\n")
  local FullTBL = {}
  FullTBL.AnimList = {}
  local GridW
  local GridH
  local ERRs = {}
  local currentAnim = false
  for i = 1,#ImpAnims do
    local cmds = Internal.breakup(ImpAnims[i], "!!")
    if cmds[1]:gsub("%s+$", "") == "SetSheetGridW" then
      if Internal.CheckNumber(cmds[2]:gsub("%s+$", "")) then
        local fix = cmds[2]:gsub("%s+$", "")
        GridW = tonumber(fix)
      else
        table.insert(ERRs,#ERRs + 1,{
        false,
        "Err with Animation File",
        i,
        TxtFle,
        "Number not found for Grid Setup, Cannot Run!"})
      end
    elseif cmds[1]:gsub("%s+$", "") == "SetSheetGridH" then
      if Internal.CheckNumber(cmds[2]:gsub("%s+$", "")) then
        local fix = cmds[2]:gsub("%s+$", "")
        GridH = tonumber(fix)
      else
        table.insert(ERRs,#ERRs + 1,{
        false,
        "Err with Animation File",
        i,
        TxtFle,
        "Number not found for Grid Setup, Cannot Run!"})
      end
    elseif cmds[1]:gsub("%s+$", "") == "CreateAnim" then
      if currentAnim == false then
        currentAnim = cmds[2]:gsub("%s+$", "")
        FullTBL[currentAnim] = {}
        local fix = cmds[2]:gsub("%s+$", "")
        table.insert(FullTBL.AnimList, #FullTBL.AnimList +1,fix )
      else
        table.insert(ERRs,#ERRs + 1,{
        false,
        "Err with Animation File",
        i,
        TxtFle,
        "New Anim Started before closing previous, Cannot run!"})
      end
    elseif cmds[1]:gsub("%s+$", "") == "AnimSpeed" then
      if currentAnim ~= false then
        if Internal.CheckNumber(cmds[2]:gsub("%s+$", "")) then
          local fix = cmds[2]:gsub("%s+$", "")
          FullTBL[currentAnim].FPS = tonumber(fix)
        else
          table.insert(ERRs,#ERRs + 1,{
          false,
          "Err with Animation File",
          i,
          TxtFle,
          "Number not found for FPS, Cannot Run!"})
        end
      else
        table.insert(ERRs,#ERRs + 1,{
        true,
        "Err with Animation File",
        i,
        TxtFle,
        "No Anim defined for Command, Ignored."})
      end
    elseif cmds[1]:gsub("%s+$", "") == "Loop" then
      if currentAnim ~= false then
        if Internal.CheckBoolean((cmds[2]:gsub("%s+$", ""))) then
          local fix = cmds[2]:gsub("%s+$", "")
          FullTBL[currentAnim].Loop = Internal.ToBoolean(fix)
        else
          table.insert(ERRs,#ERRs + 1,{
          false,
          "Err with Animation File",
          i,
          TxtFle,
          "Boolean not found for Loop, Cannot Run!"})
        end
      else
        table.insert(ERRs,#ERRs + 1,{
        true,
        "Err with Animation File",
        i,
        TxtFle,
        "No Anim defined for Command, Ignored."})
      end
    elseif cmds[1]:gsub("%s+$", "") == "AddFrame" then
      if currentAnim ~= false then
        --
        if GridH and GridW then
          if Internal.CheckNumber(cmds[2]:gsub("%s+$", "")) and Internal.CheckNumber(cmds[3]:gsub("%s+$", "")) then
            local fixA = cmds[2]:gsub("%s+$", "")
            local fixB = cmds[3]:gsub("%s+$", "")
            local posA = tonumber(fixA)*GridW
            local posB = tonumber(fixB)*GridH
            table.insert(FullTBL[currentAnim], #FullTBL[currentAnim] + 1,love.graphics.newQuad(posA, posB, GridW, GridH, AstFle))
          else
            table.insert(ERRs,#ERRs + 1,{
            false,
            "Err with Animation File",
            i,
            TxtFle,
            "Number not found for Grid Poisiton, Cannot Run!"})
          end
        else
          table.insert(ERRs,#ERRs + 1,{
          false,
          "Err with Animation File",
          i,
          TxtFle,
          "Grid Never identified for Animation, Cannot Run!"})
        end
      else
        table.insert(ERRs,#ERRs + 1,{
        true,
        "Err with Animation File",
        i,
        TxtFle,
        "No Anim defined for Command, Ignored."})
      end
    elseif cmds[1]:gsub("%s+$", "") == "finAnim" then
      if currentAnim ~= false then
        currentAnim = false
      else
        table.insert(ERRs,#ERRs + 1,{
        true,
        "Err with Animation File",
        i,
        TxtFle,
        "No Anim defined for Command, Ignored."})
      end
    else
      table.insert(ERRs,#ERRs + 1,{
      true,
      "Err with Animation File",
      i,
      TxtFle,
      "Unknown Command Found. Ignored."})
    end
  end
  if GridW and GridH then
    FullTBL.FirFrame = love.graphics.newQuad(0, 0, GridW, GridH, AstFle)
  end
  if #ERRs == 0 then
    print("Succesfully loaded Animation "..TxtFle.." with no errors!")
    return FullTBL
  else
    local cntRun = false
    for i = 1,#ERRs do
      if ERRs[i][1] == false then
        cntRun = true
      end
    end
    if cntRun == true then
      print("Unable to load Animation "..TxtFle..". "..#ERRs.." errors found. Errors are printed below \n")
      return nil
    else
      print("Succesfully loaded Animation "..TxtFle.." with "..#ERRs.." errors found. Errors are printed below \n")
      return FullTBL
    end
    for i = 1,#ERRs do
      print(ERRs[i][2])
      print(ERRs[i][3])
      print(ERRs[i][4])
      print(ERRs[i][5].."\n")
    end
  end
end
ActiveAnims = {}
Internal.AddAnim = function(AnimTbl,Sheet,x,y,r,sx,sy,ox,oy,kx,ky)
	local Token = #ActiveAnims + 1
  local total = {
  frames = AnimTbl,
  fps = AnimTbl.FPS,
  loop = AnimTbl.Loop,
  currentFrame = 1,
  timer = 0,
	playedfrm = #AnimTbl,
  sheet = Sheet,
  prop = {x,y,r,sx,sy,ox,oy,kx,ky}
  }
  table.insert(ActiveAnims, #ActiveAnims + 1,total)
	return Token
end
Internal.KillAnim = function(Place)
  if Place ~= nil then
		table.remove(ActiveAnims, Place)
	end
end
Internal.deloadAnimations = function(tbl, Sheet)
	--Animation TBL goes like dis
	--Anim.AnimList = List of Anims
	--Anim.AnimName = Animation's List of frames
	--Anim.AnimName.FPS = Frames per second
	--Anim.FirFrame = First Frame of the Spritesheet
	for i = 1,#tbl.AnimList do
		for j = 1,#tbl[tbl.AnimList[i]] do
			local atet = tbl[tbl.AnimList[i]][j]
			atet:release()
		end
	end
	Sheet:release()
end
local CurScreen = false
local ActiveScreens = {}
local ScreenIDs = {}
Internal.BuildScreen = function(ScreenName)
	if CurScreen == false then
		CurScreen = ScreenName
		Screens[ScreenName] = {}
		Screens[ScreenName].IDs = {}
		Screens[ScreenName].ScreenName = ScreenName
	else
		print("Cannot Build Screen without closing previous screen")
	end
end
Internal.CreateButton = function(ButtonName,Fire,Img,Active,Visible,ButtonText,Trigger,Color,Transparency,TextColor,FillMode,Font,TextTransparency,x,y,w,h,r,sx,sy,ox,oy,kx,ky)
	--ButtonName: String
	--Fire: Function
	--Img: Loaded Image File (ignored if nil)
	--Active: Boolean (Is the button working?)
	--Visible: Boolean (Can It be seen?)
	--ButtonText: String (if no text, leave nil)
	--Color: Table of 3 values, {1,2,3} {R,G,B}
	--Transparency: Number from 1-0 determining Transparency
	--Trigger: String (Trigger)
	--Types of Triggers:
	--OnLeftClick
	--OnRightClick
	--OnDoubleClick
	--OnMouseHover
	--OnMouseLeave
	--
	--After that, Its the classic love2d properties! :D
	--(x,y,r,sx,sy,ox,oy,kx,ky)
	if CurScreen ~= false then
		if ButtonName ~= "IDs" and ButtonName ~= "ScreenName" then
			Screens[CurScreen][ButtonName] = {}
			Screens[CurScreen][ButtonName].UiTyp = "Button"
			Screens[CurScreen][ButtonName].Fire = Fire
			Screens[CurScreen][ButtonName].Img = Img
			Screens[CurScreen][ButtonName].Visible = Visible
			Screens[CurScreen][ButtonName].Trigger = Trigger
			Screens[CurScreen][ButtonName].Text = ButtonText
			Screens[CurScreen][ButtonName].Active = Active
			Screens[CurScreen][ButtonName].Prop = {x,y,r,sx,sy,ox,oy,kx,ky}
			Screens[CurScreen][ButtonName].RectProp = {w,h}
			Screens[CurScreen][ButtonName].Color = Color
			Screens[CurScreen][ButtonName].Transparency = Transparency
			Screens[CurScreen][ButtonName].UiID = ButtonName
			Screens[CurScreen][ButtonName].TextColor = TextColor
			Screens[CurScreen][ButtonName].FillMode = FillMode
			Screens[CurScreen][ButtonName].Font = Font
			Screens[CurScreen][ButtonName].TextTransparency = TextTransparency
			Screens[CurScreen][ButtonName].Hover = false
			Screens[CurScreen][ButtonName].DB = false
			table.insert(Screens[CurScreen].IDs,#Screens[CurScreen].IDs+1,ButtonName)
		else
			print("Name your UI Asset something else! IDs and ScreenName are keywords!")
		end
	end
end
Internal.CreateFrame = function(FrameName,Img,Visible,Color,Transparency,FillMode,x,y,w,h,r,sx,sy,ox,oy,kx,ky)
	if CurScreen ~= false then
		if FrameName ~= "IDs" and FrameName ~= "ScreenName" then
			Screens[CurScreen][FrameName] = {}
			Screens[CurScreen][FrameName].UiTyp = "Frame"
			Screens[CurScreen][FrameName].Img = Img
			Screens[CurScreen][FrameName].Visible = Visible
			Screens[CurScreen][FrameName].Prop = {x,y,r,sx,sy,ox,oy,kx,ky}
			Screens[CurScreen][FrameName].RectProp = {w,h}
			Screens[CurScreen][FrameName].Color = Color
			Screens[CurScreen][FrameName].Transparency = Transparency
			Screens[CurScreen][FrameName].UiID = FrameName
			Screens[CurScreen][FrameName].FillMode = FillMode
			table.insert(Screens[CurScreen].IDs,#Screens[CurScreen].IDs+1,FrameName)
		else
			print("Name your UI Asset something else! IDs and ScreenName are keywords!")
		end
	end
end
Internal.CreateLabel = function(LabelName,Img,Visible,LabelText,Color,Transparency,TextColor,FillMode,Font,TextTransparency,x,y,w,h,r,sx,sy,ox,oy,kx,ky)
	if CurScreen ~= false then
		if LabelName ~= "IDs" and LabelName ~= "ScreenName" then
			Screens[CurScreen][LabelName] = {}
			Screens[CurScreen][LabelName].UiTyp = "Label"
			Screens[CurScreen][LabelName].Img = Img
			Screens[CurScreen][LabelName].Visible = Visible
			Screens[CurScreen][LabelName].Text = LabelText
			Screens[CurScreen][LabelName].Prop = {x,y,r,sx,sy,ox,oy,kx,ky}
			Screens[CurScreen][LabelName].RectProp = {w,h}
			Screens[CurScreen][LabelName].Color = Color
			Screens[CurScreen][LabelName].Transparency = Transparency
			Screens[CurScreen][LabelName].UiID = LabelName
			Screens[CurScreen][LabelName].FillMode = FillMode
			Screens[CurScreen][LabelName].TextColor = TextColor
			Screens[CurScreen][LabelName].Font = Font
			Screens[CurScreen][LabelName].TextTransparency = TextTransparency
			table.insert(Screens[CurScreen].IDs,#Screens[CurScreen].IDs+1,LabelName)
		else
			print("Name your UI Asset something else! IDs and ScreenName are keywords!")
		end
	end
end
Internal.deloadUI = function(UIgrp)
	--Uigrp: String
	if ActiveScreens[UIgrp] then
		for i = 1,#ActiveScreens[UIgrp] do
			if ActiveScreens[UIgrp][i].Img then
				ActiveScreens[UIgrp][i].Img:release()
			end
		end
		ActiveScreens[UIgrp] = nil
	end
end
Internal.loadScreen = function(ScreenName)
	if Screens[ScreenName] then
		ActiveScreens[ScreenName] = {}
			table.insert(ScreenIDs,#ScreenIDs+1,ScreenName)
			for i = 1,#Screens[ScreenName].IDs do
				table.insert(ActiveScreens[ScreenName],#ActiveScreens[ScreenName]+1,Screens[ScreenName][Screens[ScreenName].IDs[i]])
			end
	end
end
Internal.RemoveActiveUI = function(ScreenName)
	if ActiveScreens[ScreenName] then
		table.remove(ScreenIDs,Internal.getIndex(ScreenIDs, ScreenName))
		ActiveScreens[ScreenName] = nil
	end
end
local TempPrompts = {}
Internal.AddTempPrompt = function(ScreenName,Time)
	if Screens[ScreenName] then
		table.insert(TempPrompts,#TempPrompts+1,{
			Screen = ScreenName,
			time = Time,
			counter = 0
		})
		Internal.loadScreen(ScreenName,Time)
	end
end
Internal.EditUIProp = function(Screen,ID,Prop,Edit)
	if Screens[Screen][ID][Prop] then
		Screens[Screen][ID][Prop] = Edit
	end
end
Internal.CloseCurScreen = function()
	CurScreen = false
end
Delays = {}
Internal.Delay = function(time,fun)
	table.insert(Delays,#Delays+1,{
		counter = time,
		fire = fun
	})
end
function love.draw()
  for i = 1,#ActiveAssets.S do
    if ActiveAssets.S[i] then
			if ActiveAssets.S[i][3] then
				love.graphics.draw(ActiveAssets.S[i][3], ActiveAssets.S[i][1], ActiveAssets.S[i][2][1], ActiveAssets.S[i][2][2], ActiveAssets.S[i][2][3], ActiveAssets.S[i][2][4], ActiveAssets.S[i][2][5], ActiveAssets.S[i][2][6], ActiveAssets.S[i][2][7], ActiveAssets.S[i][2][8], ActiveAssets.S[i][2][9])
			else
				love.graphics.draw(ActiveAssets.S[i][1], ActiveAssets.S[i][2][1], ActiveAssets.S[i][2][2], ActiveAssets.S[i][2][3], ActiveAssets.S[i][2][4], ActiveAssets.S[i][2][5], ActiveAssets.S[i][2][6], ActiveAssets.S[i][2][7], ActiveAssets.S[i][2][8], ActiveAssets.S[i][2][9])
			end
    end
  end
  for i = 1,#ActiveAssets.A do
    if ActiveAssets.A[i] then
      love.audio.play(ActiveAssets.A[i])
    else
      print("Failed to load Active sound asset: "..ActiveAssets.A[i])
    end
  end
  for _, anim in ipairs(ActiveAnims) do
    love.graphics.draw(anim.sheet,anim.frames[anim.currentFrame], anim.prop[1],anim.prop[2],anim.prop[3],anim.prop[4],anim.prop[5],anim.prop[6],anim.prop[7],anim.prop[8],anim.prop[9])
  end
	for i = 1,#ScreenIDs do
		for j = 1,#ActiveScreens[ScreenIDs[i]] do
			if ActiveScreens[ScreenIDs[i]][j].UiTyp == "Button" then
				local source = Screens[ScreenIDs[i]][ActiveScreens[ScreenIDs[i]][j].UiID]
				if source.Visible == true then
					if source.Color then
						love.graphics.setColor(source.Color[1], source.Color[2], source.Color[3], source.Transparency)
					end
					if source.Img then
						local fullpropTBL = source.Prop
						love.graphics.draw(source.Img, fullpropTBL[1], fullpropTBL[2], fullpropTBL[3], fullpropTBL[4], fullpropTBL[5], fullpropTBL[6], fullpropTBL[7], fullpropTBL[8], fullpropTBL[9])
					elseif source.RectProp and source.FillMode then
						love.graphics.rectangle(source.FillMode, source.Prop[1], source.Prop[2], source.RectProp[1], source.RectProp[2])
					end
					love.graphics.setColor(1, 1, 1, 1)
					if source.Text then
						if source.TextColor then
							love.graphics.setColor(source.TextColor[1], source.TextColor[2], source.TextColor[3], source.TextTransparency)
						end
						local fullpropTBL = source.Prop
						love.graphics.print(source.Text, fullpropTBL[1]+16, fullpropTBL[2]+16, fullpropTBL[3], fullpropTBL[4]*1.3, fullpropTBL[5]*1.3, fullpropTBL[6], fullpropTBL[7], fullpropTBL[8], fullpropTBL[9])
						love.graphics.setColor(1, 1, 1, 1)
					end
				end
			elseif ActiveScreens[ScreenIDs[i]][j].UiTyp == "Label" then
				local source = Screens[ScreenIDs[i]][ActiveScreens[ScreenIDs[i]][j].UiID]
				if source.Visible == true then
					if source.Color then
						love.graphics.setColor(source.Color[1], source.Color[2], source.Color[3], source.Transparency)
					end
					if source.Img then
						local fullpropTBL = source.Prop
						love.graphics.draw(source.Img, fullpropTBL[1], fullpropTBL[2], fullpropTBL[3], fullpropTBL[4], fullpropTBL[5], fullpropTBL[6], fullpropTBL[7], fullpropTBL[8], fullpropTBL[9])
					elseif source.RectProp and source.FillMode then
						love.graphics.rectangle(source.FillMode, source.Prop[1], source.Prop[2], source.RectProp[1], source.RectProp[2])
					end
					love.graphics.setColor(1, 1, 1, 1)
					if source.Text then
						if source.TextColor then
							love.graphics.setColor(source.TextColor[1], source.TextColor[2], source.TextColor[3], source.TextTransparency)
						end
						local fullpropTBL = source.Prop
						love.graphics.print(source.Text, fullpropTBL[1]+16, fullpropTBL[2]+16, fullpropTBL[3], fullpropTBL[4]*1.3, fullpropTBL[5]*1.3, fullpropTBL[6], fullpropTBL[7], fullpropTBL[8], fullpropTBL[9])
						love.graphics.setColor(1, 1, 1, 1)
					end
				end
			elseif ActiveScreens[ScreenIDs[i]][j].UiTyp == "Frame" then
				local source = Screens[ScreenIDs[i]][ActiveScreens[ScreenIDs[i]][j].UiID]
				if source.Visible == true then
					love.graphics.setColor(source.Color[1], source.Color[2], source.Color[3], source.Transparency)
					if source.Img then
						local fullpropTBL = source.Prop
						love.graphics.draw(source.Img, fullpropTBL[1], fullpropTBL[2], fullpropTBL[3], fullpropTBL[4], fullpropTBL[5], fullpropTBL[6], fullpropTBL[7], fullpropTBL[8], fullpropTBL[9])
					else
						love.graphics.rectangle(source.FillMode, source.Prop[1], source.Prop[2], source.RectProp[1], source.RectProp[2])
					end
					love.graphics.setColor(1, 1, 1, 1)
				end
			end
		end
	end
end
function love.update(dt)
	--Animation
	--BtlTok = ReturnBtl,
	--Side = Ally
    for meep, anim in ipairs(ActiveAnims) do
        anim.timer = anim.timer + dt
        if anim.timer >= 1 / anim.fps then
            anim.timer = anim.timer - 1 / anim.fps
            anim.currentFrame = anim.currentFrame % #anim.frames + 1
						if anim.loop == false then
		          anim.playedfrm = anim.playedfrm - 1
							if anim.playedfrm <= 0 then
								Internal.KillAnim(Internal.getIndex(ActiveAnims,anim))
							end
		        end
        end
    end
		--Ui Button Functions
		for i = 1,#ScreenIDs do
			for j = 1,#ActiveScreens[ScreenIDs[i]] do
				if ActiveScreens[ScreenIDs[i]][j].UiTyp == "Button" then
					local source = Screens[ScreenIDs[i]][ActiveScreens[ScreenIDs[i]][j].UiID]
					local mX, mY = love.mouse.getPosition()
					local ButtH = 0
					local ButtW = 0
					if source.Img then
						ButtH = source.Img:getHeight()
						ButtW = source.Img:getWidth()
					else
						ButtH = source.RectProp[2]
						ButtW = source.RectProp[1]
					end
					ActiveScreens[ScreenIDs[i]][j].Hover = mX >= source.Prop[1] and mX <= source.Prop[1] + ButtW and mY >= source.Prop[2] and mY <= source.Prop[2] + ButtH
					if ActiveScreens[ScreenIDs[i]][j].Hover == false and source.DB == true then
						ActiveScreens[ScreenIDs[i]][j].DB = false
						if source.Trigger == "OnMouseLeave" then
								source.Fire()
						end
					elseif ActiveScreens[ScreenIDs[i]][j].Hover == true and source.DB == false then
						ActiveScreens[ScreenIDs[i]][j].DB = true
						if source.Trigger == "OnMouseHover" then
							source.Fire()
						end
					end
				end
			end
		end
		--TempPrompts
		for i = 1,#TempPrompts do
			TempPrompts[i].counter = TempPrompts[i].counter + dt
			if TempPrompts[i].counter >= TempPrompts[i].time then
				Internal.RemoveActiveUI(TempPrompts[i].Screen)
				table.remove(TempPrompts,i)
			end
		end
		--Delay
		for i = 1,#Delays do
			Delays[i].counter = Delays[i].counter - dt
			if Delays[i].counter <= 0 then
				Delays[i].fire()
				table.remove(Delays,i)
			end
		end
end
function love.mousepressed(x, y, button, isTouch, presses)
	--Fire: Function
	--Active: Boolean (Is the button working?)
	--Trigger: String (Trigger)
	--Types of Triggers:
	--OnLeftClick
	--OnRightClick
	--OnDoubleClick
	--OnMouseHover
	--OnMouseLeave
	--
	for i = 1,#ScreenIDs do
		for j = 1,#ActiveScreens[ScreenIDs[i]] do
			if ActiveScreens[ScreenIDs[i]][j].UiTyp == "Button" and ActiveScreens[ScreenIDs[i]][j].Active == true and ActiveScreens[ScreenIDs[i]][j].Hover == true then
				local source = Screens[ScreenIDs[i]][ActiveScreens[ScreenIDs[i]][j].UiID]
				if source.Trigger == "OnLeftClick" then
					if button == 1 then
						source.Fire()
					end
				elseif source.Trigger == "OnRightClick" then
					if button == 2 then
						source.Fire()
					end
				elseif source.Trigger == "OnDoubleClick" then
					if presses == 2 then
						source.Fire()
					end
				end
			end
		end
	end
end
local PlDie = {}
PlDie.Internal = Internal

return PlDie
