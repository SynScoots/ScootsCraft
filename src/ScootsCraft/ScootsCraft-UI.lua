ScootsCraft.addEnableButton = function()
    if(not ScootsCraft.enableButtonAdded) then
        ScootsCraft.frames.enableButton = CreateFrame('Button', 'ScootsCraft-EnableButton', _G['TradeSkillFrame'], 'UIPanelButtonTemplate')
        ScootsCraft.frames.enableButton:SetSize(22, 19)
        ScootsCraft.frames.enableButton:SetPoint('TOPLEFT', _G['TradeSkillFrame'], 'TOPLEFT', 70, -14)
        ScootsCraft.frames.enableButton:SetFrameStrata(_G['TradeSkillFrame']:GetFrameStrata())
        ScootsCraft.frames.enableButton:SetText('SC')
        
        ScootsCraft.frames.enableButton:SetScript('OnClick', function()
            ScootsCraft.setOption('active', true)
            StaticPopup_Show('SCOOTSCRAFT_RELOAD')
        end)
        
        ScootsCraft.frames.enableButton:SetScript('OnEnter', function()
            GameTooltip:SetOwner(ScootsCraft.frames.enableButton, 'ANCHOR_RIGHT')
            GameTooltip:SetText(ScootsCraft.title, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
            GameTooltip:AddLine('Enable ScootsCraft. Requires a reload of the UI to take effect.', nil, nil, nil, true)
            GameTooltip:Show()
        end)
        
        ScootsCraft.frames.enableButton:SetScript('OnLeave', function()
            GameTooltip:Hide()
        end)
        
        ScootsCraft.enableButtonAdded = true
    end
    
    ScootsCraft.frames.enableButton:SetFrameLevel(_G['TradeSkillFrame']:GetFrameLevel() + 1)
end

ScootsCraft.buildUi = function()
    if(ScootsCraft.uiBuilt ~= true) then
        ScootsCraft.buildUiMain()
        ScootsCraft.buildUiHeader()
        ScootsCraft.buildUiRecipes()
        ScootsCraft.buildUiCraft()
        ScootsCraft.buildUiFooter()
        ScootsCraft.buildUiFilters()
        
        ScootsCraft.uiBuilt = true
    end
end

ScootsCraft.buildUiMain = function()
    -- Remove old frame
    local oldTradeSkillFrame = _G['TradeSkillFrame']
    oldTradeSkillFrame:SetScript('OnHide', nil)
    HideUIPanel(oldTradeSkillFrame)
    _G['TradeSkillFrame'] = CreateFrame('Frame', 'ScootsCraft-OldTradeSkillFrame', UIParent)

    -- Master frame
    ScootsCraft.frames.master = CreateFrame('Frame', 'ScootsCraft-MasterFrame', UIParent)
    
    UIPanelWindows['ScootsCraft-MasterFrame'] = {
        ['area'] = 'left',
        ['pushable'] = 3,
        ['whileDead'] = true,
        ['width'] = 680
    }
    
    ScootsCraft.frames.master:SetToplevel(true)
    ScootsCraft.frames.master:SetMovable(true)
    ScootsCraft.frames.master:EnableMouse(true)
    ScootsCraft.frames.master:SetAttribute('UIPanelLayout-enabled', true)
    ScootsCraft.frames.master:SetAttribute('UIPanelLayout-area', 'left')
    ScootsCraft.frames.master:SetAttribute('UIPanelLayout-pushable', 1)

    ScootsCraft.frames.master:SetSize(UIPanelWindows['ScootsCraft-MasterFrame'].width, 438)
    
    -- Not a mistake: fixes issue with overlapping frames
    ShowUIPanel(ScootsCraft.frames.master)
    HideUIPanel(ScootsCraft.frames.master)
    
    ScootsCraft.frames.master:SetScript('OnHide', ScootsCraft.onHide)
    
    ScootsCraft.frames.master.icon = ScootsCraft.frames.master:CreateTexture(nil, 'OVERLAY')
    ScootsCraft.frames.master.icon:SetPoint('TOPLEFT', 8, -7)
    ScootsCraft.frames.master.icon:SetSize(60, 60)
    
    -- Foreground holder
    ScootsCraft.frames.front = CreateFrame('Frame', 'ScootsCraft-FrontFrame', ScootsCraft.frames.master)
    ScootsCraft.frames.front:SetPoint('TOPLEFT', ScootsCraft.frames.master, 'TOPLEFT', 0, 0)
    ScootsCraft.frames.front:SetSize(ScootsCraft.frames.master:GetWidth(), ScootsCraft.frames.master:GetHeight())
    
    ScootsCraft.frames.front.leftBackground = ScootsCraft.frames.front:CreateTexture()
    ScootsCraft.frames.front.leftBackground:SetTexture('Interface\\AddOns\\ScootsCraft\\Textures\\Main-Left')
    ScootsCraft.frames.front.leftBackground:SetPoint('TOPLEFT', 0, 0)
    ScootsCraft.frames.front.leftBackground:SetSize(512, 512)
    
    ScootsCraft.frames.front.rightBackground = ScootsCraft.frames.front:CreateTexture()
    ScootsCraft.frames.front.rightBackground:SetTexture('Interface\\AddOns\\ScootsCraft\\Textures\\Main-Right')
    ScootsCraft.frames.front.rightBackground:SetPoint('TOPLEFT', 512, 0)
    ScootsCraft.frames.front.rightBackground:SetSize(256, 512)
    
    -- Tooltip
    ScootsCraft.frames.tooltip = CreateFrame('GameTooltip', 'ScootsCraft-Tooltip', UIParent, 'GameTooltipTemplate')
    ScootsCraft.frames.tooltip:Hide()
end

ScootsCraft.buildUiHeader = function()
    -- Title
    ScootsCraft.frames.title = CreateFrame('Frame', 'ScootsCraft-TitleFrame', ScootsCraft.frames.front)
    ScootsCraft.frames.title:SetPoint('TOPLEFT', ScootsCraft.frames.front, 'TOPLEFT', 74, -16)
    ScootsCraft.frames.title:SetSize(520, 16)
    ScootsCraft.frames.title:EnableMouse(true)
    ScootsCraft.frames.title:RegisterForDrag('LeftButton')
    
    ScootsCraft.frames.title.text = ScootsCraft.frames.title:CreateFontString(nil, 'ARTWORK')
    ScootsCraft.frames.title.text:SetFont('Fonts\\FRIZQT__.TTF', 12)
    ScootsCraft.frames.title.text:SetPoint('LEFT', 0, 0)
    ScootsCraft.frames.title.text:SetJustifyH('LEFT')
    ScootsCraft.frames.title.text:SetTextColor(1, 1, 1)
    
    ScootsCraft.frames.title:SetScript('OnDragStart', function()
        if(ScootsCraft.getOption('draggable')) then
            ScootsCraft.frames.master:StartMoving()
        end
    end)
    
    ScootsCraft.frames.title:SetScript('OnDragStop', function()
        ScootsCraft.frames.master:StopMovingOrSizing()
    end)
    
    -- Profession link
    ScootsCraft.frames.professionLink = CreateFrame('Button', 'ScootsCraft-professionLinkButton', ScootsCraft.frames.title)
    ScootsCraft.frames.professionLink:SetSize(32, 16)
    ScootsCraft.frames.professionLink:SetFrameStrata(_G['TradeSkillFrame']:GetFrameStrata())
    
    ScootsCraft.frames.professionLink:SetNormalTexture('Interface\\TradeSkillFrame\\UI-TradeSkill-LinkButton')
    ScootsCraft.frames.professionLink:SetHighlightTexture('Interface\\TradeSkillFrame\\UI-TradeSkill-LinkButton', 'ADD')
    
    ScootsCraft.frames.professionLink:GetNormalTexture():SetTexCoord(0, 1.0, 0, 0.5)
    ScootsCraft.frames.professionLink:GetHighlightTexture():SetTexCoord(0, 1.0, 0.5, 1.0)
    
    ScootsCraft.frames.professionLink:SetScript('OnClick', function()
        local link = GetTradeSkillListLink()
        if(not ChatEdit_InsertLink(link)) then
            ChatEdit_GetLastActiveWindow():Show()
            ChatEdit_InsertLink(link)
        end
    end)
    
    ScootsCraft.frames.professionLink:SetScript('OnEnter', function()
        GameTooltip:SetOwner(ScootsCraft.frames.professionLink, 'ANCHOR_TOPLEFT')
        GameTooltip:SetText('Click here to create a link to your profession.', nil, nil, nil, nil, 1)
        GameTooltip:Show()
    end)
    
    ScootsCraft.frames.professionLink:SetScript('OnLeave', GameTooltip_Hide)
    
    -- Close button
    ScootsCraft.frames.closeButton = CreateFrame('Button', 'ScootsCraft-CloseButton', ScootsCraft.frames.front, 'UIPanelCloseButton')
    ScootsCraft.frames.closeButton:SetPoint('TOPLEFT', ScootsCraft.frames.front, 'TOPLEFT', (684 - ScootsCraft.frames.closeButton:GetWidth()), -8)
    ScootsCraft.frames.closeButton:SetFrameStrata(_G['TradeSkillFrame']:GetFrameStrata())
    ScootsCraft.frames.closeButton:SetScript('OnClick', ScootsCraft.closeCraftPanel)
    
    -- Options button
    ScootsCraft.frames.optionsButton = CreateFrame('Button', 'ScootsCraft-OptionsButton', ScootsCraft.frames.front, 'UIPanelButtonTemplate')
    ScootsCraft.frames.optionsButton:SetSize(62, 19)
    ScootsCraft.frames.optionsButton:SetPoint('TOPRIGHT', ScootsCraft.frames.closeButton, 'TOPLEFT', 3, -6)
    ScootsCraft.frames.optionsButton:SetFrameStrata(_G['TradeSkillFrame']:GetFrameStrata())
    ScootsCraft.frames.optionsButton:SetText('Options')
    ScootsCraft.frames.optionsButton:SetScript('OnClick', ScootsCraft.toggleOptions)
    
    -- Profession buttons
    ScootsCraft.frames.professionButtonsHolder = CreateFrame('Frame', 'ScootsCraft-ProfessionsHolder', ScootsCraft.frames.front)
    ScootsCraft.frames.professionButtonsHolder:SetFrameStrata(_G['TradeSkillFrame']:GetFrameStrata())
    
    ScootsCraft.professionSpells = {}
    for spellIndex, _ in ipairs(ScootsCraft.spellIds) do
        local spell = {
            ['id'] = nil,
            ['bookId'] = nil,
            ['name'] = nil,
            ['icon'] = nil,
            ['button'] = CreateFrame('Button', 'ScootsCraft-ProfessionButton-' .. spellIndex, ScootsCraft.frames.professionButtonsHolder, 'SecureActionButtonTemplate')
        }

        spell.button:SetSize(24, 24)
        spell.button:SetFrameStrata(_G['TradeSkillFrame']:GetFrameStrata())
        spell.button:SetAttribute('type', 'spell')
        spell.button:RegisterForClicks('AnyUp')
        spell.button:Hide()
        
        ScootsCraft.frames.professionButtonsHolder:SetHeight(spell.button:GetHeight())
        
        spell.button.glow = spell.button:CreateTexture(nil, 'OVERLAY')
        spell.button.glow:SetTexture('Interface\\Buttons\\UI-ActionButton-Border')
        spell.button.glow:SetBlendMode('ADD')
        spell.button.glow:SetAlpha(0)
        spell.button.glow:SetSize(42, 42)
        spell.button.glow:SetPoint('CENTER', 0, 0)
                
        spell.button:SetScript('OnEnter', function()
            GameTooltip_SetDefaultAnchor(GameTooltip, spell.button)
            GameTooltip:SetSpell(spell.bookId, BOOKTYPE_SPELL)
            GameTooltip:Show()
            
            if((not ScootsCraft.activeProfession or spell.name ~= ScootsCraft.activeProfession) and (ScootsCraft.activeProfession ~= 'Mining' or spell.name ~= 'Smelting')) then
                spell.button.glow:SetVertexColor(0.3, 0.3, 0.8)
                spell.button.glow:SetAlpha(1)
            end
        end)
        
        spell.button:SetScript('OnLeave', function()
            GameTooltip:Hide()
            
            if((not ScootsCraft.activeProfession or spell.name ~= ScootsCraft.activeProfession) and (ScootsCraft.activeProfession ~= 'Mining' or spell.name ~= 'Smelting')) then
                spell.button.glow:SetAlpha(0)
            end
        end)
        
        ScootsCraft.professionSpells[spellIndex] = spell
    end
end

ScootsCraft.buildUiRecipes = function()
    -- Recipe frame
    ScootsCraft.frames.recipeFrame = CreateFrame('ScrollFrame', 'ScootsCraft-RecipeFrame', ScootsCraft.frames.front, 'FauxScrollFrameTemplate')
    ScootsCraft.frames.recipeFrame:SetSize(300, 336)
    ScootsCraft.frames.recipeFrame:SetPoint('TOPLEFT', ScootsCraft.frames.front, 'TOPLEFT', 20, -74)
    ScootsCraft.frames.recipeFrame:SetFrameStrata(_G['TradeSkillFrame']:GetFrameStrata())
    
    ScootsCraft.recipesVisible = 20
    ScootsCraft.recipeLineHeight = ScootsCraft.frames.recipeFrame:GetHeight() / ScootsCraft.recipesVisible
    
    ScootsCraft.frames.recipeFrame:SetScript('OnVerticalScroll', function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, ScootsCraft.recipeLineHeight, ScootsCraft.updateDisplayedRecipes)
    end)
    
    ScootsCraft.frames.recipes = {}
    for i = 1, ScootsCraft.recipesVisible do
        local recipeLine = CreateFrame('Button', 'ScootsCraft-RecipeFrameLine-' .. tostring(i), ScootsCraft.frames.recipeFrame)
        recipeLine:SetSize(ScootsCraft.frames.recipeFrame:GetWidth(), ScootsCraft.recipeLineHeight)
        recipeLine:SetPoint('TOPLEFT', ScootsCraft.frames.recipeFrame, 'TOPLEFT', 0, 0 - (ScootsCraft.recipeLineHeight * (i - 1)))
        recipeLine:SetFrameStrata(_G['TradeSkillFrame']:GetFrameStrata())
        recipeLine:EnableMouse(true)
        recipeLine.isSectionHead = false
        
        recipeLine.underline = recipeLine:CreateTexture()
        recipeLine.underline:SetSize(recipeLine:GetWidth() - 20, 1)
        recipeLine.underline:SetPoint('BOTTOMLEFT', 20, 0)
        recipeLine.underline:SetTexture(1, 1, 0.5, 0.4)
        recipeLine.underline:SetAlpha(0)
        
        recipeLine.highlight = recipeLine:CreateTexture(nil, 'OVERLAY')
        recipeLine.highlight:SetAllPoints()
        recipeLine.highlight:SetTexture(0.25, 0.5, 1, 0.4)
        recipeLine.highlight:SetAlpha(0)
        
        recipeLine.icon = recipeLine:CreateTexture()
        recipeLine.icon:SetSize(ScootsCraft.recipeLineHeight, ScootsCraft.recipeLineHeight)
        recipeLine.icon:SetPoint('TOPLEFT', 2, 0)
        recipeLine.icon:SetAlpha(0)
    
        recipeLine.text = recipeLine:CreateFontString(nil, 'ARTWORK')
        recipeLine.text:SetFont('Fonts\\FRIZQT__.TTF', 11)
        recipeLine.text:SetPoint('LEFT', 20, 0)
        recipeLine.text:SetJustifyH('LEFT')
        
        recipeLine.selected = recipeLine:CreateTexture(nil, 'BACKGROUND')
        recipeLine.selected:SetAllPoints()
        recipeLine.selected:SetTexture('Interface\\Buttons\\UI-Listbox-Highlight2')
        recipeLine.selected:SetAlpha(0)
        
        recipeLine:SetScript('OnEnter', function()
            if(recipeLine.isSectionHead ~= true) then
                recipeLine.highlight:SetAlpha(1)
            end
            
            if(recipeLine.isSectionHead ~= true) then
                if(ScootsCraft.getOption('recipe-tooltip') == 'item') then
                    GameTooltip:SetOwner(recipeLine, 'ANCHOR_RIGHT')
                    GameTooltip:SetTradeSkillItem(recipeLine.recipe.index)
                elseif(ScootsCraft.getOption('recipe-tooltip') == 'recipe') then
                    GameTooltip:SetOwner(recipeLine, 'ANCHOR_RIGHT')
                    GameTooltip:SetHyperlink(recipeLine.recipe.tradelink)
                end
            end
        end)
        
        recipeLine:SetScript('OnLeave', function()
            recipeLine.highlight:SetAlpha(0)
            GameTooltip_Hide(recipeLine)
        end)
        
        recipeLine:SetScript('OnClick', function()
            if(recipeLine.isSectionHead ~= true) then
                if(IsShiftKeyDown()) then
                    HandleModifiedItemClick(recipeLine.recipe.tradelink)
                else
                    ScootsCraft.selectRecipe(recipeLine.recipe)
                    ScootsCraft.updateDisplayedRecipes()
                end
            end
        end)
        
        recipeLine.sectionToggle = CreateFrame('Button', 'ScootsCraft-SectionToggleButton-' .. tostring(i), recipeLine)
        recipeLine.sectionToggle:SetSize(16, 16)
        recipeLine.sectionToggle:SetPoint('LEFT', recipeLine, 'LEFT', 3, 0)
        recipeLine.sectionToggle:SetFrameStrata(_G['TradeSkillFrame']:GetFrameStrata())
        recipeLine.sectionToggle:SetHitRectInsets(-3, recipeLine.sectionToggle:GetWidth() - recipeLine:GetWidth(), 0, 0)
        
        recipeLine.sectionToggle:SetHighlightTexture('Interface\\Buttons\\UI-PlusButton-Hilight', 'ADD')
        
        recipeLine.sectionToggle:SetScript('OnClick', function()
            ScootsCraft.toggleSection(recipeLine.section)
        end)
        
        ScootsCraft.frames.recipes[i] = recipeLine
    end
end

ScootsCraft.buildUiCraft = function()
    -- Craft frame
    ScootsCraft.frames.craftItemScroller = CreateFrame('ScrollFrame', 'ScootsCraft-CraftItemScroller', ScootsCraft.frames.front, 'UIPanelScrollFrameTemplate')
    ScootsCraft.frames.craftItemScroller:SetSize(300, 336)
    ScootsCraft.frames.craftItemScroller:SetPoint('TOPLEFT', ScootsCraft.frames.front, 'TOPLEFT', 350, -74)
    ScootsCraft.frames.craftItemScroller:SetFrameStrata(_G['TradeSkillFrame']:GetFrameStrata())
    
    ScootsCraft.frames.craftItemHolder = CreateFrame('Frame', 'ScootsCraft-CraftItemHolder', ScootsCraft.frames.craftItemScroller)
    ScootsCraft.frames.craftItemHolder:SetWidth(ScootsCraft.frames.craftItemScroller:GetWidth())
    ScootsCraft.frames.craftItemHolder:SetPoint('TOPLEFT', ScootsCraft.frames.craftItemScroller, 'TOPLEFT', 0, 0)
    ScootsCraft.frames.craftItemHolder:SetFrameStrata(_G['TradeSkillFrame']:GetFrameStrata())
    
    ScootsCraft.frames.craftItemScroller:SetScrollChild(ScootsCraft.frames.craftItemHolder)
    
    ScootsCraft.frames.craftItem = CreateFrame('Frame', 'ScootsCraft-CraftItem', ScootsCraft.frames.craftItemHolder)
    ScootsCraft.frames.craftItem:SetSize(ScootsCraft.frames.craftItemHolder:GetWidth() - 6, ScootsCraft.frames.craftItemHolder:GetHeight() - 10)
    ScootsCraft.frames.craftItem:SetPoint('TOPLEFT', ScootsCraft.frames.craftItemHolder, 'TOPLEFT', 3, -5)
    ScootsCraft.frames.craftItem:SetFrameStrata(_G['TradeSkillFrame']:GetFrameStrata())
    
    -- Craft frame contents: Icon
    ScootsCraft.frames.craftIcon = CreateFrame('Button', 'ScootsCraft-CraftIcon', ScootsCraft.frames.craftItem)
    ScootsCraft.frames.craftIcon:SetSize(37, 37)
    ScootsCraft.frames.craftIcon:SetPoint('TOPLEFT', ScootsCraft.frames.craftItem, 'TOPLEFT', 0, 0)
    ScootsCraft.frames.craftIcon:SetFrameStrata(_G['TradeSkillFrame']:GetFrameStrata())
    
    ScootsCraft.frames.craftIcon.text = ScootsCraft.frames.craftIcon:CreateFontString(nil, 'ARTWORK')
    ScootsCraft.frames.craftIcon.text:SetFontObject('NumberFontNormal')
    ScootsCraft.frames.craftIcon.text:SetPoint('BOTTOMRIGHT', -5, 2)
    ScootsCraft.frames.craftIcon.text:SetJustifyH('RIGHT')
    ScootsCraft.frames.craftIcon.hasItem = 1
    
    ScootsCraft.frames.craftIcon:SetScript('OnClick', function()
        if(ScootsCraft.selectedCraft[ScootsCraft.activeProfession]) then
            HandleModifiedItemClick(ScootsCraft.selectedCraft[ScootsCraft.activeProfession].link)
        end
    end)
    
    ScootsCraft.frames.craftIcon:SetScript('OnEnter', function()
        if(ScootsCraft.selectedCraft[ScootsCraft.activeProfession]) then
            GameTooltip:SetOwner(ScootsCraft.frames.craftIcon, 'ANCHOR_RIGHT')
            GameTooltip:SetTradeSkillItem(ScootsCraft.selectedCraft[ScootsCraft.activeProfession].index)
        end
        CursorUpdate(ScootsCraft.frames.craftIcon)
    end)
    
    ScootsCraft.frames.craftIcon:SetScript('OnLeave', GameTooltip_HideResetCursor)
    
    -- Craft frame contents: Name
    ScootsCraft.frames.craftItem.name = ScootsCraft.frames.craftItem:CreateFontString(nil, 'ARTWORK')
    ScootsCraft.frames.craftItem.name:SetWidth(ScootsCraft.frames.craftItem:GetWidth() - (ScootsCraft.frames.craftIcon:GetWidth() + 10))
    ScootsCraft.frames.craftItem.name:SetFontObject('GameFontNormal')
    ScootsCraft.frames.craftItem.name:SetPoint('TOPLEFT', ScootsCraft.frames.craftIcon:GetWidth() + 10, 0)
    ScootsCraft.frames.craftItem.name:SetJustifyH('LEFT')
    
    -- Craft frame contents: Requirements
    ScootsCraft.frames.craftItem.requiresLabel = ScootsCraft.frames.craftItem:CreateFontString(nil, 'ARTWORK')
    ScootsCraft.frames.craftItem.requiresLabel:SetFontObject('GameFontHighlightSmall')
    ScootsCraft.frames.craftItem.requiresLabel:SetPoint('TOPLEFT', ScootsCraft.frames.craftItem.name, 'BOTTOMLEFT', 0, 0)
    ScootsCraft.frames.craftItem.requiresLabel:SetJustifyH('LEFT')
    
    ScootsCraft.frames.craftItem.requires = ScootsCraft.frames.craftItem:CreateFontString(nil, 'ARTWORK')
    ScootsCraft.frames.craftItem.requires:SetWidth(ScootsCraft.frames.craftItem:GetWidth() - (ScootsCraft.frames.craftIcon:GetWidth() + 10 + ScootsCraft.frames.craftItem.requiresLabel:GetWidth() + 4))
    ScootsCraft.frames.craftItem.requires:SetFontObject('GameFontHighlightSmall')
    ScootsCraft.frames.craftItem.requires:SetPoint('TOPLEFT', ScootsCraft.frames.craftItem.requiresLabel, 'TOPRIGHT', 4, 0)
    ScootsCraft.frames.craftItem.requires:SetJustifyH('LEFT')
    
    -- Craft frame contents: Cooldown
    ScootsCraft.frames.craftItem.cooldown = ScootsCraft.frames.craftItem:CreateFontString(nil, 'ARTWORK')
    ScootsCraft.frames.craftItem.cooldown:SetFontObject('GameFontRedSmall')
    ScootsCraft.frames.craftItem.cooldown:SetPoint('TOPLEFT', ScootsCraft.frames.craftItem.requiresLabel, 'BOTTOMLEFT', 0, 0)
    ScootsCraft.frames.craftItem.cooldown:SetJustifyH('LEFT')
    
    -- Craft frame contents: Description
    ScootsCraft.frames.craftItem.description = ScootsCraft.frames.craftItem:CreateFontString(nil, 'ARTWORK')
    ScootsCraft.frames.craftItem.description:SetWidth(ScootsCraft.frames.craftItem:GetWidth())
    ScootsCraft.frames.craftItem.description:SetFontObject('GameFontHighlightSmall')
    ScootsCraft.frames.craftItem.description:SetJustifyH('LEFT')
    
    -- Craft frame contents: Reagents
    ScootsCraft.frames.craftItem.reagentsLabel = ScootsCraft.frames.craftItem:CreateFontString(nil, 'ARTWORK')
    ScootsCraft.frames.craftItem.reagentsLabel:SetFontObject('GameFontNormalSmall')
    ScootsCraft.frames.craftItem.reagentsLabel:SetPoint('TOPLEFT', ScootsCraft.frames.craftItem.description, 'BOTTOMLEFT', 0, -10)
    ScootsCraft.frames.craftItem.reagentsLabel:SetJustifyH('LEFT')
    ScootsCraft.frames.craftItem.reagentsLabel:SetText('Reagents:')
    
    ScootsCraft.frames.reagents = {}
    for i = 1, 8 do
        ScootsCraft.frames.reagents[i] = CreateFrame('Button', 'ScootsCraft-CraftItem-Reagent-' .. tostring(i), ScootsCraft.frames.craftItem, 'TradeSkillItemTemplate')
        
        if(i == 1) then
            ScootsCraft.frames.reagents[i]:SetPoint('TOPLEFT', ScootsCraft.frames.craftItem.reagentsLabel, 'BOTTOMLEFT', 0, -3)
        elseif(i % 2 == 0) then
            ScootsCraft.frames.reagents[i]:SetPoint('TOPLEFT', ScootsCraft.frames.reagents[i - 1], 'TOPRIGHT', 0, 0)
        else
            ScootsCraft.frames.reagents[i]:SetPoint('TOPRIGHT', ScootsCraft.frames.reagents[i - 1], 'BOTTOMLEFT', 0, -2)
        end
        
        ScootsCraft.frames.reagents[i]:SetScript('OnEnter', function()
            GameTooltip:SetOwner(ScootsCraft.frames.reagents[i], 'ANCHOR_TOPLEFT')
            GameTooltip:SetTradeSkillItem(ScootsCraft.selectedCraft[ScootsCraft.activeProfession].index, i)
            CursorUpdate(ScootsCraft.frames.reagents[i])
        end)
        
        ScootsCraft.frames.reagents[i]:SetScript('OnLeave', function()
            GameTooltip:Hide()
            ResetCursor()
        end)
        
        ScootsCraft.frames.reagents[i]:SetScript('OnClick', function()
            HandleModifiedItemClick(ScootsCraft.selectedCraft[ScootsCraft.activeProfession].reagents[i].link)
            
            if(ScootsCraft.frames.reagents[i].itemId and not IsControlKeyDown() and not IsAltKeyDown() and not IsShiftKeyDown()) then
                ScootsCraft.jumpToItemId(ScootsCraft.frames.reagents[i].itemId)
            end
        end)
    end
end

ScootsCraft.buildUiFooter = function()
    -- Toggle all button
    ScootsCraft.frames.allSectionsToggle = CreateFrame('Button', 'ScootsCraft-AllSectionsToggleButton', ScootsCraft.frames.front)
    ScootsCraft.frames.allSectionsToggle:SetSize(16, 16)
    ScootsCraft.frames.allSectionsToggle:SetPoint('TOPLEFT', ScootsCraft.frames.front, 'TOPLEFT', 22, -415)
    ScootsCraft.frames.allSectionsToggle:SetFrameStrata(_G['TradeSkillFrame']:GetFrameStrata())
    ScootsCraft.frames.allSectionsToggle:SetHitRectInsets(-3, -20, 0, 0)
    
    ScootsCraft.frames.allSectionsToggle:SetNormalTexture('Interface\\Buttons\\UI-MinusButton-Up')
    ScootsCraft.frames.allSectionsToggle:SetPushedTexture('Interface\\Buttons\\UI-MinusButton-Down')
    ScootsCraft.frames.allSectionsToggle:SetHighlightTexture('Interface\\Buttons\\UI-PlusButton-Hilight', 'ADD')
    
    ScootsCraft.frames.allSectionsToggle:SetScript('OnClick', function()
        ScootsCraft.toggleAllSections()
    end)
    
    ScootsCraft.frames.allSectionsToggle.label = ScootsCraft.frames.allSectionsToggle:CreateFontString(nil, 'ARTWORK')
    ScootsCraft.frames.allSectionsToggle.label:SetFontObject('GameFontNormal')
    ScootsCraft.frames.allSectionsToggle.label:SetPoint('LEFT', ScootsCraft.frames.allSectionsToggle, 'RIGHT', 3, 0)
    ScootsCraft.frames.allSectionsToggle.label:SetJustifyH('LEFT')
    ScootsCraft.frames.allSectionsToggle.label:SetText('All')
    
    -- Create button
    ScootsCraft.frames.createButton = CreateFrame('Button', 'ScootsCraft-CreateButton', ScootsCraft.frames.front, 'UIPanelButtonTemplate')
    ScootsCraft.frames.createButton:SetSize(80, 19)
    ScootsCraft.frames.createButton:SetPoint('TOPLEFT', ScootsCraft.frames.front, 'TOPLEFT', (675 - ScootsCraft.frames.createButton:GetWidth()), -413)
    ScootsCraft.frames.createButton:SetFrameStrata(_G['TradeSkillFrame']:GetFrameStrata())
    ScootsCraft.frames.createButton:SetText('Create')
    ScootsCraft.frames.createButton:Disable()
    
    ScootsCraft.frames.createButton:SetScript('OnClick', function()
        if(ScootsCraft.selectedCraft[ScootsCraft.activeProfession].number > 0) then
            DoTradeSkill(ScootsCraft.selectedCraft[ScootsCraft.activeProfession].index, ScootsCraft.frames.quantity:GetNumber())
            EditBox_ClearFocus(ScootsCraft.frames.quantity)
        end
    end)
    
    -- Quantity: Increment
    ScootsCraft.frames.increment = CreateFrame('Button', 'ScootsCraft-Quantity-IncrementButton', ScootsCraft.frames.front)
    ScootsCraft.frames.increment:SetSize(19, 19)
    ScootsCraft.frames.increment:SetPoint('TOPRIGHT', ScootsCraft.frames.createButton, 'TOPLEFT', -1, 0)
    ScootsCraft.frames.increment:SetFrameStrata(_G['TradeSkillFrame']:GetFrameStrata())
    ScootsCraft.frames.increment:Hide()
    
    ScootsCraft.frames.increment:SetNormalTexture('Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up')
    ScootsCraft.frames.increment:SetPushedTexture('Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down')
    ScootsCraft.frames.increment:SetDisabledTexture('Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled')
    ScootsCraft.frames.increment:SetHighlightTexture('Interface\\Buttons\\UI-Common-MouseHilight', 'ADD')
    
    ScootsCraft.frames.increment:SetScript('OnClick', function()
        local check = ScootsCraft.frames.quantity:GetNumber()
        local maxQty = math.min(200, ScootsCraft.selectedCraft[ScootsCraft.activeProfession].number)
        
        if(check < maxQty) then
            ScootsCraft.frames.quantity:SetText(tostring(check + 1))
        end
    end)
    
    -- Quantity
    ScootsCraft.frames.quantity = CreateFrame('EditBox', 'ScootsCraft-Quantity', ScootsCraft.frames.front)
    ScootsCraft.frames.quantity:SetSize(30, 19)
    ScootsCraft.frames.quantity:SetPoint('TOPRIGHT', ScootsCraft.frames.increment, 'TOPLEFT', 0, 0)
    ScootsCraft.frames.quantity:SetFrameStrata(_G['TradeSkillFrame']:GetFrameStrata())
    ScootsCraft.frames.quantity:SetAutoFocus(false)
    ScootsCraft.frames.quantity:SetMaxLetters(3)
    ScootsCraft.frames.quantity:SetNumeric(true)
    ScootsCraft.frames.quantity:SetFontObject('GameFontHighlightSmall')
    ScootsCraft.frames.quantity:SetText('1')
    ScootsCraft.frames.quantity:SetJustifyH('CENTER')
    ScootsCraft.frames.quantity:Hide()
    
    ScootsCraft.frames.quantity:SetScript('OnEnterPressed', EditBox_ClearFocus)
    ScootsCraft.frames.quantity:SetScript('OnEscapePressed', EditBox_ClearFocus)
    ScootsCraft.frames.quantity:SetScript('OnEditFocusGained', EditBox_HighlightText)
    
    ScootsCraft.frames.quantity:SetScript('OnEditFocusLost', function()
        EditBox_ClearHighlight(ScootsCraft.frames.quantity)
        
        local check = ScootsCraft.frames.quantity:GetNumber()
        local maxQty = math.min(200, ScootsCraft.selectedCraft[ScootsCraft.activeProfession].number)
        
        if(check < 1) then
            ScootsCraft.frames.quantity:SetText('1')
        elseif(check > maxQty) then
            ScootsCraft.frames.quantity:SetText(tostring(maxQty))
        end
    end)
    
    ScootsCraft.frames.quantity:SetScript('OnTextChanged', function()
        local check = ScootsCraft.frames.quantity:GetNumber()
        
        if(ScootsCraft.selectedCraft[ScootsCraft.activeProfession] and check ~= 1) then
            local maxQty = math.min(200, ScootsCraft.selectedCraft[ScootsCraft.activeProfession].number)
            
            if(check ~= nil) then
                if(check <= 1) then
                    ScootsCraft.frames.decrement:Disable()
                else
                    ScootsCraft.frames.decrement:Enable()
                end
                
                if(check >= maxQty) then
                    ScootsCraft.frames.increment:Disable()
                else
                    ScootsCraft.frames.increment:Enable()
                end
            end
        end
    end)
    
    ScootsCraft.frames.quantity.bgLeft = ScootsCraft.frames.quantity:CreateTexture(nil, 'BACKGROUND')
    ScootsCraft.frames.quantity.bgLeft:SetTexture('Interface\\Common\\Common-Input-Border')
    ScootsCraft.frames.quantity.bgLeft:SetSize(8, 19)
    ScootsCraft.frames.quantity.bgLeft:SetPoint('LEFT', 0, 0)
    ScootsCraft.frames.quantity.bgLeft:SetTexCoord(0, 0.0625, 0, 0.625)
    
    ScootsCraft.frames.quantity.bgRight = ScootsCraft.frames.quantity:CreateTexture(nil, 'BACKGROUND')
    ScootsCraft.frames.quantity.bgRight:SetTexture('Interface\\Common\\Common-Input-Border')
    ScootsCraft.frames.quantity.bgRight:SetSize(8, 19)
    ScootsCraft.frames.quantity.bgRight:SetPoint('RIGHT', 0, 0)
    ScootsCraft.frames.quantity.bgRight:SetTexCoord(0.9375, 1.0, 0, 0.625)
    
    ScootsCraft.frames.quantity.bgMiddle = ScootsCraft.frames.quantity:CreateTexture(nil, 'BACKGROUND')
    ScootsCraft.frames.quantity.bgMiddle:SetTexture('Interface\\Common\\Common-Input-Border')
    ScootsCraft.frames.quantity.bgMiddle:SetSize(10, 19)
    ScootsCraft.frames.quantity.bgMiddle:SetPoint('LEFT', ScootsCraft.frames.quantity.bgLeft, 'RIGHT', 0, 0)
    ScootsCraft.frames.quantity.bgMiddle:SetPoint('RIGHT', ScootsCraft.frames.quantity.bgRight, 'LEFT', 0, 0)
    ScootsCraft.frames.quantity.bgMiddle:SetTexCoord(0.0625, 0.9375, 0, 0.625)
    
    -- Quantity: Decrement
    ScootsCraft.frames.decrement = CreateFrame('Button', 'ScootsCraft-Quantity-DecrementButton', ScootsCraft.frames.front)
    ScootsCraft.frames.decrement:SetSize(19, 19)
    ScootsCraft.frames.decrement:SetPoint('TOPRIGHT', ScootsCraft.frames.quantity, 'TOPLEFT', 0, 0)
    ScootsCraft.frames.decrement:SetFrameStrata(_G['TradeSkillFrame']:GetFrameStrata())
    ScootsCraft.frames.decrement:Hide()
    
    ScootsCraft.frames.decrement:SetNormalTexture('Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up')
    ScootsCraft.frames.decrement:SetPushedTexture('Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down')
    ScootsCraft.frames.decrement:SetDisabledTexture('Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled')
    ScootsCraft.frames.decrement:SetHighlightTexture('Interface\\Buttons\\UI-Common-MouseHilight', 'ADD')
    
    ScootsCraft.frames.decrement:SetScript('OnClick', function()
        local check = ScootsCraft.frames.quantity:GetNumber()
        
        if(check > 1) then
            ScootsCraft.frames.quantity:SetText(tostring(check - 1))
        end
    end)
    
    -- Create all button
    ScootsCraft.frames.createAllButton = CreateFrame('Button', 'ScootsCraft-CreateButton', ScootsCraft.frames.front, 'UIPanelButtonTemplate')
    ScootsCraft.frames.createAllButton:SetSize(80, 19)
    ScootsCraft.frames.createAllButton:SetPoint('TOPRIGHT', ScootsCraft.frames.decrement, 'TOPLEFT', -1, 0)
    ScootsCraft.frames.createAllButton:SetFrameStrata(_G['TradeSkillFrame']:GetFrameStrata())
    ScootsCraft.frames.createAllButton:SetText('Create all')
    ScootsCraft.frames.createAllButton:Hide()
    
    ScootsCraft.frames.createAllButton:SetScript('OnClick', function()
        if(ScootsCraft.selectedCraft[ScootsCraft.activeProfession].number > 0) then
            local maxQty = math.min(200, ScootsCraft.selectedCraft[ScootsCraft.activeProfession].number)
            ScootsCraft.frames.quantity:SetText(tostring(maxQty))
            DoTradeSkill(ScootsCraft.selectedCraft[ScootsCraft.activeProfession].index, maxQty)
            EditBox_ClearFocus(ScootsCraft.frames.quantity)
        end
    end)
end

ScootsCraft.buildUiFilters = function()
    -- Filters: Have Materials
    ScootsCraft.frames.availableFilter = CreateFrame('CheckButton', 'ScootsCraft-Filters-Available', ScootsCraft.frames.front, 'UICheckButtonTemplate')
    ScootsCraft.frames.availableFilter:SetSize(24, 24)
    ScootsCraft.frames.availableFilter:SetPoint('TOPLEFT', ScootsCraft.frames.front, 'TOPLEFT', 70, -30)
    ScootsCraft.frames.availableFilter:SetFrameStrata(_G['TradeSkillFrame']:GetFrameStrata())
    
    _G[ScootsCraft.frames.availableFilter:GetName() .. 'Text']:SetText('Have Materials')
    _G[ScootsCraft.frames.availableFilter:GetName() .. 'Text']:ClearAllPoints()
    _G[ScootsCraft.frames.availableFilter:GetName() .. 'Text']:SetPoint('TOPLEFT', ScootsCraft.frames.availableFilter, 'TOPRIGHT', -2, -5)
    
    ScootsCraft.frames.availableFilter:SetHitRectInsets(0, 0 - _G[ScootsCraft.frames.availableFilter:GetName() .. 'Text']:GetWidth(), 0, 0)
    
    ScootsCraft.frames.availableFilter:SetScript('OnClick', function()
        ScootsCraft.setFilter('available', ScootsCraft.frames.availableFilter:GetChecked())
    end)
    
    ScootsCraft.frames.availableFilter:SetScript('OnEnter', function()
        GameTooltip:SetOwner(ScootsCraft.frames.availableFilter, 'ANCHOR_LEFT')
        GameTooltip:SetText('Only show recipes that you have the materials to make.', nil, nil, nil, nil, 1)
    end)
    
    ScootsCraft.frames.availableFilter:SetScript('OnLeave', GameTooltip_Hide)
    
    -- Filters: Equipment Only
    ScootsCraft.frames.equipmentOnlyFilter = CreateFrame('CheckButton', 'ScootsCraft-Filters-EquipmentOnly', ScootsCraft.frames.front, 'UICheckButtonTemplate')
    ScootsCraft.frames.equipmentOnlyFilter:SetSize(24, 24)
    ScootsCraft.frames.equipmentOnlyFilter:SetPoint('LEFT', ScootsCraft.frames.availableFilter, 'RIGHT', 105, 0)
    ScootsCraft.frames.equipmentOnlyFilter:SetFrameStrata(_G['TradeSkillFrame']:GetFrameStrata())
    
    _G[ScootsCraft.frames.equipmentOnlyFilter:GetName() .. 'Text']:SetText('Equipment Only')
    _G[ScootsCraft.frames.equipmentOnlyFilter:GetName() .. 'Text']:ClearAllPoints()
    _G[ScootsCraft.frames.equipmentOnlyFilter:GetName() .. 'Text']:SetPoint('TOPLEFT', ScootsCraft.frames.equipmentOnlyFilter, 'TOPRIGHT', -2, -5)
    
    ScootsCraft.frames.equipmentOnlyFilter:SetHitRectInsets(0, 0 - _G[ScootsCraft.frames.equipmentOnlyFilter:GetName() .. 'Text']:GetWidth(), 0, 0)
    
    ScootsCraft.frames.equipmentOnlyFilter:SetScript('OnClick', function()
        ScootsCraft.setFilter('equipment-only', ScootsCraft.frames.equipmentOnlyFilter:GetChecked())
    end)
    
    ScootsCraft.frames.equipmentOnlyFilter:SetScript('OnEnter', function()
        GameTooltip:SetOwner(ScootsCraft.frames.equipmentOnlyFilter, 'ANCHOR_LEFT')
        GameTooltip:SetText('Only show recipes that produce equippable items.', nil, nil, nil, nil, 1)
    end)
    
    ScootsCraft.frames.equipmentOnlyFilter:SetScript('OnLeave', GameTooltip_Hide)
    
    -- Filters: Subclasses
    ScootsCraft.frames.subclassFilter = CreateFrame('Frame', 'ScootsCraft-Filters-Subclass', ScootsCraft.frames.front, 'UIDropDownMenuTemplate')
    ScootsCraft.frames.subclassFilter:SetPoint('TOPLEFT', ScootsCraft.frames.availableFilter, 'BOTTOMLEFT', -15, 6)
    ScootsCraft.frames.subclassFilter:SetFrameStrata(_G['TradeSkillFrame']:GetFrameStrata())
    
    -- Filters: Slots
    ScootsCraft.frames.slotFilter = CreateFrame('Frame', 'ScootsCraft-Filters-Slot', ScootsCraft.frames.front, 'UIDropDownMenuTemplate')
    ScootsCraft.frames.slotFilter:SetPoint('TOPLEFT', ScootsCraft.frames.subclassFilter, 'TOPRIGHT', 90, 0)
    ScootsCraft.frames.slotFilter:SetFrameStrata(_G['TradeSkillFrame']:GetFrameStrata())
    
    -- Filters: Search
    ScootsCraft.frames.searchFilter = CreateFrame('EditBox', 'ScootsCraft-Quantity', ScootsCraft.frames.front)
    ScootsCraft.frames.searchFilter:SetSize(100, 19)
    ScootsCraft.frames.searchFilter:SetPoint('TOPLEFT', ScootsCraft.frames.front, 'TOPLEFT', 70, -413)
    ScootsCraft.frames.searchFilter:SetFrameStrata(_G['TradeSkillFrame']:GetFrameStrata())
    ScootsCraft.frames.searchFilter:SetAutoFocus(false)
    ScootsCraft.frames.searchFilter:SetFontObject('GameFontHighlightSmall')
    ScootsCraft.frames.searchFilter:SetJustifyH('LEFT')
    ScootsCraft.frames.searchFilter:SetTextInsets(5, 5, 0, 0)

    ScootsCraft.frames.searchFilter.label = ScootsCraft.frames.searchFilter:CreateFontString(nil, 'OVERLAY')
    ScootsCraft.frames.searchFilter.label:SetFontObject('GameFontHighlightSmall')
    ScootsCraft.frames.searchFilter.label:SetPoint('LEFT', 5, 0)
    ScootsCraft.frames.searchFilter.label:SetJustifyH('LEFT')
    ScootsCraft.frames.searchFilter.label:SetText('Search')
    
    local clearFocus = function(self)
        ScootsCraft.searchFilterFocussed = nil
        EditBox_ClearFocus(self)
    end
    
    ScootsCraft.frames.searchFilter:SetScript('OnEnterPressed', clearFocus)
    ScootsCraft.frames.searchFilter:SetScript('OnEscapePressed', clearFocus)
    ScootsCraft.frames.searchFilter:SetScript('OnEditFocusGained', function()
        ScootsCraft.searchFilterFocussed = true
        ScootsCraft.frames.searchFilter.label:Hide()
        EditBox_HighlightText(ScootsCraft.frames.searchFilter)
    end)
    
    ScootsCraft.frames.searchFilter:SetScript('OnEditFocusLost', function()
        if(ScootsCraft.frames.searchFilter:GetText() == '') then
            ScootsCraft.frames.searchFilter.label:Show()
        end
    end)
    
    ScootsCraft.frames.searchFilter:SetScript('OnTextChanged', function()
        ScootsCraft.setFilter('search', ScootsCraft.frames.searchFilter:GetText())
    end)
    
    ScootsCraft.frames.searchFilter.bgLeft = ScootsCraft.frames.searchFilter:CreateTexture(nil, 'BACKGROUND')
    ScootsCraft.frames.searchFilter.bgLeft:SetTexture('Interface\\Common\\Common-Input-Border')
    ScootsCraft.frames.searchFilter.bgLeft:SetSize(8, 19)
    ScootsCraft.frames.searchFilter.bgLeft:SetPoint('LEFT', 0, 0)
    ScootsCraft.frames.searchFilter.bgLeft:SetTexCoord(0, 0.0625, 0, 0.625)
    
    ScootsCraft.frames.searchFilter.bgRight = ScootsCraft.frames.searchFilter:CreateTexture(nil, 'BACKGROUND')
    ScootsCraft.frames.searchFilter.bgRight:SetTexture('Interface\\Common\\Common-Input-Border')
    ScootsCraft.frames.searchFilter.bgRight:SetSize(8, 19)
    ScootsCraft.frames.searchFilter.bgRight:SetPoint('RIGHT', 0, 0)
    ScootsCraft.frames.searchFilter.bgRight:SetTexCoord(0.9375, 1.0, 0, 0.625)
    
    ScootsCraft.frames.searchFilter.bgMiddle = ScootsCraft.frames.searchFilter:CreateTexture(nil, 'BACKGROUND')
    ScootsCraft.frames.searchFilter.bgMiddle:SetTexture('Interface\\Common\\Common-Input-Border')
    ScootsCraft.frames.searchFilter.bgMiddle:SetSize(10, 19)
    ScootsCraft.frames.searchFilter.bgMiddle:SetPoint('LEFT', ScootsCraft.frames.searchFilter.bgLeft, 'RIGHT', 0, 0)
    ScootsCraft.frames.searchFilter.bgMiddle:SetPoint('RIGHT', ScootsCraft.frames.searchFilter.bgRight, 'LEFT', 0, 0)
    ScootsCraft.frames.searchFilter.bgMiddle:SetTexCoord(0.0625, 0.9375, 0, 0.625)
    
    -- Filters: Equipment (attuneable)
    ScootsCraft.frames.equipmentFilter = CreateFrame('Frame', 'ScootsCraft-Filters-Equipment', ScootsCraft.frames.front, 'UIDropDownMenuTemplate')
    ScootsCraft.frames.equipmentFilter:SetPoint('LEFT', ScootsCraft.frames.searchFilter, 'RIGHT', -14, -2)
    ScootsCraft.frames.equipmentFilter:SetFrameStrata(_G['TradeSkillFrame']:GetFrameStrata())
    
    -- Filters: Forges
    ScootsCraft.frames.forgeFilter = CreateFrame('Frame', 'ScootsCraft-Filters-Forge', ScootsCraft.frames.front, 'UIDropDownMenuTemplate')
    ScootsCraft.frames.forgeFilter:SetPoint('LEFT', ScootsCraft.frames.equipmentFilter, 'RIGHT', 90, 0)
    ScootsCraft.frames.forgeFilter:SetFrameStrata(_G['TradeSkillFrame']:GetFrameStrata())
end

ScootsCraft.buildUiOptions = function()
    -- Main
    ScootsCraft.frames.options = CreateFrame('Frame', 'ScootsCraft-Options', ScootsCraft.frames.front)
    ScootsCraft.frames.options:SetSize(659, 341)
    ScootsCraft.frames.options:SetFrameStrata(ScootsCraft.frames.master:GetFrameStrata())
    ScootsCraft.frames.options:SetPoint('TOPLEFT', ScootsCraft.frames.front, 'TOPLEFT', 17, -72)
    ScootsCraft.frames.options:EnableMouse(true)

    ScootsCraft.frames.options.leftBackground = ScootsCraft.frames.options:CreateTexture(nil, 'BACKGROUND')
    ScootsCraft.frames.options.leftBackground:SetTexture('Interface\\AddOns\\ScootsCraft\\Textures\\Options-Left')
    ScootsCraft.frames.options.leftBackground:SetPoint('TOPLEFT', 0, 0)
    ScootsCraft.frames.options.leftBackground:SetSize(512, 512)
    
    ScootsCraft.frames.options.rightBackground = ScootsCraft.frames.options:CreateTexture(nil, 'BACKGROUND')
    ScootsCraft.frames.options.rightBackground:SetTexture('Interface\\AddOns\\ScootsCraft\\Textures\\Options-Right')
    ScootsCraft.frames.options.rightBackground:SetPoint('TOPLEFT', 512, 0)
    ScootsCraft.frames.options.rightBackground:SetSize(256, 512)
    
    -- Option: Recipe tooltip
    -- Header
    ScootsCraft.frames.options.recipeTooltipHeader = ScootsCraft.frames.options:CreateFontString(nil, 'ARTWORK')
    ScootsCraft.frames.options.recipeTooltipHeader:SetFontObject('GameFontNormal')
    ScootsCraft.frames.options.recipeTooltipHeader:SetPoint('TOPLEFT', 10, -10)
    ScootsCraft.frames.options.recipeTooltipHeader:SetJustifyH('LEFT')
    ScootsCraft.frames.options.recipeTooltipHeader:SetText('Tooltip on the recipe list')
    
    -- None
    ScootsCraft.frames.optionRecipeTooltipNone = CreateFrame('CheckButton', 'ScootsCraft-Option-RecipeTooltip-None', ScootsCraft.frames.options, 'UICheckButtonTemplate')
    ScootsCraft.frames.optionRecipeTooltipNone:SetSize(24, 24)
    ScootsCraft.frames.optionRecipeTooltipNone:SetPoint('TOPLEFT', ScootsCraft.frames.options.recipeTooltipHeader, 'BOTTOMLEFT', 0, -4)
    ScootsCraft.frames.optionRecipeTooltipNone:SetFrameStrata(ScootsCraft.frames.master:GetFrameStrata())
    
    if(ScootsCraft.getOption('recipe-tooltip') == nil) then
        ScootsCraft.frames.optionRecipeTooltipNone:SetChecked(true)
    end
    
    _G[ScootsCraft.frames.optionRecipeTooltipNone:GetName() .. 'Text']:SetText('None')
    _G[ScootsCraft.frames.optionRecipeTooltipNone:GetName() .. 'Text']:ClearAllPoints()
    _G[ScootsCraft.frames.optionRecipeTooltipNone:GetName() .. 'Text']:SetPoint('TOPLEFT', ScootsCraft.frames.optionRecipeTooltipNone, 'TOPRIGHT', -2, -5)
    
    ScootsCraft.frames.optionRecipeTooltipNone:SetHitRectInsets(0, 0 - _G[ScootsCraft.frames.optionRecipeTooltipNone:GetName() .. 'Text']:GetWidth(), 0, 0)
    
    ScootsCraft.frames.optionRecipeTooltipNone:SetScript('OnClick', function()
        ScootsCraft.frames.optionRecipeTooltipNone:SetChecked(true)
        ScootsCraft.frames.optionRecipeTooltipItem:SetChecked(false)
        ScootsCraft.frames.optionRecipeTooltipRecipe:SetChecked(false)
        ScootsCraft.setOption('recipe-tooltip', nil)
        ScootsCraft.updateDisplayedRecipes()
    end)
    
    -- Item
    ScootsCraft.frames.optionRecipeTooltipItem = CreateFrame('CheckButton', 'ScootsCraft-Option-RecipeTooltip-Item', ScootsCraft.frames.options, 'UICheckButtonTemplate')
    ScootsCraft.frames.optionRecipeTooltipItem:SetSize(24, 24)
    ScootsCraft.frames.optionRecipeTooltipItem:SetPoint('LEFT', ScootsCraft.frames.optionRecipeTooltipNone, 'RIGHT', _G[ScootsCraft.frames.optionRecipeTooltipNone:GetName() .. 'Text']:GetWidth() + 5, 0)
    ScootsCraft.frames.optionRecipeTooltipItem:SetFrameStrata(ScootsCraft.frames.master:GetFrameStrata())
    
    if(ScootsCraft.getOption('recipe-tooltip') == 'item') then
        ScootsCraft.frames.optionRecipeTooltipItem:SetChecked(true)
    end
    
    _G[ScootsCraft.frames.optionRecipeTooltipItem:GetName() .. 'Text']:SetText('Item')
    _G[ScootsCraft.frames.optionRecipeTooltipItem:GetName() .. 'Text']:ClearAllPoints()
    _G[ScootsCraft.frames.optionRecipeTooltipItem:GetName() .. 'Text']:SetPoint('TOPLEFT', ScootsCraft.frames.optionRecipeTooltipItem, 'TOPRIGHT', -2, -5)
    
    ScootsCraft.frames.optionRecipeTooltipItem:SetHitRectInsets(0, 0 - _G[ScootsCraft.frames.optionRecipeTooltipItem:GetName() .. 'Text']:GetWidth(), 0, 0)
    
    ScootsCraft.frames.optionRecipeTooltipItem:SetScript('OnClick', function()
        ScootsCraft.frames.optionRecipeTooltipNone:SetChecked(false)
        ScootsCraft.frames.optionRecipeTooltipItem:SetChecked(true)
        ScootsCraft.frames.optionRecipeTooltipRecipe:SetChecked(false)
        ScootsCraft.setOption('recipe-tooltip', 'item')
        ScootsCraft.updateDisplayedRecipes()
    end)
    
    -- Recipe
    ScootsCraft.frames.optionRecipeTooltipRecipe = CreateFrame('CheckButton', 'ScootsCraft-Option-RecipeTooltip-Recipe', ScootsCraft.frames.options, 'UICheckButtonTemplate')
    ScootsCraft.frames.optionRecipeTooltipRecipe:SetSize(24, 24)
    ScootsCraft.frames.optionRecipeTooltipRecipe:SetPoint('LEFT', ScootsCraft.frames.optionRecipeTooltipItem, 'RIGHT', _G[ScootsCraft.frames.optionRecipeTooltipItem:GetName() .. 'Text']:GetWidth() + 5, 0)
    ScootsCraft.frames.optionRecipeTooltipRecipe:SetFrameStrata(ScootsCraft.frames.master:GetFrameStrata())
    
    if(ScootsCraft.getOption('recipe-tooltip') == 'recipe') then
        ScootsCraft.frames.optionRecipeTooltipRecipe:SetChecked(true)
    end
    
    _G[ScootsCraft.frames.optionRecipeTooltipRecipe:GetName() .. 'Text']:SetText('Recipe')
    _G[ScootsCraft.frames.optionRecipeTooltipRecipe:GetName() .. 'Text']:ClearAllPoints()
    _G[ScootsCraft.frames.optionRecipeTooltipRecipe:GetName() .. 'Text']:SetPoint('TOPLEFT', ScootsCraft.frames.optionRecipeTooltipRecipe, 'TOPRIGHT', -2, -5)
    
    ScootsCraft.frames.optionRecipeTooltipRecipe:SetHitRectInsets(0, 0 - _G[ScootsCraft.frames.optionRecipeTooltipRecipe:GetName() .. 'Text']:GetWidth(), 0, 0)
    
    ScootsCraft.frames.optionRecipeTooltipRecipe:SetScript('OnClick', function()
        ScootsCraft.frames.optionRecipeTooltipNone:SetChecked(false)
        ScootsCraft.frames.optionRecipeTooltipItem:SetChecked(false)
        ScootsCraft.frames.optionRecipeTooltipRecipe:SetChecked(true)
        ScootsCraft.setOption('recipe-tooltip', 'recipe')
        ScootsCraft.updateDisplayedRecipes()
    end)
    
    -- Option: Draggable
    -- Header
    ScootsCraft.frames.options.draggableHeader = ScootsCraft.frames.options:CreateFontString(nil, 'ARTWORK')
    ScootsCraft.frames.options.draggableHeader:SetFontObject('GameFontNormal')
    ScootsCraft.frames.options.draggableHeader:SetPoint('TOPLEFT', ScootsCraft.frames.optionRecipeTooltipNone, 'BOTTOMLEFT', 0, -10)
    ScootsCraft.frames.options.draggableHeader:SetJustifyH('LEFT')
    ScootsCraft.frames.options.draggableHeader:SetText('Click header to drag window')
    
    -- Checkbox
    ScootsCraft.frames.optionDraggable = CreateFrame('CheckButton', 'ScootsCraft-Option-Draggable', ScootsCraft.frames.options, 'UICheckButtonTemplate')
    ScootsCraft.frames.optionDraggable:SetSize(24, 24)
    ScootsCraft.frames.optionDraggable:SetPoint('TOPLEFT', ScootsCraft.frames.options.draggableHeader, 'BOTTOMLEFT', 0, -4)
    ScootsCraft.frames.optionDraggable:SetFrameStrata(ScootsCraft.frames.master:GetFrameStrata())
    
    if(ScootsCraft.getOption('draggable')) then
        ScootsCraft.frames.optionDraggable:SetChecked(true)
    end
    
    _G[ScootsCraft.frames.optionDraggable:GetName() .. 'Text']:SetText('Make window draggable')
    _G[ScootsCraft.frames.optionDraggable:GetName() .. 'Text']:ClearAllPoints()
    _G[ScootsCraft.frames.optionDraggable:GetName() .. 'Text']:SetPoint('TOPLEFT', ScootsCraft.frames.optionDraggable, 'TOPRIGHT', -2, -5)
    
    ScootsCraft.frames.optionDraggable:SetHitRectInsets(0, 0 - _G[ScootsCraft.frames.optionDraggable:GetName() .. 'Text']:GetWidth(), 0, 0)
    
    ScootsCraft.frames.optionDraggable:SetScript('OnClick', function()
        ScootsCraft.setOption('draggable', ScootsCraft.frames.optionDraggable:GetChecked())
        ScootsCraft.updateDisplayedRecipes()
    end)
    
    -- Option: Remember filters
    -- Header
    ScootsCraft.frames.options.rememberFiltersHeader = ScootsCraft.frames.options:CreateFontString(nil, 'ARTWORK')
    ScootsCraft.frames.options.rememberFiltersHeader:SetFontObject('GameFontNormal')
    ScootsCraft.frames.options.rememberFiltersHeader:SetPoint('TOPLEFT', ScootsCraft.frames.optionDraggable, 'BOTTOMLEFT', 0, -10)
    ScootsCraft.frames.options.rememberFiltersHeader:SetJustifyH('LEFT')
    ScootsCraft.frames.options.rememberFiltersHeader:SetText('Remember filters')
    
    -- Checkbox
    ScootsCraft.frames.optionRememberFilters = CreateFrame('CheckButton', 'ScootsCraft-Option-RememberFilters', ScootsCraft.frames.options, 'UICheckButtonTemplate')
    ScootsCraft.frames.optionRememberFilters:SetSize(24, 24)
    ScootsCraft.frames.optionRememberFilters:SetPoint('TOPLEFT', ScootsCraft.frames.options.rememberFiltersHeader, 'BOTTOMLEFT', 0, -4)
    ScootsCraft.frames.optionRememberFilters:SetFrameStrata(ScootsCraft.frames.master:GetFrameStrata())
    
    ScootsCraft.frames.optionRememberFilters:SetScript('OnEnter', function()
        GameTooltip:SetOwner(ScootsCraft.frames.optionRememberFilters, 'ANCHOR_RIGHT')
        GameTooltip:SetText('Remember filters', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
        GameTooltip:AddLine('When enabled, your filters for each profession will be remembered between game sessions.', nil, nil, nil, true)
        GameTooltip:Show()
    end)
    
    ScootsCraft.frames.optionRememberFilters:SetScript('OnLeave', GameTooltip_Hide)
    
    if(ScootsCraft.getOption('remember-filters')) then
        ScootsCraft.frames.optionRememberFilters:SetChecked(true)
    end
    
    _G[ScootsCraft.frames.optionRememberFilters:GetName() .. 'Text']:SetText('Remember')
    _G[ScootsCraft.frames.optionRememberFilters:GetName() .. 'Text']:ClearAllPoints()
    _G[ScootsCraft.frames.optionRememberFilters:GetName() .. 'Text']:SetPoint('TOPLEFT', ScootsCraft.frames.optionRememberFilters, 'TOPRIGHT', -2, -5)
    
    ScootsCraft.frames.optionRememberFilters:SetHitRectInsets(0, 0 - _G[ScootsCraft.frames.optionRememberFilters:GetName() .. 'Text']:GetWidth(), 0, 0)
    
    ScootsCraft.frames.optionRememberFilters:SetScript('OnClick', function()
        ScootsCraft.setOption('remember-filters', ScootsCraft.frames.optionRememberFilters:GetChecked())
    end)
    
    -- Option: Use default frames
    -- Header
    ScootsCraft.frames.options.defaultFramesHeader = ScootsCraft.frames.options:CreateFontString(nil, 'ARTWORK')
    ScootsCraft.frames.options.defaultFramesHeader:SetFontObject('GameFontNormal')
    ScootsCraft.frames.options.defaultFramesHeader:SetPoint('TOPLEFT', ScootsCraft.frames.optionRememberFilters, 'BOTTOMLEFT', 0, -10)
    ScootsCraft.frames.options.defaultFramesHeader:SetJustifyH('LEFT')
    ScootsCraft.frames.options.defaultFramesHeader:SetText('Use default profession frames')
    
    -- Button
    ScootsCraft.frames.optionDefaultFrames = CreateFrame('Button', 'ScootsCraft-Option-UseDefaultFrames', ScootsCraft.frames.options, 'UIPanelButtonTemplate')
    ScootsCraft.frames.optionDefaultFrames:SetSize(140, 19)
    ScootsCraft.frames.optionDefaultFrames:SetPoint('TOPLEFT', ScootsCraft.frames.options.defaultFramesHeader, 'BOTTOMLEFT', 0, -4)
    ScootsCraft.frames.optionDefaultFrames:SetFrameStrata(_G['TradeSkillFrame']:GetFrameStrata())
    ScootsCraft.frames.optionDefaultFrames:SetText('Use Default Frames')
    
    ScootsCraft.frames.optionDefaultFrames:SetScript('OnEnter', function()
        GameTooltip:SetOwner(ScootsCraft.frames.optionDefaultFrames, 'ANCHOR_RIGHT')
        GameTooltip:SetText('Enable Default Frames', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
        GameTooltip:AddLine('Revert to the default Blizzard profession frames. Requires a reload of the UI to take effect.', nil, nil, nil, true)
        GameTooltip:Show()
    end)
    
    ScootsCraft.frames.optionDefaultFrames:SetScript('OnLeave', GameTooltip_Hide)
    
    ScootsCraft.frames.optionDefaultFrames:SetScript('OnClick', function()
        ScootsCraft.setOption('active', false)
        StaticPopup_Show('SCOOTSCRAFT_RELOAD')
    end)
    
    -- Note
    ScootsCraft.frames.options.defaultFramesNote = ScootsCraft.frames.options:CreateFontString(nil, 'ARTWORK')
    ScootsCraft.frames.options.defaultFramesNote:SetWidth(200)
    ScootsCraft.frames.options.defaultFramesNote:SetFontObject('GameFontHighlightSmall')
    ScootsCraft.frames.options.defaultFramesNote:SetPoint('TOPLEFT', ScootsCraft.frames.optionDefaultFrames, 'BOTTOMLEFT', 0, -4)
    ScootsCraft.frames.options.defaultFramesNote:SetJustifyH('LEFT')
    ScootsCraft.frames.options.defaultFramesNote:SetText('This can be manually triggered by typing ' .. '\124cff' .. '98fb98' .. '/scootscraft toggle' .. '\124r' .. ' in chat.')
end

ScootsCraft.setAckisButton = function()
    if(ScootsCraft.ackisButtonIsSet ~= true and ScootsCraft.ackisButton) then
        ScootsCraft.ackisButton:SetParent(ScootsCraft.frames.front)
        ScootsCraft.ackisButton:SetPoint('TOPRIGHT', ScootsCraft.frames.optionsButton, 'TOPLEFT', 2, 0)
        ScootsCraft.ackisButton:SetSize(80, 19)
        ScootsCraft.ackisButton:SetText('Ackis Scan')
        ScootsCraft.ackisButton:Show()
        
        ScootsCraft.frames.title:SetWidth(ScootsCraft.frames.title:GetWidth() - ScootsCraft.ackisButton:GetWidth())
        
        ScootsCraft.ackisButtonIsSet = true
    end
end

ScootsCraft.setFrameLevels = function()
    ScootsCraft.frames.front:SetFrameLevel(ScootsCraft.frames.master:GetFrameLevel() + 1)
    
    ScootsCraft.frames.title:SetFrameLevel(ScootsCraft.frames.master:GetFrameLevel() + 2)
    ScootsCraft.frames.professionLink:SetFrameLevel(ScootsCraft.frames.master:GetFrameLevel() + 3)
    ScootsCraft.frames.closeButton:SetFrameLevel(ScootsCraft.frames.master:GetFrameLevel() + 2)
    ScootsCraft.frames.optionsButton:SetFrameLevel(ScootsCraft.frames.master:GetFrameLevel() + 2)
    
    if(ScootsCraft.ackisButtonIsSet ~= true and ScootsCraft.ackisButton) then
        ScootsCraft.ackisButton:SetFrameLevel(ScootsCraft.frames.master:GetFrameLevel() + 2)
    end
    
    ScootsCraft.frames.professionButtonsHolder:SetFrameLevel(ScootsCraft.frames.master:GetFrameLevel() + 2)
    
    for _, spell in pairs(ScootsCraft.professionSpells) do
        spell.button:SetFrameLevel(ScootsCraft.frames.master:GetFrameLevel() + 3)
    end
    
    ScootsCraft.frames.recipeFrame:SetFrameLevel(ScootsCraft.frames.master:GetFrameLevel() + 2)
    
    for _, frame in pairs(ScootsCraft.frames.recipes) do
        frame:SetFrameLevel(ScootsCraft.frames.master:GetFrameLevel() + 3)
        frame.sectionToggle:SetFrameLevel(ScootsCraft.frames.master:GetFrameLevel() + 4)
    end
    
    ScootsCraft.frames.craftItemScroller:SetFrameLevel(ScootsCraft.frames.master:GetFrameLevel() + 2)
    ScootsCraft.frames.craftItemHolder:SetFrameLevel(ScootsCraft.frames.master:GetFrameLevel() + 3)
    ScootsCraft.frames.craftItem:SetFrameLevel(ScootsCraft.frames.master:GetFrameLevel() + 4)
    ScootsCraft.frames.craftIcon:SetFrameLevel(ScootsCraft.frames.master:GetFrameLevel() + 5)
    
    for _, frame in pairs(ScootsCraft.frames.reagents) do
        frame:SetFrameLevel(ScootsCraft.frames.master:GetFrameLevel() + 5)
    end
    
    ScootsCraft.frames.allSectionsToggle:SetFrameLevel(ScootsCraft.frames.master:GetFrameLevel() + 2)
    ScootsCraft.frames.createButton:SetFrameLevel(ScootsCraft.frames.master:GetFrameLevel() + 2)
    ScootsCraft.frames.increment:SetFrameLevel(ScootsCraft.frames.master:GetFrameLevel() + 2)
    ScootsCraft.frames.quantity:SetFrameLevel(ScootsCraft.frames.master:GetFrameLevel() + 2)
    ScootsCraft.frames.decrement:SetFrameLevel(ScootsCraft.frames.master:GetFrameLevel() + 2)
    ScootsCraft.frames.createAllButton:SetFrameLevel(ScootsCraft.frames.master:GetFrameLevel() + 2)
    
    ScootsCraft.frames.availableFilter:SetFrameLevel(ScootsCraft.frames.master:GetFrameLevel() + 2)
    ScootsCraft.frames.subclassFilter:SetFrameLevel(ScootsCraft.frames.master:GetFrameLevel() + 2)
    ScootsCraft.frames.slotFilter:SetFrameLevel(ScootsCraft.frames.master:GetFrameLevel() + 2)
    ScootsCraft.frames.searchFilter:SetFrameLevel(ScootsCraft.frames.master:GetFrameLevel() + 2)
    ScootsCraft.frames.equipmentFilter:SetFrameLevel(ScootsCraft.frames.master:GetFrameLevel() + 2)
    ScootsCraft.frames.forgeFilter:SetFrameLevel(ScootsCraft.frames.master:GetFrameLevel() + 2)
    
    if(ScootsCraft.frames.options) then
        ScootsCraft.frames.options:SetFrameLevel(ScootsCraft.frames.master:GetFrameLevel() + 6)
        
        ScootsCraft.frames.optionRecipeTooltipNone:SetFrameLevel(ScootsCraft.frames.master:GetFrameLevel() + 7)
        ScootsCraft.frames.optionRecipeTooltipItem:SetFrameLevel(ScootsCraft.frames.master:GetFrameLevel() + 7)
        ScootsCraft.frames.optionRecipeTooltipRecipe:SetFrameLevel(ScootsCraft.frames.master:GetFrameLevel() + 7)
        ScootsCraft.frames.optionDefaultFrames:SetFrameLevel(ScootsCraft.frames.master:GetFrameLevel() + 7)
    end
end