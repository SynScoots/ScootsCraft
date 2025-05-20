ScootsCraft = {
    ['title'] = 'ScootsCraft',
    ['spellIds'] = {
        51304, -- Alchemy
        51300, -- Blacksmithing
        51313, -- Enchanting
        51306, -- Engineering
        45363, -- Inscription
        51311, -- Jewelcrafting
        51302, -- Leatherworking
        2656,  -- Smelting
        51309, -- Tailoring
        51296, -- Cooking
        45542  -- First Aid
    },
    ['frames'] = {
        ['events'] = CreateFrame('Frame', 'ScootsCraft-EventsFrame', UIParent)
    },
    ['skillLevels'] = {},
    ['cachedCrafts'] = {},
    ['cachedCraftSections'] = {},
    ['cachedEquipmentSlots'] = {},
    ['hiddenSections'] = {},
    ['filteredCrafts'] = {},
    ['selectedCraft'] = {},
    ['scrollOffsets'] = {},
    ['defaultFilters'] = {
        ['available'] = false,
        ['equipment-only'] = false,
        ['subclass'] = nil,
        ['search'] = nil,
        ['slot'] = nil,
        ['equipment'] = nil,
        ['forge'] = nil
    },
    ['filters'] = {},
    ['filterChoices'] = {
        ['equipment'] = {
            {nil, 'All Equipment'},
            {'account', 'Attuneable (Acc)'},
            {'character', 'Attuneable (Char)'},
        },
        ['forge'] = {
            {nil, 'All Forge Levels'},
            {-1, '<= Unattuned'},
            {0, '<= Baseline'},
            {1, '<= Titanforged'},
            {2, '<= Warforged'},
            {3, '<= Lightforged'}
        }
    },
    ['cachedReagentCrafts'] = {}
}

ScootsCraft.onLoad = function()
    ScootsCraft.addonLoaded = true
    ScootsCraft.lockedActive = ScootsCraft.getOption('active')
end

ScootsCraft.onHide = function()
    ScootsCraft.cachedCrafts = {}
    ScootsCraft.cachedCraftSections = {}
    ScootsCraft.cachedEquipmentSlots = {}
    ScootsCraft.filteredCrafts = {}
    CloseTradeSkill()
end

ScootsCraft.loadOptions = function()
    if(ScootsCraft.optionsLoaded) then
        return nil
    end
    
    ScootsCraft.options = {
        ['active'] = true
    }
    
    if(ScootsCraft.addonLoaded and _G['SCOOTSCRAFT_OPTIONS'] ~= nil) then
        for key, value in pairs(_G['SCOOTSCRAFT_OPTIONS']) do
            ScootsCraft.options[key] = value
        end
        
        ScootsCraft.optionsLoaded = true
    end
end

ScootsCraft.setOption = function(key, value)
    if(not ScootsCraft.optionsLoaded) then
        ScootsCraft.loadOptions()
    end
    
    ScootsCraft.options[key] = value
    
    if(ScootsCraft.addonLoaded) then
        _G['SCOOTSCRAFT_OPTIONS'] = ScootsCraft.options
    end
end

ScootsCraft.getOption = function(key)
    if(not ScootsCraft.optionsLoaded) then
        ScootsCraft.loadOptions()
    end
    
    return ScootsCraft.options[key]
end

ScootsCraft.onLogout = function()
    if(ScootsCraft.optionsLoaded) then
        _G['SCOOTSCRAFT_OPTIONS'] = ScootsCraft.options
        ScootsCraft.closeCraftPanel()
    end
end

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

ScootsCraft.openCraftPanel = function()
    ScootsCraft.buildUi()
    ScootsCraft.setAckisButton()
    
    ScootsCraft.frames.master:ClearAllPoints()
    ScootsCraft.frames.master:SetPoint('TOPLEFT', UIParent, 'TOPLEFT', 0, -104)
    
    ScootsCraft.renderProfession()
    ShowUIPanel(ScootsCraft.frames.master)
end

ScootsCraft.closeCraftPanel = function()
    if(ScootsCraft.uiBuilt) then
        HideUIPanel(ScootsCraft.frames.master)
    end
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
end

ScootsCraft.buildUiHeader = function()
    -- Title
    ScootsCraft.frames.title = CreateFrame('Frame', 'ScootsCraft-TitleFrame', ScootsCraft.frames.front)
    ScootsCraft.frames.title:SetPoint('TOPLEFT', ScootsCraft.frames.front, 'TOPLEFT', 74, -16)
    ScootsCraft.frames.title:SetSize(440, 16)
    
    ScootsCraft.frames.title.text = ScootsCraft.frames.title:CreateFontString(nil, 'ARTWORK')
    ScootsCraft.frames.title.text:SetFont('Fonts\\FRIZQT__.TTF', 12)
    ScootsCraft.frames.title.text:SetPoint('LEFT', 0, 0)
    ScootsCraft.frames.title.text:SetJustifyH('LEFT')
    ScootsCraft.frames.title.text:SetTextColor(1, 1, 1)
    
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
    local prev = nil
    for _, spellId in ipairs(ScootsCraft.spellIds) do
        if(IsSpellKnown(spellId)) then
            local name, _, icon = GetSpellInfo(spellId)
            local spell = {
                ['id'] = spellId,
                ['name'] = name,
                ['icon'] = icon,
                ['button'] = CreateFrame('Button', 'ScootsCraft-ProfessionButton-' .. name, ScootsCraft.frames.professionButtonsHolder, 'SecureActionButtonTemplate')
            }
            
            for i = 1, MAX_SPELLS do
                bookSpellName = GetSpellName(i, BOOKTYPE_SPELL)
                
                if(bookSpellName == name) then
                    spell.bookId = i
                    break
                end
            end

            spell.button:SetSize(24, 24)
            spell.button:SetFrameStrata(_G['TradeSkillFrame']:GetFrameStrata())
            spell.button:SetAttribute('type', 'spell')
            spell.button:SetAttribute('spell', spell.id)
            spell.button:SetNormalTexture(icon)
            spell.button:RegisterForClicks('AnyUp')
            
            if(prev == nil) then
                spell.button:SetPoint('TOPLEFT', ScootsCraft.frames.professionButtonsHolder, 'TOPLEFT', 0, 0)
                ScootsCraft.frames.professionButtonsHolder:SetHeight(spell.button:GetHeight())
            else
                spell.button:SetPoint('TOPLEFT', prev, 'TOPRIGHT', 0, 0)
            end
            
            ScootsCraft.frames.professionButtonsHolder:SetWidth(ScootsCraft.frames.professionButtonsHolder:GetWidth() + spell.button:GetWidth())
            
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
            
            table.insert(ScootsCraft.professionSpells, spell)
            prev = spell.button
        end
    end
    
    ScootsCraft.frames.professionButtonsHolder:SetPoint('TOPLEFT', ScootsCraft.frames.front, 'TOPLEFT', (670 - ScootsCraft.frames.professionButtonsHolder:GetWidth()), -42)
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
            if(ScootsCraft.frames.reagents[i].itemId and not IsControlKeyDown() and not IsAltKeyDown() and not IsShiftKeyDown()) then
                ScootsCraft.jumpToItemId(ScootsCraft.frames.reagents[i].itemId)
            end
            
            HandleModifiedItemClick(ScootsCraft.selectedCraft[ScootsCraft.activeProfession].reagents[i].link)
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
    
    ScootsCraft.frames.searchFilter:SetScript('OnEnterPressed', EditBox_ClearFocus)
    ScootsCraft.frames.searchFilter:SetScript('OnEscapePressed', EditBox_ClearFocus)
    ScootsCraft.frames.searchFilter:SetScript('OnEditFocusGained', function()
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
    ScootsCraft.frames.options.recipeTooltipHeader:SetWidth(ScootsCraft.frames.craftItem:GetWidth() - (ScootsCraft.frames.craftIcon:GetWidth() + 10))
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
    
    -- Option: Use default frames
    -- Header
    ScootsCraft.frames.options.defaultFramesHeader = ScootsCraft.frames.options:CreateFontString(nil, 'ARTWORK')
    ScootsCraft.frames.options.defaultFramesHeader:SetWidth(ScootsCraft.frames.craftItem:GetWidth() - (ScootsCraft.frames.craftIcon:GetWidth() + 10))
    ScootsCraft.frames.options.defaultFramesHeader:SetFontObject('GameFontNormal')
    ScootsCraft.frames.options.defaultFramesHeader:SetPoint('TOPLEFT', ScootsCraft.frames.optionRecipeTooltipNone, 'BOTTOMLEFT', 0, -10)
    ScootsCraft.frames.options.defaultFramesHeader:SetJustifyH('LEFT')
    ScootsCraft.frames.options.defaultFramesHeader:SetText('Tooltip on the recipe list')
    
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
        
        ScootsCraft.ackisButtonIsSet = true
    end
end

ScootsCraft.renderProfession = function()
    local professionName, currentSkill, maxSkill = GetTradeSkillLine()
    
    if(ScootsCraft.uiBuilt ~= true or professionName == 'UNKNOWN') then
        HideUIPanel(ScootsCraft.frames.master)
        return nil
    end
    
    ScootsCraft.activeProfession = professionName
    
    -- Make the active profession button glow
    for _, spell in pairs(ScootsCraft.professionSpells) do
        spell.button.glow:SetAlpha(0)
        spell.button:Enable()
        
        if(spell.name == professionName or (spell.name == 'Smelting' and professionName == 'Mining')) then
            spell.button.glow:SetVertexColor(0.8, 0.8, 0)
            spell.button.glow:SetAlpha(1)
            spell.button:Disable()
            
            SetPortraitToTexture(ScootsCraft.frames.master.icon, spell.icon)
        end
    end
    
    -- Set default filter values
    if(ScootsCraft.filters[ScootsCraft.activeProfession] == nil) then
        ScootsCraft.filters[ScootsCraft.activeProfession] = {}
        
        for key, value in pairs(ScootsCraft.defaultFilters) do
            ScootsCraft.filters[ScootsCraft.activeProfession][key] = value
        end
    end
    
    -- Bring collapsed sections/scroll position from last time we were on this profession
    if(ScootsCraft.hiddenSections[professionName] == nil) then
        ScootsCraft.hiddenSections[professionName] = {}
    end
    
    if(ScootsCraft.scrollOffsets[ScootsCraft.activeProfession] ~= nil) then
        FauxScrollFrame_SetOffset(ScootsCraft.frames.recipeFrame, ScootsCraft.scrollOffsets[ScootsCraft.activeProfession])
        ScootsCraft.frames.recipeFrame:SetVerticalScroll(ScootsCraft.scrollOffsets[ScootsCraft.activeProfession] * ScootsCraft.recipeLineHeight)
    else
        FauxScrollFrame_SetOffset(ScootsCraft.frames.recipeFrame, 0)
        ScootsCraft.frames.recipeFrame:SetVerticalScroll(0)
    end
    
    -- Set title up
    ScootsCraft.frames.title.text:SetText(ScootsCraft.title .. ' - ' .. professionName .. ' [' .. tostring(currentSkill) .. ' / ' .. tostring(maxSkill) .. ']')
    ScootsCraft.skillLevels[professionName] = {currentSkill, maxSkill}
    ScootsCraft.frames.professionLink:SetPoint('LEFT', ScootsCraft.frames.title.text, 'RIGHT', 20, 0)
    
    -- Prepare profession
    ScootsCraft.cacheProfession()
    
    -- Setup filters
    UIDropDownMenu_Initialize(ScootsCraft.frames.subclassFilter, ScootsCraft.setSubclassFilterValues)
    UIDropDownMenu_Initialize(ScootsCraft.frames.slotFilter, ScootsCraft.setSlotFilterValues)
    UIDropDownMenu_Initialize(ScootsCraft.frames.equipmentFilter, ScootsCraft.setEquipmentFilterValues)
    UIDropDownMenu_Initialize(ScootsCraft.frames.forgeFilter, ScootsCraft.setForgeFilterValues)
    
    -- Apply filters from last time we viewed this profession
    -- Available
    ScootsCraft.frames.availableFilter:SetChecked(ScootsCraft.filters[professionName].available)
    
    -- Equipment Only
    ScootsCraft.frames.equipmentOnlyFilter:SetChecked(ScootsCraft.filters[professionName]['equipment-only'])
    
    -- Search
    if(ScootsCraft.filters[professionName].search) then
        ScootsCraft.frames.searchFilter:SetText(ScootsCraft.filters[professionName].search)
    else
        ScootsCraft.frames.searchFilter:SetText('')
    end
    
    -- Subclass
    if(ScootsCraft.filters[professionName].subclass) then
        local index = 1
        for sectionIndex, sectionName in ipairs(ScootsCraft.cachedCraftSections) do
            index = index + 1
            if(ScootsCraft.filters[professionName].subclass == sectionIndex) then
                UIDropDownMenu_SetSelectedValue(ScootsCraft.frames.subclassFilter, index)
                UIDropDownMenu_SetText(ScootsCraft.frames.subclassFilter, sectionName)
                break
            end
        end
    else
        UIDropDownMenu_SetSelectedValue(ScootsCraft.frames.subclassFilter, 1)
        UIDropDownMenu_SetText(ScootsCraft.frames.subclassFilter, 'All Subclasses')
    end
    
    -- Slot
    if(ScootsCraft.filters[professionName].slot) then
        local index = 1
        for slotName, _ in ipairs(ScootsCraft.cachedEquipmentSlots) do
            index = index + 1
            if(ScootsCraft.filters[professionName].slot == slotName) then
                UIDropDownMenu_SetSelectedValue(ScootsCraft.frames.slotFilter, index)
                UIDropDownMenu_SetText(ScootsCraft.frames.slotFilter, sectionName)
                break
            end
        end
    else
        UIDropDownMenu_SetSelectedValue(ScootsCraft.frames.slotFilter, 1)
        UIDropDownMenu_SetText(ScootsCraft.frames.slotFilter, 'All Slots')
    end
    
    -- Equipment
    local index = 0
    for _, choice in ipairs(ScootsCraft.filterChoices.equipment) do
        index = index + 1
        if(ScootsCraft.filters[professionName].equipment == choice[1]) then
            UIDropDownMenu_SetSelectedValue(ScootsCraft.frames.equipmentFilter, index)
            UIDropDownMenu_SetText(ScootsCraft.frames.equipmentFilter, choice[2])
            break
        end
    end
    
    -- Forge
    local index = 0
    for _, choice in ipairs(ScootsCraft.filterChoices.forge) do
        index = index + 1
        if(ScootsCraft.filters[professionName].forge == choice[1]) then
            UIDropDownMenu_SetSelectedValue(ScootsCraft.frames.forgeFilter, index)
            UIDropDownMenu_SetText(ScootsCraft.frames.forgeFilter, choice[2])
            break
        end
    end
    
    -- Hide options if they're open
    if(ScootsCraft.frames.options and ScootsCraft.frames.options:IsVisible()) then
        ScootsCraft.frames.options:Hide()
        ScootsCraft.frames.optionsButton:SetText('Options')
    end
    
    -- Display it all
    ScootsCraft.filterCrafts()
    ScootsCraft.updateDisplayedRecipes()
    ScootsCraft.setFrameLevels()
end

ScootsCraft.setSubclassFilterValues = function(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    
    info.text = 'All Subclasses'
    info.func = function()
        UIDropDownMenu_SetText(ScootsCraft.frames.subclassFilter, 'All Subclasses')
        ScootsCraft.setFilter('subclass', nil)
    end
    UIDropDownMenu_AddButton(info, level)
    
    for sectionIndex, sectionName in ipairs(ScootsCraft.cachedCraftSections) do
        info.text = sectionName
        info.func = function()
            UIDropDownMenu_SetText(ScootsCraft.frames.subclassFilter, sectionName)
            ScootsCraft.setFilter('subclass', sectionIndex)
        end
        UIDropDownMenu_AddButton(info, level)
    end
end

ScootsCraft.setSlotFilterValues = function(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    
    info.text = 'All Slots'
    info.func = function()
        UIDropDownMenu_SetText(ScootsCraft.frames.slotFilter, 'All Slots')
        ScootsCraft.setFilter('slot', nil)
    end
    UIDropDownMenu_AddButton(info, level)
    
    local slots = {
        'Head', 'Neck', 'Shoulders', 'Back', 'Chest', 'Shirt', 'Wrist', 'Hands', 'Waist', 'Legs', 'Feet', 'Finger', 'Trinket', '1H Weapon', '2H Weapon', 'Off Hand', 'Ranged', 'Ammunition', 'Container', 'Created Items'
    }
    
    for _, slotName in ipairs(slots) do
        if(ScootsCraft.cachedEquipmentSlots[slotName]) then
            info.text = slotName
            info.func = function()
                UIDropDownMenu_SetText(ScootsCraft.frames.slotFilter, slotName)
                ScootsCraft.setFilter('slot', slotName)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end
end

ScootsCraft.setEquipmentFilterValues = function(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    
    for _, choice in ipairs(ScootsCraft.filterChoices.equipment) do
        info.text = choice[2]
        info.func = function()
            UIDropDownMenu_SetText(ScootsCraft.frames.equipmentFilter, choice[2])
            ScootsCraft.setFilter('equipment', choice[1])
        end
        
        UIDropDownMenu_AddButton(info, level)
    end
end

ScootsCraft.setForgeFilterValues = function(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    
    for _, choice in ipairs(ScootsCraft.filterChoices.forge) do
        info.text = choice[2]
        info.func = function()
            UIDropDownMenu_SetText(ScootsCraft.frames.forgeFilter, choice[2])
            ScootsCraft.setFilter('forge', choice[1])
        end
        
        UIDropDownMenu_AddButton(info, level)
    end
end

ScootsCraft.toggleSection = function(sectionIndex)
    if(ScootsCraft.hiddenSections[ScootsCraft.activeProfession][sectionIndex]) then
        ScootsCraft.hiddenSections[ScootsCraft.activeProfession][sectionIndex] = nil
    else
        ScootsCraft.hiddenSections[ScootsCraft.activeProfession][sectionIndex] = true
    end
    
    local anyVisible = false
    for sectionIndex, _ in pairs(ScootsCraft.cachedCraftSections) do
        if(ScootsCraft.hiddenSections[ScootsCraft.activeProfession][sectionIndex] == nil) then
            anyVisible = true
            break
        end
    end
    
    if(anyVisible) then
        ScootsCraft.frames.allSectionsToggle:SetNormalTexture('Interface\\Buttons\\UI-MinusButton-Up')
        ScootsCraft.frames.allSectionsToggle:SetPushedTexture('Interface\\Buttons\\UI-MinusButton-Down')
    else
        ScootsCraft.frames.allSectionsToggle:SetNormalTexture('Interface\\Buttons\\UI-PlusButton-Up')
        ScootsCraft.frames.allSectionsToggle:SetPushedTexture('Interface\\Buttons\\UI-PlusButton-Down')
    end
    
    ScootsCraft.filterCrafts()
    ScootsCraft.updateDisplayedRecipes()
end

ScootsCraft.toggleAllSections = function()
    local hiddenAny = false
    
    for sectionIndex, _ in pairs(ScootsCraft.cachedCraftSections) do
        if(ScootsCraft.hiddenSections[ScootsCraft.activeProfession][sectionIndex] == nil) then
            ScootsCraft.hiddenSections[ScootsCraft.activeProfession][sectionIndex] = true
            hiddenAny = true
        end
    end
    
    if(hiddenAny) then
        ScootsCraft.frames.allSectionsToggle:SetNormalTexture('Interface\\Buttons\\UI-PlusButton-Up')
        ScootsCraft.frames.allSectionsToggle:SetPushedTexture('Interface\\Buttons\\UI-PlusButton-Down')
    else
        ScootsCraft.frames.allSectionsToggle:SetNormalTexture('Interface\\Buttons\\UI-MinusButton-Up')
        ScootsCraft.frames.allSectionsToggle:SetPushedTexture('Interface\\Buttons\\UI-MinusButton-Down')
        
        for sectionIndex, _ in pairs(ScootsCraft.cachedCraftSections) do
            ScootsCraft.hiddenSections[ScootsCraft.activeProfession][sectionIndex] = nil
        end
    end
    
    ScootsCraft.filterCrafts()
    ScootsCraft.updateDisplayedRecipes()
end

ScootsCraft.extractId = function(link)
    if(link == nil) then
        return 'unknown', nil
    end
    
    local subString = string.match(link, 'item:%d+')
    
    if(subString) then
        return 'item', tonumber(string.match(subString, '%d+'))
    end
    
    subString = string.match(link, 'enchant:%d+')
    if(subString) then
        return 'spell', tonumber(string.match(subString, '%d+'))
    end
    
    return 'unknown', nil
end

ScootsCraft.cacheProfession = function()
    local recipeCount = GetNumTradeSkills()
    ScootsCraft.cachedCrafts = {}
    ScootsCraft.cachedCraftSections = {}
    ScootsCraft.cachedEquipmentSlots = {}
    local sectionIndex = 0
    
    for skillIndex = 1, recipeCount do
        local skillName, skillType, numAvailable, _, altVerb = GetTradeSkillInfo(skillIndex)
        
        if(skillType == 'header') then
            sectionIndex = sectionIndex + 1
            ScootsCraft.cachedCraftSections[sectionIndex] = skillName
            ScootsCraft.cachedCrafts[sectionIndex] = {}
        else
            local minMade, maxMade = GetTradeSkillNumMade(skillIndex)
            
            local craft = {
                ['index'] = skillIndex,
                ['section'] = sectionIndex,
                ['name'] = skillName,
                ['description'] = GetTradeSkillDescription(skillIndex),
                ['type'] = skillType,
                ['number'] = numAvailable,
                ['verb'] = altVerb,
                ['link'] = GetTradeSkillItemLink(skillIndex),
                ['tradelink'] = GetTradeSkillRecipeLink(skillIndex),
                ['icon'] = GetTradeSkillIcon(skillIndex),
                ['slot'] = nil,
                ['equippable'] = false,
                ['min'] = minMade,
                ['max'] = maxMade,
                ['forge'] = -1,
                ['attune'] = false,
                ['attuneany'] = false,
                ['requires'] = BuildColoredListString(GetTradeSkillTools(skillIndex)),
                ['reagents'] = {},
            }
            
            if(craft.link) then
                local linkType, linkId = ScootsCraft.extractId(craft.link)
                craft.id = linkId
                craft.craftid = linkType .. '-' .. tostring(linkId)
                craft.crafttype = linkType
                
                if(linkType == 'item') then
                    craft.equippable = IsEquippableItem(craft.id)
                    craft.slot = ScootsCraft.mapInvTypeToSlot(select(9, GetItemInfo(craft.link)))
                elseif(linkType == 'spell') then
                    craft.slot = ScootsCraft.mapSpellIdToSlot(linkId)
                end
            end
            
            if(craft.crafttype and craft.crafttype == 'item') then
                if(GetItemAttuneForge and craft.id) then
                    craft.forge = GetItemAttuneForge(craft.id)
                end
                
                if(GetItemTagsCustom) then
                    local tags = GetItemTagsCustom(craft.id)
                    if(tags and bit.band(tags, 96) == 64) then
                        if(CanAttuneItemHelper and CanAttuneItemHelper(craft.id) > 0) then
                            craft.attune = true
                            craft.attuneany = true
                        elseif(IsAttunableBySomeone) then
                            local check = IsAttunableBySomeone(craft.id)
                            if(check ~= nil and check ~= 0) then
                                craft.attuneany = true
                            end
                        end
                    end
                end
            end
            
            local reagentCount = GetTradeSkillNumReagents(skillIndex)
            
            for reagentIndex = 1, reagentCount do
                local reagentName, reagentTexture, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(skillIndex, reagentIndex)
                local reagent = {
                    ['name'] = reagentName,
                    ['icon'] = reagentTexture,
                    ['required'] = reagentCount,
                    ['owned'] = playerReagentCount,
                    ['link'] = GetTradeSkillReagentItemLink(skillIndex, reagentIndex)
                }
                
                craft.reagents[reagentIndex] = reagent
            end
            
            if(craft.slot ~= nil) then
                ScootsCraft.cachedEquipmentSlots[craft.slot] = true
            end
            
            table.insert(ScootsCraft.cachedCrafts[sectionIndex], craft)
        end
    end
end

ScootsCraft.mapInvTypeToSlot = function(invType)
    local map = {
        ['INVTYPE_RANGEDRIGHT'] = 'Ranged',
        ['INVTYPE_SHIELD'] = 'Off Hand',
        ['INVTYPE_WEAPON'] = '1H Weapon',
        ['INVTYPE_2HWEAPON'] = '2H Weapon',
        ['INVTYPE_WRIST'] = 'Wrist',
        ['INVTYPE_TRINKET'] = 'Trinket',
        ['INVTYPE_NECK'] = 'Neck',
        ['INVTYPE_CLOAK'] = 'Back',
        ['INVTYPE_BODY'] = 'Shirt',
        ['INVTYPE_HEAD'] = 'Head',
        ['INVTYPE_FEET'] = 'Feet',
        ['INVTYPE_ROBE'] = 'Chest',
        ['INVTYPE_BAG'] = 'Container',
        ['INVTYPE_HOLDABLE'] = 'Off Hand',
        ['INVTYPE_AMMO'] = 'Ammunition',
        ['INVTYPE_FINGER'] = 'Finger',
        ['INVTYPE_THROWN'] = 'Ranged',
        ['INVTYPE_HAND'] = 'Hands',
        ['INVTYPE_WAIST'] = 'Waist',
        ['INVTYPE_LEGS'] = 'Legs',
        ['INVTYPE_SHOULDER'] = 'Shoulder',
        ['INVTYPE_CHEST'] = 'Chest',
        ['INVTYPE_WEAPONMAINHAND'] = '1H Weapon'
    }
    
    if(map[invType]) then
        return map[invType]
    end
    
    return 'Created Items'
end

ScootsCraft.mapSpellIdToSlot = function(spellId)
    local map = {
        ['Head'] = {
            67839
        },
        ['Shoulders'] = {
            61117, 61118, 61119, 61120
        },
        ['Back'] = {
            55002, 63765, 55769, 55642, 55777, 44631, 47899, 44591, 47898, 47672, 60663, 44596, 44556, 44500, 44582, 47051, 34005, 60609, 34003, 34004, 27961, 25086, 25081, 25082, 25083, 25084, 20015, 20014, 13882, 13746, 13794, 13657, 13635, 13522, 7861, 13421, 13419, 7771, 7454, 44483, 44494, 44590, 34006, 27962
        },
        ['Chest'] = {
            60692, 44588, 47900, 44509, 47766, 44492, 46594, 44623, 27958, 27960, 33992, 33990, 27957, 20025, 20028, 33991, 20026, 13941, 13917, 13858, 13700, 13663, 13640, 13626, 13607, 13538, 7857, 7748, 7426, 7443, 7420, 7776
        },
        ['Wrist'] = {
            55628, 57683, 57691, 57690, 62256, 60767, 44575, 44593, 44598, 44616, 44635, 44555, 60616, 27914, 27913, 27911, 27905, 27899, 34001, 34002, 23802, 23801, 20011, 20009, 20008, 13945, 13939, 13931, 13846, 13822, 13661, 13646, 13648, 13642, 13622, 13536, 13501, 7859, 7779, 7782, 7766, 7457, 7428, 7418, 27917, 27906, 20010
        },
        ['Hands'] = {
            55641, 54998, 54999, 63770, 44625, 60668, 44529, 44488, 44484, 44513, 44592, 44506, 33997, 33994, 33999, 33995, 33996, 33993, 25078, 20013, 25079, 25073, 25080, 25072, 20012, 13948, 13947, 13868, 13887, 13841, 13815, 13698, 13620, 71692, 25074, 13617, 13612
        },
        ['Waist'] = {
            54736, 54793
        },
        ['Legs'] = {
            60583, 60584, 56034, 56039
        },
        ['Feet'] = {
            55016, 60763, 47901, 44589, 44508, 44584, 60623, 60606, 44528, 27954, 34008, 27951, 27950, 27948, 20023, 20024, 20020, 13935, 63746, 13890, 13836, 13687, 13644, 13637, 7867, 7863, 34007
        },
        ['Finger'] = {
            44645, 44636, 59636, 27926, 27927, 27924, 27920
        },
        ['1H Weapon'] = {
            64441, 64579, 59619, 59621, 59625, 60714, 60707, 44621, 44524, 44576, 44633, 44510, 44629, 60621, 42974, 27984, 27982, 27981, 28004, 28003, 34010, 27975, 27967, 27972, 42620, 46578, 23800, 20034, 22750, 20032, 23804, 23803, 22749, 23799, 20031, 20033, 20029, 13898, 13943, 13915, 13693, 13653, 13655, 13503, 7786, 7788, 27968, 21931
        },
        ['2H Weapon'] = {
            62948, 60691, 44595, 44630, 62959, 27977, 27971, 27837, 20036, 20035, 20030, 13937, 13695, 13529, 13380, 7745, 7793
        },
        ['Off Hand'] = {
            44489, 60653, 27946, 44383, 27945, 34009, 27944, 20016, 20017, 13933, 13905, 13817, 13689, 13659, 13631, 13485, 13464, 13378
        },
        ['Created Items'] = {
            60893, 61177, 61288, 69412
        }
    }
    
    for slot, idList in pairs(map) do
        for _, mappedSpellId in pairs(idList) do
            if(spellId == mappedSpellId) then
                return slot
            end
        end
    end
    
    return nil
end

ScootsCraft.filterCrafts = function()
    ScootsCraft.filteredCrafts = {}
    
    local selectedCraftInFilter = false
    
    for sectionIndex, crafts in ipairs(ScootsCraft.cachedCrafts) do
        table.insert(ScootsCraft.filteredCrafts, {
            ['type'] = 'section',
            ['detail'] = {
                ['name'] = ScootsCraft.cachedCraftSections[sectionIndex],
                ['index'] = sectionIndex
            }
        })
        
        local addedAny = false
    
        for _, craft in ipairs(crafts) do
            repeat
                -- Filter: Have Materials
                if(ScootsCraft.filters[ScootsCraft.activeProfession].available and craft.number < 1) then
                    break
                end
                
                -- Filter: Equipment Only
                if(ScootsCraft.filters[ScootsCraft.activeProfession]['equipment-only'] and not craft.equippable) then
                    break
                end
                
                -- Filter: Search
                if(ScootsCraft.filters[ScootsCraft.activeProfession].search) then
                    if(not string.match(string.lower(craft.name), string.lower(ScootsCraft.filters[ScootsCraft.activeProfession].search))) then
                        local hasMatch = false
                        
                        for _, reagent in pairs(craft.reagents) do
                            if(string.match(string.lower(reagent.name), string.lower(ScootsCraft.filters[ScootsCraft.activeProfession].search))) then
                                hasMatch = true
                                break
                            end
                        end
                        
                        if(hasMatch ~= true) then
                            break
                        end
                    end
                end
                
                -- Filter: Subclass
                if(ScootsCraft.filters[ScootsCraft.activeProfession].subclass) then
                    if(sectionIndex ~= ScootsCraft.filters[ScootsCraft.activeProfession].subclass) then
                        break
                    end
                end
                
                -- Filter: Slot
                if(ScootsCraft.filters[ScootsCraft.activeProfession].slot) then
                    if(craft.slot ~= ScootsCraft.filters[ScootsCraft.activeProfession].slot) then
                        break
                    end
                end
                
                -- Filter: Equipment (attuneable)
                if(ScootsCraft.filters[ScootsCraft.activeProfession].equipment and craft.equippable) then
                    if(ScootsCraft.filters[ScootsCraft.activeProfession].equipment == 'account') then
                        if(craft.attuneany ~= true) then
                            break
                        end
                    elseif(ScootsCraft.filters[ScootsCraft.activeProfession].equipment == 'character') then
                        if(craft.attune ~= true) then
                            break
                        end
                    end
                end
                
                -- Filter: Forge level
                if(ScootsCraft.filters[ScootsCraft.activeProfession].forge) then
                    if(craft.forge and craft.forge > ScootsCraft.filters[ScootsCraft.activeProfession].forge) then
                        break
                    end
                end
                
                addedAny = true
                
                if(ScootsCraft.hiddenSections[ScootsCraft.activeProfession][sectionIndex]) then
                    break
                end
                
                table.insert(ScootsCraft.filteredCrafts, {
                    ['type'] = 'craft',
                    ['detail'] = craft
                })
                
                if(ScootsCraft.selectedCraft[ScootsCraft.activeProfession] and ScootsCraft.selectedCraft[ScootsCraft.activeProfession].craftid == craft.craftid) then
                    selectedCraftInFilter = true
                    ScootsCraft.selectRecipe(craft)
                end
            until true
        end
            
        if(addedAny ~= true) then
            table.remove(ScootsCraft.filteredCrafts)
        end
    end
    
    if(selectedCraftInFilter == false) then
        for _, craft in ipairs(ScootsCraft.filteredCrafts) do
            if(craft.type == 'craft') then
                ScootsCraft.selectRecipe(craft.detail)
                break
            end
        end
    end
end

ScootsCraft.updateDisplayedRecipes = function()
    if(ScootsCraft.filteredCrafts == nil) then
        return nil
    end
    
    FauxScrollFrame_Update(ScootsCraft.frames.recipeFrame, #ScootsCraft.filteredCrafts, ScootsCraft.recipesVisible, ScootsCraft.recipeLineHeight, nil, nil, nil, nil, nil, nil, true)
    local offset = FauxScrollFrame_GetOffset(ScootsCraft.frames.recipeFrame)
    
    ScootsCraft.scrollOffsets[ScootsCraft.activeProfession] = offset
    
    for i = 1, ScootsCraft.recipesVisible do
        local recipeIndex = i + offset
        local recipe = ScootsCraft.filteredCrafts[recipeIndex]
        local frame = ScootsCraft.frames.recipes[i]
        
        if(recipe == nil) then
            frame:Hide()
            frame.recipe = nil
        else
            frame:Show()
            frame.icon:SetAlpha(0)
            
            if(recipe.type == 'section') then
                frame.isSectionHead = true
                frame.section = recipe.detail.index
                frame.text:SetText(recipe.detail.name)
                frame.text:SetTextColor(1, 1, 1)
                frame.recipe = nil
                frame.underline:SetAlpha(1)
                frame.selected:SetAlpha(0)
                frame.sectionToggle:Show()
                
                if(ScootsCraft.hiddenSections[ScootsCraft.activeProfession][frame.section]) then
                    frame.sectionToggle:SetNormalTexture('Interface\\Buttons\\UI-PlusButton-Up')
                    frame.sectionToggle:SetPushedTexture('Interface\\Buttons\\UI-PlusButton-Down')
                else
                    frame.sectionToggle:SetNormalTexture('Interface\\Buttons\\UI-MinusButton-Up')
                    frame.sectionToggle:SetPushedTexture('Interface\\Buttons\\UI-MinusButton-Down')
                end
            else
                frame.isSectionHead = false
                frame.section = nil
                frame.recipe = recipe.detail
                frame.underline:SetAlpha(0)
                frame.selected:SetAlpha(0)
                frame.sectionToggle:Hide()
                
                if(ScootsCraft.selectedCraft[ScootsCraft.activeProfession] and recipe.detail.craftid == ScootsCraft.selectedCraft[ScootsCraft.activeProfession].craftid) then
                    frame.selected:SetAlpha(0.3)
                end
                
                if(recipe.detail.forge == 0) then
                    frame.text:SetTextColor(0.65, 1, 0.5)
                    frame.selected:SetVertexColor(0.65, 1, 0.5)
                elseif(recipe.detail.forge == 1) then
                    frame.text:SetTextColor(0.5, 0.5, 1)
                    frame.selected:SetVertexColor(0.5, 0.5, 1)
                elseif(recipe.detail.forge == 2) then
                    frame.text:SetTextColor(1, 0.65, 0.5)
                    frame.selected:SetVertexColor(1, 0.65, 0.5)
                elseif(recipe.detail.forge == 3) then
                    frame.text:SetTextColor(1, 1, 0.65)
                    frame.selected:SetVertexColor(1, 1, 0.65)
                else
                    if(recipe.detail.attune) then
                        frame.text:SetTextColor(0.8, 0.8, 0.8)
                        frame.selected:SetVertexColor(0.8, 0.8, 0.8)
                    else
                        frame.text:SetTextColor(0.5, 0.5, 0.5)
                        frame.selected:SetVertexColor(0.5, 0.5, 0.5)
                    end
                end
                
                if(recipe.detail.type == 'trivial' or ScootsCraft.skillLevels[ScootsCraft.activeProfession][1] >= ScootsCraft.skillLevels[ScootsCraft.activeProfession][2]) then
                    frame.icon:SetAlpha(0)
                else
                    frame.icon:SetTexture('Interface\\AddOns\\ScootsCraft\\Textures\\Craft-' .. recipe.detail.type)
                    frame.icon:SetAlpha(1)
                end
                
                local suffix = ''
                if(recipe.detail.number > 0) then
                    suffix = ' [' .. recipe.detail.number .. ']'
                end
                frame.text:SetText(recipe.detail.name .. suffix)
            end
        end
    end
end

ScootsCraft.selectRecipe = function(craft)
    ScootsCraft.selectedCraft[ScootsCraft.activeProfession] = craft
    ScootsCraft.frames.craftIcon:SetNormalTexture(craft.icon)
    
    local height = ScootsCraft.frames.craftIcon:GetHeight()
    
    if(craft.max > 1) then
        if(craft.min == craft.max) then
            ScootsCraft.frames.craftIcon.text:SetText(craft.min)
        else
            ScootsCraft.frames.craftIcon.text:SetText(craft.min .. '-' .. craft.max)
        end
        
        if(ScootsCraft.frames.craftIcon.text:GetWidth() > ScootsCraft.frames.craftIcon:GetWidth()) then
            ScootsCraft.frames.craftIcon.text:SetText('~' .. math.floor((craft.min + craft.max) / 2))
        end
    else
        ScootsCraft.frames.craftIcon.text:SetText('')
    end
    
    ScootsCraft.frames.craftItem.name:SetText(craft.name)
    
    if(craft.requires) then
        ScootsCraft.frames.craftItem.requiresLabel:SetText('Requires:')
        ScootsCraft.frames.craftItem.requires:SetText(craft.requires)
    else
        ScootsCraft.frames.craftItem.requiresLabel:SetText('')
        ScootsCraft.frames.craftItem.requires:SetText('')
    end
    
    local cooldown = GetTradeSkillCooldown(craft.index)
    if(cooldown) then
        ScootsCraft.frames.craftItem.cooldown:SetText('Cooldown remaining: ' .. SecondsToTime(cooldown))
    else
        ScootsCraft.frames.craftItem.cooldown:SetText('')
    end
    
    if(craft.description) then
        ScootsCraft.frames.craftItem.description:SetPoint('TOPLEFT', ScootsCraft.frames.craftIcon, 'BOTTOMLEFT', 0, -10)
        ScootsCraft.frames.craftItem.description:SetText(craft.description)
        height = height + ScootsCraft.frames.craftItem.description:GetHeight() + 10
    else
        ScootsCraft.frames.craftItem.description:SetPoint('TOPLEFT', ScootsCraft.frames.craftIcon, 'BOTTOMLEFT', 0, 0)
        ScootsCraft.frames.craftItem.description:SetText('')
    end
    
    ScootsCraft.frames.craftItem.reagentsLabel:Hide()
    for i = 1, 8 do
        local reagent = craft.reagents[i]

        if(reagent and reagent.name and reagent.icon) then
            if(i == 1) then
                ScootsCraft.frames.craftItem.reagentsLabel:Show()
                height = height + ScootsCraft.frames.craftItem.reagentsLabel:GetHeight() + 10 + ScootsCraft.frames.reagents[i]:GetHeight() + 3
            elseif(i % 2 == 1) then
                height = height + ScootsCraft.frames.reagents[i]:GetHeight() + 2
            end
        
            ScootsCraft.frames.reagents[i]:Show()
            SetItemButtonTexture(ScootsCraft.frames.reagents[i], reagent.icon)
            _G[ScootsCraft.frames.reagents[i]:GetName() .. 'Name']:SetText(reagent.name)
            
            if(reagent.link) then
                local _, reagentItemId = ScootsCraft.extractId(reagent.link)
                if(reagentItemId) then
                    ScootsCraft.frames.reagents[i].itemId = reagentItemId
                end
            else
                ScootsCraft.frames.reagents[i].itemId = nil
            end
            
            if(reagent.required <= reagent.owned) then
                SetItemButtonTextureVertexColor(ScootsCraft.frames.reagents[i], 1, 1, 1)
                _G[ScootsCraft.frames.reagents[i]:GetName() .. 'Name']:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
            else
                SetItemButtonTextureVertexColor(ScootsCraft.frames.reagents[i], 0.5, 0.5, 0.5)
                _G[ScootsCraft.frames.reagents[i]:GetName() .. 'Name']:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
            end
            
            local reagentOwnedText = reagent.owned
            if(reagent.owned > 99) then
                reagentOwnedText = '*'
            end
            _G[ScootsCraft.frames.reagents[i]:GetName() .. 'Count']:SetText(reagentOwnedText .. ' /' .. reagent.required)
        else
            ScootsCraft.frames.reagents[i]:Hide()
        end
    end
    
    ScootsCraft.frames.craftItem:SetHeight(height)
    ScootsCraft.frames.craftItemHolder:SetHeight(height + 10)
    
    ScootsCraft.frames.createButton:SetText(craft.verb or 'Create')
    
    ScootsCraft.frames.createButton:Disable()
    ScootsCraft.frames.quantity:Hide()
    ScootsCraft.frames.increment:Hide()
    ScootsCraft.frames.decrement:Hide()
    ScootsCraft.frames.createAllButton:Hide()
    
    if(craft.number > 0) then
        ScootsCraft.frames.createButton:Enable()
        ScootsCraft.frames.quantity:SetText('1')
        
        if(not craft.verb) then
            ScootsCraft.frames.quantity:Show()
            ScootsCraft.frames.increment:Show()
            ScootsCraft.frames.decrement:Show()
            ScootsCraft.frames.createAllButton:Show()
            
            if(craft.number == 1) then
                ScootsCraft.frames.increment:Disable()
            else
                ScootsCraft.frames.increment:Enable()
            end
        end
    end
end

ScootsCraft.jumpToItemId = function(itemId)
    if(not ScootsCraft.cachedReagentCrafts[ScootsCraft.activeProfession]) then
        ScootsCraft.cachedReagentCrafts[ScootsCraft.activeProfession] = {}
    end
    
    if(ScootsCraft.cachedReagentCrafts[itemId] ~= nil) then
        if(ScootsCraft.cachedReagentCrafts[itemId] ~= false) then
            ScootsCraft.selectRecipe(ScootsCraft.cachedReagentCrafts[ScootsCraft.activeProfession][itemId])
            ScootsCraft.updateDisplayedRecipes()
        end
        
        return nil
    end
    
    for _, crafts in pairs(ScootsCraft.cachedCrafts) do
        for _, craft in pairs(crafts) do
            if(craft.crafttype == 'item' and craft.id == itemId) then
                ScootsCraft.cachedReagentCrafts[ScootsCraft.activeProfession][itemId] = craft
                ScootsCraft.selectRecipe(craft)
                ScootsCraft.updateDisplayedRecipes()
                return nil
            end
        end
    end
    
    ScootsCraft.cachedReagentCrafts[ScootsCraft.activeProfession][itemId] = false
end

ScootsCraft.setFilter = function(key, value)
    if(type(value) == 'string' and value == '') then
        value = nil
    end
    
    ScootsCraft.filters[ScootsCraft.activeProfession][key] = value
    ScootsCraft.filterCrafts()
    ScootsCraft.updateDisplayedRecipes()
end

ScootsCraft.toggleOptions = function()
    if(not ScootsCraft.frames.options) then
        ScootsCraft.buildUiOptions()
        ScootsCraft.frames.options:Hide()
    end
    
    if(ScootsCraft.frames.options:IsVisible()) then
        ScootsCraft.frames.options:Hide()
        ScootsCraft.frames.optionsButton:SetText('Options')
    else
        ScootsCraft.frames.options:Show()
        ScootsCraft.frames.optionsButton:SetText('Close')
        ScootsCraft.setFrameLevels()
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

StaticPopupDialogs['SCOOTSCRAFT_RELOAD'] = {
    ['text'] = 'This action requires reloading the UI to take effect. Reload now?',
    ['button1'] = 'Yes',
    ['button2'] = 'No',
    ['OnAccept'] = ReloadUI,
    ['timeout'] = 0,
    ['whileDead'] = true,
    ['hideOnEscape'] = true
}

SLASH_SCOOTSCRAFT1 = '/scootscraft'
SlashCmdList['SCOOTSCRAFT'] = function(...)
    local arg1 = select(1, ...)
    if(arg1 and string.lower(arg1) == 'toggle') then
        ScootsCraft.setOption('active', not ScootsCraft.options.active)
        StaticPopup_Show('SCOOTSCRAFT_RELOAD')
    else
        print('\124cff' .. '98fb98' .. ScootsCraft.title .. '\124r' .. ' usage:')
        print('\124cff' .. '98fb98' .. '/scootscraft toggle' .. '\124r' .. ' - Activates or deactivates' .. ScootsCraft.title .. '.')
    end
end

ScootsCraft.eventHandler = function(self, event, arg1)
    if(event == 'ADDON_LOADED' and arg1 == 'ScootsCraft') then
        ScootsCraft.onLoad()
    elseif(event == 'PLAYER_LOGOUT') then
        ScootsCraft.onLogout()
    elseif(event == 'PLAYER_LEAVING_WORLD') then
        ScootsCraft.closeCraftPanel()
    elseif(event == 'TRADE_SKILL_SHOW') then
        if(ScootsCraft.lockedActive) then
            ScootsCraft.openCraftPanel()
        else
            ScootsCraft.addEnableButton()
        end
    elseif(event == 'TRADE_SKILL_UPDATE') then
        if(ScootsCraft.lockedActive) then
            ScootsCraft.renderProfession()
        end
    elseif(event == 'TRADE_SKILL_CLOSE') then
        if(ScootsCraft.lockedActive) then
            ScootsCraft.closeCraftPanel()
        end
    end
end

ScootsCraft.frames.events:SetScript('OnEvent', ScootsCraft.eventHandler)

ScootsCraft.frames.events:RegisterEvent('ADDON_LOADED')
ScootsCraft.frames.events:RegisterEvent('PLAYER_LOGOUT')
ScootsCraft.frames.events:RegisterEvent('TRADE_SKILL_SHOW')
ScootsCraft.frames.events:RegisterEvent('TRADE_SKILL_UPDATE')
ScootsCraft.frames.events:RegisterEvent('TRADE_SKILL_CLOSE')
ScootsCraft.frames.events:RegisterEvent('PLAYER_LEAVING_WORLD')