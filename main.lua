--[[--------------------------------------------------

  Macro Tooltips [MacroTT-V] v1.0.0
  
  Vanilla WoW addon to add custom tooltip text to
  macros, since #showtooltip doesn't exist yet in
  the the 1.12 universe.

  Should work with default bars and Bongos.
  
  https://github.com/fulzamoth

  Inspired by Anaron's MacroTooltip

--------------------------------------------------]]--


SLASH_MACROTT1="/mtts";
SLASH_MACROTT2="/mtte";
SLASH_MACROTT3="/mttc";
SLASH_MACROTT4="/mtta";
SlashCmdList["MACROTT"] = function(Flag) 
end
  
function trim(s)
  return (string.gsub(s,"^%s*(.-)%s*$", "%1"))
end

function ActionButton_SetTooltip()
  if ( GetCVar("UberTooltips") == "1" ) then
    GameTooltip_SetDefaultAnchor(GameTooltip, this);
  else
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
  end
  local button 
  if BActionButton then  -- Checks if the button is a Bongos button
    button = BActionButton.GetPagedID(this:GetID())
  else
    button = ActionButton_GetPagedID(this)
  end
  local buttonMacroName = GetActionText(button)

  customTooltip = false
  if buttonMacroName then
    for macroSlot = 1, 36, 1 do
      macroName,_,macroBody = GetMacroInfo(macroSlot)
      if buttonMacroName == macroName then
        break
      elseif not macroName then -- we've run through available macros in this tab
        if macroSlot <= 18 then -- if we're in the General macro tab still...
          macroSlot = 18        -- ...skip to last slot in General so loop starts in Character tab next
        else
          break                 -- we're all out of macros to check.
        end
      end
    end

    for macroLine in string.gfind(macroBody, "[^%\n]+") do
      repeat  
        --[[
          /mttsp - tooltip from spell
        ]]
        if string.find(macroLine, "^/mtts ") then
          local spellName, spellRank, rankedSpellSlot
          rankStart, rankEnd = string.find(macroLine,"%(Rank %d+%)")
          if rankStart then
            spellName = trim(string.sub(macroLine, 7, rankStart - 1))
            spellRank = string.sub(macroLine, rankStart + 1, rankEnd - 1)
          else
            spellName = trim(string.sub(macroLine, 7))
          end
          local spellSlot = 1
          while true do
            bookSpellName, bookSpellRank = GetSpellName(spellSlot, "player")
            if not bookSpellName then -- We've reached the end of the spellbook
              break
            end
            if spellRank then
              if bookSpellName == spellName and bookSpellRank == spellRank then 
                rankedSpellSlot = spellSlot
                spellHighRank = bookSpellRank
                break
              end
            elseif bookSpellName == spellName then
              rankedSpellSlot = spellSlot -- Store the spell slot; we'll keep checking for higher rank
              spellHighRank = bookSpellRank
            end
            spellSlot = spellSlot + 1
          end
          GameTooltip:SetSpell(rankedSpellSlot,"player")
          if not (spellHighRank == '') then
            GameTooltip:AddLine("(" .. spellHighRank ..")",0.5,0.5,0.5)
          end
          this.updateTooltip = TOOLTIP_UPDATE_TIME;
          customTooltip = true
          break
        end
        --[[
          /mtte - tooltip from equipped item
        ]]
        if string.find(macroLine, "^/mtte ") then
          itemSlots = { -- These are the WoW Inventory Slot IDs
                ammo = 0, 
                head = 1, 
                neck = 2, 
                shoulder = 3, 
                body = 4, 
                chest = 5, 
                waist = 6, 
                legs = 7, 
                feet = 8,
                wrist = 9, 
                hands = 10,  
                finger = 11, 
                finger1 = 12, 
                trinket = 13, 
                trinket2 = 14, 
                cloak = 15,
                mainhand = 16, 
                offhand = 17, 
                ranged = 18,
                wand = 18,
                tabard = 19 
                }

          equipSlot = itemSlots[string.sub(macroLine, 7)] or tonumber(string.sub(macroLine, 7))
          if GetInventoryItemLink("player", equipSlot) then -- check to see if anything is equipped in this slot
            GameTooltip:SetInventoryItem("player", equipSlot )
          else
            GameTooltip:SetText("No item equipped in slot " .. equipSlot,1,1,0.5)
          end   
          this.updateTooltip = TOOLTIP_UPDATE_TIME;
          customTooltip = true
          break
        end
        --[[
          /mttc - custom tooltip header text
        ]]
        if string.find(macroLine, "^/mttc ") then
          GameTooltip:SetText(string.sub(macroLine, 7),0.9,1,1)
          this.updateTooltip = TOOLTIP_UPDATE_TIME;
          customTooltip = true
          break
        end
        --[[
          /mtta - additional text for tooltip
        ]]
        if string.find(macroLine, "^/mtta") then
          GameTooltip:AddLine(string.sub(macroLine, 7) .. " " ,0,0.80,0.81) -- appended space allows for blank lines in tooltip
          this.updateTooltip = TOOLTIP_UPDATE_TIME;
          customTooltip = true
          break
        end
      until true
    end
  end
  if DAB_INITIALIZED then -- Enables Discord Action Bars "Modify Tooltip" option if DAB is running
    if (DAB_Settings[DAB_INDEX].ModifyTooltip) then
      GameTooltip:AddLine(DAB_TEXT.ButtonID..this:GetID().."     "..DAB_TEXT.ActionID..this:GetActionID(), .6, .6, .6, .6, .6, .6);
      GameTooltip:SetHeight(GameTooltip:GetHeight() + 15);
      if (GameTooltip:GetWidth() < 200) then
        GameTooltip:SetWidth(200);
      end
    end
  end
  if customTooltip then
    GameTooltip:Show()
    this.updateTooltip = nil; 
  elseif ( GameTooltip:SetAction(button) ) then
    this.updateTooltip = TOOLTIP_UPDATE_TIME;
  else
    this.updateTooltip = nil;
  end
end

if BActionButton then -- Hook Bongos Bar tooltip
  BActionButton.UpdateTooltip = ActionButton_SetTooltip 
end 

if DAB_ActionButton_OnEnter then -- Hook Discord Action Bars tooltip
  mtt_DAB_ActionButton_OnEnter = DAB_ActionButton_OnEnter
  function DAB_ActionButton_OnEnter()
    mtt_DAB_ActionButton_OnEnter()
  	local bar = DAB_Settings[DAB_INDEX].Buttons[this:GetID()].Bar;
  	if (bar ~= "F" and DAB_Settings[DAB_INDEX].Bar[bar].disableTooltips) then return; end
	  if (bar == "F" and DAB_Settings[DAB_INDEX].Floaters[id].disableTooltip) then return; end
    ActionButton_SetTooltip()
  end
end 
