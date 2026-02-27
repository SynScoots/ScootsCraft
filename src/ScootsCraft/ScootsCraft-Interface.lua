ScootsCraft.interface = {}

ScootsCraft.interface.toggle = function()
    if(ScootsCraft.frames.master == nil and ScootsCraft.preBuildChecks()) then
        ScootsCraft.interface.build()
    end
    
    if(ScootsCraft.frames.master) then
        if(ScootsCraft.frames.master:IsVisible()) then
            HideUIPanel(ScootsCraft.frames.master)
        else
            ShowUIPanel(ScootsCraft.frames.master)
        end
    end
end

ScootsCraft.interface.build = function()
    ScootsCraft.interface.buildMainWindow()
    local skillIndex = ScootsCraft.interface.buildProfessionSwatch()
    ScootsCraft.interface.buildFilterWindow()
    ScootsCraft.interface.buildRecipeList()
    ScootsCraft.interface.buildDetailsPane()
    ScootsCraft.interface.buildSummaryPane()
    ScootsCraft.interface.buildFooterLeft()
    ScootsCraft.interface.buildFooterRight()
    
    ScootsCraft.setActiveSkill(skillIndex)
    
    ScootsCraft.frames.events:RegisterEvent('BAG_UPDATE')
end

ScootsCraft.interface.buildMainWindow = function()
    ScootsCraft.frames.master = CreateFrame('Frame', 'ScootsCraft-MasterFrame', UIParent)
    
    UIPanelWindows[ScootsCraft.frames.master:GetName()] = {
        ['area'] = 'left',
        ['pushable'] = 1,
        ['whileDead'] = true,
        ['width'] = 838
    }
    
    ScootsCraft.frames.master:SetToplevel(true)
    ScootsCraft.frames.master:SetMovable(true)
    ScootsCraft.frames.master:EnableMouse(true)
    ScootsCraft.frames.master:SetAttribute('UIPanelLayout-enabled', true)
    ScootsCraft.frames.master:SetAttribute('UIPanelLayout-area', 'left')
    ScootsCraft.frames.master:SetAttribute('UIPanelLayout-pushable', 1)

    ScootsCraft.frames.master:SetSize(UIPanelWindows[ScootsCraft.frames.master:GetName()].width, 438)
    ScootsCraft.frames.master:SetFrameStrata('MEDIUM')
    
    -- Not a mistake: fixes issue with overlapping frames
    ShowUIPanel(ScootsCraft.frames.master)
    HideUIPanel(ScootsCraft.frames.master)
    
    ScootsCraft.frames.master.icon = ScootsCraft.frames.master:CreateTexture(nil, 'OVERLAY')
    ScootsCraft.frames.master.icon:SetPoint('TOPLEFT', 8, -4)
    ScootsCraft.frames.master.icon:SetSize(60, 60)
    
    --
    
    ScootsCraft.frames.front = CreateFrame('Frame', 'ScootsCraft-FrontFrame', ScootsCraft.frames.master)
    ScootsCraft.frames.front:SetPoint('TOPLEFT', ScootsCraft.frames.master, 'TOPLEFT', 0, 0)
    ScootsCraft.frames.front:SetSize(ScootsCraft.frames.master:GetWidth(), ScootsCraft.frames.master:GetHeight())
    
    ScootsCraft.frames.front.background = ScootsCraft.frames.front:CreateTexture()
    ScootsCraft.frames.front.background:SetTexture('Interface\\AddOns\\ScootsCraft\\Textures\\Background')
    ScootsCraft.frames.front.background:SetPoint('TOPLEFT', 0, 0)
    ScootsCraft.frames.front.background:SetSize(1024, 512)
    
    ScootsCraft.frames.master:SetScript('OnMouseDown', function()
        EditBox_ClearFocus(ScootsCraft.frames.searchFilter)
    end)
    
    --
    
    ScootsCraft.frames.title = CreateFrame('Frame', 'ScootsCraft-Title', ScootsCraft.frames.front)
    ScootsCraft.frames.title:SetSize(680, 21)
    ScootsCraft.frames.title:SetPoint('TOPLEFT', ScootsCraft.frames.front, 'TOPLEFT', 68, -11)
    ScootsCraft.frames.title:EnableMouse(true)
    ScootsCraft.frames.title:RegisterForDrag('LeftButton')
    
    ScootsCraft.frames.title.addonName = ScootsCraft.frames.title:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    ScootsCraft.frames.title.addonName:SetPoint('LEFT', 8, 0)
    ScootsCraft.frames.title.addonName:SetJustifyH('LEFT')
    ScootsCraft.frames.title.addonName:SetText(ScootsCraft.title)

    ScootsCraft.frames.title.version = ScootsCraft.frames.title:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
    ScootsCraft.frames.title.version:SetTextColor(0.6, 0.98, 0.6)
    ScootsCraft.frames.title.version:SetPoint('BOTTOMLEFT', ScootsCraft.frames.title.addonName, 'BOTTOMRIGHT', 1, 0)
    ScootsCraft.frames.title.version:SetJustifyH('LEFT')
    ScootsCraft.frames.title.version:SetText(ScootsCraft.version)

    ScootsCraft.frames.title.skillName = ScootsCraft.frames.title:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    ScootsCraft.frames.title.skillName:SetPoint('BOTTOMLEFT', ScootsCraft.frames.title.version, 'BOTTOMRIGHT', 1, 0)
    ScootsCraft.frames.title.skillName:SetJustifyH('LEFT')
    
    ScootsCraft.frames.title:SetScript('OnDragStart', function()
        if(ScootsCraft.options.get('drag-window')) then
            ScootsCraft.frames.master:StartMoving()
        end
    end)
    
    ScootsCraft.frames.title:SetScript('OnDragStop', function()
        ScootsCraft.frames.master:StopMovingOrSizing()
    end)
    
    --
    
    ScootsCraft.frames.optionsButton = CreateFrame('Button', 'ScootsCraft-OptionsButton', ScootsCraft.frames.front, 'UIPanelButtonTemplate')
    ScootsCraft.frames.optionsButton:SetSize(64, 19)
    ScootsCraft.frames.optionsButton:SetPoint('TOPLEFT', ScootsCraft.frames.front, 'TOPLEFT', 749, -12)
    ScootsCraft.frames.optionsButton:SetText('Options')
    
    ScootsCraft.frames.optionsButton:SetScript('OnClick', function()
        ScootsCraft.options.open()
    end)
    
    --
    
    ScootsCraft.frames.closeButton = CreateFrame('Button', 'ScootsCraft-CloseButton', ScootsCraft.frames.front, 'UIPanelCloseButton')
    ScootsCraft.frames.closeButton:SetPoint('TOPLEFT', ScootsCraft.frames.front, 'TOPLEFT', 809, -6)
    ScootsCraft.frames.closeButton:SetScript('OnClick', ScootsCraft.interface.toggle)
end

ScootsCraft.interface.buildFooterLeft = function()
    ScootsCraft.frames.summariseButton = CreateFrame('Button', 'ScootsCraft-SummariseButton', ScootsCraft.frames.front, 'UIPanelButtonTemplate')
    ScootsCraft.frames.summariseButton:SetSize(80, 19)
    ScootsCraft.frames.summariseButton:SetPoint('TOPLEFT', ScootsCraft.frames.front, 'TOPLEFT', 16, -410)
    ScootsCraft.frames.summariseButton:SetText('Summarise')
    
    ScootsCraft.frames.summariseButton:SetScript('OnClick', function()
        ScootsCraft.generateSummary(ScootsCraft.activeSkill)
    end)
    
    ScootsCraft.frames.summariseButton:SetScript('OnEnter', function()
        GameTooltip:SetOwner(ScootsCraft.frames.summariseButton, 'ANCHOR_TOPLEFT')
        GameTooltip:SetText('Summarise profession', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
        GameTooltip:AddLine('Generate a summary of all reagents you need to gather to create one of every item for ' .. ScootsCraft.skills[ScootsCraft.skillIndexMap[ScootsCraft.activeSkill]].displayName .. '.', nil, nil, nil, true)
        GameTooltip:AddLine('Result is influenced by the current value for the filters above.', nil, nil, nil, true)
        GameTooltip:AddLine(' ', nil, nil, nil, true)
        GameTooltip:AddLine('Recipes you have not learned will be excluded from the result.', nil, nil, nil, true)
        
        if(ScootsCraft.options.get('discount-summaries')) then
            GameTooltip:AddLine('Reagents in your resource bank and inventory will reduce the final counts.', nil, nil, nil, true)
        end
        
        
        GameTooltip:AddLine(' ', nil, nil, nil, true)
        GameTooltip:AddLine('Counts will be inflated in cases where a reagent is also a craft returned by the current filter values.', nil, nil, nil, true)
        GameTooltip:Show()
    end)
    
    ScootsCraft.frames.summariseButton:SetScript('OnLeave', GameTooltip_Hide)
    
    --
    
    ScootsCraft.frames.summariseAllButton = CreateFrame('Button', 'ScootsCraft-SummariseButton', ScootsCraft.frames.front, 'UIPanelButtonTemplate')
    ScootsCraft.frames.summariseAllButton:SetSize(26, 19)
    ScootsCraft.frames.summariseAllButton:SetPoint('TOPLEFT', ScootsCraft.frames.summariseButton, 'TOPRIGHT', 2, 0)
    ScootsCraft.frames.summariseAllButton:SetText('All')
    
    ScootsCraft.frames.summariseAllButton:SetScript('OnClick', function()
        ScootsCraft.generateSummary(nil)
    end)
    
    ScootsCraft.frames.summariseAllButton:SetScript('OnEnter', function()
        GameTooltip:SetOwner(ScootsCraft.frames.summariseAllButton, 'ANCHOR_TOPLEFT')
        GameTooltip:SetText('Summarise all professions', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
        GameTooltip:AddLine('Generate a summary of all reagents you need to gather to create one of every item for all learned professions.', nil, nil, nil, true)
        GameTooltip:AddLine('Result is influenced by the current value for the filters above.', nil, nil, nil, true)
        GameTooltip:AddLine(' ', nil, nil, nil, true)
        GameTooltip:AddLine('Recipes you have not learned will be excluded from the result.', nil, nil, nil, true)
        
        if(ScootsCraft.options.get('discount-summaries')) then
            GameTooltip:AddLine('Reagents in your resource bank and inventory will reduce the final counts.', nil, nil, nil, true)
        end
        
        GameTooltip:AddLine(' ', nil, nil, nil, true)
        GameTooltip:AddLine('Counts will be inflated in cases where a reagent is also a craft returned by the current filter values.', nil, nil, nil, true)
        GameTooltip:Show()
    end)
    
    ScootsCraft.frames.summariseAllButton:SetScript('OnLeave', GameTooltip_Hide)
    
    --
    
    ScootsCraft.frames.front.recipeCount = ScootsCraft.frames.front:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
    ScootsCraft.frames.front.recipeCount:SetPoint('TOPRIGHT', ScootsCraft.frames.front, 'TOPLEFT', 170, -392)
    ScootsCraft.frames.front.recipeCount:SetJustifyH('RIGHT')
    
    --

    ScootsCraft.frames.toggleAllSections = CreateFrame('Button', 'ScootsCraft-ToggleAllSections', ScootsCraft.frames.front)
    ScootsCraft.frames.toggleAllSections:SetSize(16, 16)
    ScootsCraft.frames.toggleAllSections:SetPoint('TOPLEFT', ScootsCraft.frames.front, 'TOPLEFT', 179, -412)
    ScootsCraft.frames.toggleAllSections:SetHitRectInsets(-3, -20, 0, 0)
    ScootsCraft.frames.toggleAllSections:SetHighlightTexture('Interface\\Buttons\\UI-PlusButton-Hilight', 'ADD')
    ScootsCraft.frames.toggleAllSections:SetNormalTexture('Interface\\Buttons\\UI-MinusButton-Up')
    ScootsCraft.frames.toggleAllSections:SetPushedTexture('Interface\\Buttons\\UI-MinusButton-Down')

    ScootsCraft.frames.toggleAllSections:SetScript('OnClick', ScootsCraft.toggleAllSections)
    
    ScootsCraft.frames.toggleAllSections.label = ScootsCraft.frames.toggleAllSections:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    ScootsCraft.frames.toggleAllSections.label:SetPoint('LEFT', ScootsCraft.frames.toggleAllSections, 'RIGHT', 3, 0)
    ScootsCraft.frames.toggleAllSections.label:SetJustifyH('LEFT')
    ScootsCraft.frames.toggleAllSections.label:SetText('All')
end

ScootsCraft.interface.buildFooterRight = function()
    ScootsCraft.frames.createButton = CreateFrame('Button', 'ScootsCraft-CreateButton', ScootsCraft.frames.front, 'UIPanelButtonTemplate')
    ScootsCraft.frames.createButton:SetSize(80, 19)
    ScootsCraft.frames.createButton:SetPoint('TOPLEFT', ScootsCraft.frames.front, 'TOPLEFT', 750, -410)
    ScootsCraft.frames.createButton:SetText('Create')
    ScootsCraft.frames.createButton:Disable()
    
    ScootsCraft.frames.createButton:SetScript('OnClick', ScootsCraft.craftItem)
    
    --
    
    ScootsCraft.frames.increment = CreateFrame('Button', 'ScootsCraft-Quantity-IncrementButton', ScootsCraft.frames.front)
    ScootsCraft.frames.increment:SetSize(19, 19)
    ScootsCraft.frames.increment:SetPoint('TOPRIGHT', ScootsCraft.frames.createButton, 'TOPLEFT', -1, 0)
    ScootsCraft.frames.increment:Hide()
    
    ScootsCraft.frames.increment:SetNormalTexture('Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up')
    ScootsCraft.frames.increment:SetPushedTexture('Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down')
    ScootsCraft.frames.increment:SetDisabledTexture('Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled')
    ScootsCraft.frames.increment:SetHighlightTexture('Interface\\Buttons\\UI-Common-MouseHilight', 'ADD')
    
    ScootsCraft.frames.increment:SetScript('OnClick', function()
        local check = ScootsCraft.frames.quantity:GetNumber()
        local maxQty = 200
        
        if(check < maxQty) then
            ScootsCraft.frames.quantity:SetNumber(check + 1)
        end
    end)
    
    --
    
    ScootsCraft.frames.quantity = CreateFrame('EditBox', 'ScootsCraft-Quantity', ScootsCraft.frames.front)
    ScootsCraft.frames.quantity:SetSize(30, 19)
    ScootsCraft.frames.quantity:SetPoint('TOPRIGHT', ScootsCraft.frames.increment, 'TOPLEFT', 0, 0)
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
        local maxQty = 200
        
        if(check < 1) then
            ScootsCraft.frames.quantity:SetNumber(1)
        elseif(check > maxQty) then
            ScootsCraft.frames.quantity:SetNumber(maxQty)
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
    
    --
    
    ScootsCraft.frames.decrement = CreateFrame('Button', 'ScootsCraft-Quantity-DecrementButton', ScootsCraft.frames.front)
    ScootsCraft.frames.decrement:SetSize(19, 19)
    ScootsCraft.frames.decrement:SetPoint('TOPRIGHT', ScootsCraft.frames.quantity, 'TOPLEFT', 0, 0)
    ScootsCraft.frames.decrement:Hide()
    
    ScootsCraft.frames.decrement:SetNormalTexture('Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up')
    ScootsCraft.frames.decrement:SetPushedTexture('Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down')
    ScootsCraft.frames.decrement:SetDisabledTexture('Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled')
    ScootsCraft.frames.decrement:SetHighlightTexture('Interface\\Buttons\\UI-Common-MouseHilight', 'ADD')
    
    ScootsCraft.frames.decrement:SetScript('OnClick', function()
        local check = ScootsCraft.frames.quantity:GetNumber()
        
        if(check > 1) then
            ScootsCraft.frames.quantity:SetNumber(check - 1)
        end
    end)
    
    --
    
    ScootsCraft.frames.createAllButton = CreateFrame('Button', 'ScootsCraft-CreateButton', ScootsCraft.frames.front, 'UIPanelButtonTemplate')
    ScootsCraft.frames.createAllButton:SetSize(80, 19)
    ScootsCraft.frames.createAllButton:SetPoint('TOPRIGHT', ScootsCraft.frames.decrement, 'TOPLEFT', -1, 0)
    ScootsCraft.frames.createAllButton:SetText('Create all')
    ScootsCraft.frames.createAllButton:Hide()
    
    ScootsCraft.frames.createAllButton:SetScript('OnClick', function()
        ScootsCraft.frames.quantity:SetNumber(math.min(200, (select(5, Custom_GetProfessionRecipeInfo(ScootsCraft.visibleSpellId)))))
        ScootsCraft.craftItem()
    end)
    
    --
    
    ScootsCraft.frames.front.forgeHelper = {}
    
    local map = {
        {
            ['name'] = 'Lightforged',
            ['value'] = 3,
        },
        {
            ['name'] = 'Warforged',
            ['value'] = 2,
        },
        {
            ['name'] = 'Titanforged',
            ['value'] = 1,
        },
    }
    
    local prev = nil
    
    for _, field in ipairs(map) do
        local checkbox = CreateFrame('CheckButton', 'ScootsCraft-ForgeHelper-' .. field.name, ScootsCraft.frames.front, 'UICheckButtonTemplate')
        checkbox:SetSize(22, 22)
        
        _G[checkbox:GetName() .. 'Text']:SetText(field.name)
        _G[checkbox:GetName() .. 'Text']:ClearAllPoints()
        _G[checkbox:GetName() .. 'Text']:SetPoint('TOPLEFT', checkbox, 'TOPRIGHT', -2, -5)
        
        checkbox:SetHitRectInsets(0, 0 - _G[checkbox:GetName() .. 'Text']:GetWidth(), 0, 0)
        
        if(prev == nil) then
            checkbox:SetPoint('RIGHT', ScootsCraft.frames.createAllButton, 'LEFT', 0 - (10 + _G[checkbox:GetName() .. 'Text']:GetWidth()), -1)
        else
            checkbox:SetPoint('RIGHT', prev, 'LEFT', 0 - _G[checkbox:GetName() .. 'Text']:GetWidth(), 0)
        end
        
        checkbox:SetScript('OnClick', function()
            if(checkbox:GetChecked() == 1) then
                for name, check in pairs(ScootsCraft.frames.front.forgeHelper) do
                    if(name ~= field.name) then
                        check:SetChecked(false)
                    end
                end
                
                ScootsCraft.forgeHelper = field.value
            else
                ScootsCraft.forgeHelper = nil
            end
        end)
        
        checkbox:SetScript('OnEnter', function()
            GameTooltip:SetOwner(checkbox, 'ANCHOR_TOPLEFT')
            GameTooltip:SetText('Forge-helper: ' .. field.name, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
            GameTooltip:AddLine('With this field checked, automatically destroy crafted items below ' .. field.name .. ' variants. Additionally, the quantity field will no longer reset after crafting.', nil, nil, nil, true)
            GameTooltip:AddLine(' ')
            GameTooltip:AddLine('If a merchant window is open, failed attempts will be vendored instead of destroyed.', nil, nil, nil, true)
            GameTooltip:Show()
        end)
        
        checkbox:SetScript('OnLeave', GameTooltip_Hide)
        
        checkbox:Hide()
        
        ScootsCraft.frames.front.forgeHelper[field.name] = checkbox
        prev = checkbox
    end
    
    ScootsCraft.frames.front.forgeHelperTitle = ScootsCraft.frames.front:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
    ScootsCraft.frames.front.forgeHelperTitle:SetPoint('RIGHT', prev, 'LEFT', 0, 1)
    ScootsCraft.frames.front.forgeHelperTitle:SetJustifyH('RIGHT')
    ScootsCraft.frames.front.forgeHelperTitle:SetText('Forge-helper: ')
    ScootsCraft.frames.front.forgeHelperTitle:Hide()
end

ScootsCraft.interface.buildProfessionSwatch = function()
    local skillIdMap = ScootsCraft.data.getProfessionMap()

    ScootsCraft.frames.skillButtons = ScootsCraft.frames.skillButtons or {}
    local prior = nil
    
    for skillIndex = #skillIdMap, 1, -1 do
        local skill = skillIdMap[skillIndex]
        
        if(ScootsCraft.skills[skillIndex].spellId ~= nil) then
            local button
            
            if(ScootsCraft.frames.skillButtons[ScootsCraft.skills[skillIndex].name] ~= nil) then
                button = ScootsCraft.frames.skillButtons[ScootsCraft.skills[skillIndex].name]
            else
                button = CreateFrame('Button', 'ScootsCraft-Skillbutton-' .. ScootsCraft.skills[skillIndex].name, ScootsCraft.frames.front, 'ActionButtonTemplate')
                button:SetSize(30, 30)
                
                _G[button:GetName() .. 'Icon']:SetTexture(ScootsCraft.skills[skillIndex].icon)
                _G[button:GetName() .. 'NormalTexture']:SetAlpha(0)
                
                button.activeGlow = button:CreateTexture(nil, 'OVERLAY')
                button.activeGlow:SetTexture('Interface\\Buttons\\UI-ActionButton-Border')
                button.activeGlow:SetBlendMode('ADD')
                button.activeGlow:SetAlpha(0)
                button.activeGlow:SetSize(52, 52)
                button.activeGlow:SetPoint('CENTER', 0, 0)
                
                button:HookScript('OnEnter', function()
                    GameTooltip_SetDefaultAnchor(GameTooltip, button)
                    GameTooltip:SetSpellByID(ScootsCraft.skills[skillIndex].spellId)
                    GameTooltip:Show()
                    
                    if(ScootsCraft.activeSkill ~= ScootsCraft.skills[skillIndex].skillId) then
                        button.activeGlow:SetVertexColor(0.3, 0.3, 0.8)
                        button.activeGlow:SetAlpha(1)
                    end
                end)
                
                button:HookScript('OnLeave', function()
                    GameTooltip:Hide()
                
                    if(ScootsCraft.activeSkill ~= ScootsCraft.skills[skillIndex].skillId) then
                        button.activeGlow:SetAlpha(0)
                    end
                end)
                
                button:SetScript('OnClick', function()
                    ScootsCraft.setActiveSkill(skillIndex)
                end)
            end
            
            if(prior == nil) then
                button:SetPoint('TOPRIGHT', ScootsCraft.frames.front, 'TOPLEFT', 830, -36)
            else
                button:SetPoint('TOPRIGHT', prior, 'TOPLEFT', -2, 0)
            end
            
            prior = button
            ScootsCraft.frames.skillButtons[ScootsCraft.skills[skillIndex].name] = button
        end
    end
    
    if(ScootsCraft.activeSkill ~= nil) then
        for skillIndex, _ in pairs(ScootsCraft.skills) do
            if(ScootsCraft.skills[skillIndex].skillId == ScootsCraft.activeSkill) then
                if(ScootsCraft.frames.skillButtons[ScootsCraft.skills[skillIndex].name] ~= nil) then
                    return skillIndex
                end
                
                break
            end
        end
    end
    
    for skillIndex, _ in pairs(ScootsCraft.skills) do
        if(ScootsCraft.frames.skillButtons[ScootsCraft.skills[skillIndex].name] ~= nil) then
            ScootsCraft.activeSkill = ScootsCraft.skills[skillIndex].skillId
            return skillIndex
        end
    end
end

ScootsCraft.interface.buildRecipeList = function()
    ScootsCraft.frames.recipeFrame = CreateFrame('ScrollFrame', 'ScootsCraft-RecipeFrame', ScootsCraft.frames.front, 'FauxScrollFrameTemplate')
    ScootsCraft.frames.recipeFrame:SetSize(301, 334)
    ScootsCraft.frames.recipeFrame:SetPoint('TOPLEFT', ScootsCraft.frames.front, 'TOPLEFT', 176, -72)
    
    ScootsCraft.recipesVisible = 20
    ScootsCraft.recipeLineHeight = ScootsCraft.frames.recipeFrame:GetHeight() / ScootsCraft.recipesVisible
    
    ScootsCraft.frames.recipeFrame:SetScript('OnVerticalScroll', function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, ScootsCraft.recipeLineHeight, ScootsCraft.renderRecipeList)
    end)
    
    ScootsCraft.frames.recipes = {}
    for recipeIndex = 1, ScootsCraft.recipesVisible do
        local recipeLine = CreateFrame('Button', 'ScootsCraft-RecipeFrameLine-' .. tostring(recipeIndex), ScootsCraft.frames.recipeFrame)
        recipeLine:SetSize(ScootsCraft.frames.recipeFrame:GetWidth(), ScootsCraft.recipeLineHeight)
        recipeLine:SetPoint('TOPLEFT', ScootsCraft.frames.recipeFrame, 'TOPLEFT', 0, 0 - (ScootsCraft.recipeLineHeight * (recipeIndex - 1)))
        recipeLine:EnableMouse(true)
        recipeLine.isSectionHead = false
        
        recipeLine.underline = recipeLine:CreateTexture()
        recipeLine.underline:SetSize(recipeLine:GetWidth() - 20, 1)
        recipeLine.underline:SetPoint('BOTTOMLEFT', 20, 0)
        recipeLine.underline:SetTexture(1, 1, 0.5, 0.4)
        recipeLine.underline:SetAlpha(0)
        
        recipeLine.highlight = recipeLine:CreateTexture(nil, 'ARTWORK')
        recipeLine.highlight:SetAllPoints()
        recipeLine.highlight:SetTexture(0.25, 0.5, 1, 0.4)
        recipeLine.highlight:SetAlpha(0)
        
        recipeLine.icon = recipeLine:CreateTexture(nil, 'OVERLAY')
        recipeLine.icon:SetSize(ScootsCraft.recipeLineHeight, ScootsCraft.recipeLineHeight)
        recipeLine.icon:SetPoint('TOPLEFT', 2, 1)
        recipeLine.icon:SetAlpha(0)
    
        recipeLine.text = recipeLine:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        recipeLine.text:SetPoint('LEFT', 20, 0)
        recipeLine.text:SetJustifyH('LEFT')
        
        recipeLine.selected = recipeLine:CreateTexture(nil, 'BACKGROUND')
        recipeLine.selected:SetAllPoints()
        recipeLine.selected:SetTexture('Interface\\Buttons\\UI-Listbox-Highlight2')
        recipeLine.selected:SetAlpha(0)
        
        recipeLine.bounty = recipeLine:CreateTexture(nil, 'OVERLAY')
        recipeLine.bounty:SetSize(ScootsCraft.recipeLineHeight - 2, ScootsCraft.recipeLineHeight - 2)
        recipeLine.bounty:SetTexture('Interface\\MoneyFrame\\UI-GoldIcon')
        recipeLine.bounty:SetPoint('TOPRIGHT', 0, -1)
        recipeLine.bounty:SetAlpha(0)
        
        recipeLine:SetScript('OnEnter', function()
            if(recipeLine.isSectionHead ~= true) then
                recipeLine.highlight:SetAlpha(1)
            end
            
            if(recipeLine.isSectionHead ~= true) then
                if(ScootsCraft.options.get('recipe-list-tooltip') == 'item') then
                    GameTooltip:SetOwner(recipeLine, 'ANCHOR_RIGHT')
                    
                    local itemId = select(3, Custom_GetProfessionRecipeInfo(recipeLine.recipe.spellId))
                    local itemLink
                    
                    if((itemId or 0) ~= 0) then
                        itemLink = ScootsCraft.getItemLink(itemId)
                    else
                        itemLink = ScootsCraft.getCraftingLink(recipeLine.recipe.spellId)
                    end
                    
                    GameTooltip:SetHyperlink(itemLink)
                    
                    GameTooltip:Show()
                elseif(ScootsCraft.options.get('recipe-list-tooltip') == 'recipe') then
                    GameTooltip:SetOwner(recipeLine, 'ANCHOR_RIGHT')
                    GameTooltip:SetHyperlink(ScootsCraft.getCraftingLink(recipeLine.recipe.spellId))
                    GameTooltip:Show()
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
                    HandleModifiedItemClick(ScootsCraft.getCraftingLink(recipeLine.recipe.spellId))
                else
                    ScootsCraft.selectRecipe(recipeLine.recipe.spellId)
                end
            end
        end)
        
        recipeLine.sectionToggle = CreateFrame('Button', 'ScootsCraft-SectionToggleButton-' .. tostring(recipeIndex), recipeLine)
        recipeLine.sectionToggle:SetSize(16, 16)
        recipeLine.sectionToggle:SetPoint('LEFT', recipeLine, 'LEFT', 3, 0)
        recipeLine.sectionToggle:SetHitRectInsets(-3, recipeLine.sectionToggle:GetWidth() - recipeLine:GetWidth(), 0, 0)
        recipeLine.sectionToggle:SetHighlightTexture('Interface\\Buttons\\UI-PlusButton-Hilight', 'ADD')
        recipeLine.sectionToggle:Hide()
        
        recipeLine.sectionToggle:SetScript('OnClick', function()
            ScootsCraft.toggleSection(recipeLine.section)
        end)
        
        ScootsCraft.frames.recipes[recipeIndex] = recipeLine
    end
end

ScootsCraft.interface.buildDetailsPane = function()
    -- Craft frame
    ScootsCraft.frames.craftItemScroller = CreateFrame('ScrollFrame', 'ScootsCraft-CraftItemScroller', ScootsCraft.frames.front, 'UIPanelScrollFrameTemplate')
    ScootsCraft.frames.craftItemScroller:SetSize(301, 334)
    ScootsCraft.frames.craftItemScroller:SetPoint('TOPLEFT', ScootsCraft.frames.front, 'TOPLEFT', 505, -72)
    
    ScootsCraft.frames.craftItemHolder = CreateFrame('Frame', 'ScootsCraft-CraftItemHolder', ScootsCraft.frames.craftItemScroller)
    ScootsCraft.frames.craftItemHolder:SetWidth(ScootsCraft.frames.craftItemScroller:GetWidth())
    ScootsCraft.frames.craftItemHolder:SetPoint('TOPLEFT', ScootsCraft.frames.craftItemScroller, 'TOPLEFT', 0, 0)
    
    ScootsCraft.frames.craftItemScroller:SetScrollChild(ScootsCraft.frames.craftItemHolder)
    
    ScootsCraft.frames.craftItem = CreateFrame('Frame', 'ScootsCraft-CraftItem', ScootsCraft.frames.craftItemHolder)
    ScootsCraft.frames.craftItem:SetSize(ScootsCraft.frames.craftItemHolder:GetWidth() - 6, ScootsCraft.frames.craftItemHolder:GetHeight() - 10)
    ScootsCraft.frames.craftItem:SetPoint('TOPLEFT', ScootsCraft.frames.craftItemHolder, 'TOPLEFT', 3, -5)
    ScootsCraft.frames.craftItem:Hide()
    
    -- Craft frame contents: Top text
    ScootsCraft.frames.craftItem.canCraftText = ScootsCraft.frames.craftItem:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
    ScootsCraft.frames.craftItem.canCraftText:SetPoint('TOPLEFT', ScootsCraft.frames.craftItem, 'TOPLEFT', 0, 0)
    ScootsCraft.frames.craftItem.canCraftText:SetJustifyH('LEFT')
    
    ScootsCraft.frames.craftItem.spellIdText = ScootsCraft.frames.craftItem:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
    ScootsCraft.frames.craftItem.spellIdText:SetPoint('TOPRIGHT', ScootsCraft.frames.craftItem, 'TOPLEFT', 294, 0)
    ScootsCraft.frames.craftItem.spellIdText:SetJustifyH('RIGHT')
    
    -- Craft frame contents: Icon
    ScootsCraft.frames.craftIcon = CreateFrame('Button', 'ScootsCraft-CraftIcon', ScootsCraft.frames.craftItem)
    ScootsCraft.frames.craftIcon:SetSize(37, 37)
    ScootsCraft.frames.craftIcon:SetPoint('TOPLEFT', ScootsCraft.frames.craftItem.canCraftText, 'BOTTOMLEFT', 0, -4)
    
    ScootsCraft.frames.craftIcon.text = ScootsCraft.frames.craftIcon:CreateFontString(nil, 'ARTWORK', 'NumberFontNormal')
    ScootsCraft.frames.craftIcon.text:SetPoint('BOTTOMRIGHT', -5, 2)
    ScootsCraft.frames.craftIcon.text:SetJustifyH('RIGHT')
    ScootsCraft.frames.craftIcon.hasItem = 1
    
    ScootsCraft.frames.craftIcon:SetScript('OnClick', function()
        local createdItemId = select(3, Custom_GetProfessionRecipeInfo(ScootsCraft.frames.craftIcon.spellId))
        
        if((createdItemId or 0) ~= 0) then
            HandleModifiedItemClick(ScootsCraft.getItemLink(createdItemId))
        else
            HandleModifiedItemClick(ScootsCraft.getCraftingLink(ScootsCraft.frames.craftIcon.spellId))
        end
    end)
    
    ScootsCraft.frames.craftIcon:SetScript('OnEnter', function()
        local createdItemId = select(3, Custom_GetProfessionRecipeInfo(ScootsCraft.frames.craftIcon.spellId))
        
        GameTooltip:SetOwner(ScootsCraft.frames.craftIcon, 'ANCHOR_RIGHT')
        
        if((createdItemId or 0) ~= 0) then
            GameTooltip:SetHyperlink(ScootsCraft.getItemLink(createdItemId))
        else
            GameTooltip:SetHyperlink(ScootsCraft.getCraftingLink(ScootsCraft.frames.craftIcon.spellId))
        end
    
        GameTooltip:Show()
        CursorUpdate(ScootsCraft.frames.craftIcon)
    end)
    
    ScootsCraft.frames.craftIcon:SetScript('OnLeave', GameTooltip_HideResetCursor)
    
    -- Craft frame contents: Name
    ScootsCraft.frames.craftItem.name = ScootsCraft.frames.craftItem:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    ScootsCraft.frames.craftItem.name:SetWidth(ScootsCraft.frames.craftItem:GetWidth() - (ScootsCraft.frames.craftIcon:GetWidth() + 10))
    ScootsCraft.frames.craftItem.name:SetPoint('TOPLEFT', ScootsCraft.frames.craftIcon, 'TOPRIGHT', 10, 0)
    ScootsCraft.frames.craftItem.name:SetJustifyH('LEFT')
    
    -- Craft frame contents: Requirements
    ScootsCraft.frames.craftItem.requiresLabel = ScootsCraft.frames.craftItem:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
    ScootsCraft.frames.craftItem.requiresLabel:SetPoint('TOPLEFT', ScootsCraft.frames.craftItem.name, 'BOTTOMLEFT', 0, 0)
    ScootsCraft.frames.craftItem.requiresLabel:SetJustifyH('LEFT')
    
    ScootsCraft.frames.craftItem.requires = ScootsCraft.frames.craftItem:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
    ScootsCraft.frames.craftItem.requires:SetWidth(ScootsCraft.frames.craftItem:GetWidth() - (ScootsCraft.frames.craftIcon:GetWidth() + 10 + ScootsCraft.frames.craftItem.requiresLabel:GetWidth() + 4))
    ScootsCraft.frames.craftItem.requires:SetPoint('TOPLEFT', ScootsCraft.frames.craftItem.requiresLabel, 'TOPRIGHT', 4, 0)
    ScootsCraft.frames.craftItem.requires:SetJustifyH('LEFT')
    
    -- Craft frame contents: Cooldown
    ScootsCraft.frames.craftItem.cooldown = ScootsCraft.frames.craftItem:CreateFontString(nil, 'ARTWORK', 'GameFontRedSmall')
    ScootsCraft.frames.craftItem.cooldown:SetPoint('TOPLEFT', ScootsCraft.frames.craftItem.requiresLabel, 'BOTTOMLEFT', 0, 0)
    ScootsCraft.frames.craftItem.cooldown:SetJustifyH('LEFT')
    
    -- Craft frame contents: Description
    ScootsCraft.frames.craftItem.description = ScootsCraft.frames.craftItem:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
    ScootsCraft.frames.craftItem.description:SetWidth(ScootsCraft.frames.craftItem:GetWidth())
    ScootsCraft.frames.craftItem.description:SetJustifyH('LEFT')
    
    -- Craft frame contents: Reagents
    ScootsCraft.frames.craftItem.reagentsLabel = ScootsCraft.frames.craftItem:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
    ScootsCraft.frames.craftItem.reagentsLabel:SetPoint('TOPLEFT', ScootsCraft.frames.craftItem.description, 'BOTTOMLEFT', 0, -10)
    ScootsCraft.frames.craftItem.reagentsLabel:SetJustifyH('LEFT')
    ScootsCraft.frames.craftItem.reagentsLabel:SetText('Reagents:')
    
    ScootsCraft.frames.reagents = {}
    for reagentIndex = 1, 8 do
        ScootsCraft.frames.reagents[reagentIndex] = CreateFrame('Button', 'ScootsCraft-CraftItem-Reagent-' .. tostring(reagentIndex), ScootsCraft.frames.craftItem, 'TradeSkillItemTemplate')
        
        if(reagentIndex == 1) then
            ScootsCraft.frames.reagents[reagentIndex]:SetPoint('TOPLEFT', ScootsCraft.frames.craftItem.reagentsLabel, 'BOTTOMLEFT', 0, -3)
        elseif(reagentIndex % 2 == 0) then
            ScootsCraft.frames.reagents[reagentIndex]:SetPoint('TOPLEFT', ScootsCraft.frames.reagents[reagentIndex - 1], 'TOPRIGHT', 0, 0)
        else
            ScootsCraft.frames.reagents[reagentIndex]:SetPoint('TOPRIGHT', ScootsCraft.frames.reagents[reagentIndex - 1], 'BOTTOMLEFT', 0, -2)
        end
        
        ScootsCraft.frames.reagents[reagentIndex]:SetScript('OnEnter', function()
            GameTooltip:SetOwner(ScootsCraft.frames.reagents[reagentIndex], 'ANCHOR_TOPLEFT')
            GameTooltip:SetHyperlink(ScootsCraft.getItemLink(ScootsCraft.frames.reagents[reagentIndex].itemId))
            GameTooltip:Show()
            CursorUpdate(ScootsCraft.frames.reagents[reagentIndex])
        end)
        
        ScootsCraft.frames.reagents[reagentIndex]:SetScript('OnLeave', function()
            GameTooltip:Hide()
            ResetCursor()
        end)
        
        ScootsCraft.frames.reagents[reagentIndex]:SetScript('OnClick', function()
            HandleModifiedItemClick(ScootsCraft.getItemLink(ScootsCraft.frames.reagents[reagentIndex].itemId))
            
            if(ScootsCraft.frames.reagents[reagentIndex].itemId and not IsControlKeyDown() and not IsAltKeyDown() and not IsShiftKeyDown()) then
                ScootsCraft.handleReagentJump(ScootsCraft.frames.reagents[reagentIndex].itemId)
            end
        end)
    end
end

ScootsCraft.interface.buildSummaryPane = function()
    ScootsCraft.frames.summaryFrame = CreateFrame('ScrollFrame', 'ScootsCraft-SummaryFrame', ScootsCraft.frames.front, 'FauxScrollFrameTemplate')
    ScootsCraft.frames.summaryFrame:SetSize(301, 334)
    ScootsCraft.frames.summaryFrame:SetPoint('TOPLEFT', ScootsCraft.frames.front, 'TOPLEFT', 505, -72)
    ScootsCraft.frames.summaryFrame:Hide()
    
    ScootsCraft.frames.summaryFrame.leftHeader = ScootsCraft.frames.summaryFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    ScootsCraft.frames.summaryFrame.leftHeader:SetPoint('TOPLEFT', 20, -3)
    ScootsCraft.frames.summaryFrame.leftHeader:SetJustifyH('LEFT')
    ScootsCraft.frames.summaryFrame.leftHeader:SetText('Reagent')
    
    ScootsCraft.frames.summaryFrame.rightHeader = ScootsCraft.frames.summaryFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    ScootsCraft.frames.summaryFrame.rightHeader:SetPoint('TOPRIGHT', -2, -3)
    ScootsCraft.frames.summaryFrame.rightHeader:SetJustifyH('RIGHT')
    ScootsCraft.frames.summaryFrame.rightHeader:SetText('Quantity')
    
    ScootsCraft.summaryLinesVisible = 19
    ScootsCraft.summaryLineHeight = ScootsCraft.frames.summaryFrame:GetHeight() / (ScootsCraft.summaryLinesVisible + 1)
    
    ScootsCraft.frames.summaryFrame:SetScript('OnVerticalScroll', function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, ScootsCraft.summaryLineHeight, ScootsCraft.renderSummary)
    end)
    
    ScootsCraft.frames.summaryLines = {}
    for summaryLineIndex = 1, ScootsCraft.summaryLinesVisible do
        local summaryLine = CreateFrame('Button', 'ScootsCraft-SummaryFrameLine-' .. tostring(summaryLineIndex), ScootsCraft.frames.summaryFrame)
        summaryLine:SetSize(ScootsCraft.frames.summaryFrame:GetWidth(), ScootsCraft.summaryLineHeight)
        summaryLine:SetPoint('TOPLEFT', ScootsCraft.frames.summaryFrame, 'TOPLEFT', 0, 0 - (ScootsCraft.summaryLineHeight * summaryLineIndex))
        summaryLine:EnableMouse(true)
    
        summaryLine.leftText = summaryLine:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        summaryLine.leftText:SetPoint('LEFT', 20, 0)
        summaryLine.leftText:SetJustifyH('LEFT')
    
        summaryLine.rightText = summaryLine:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        summaryLine.rightText:SetPoint('RIGHT', -2, 0)
        summaryLine.rightText:SetJustifyH('RIGHT')
        
        summaryLine.highlight = summaryLine:CreateTexture(nil, 'ARTWORK')
        summaryLine.highlight:SetAllPoints()
        summaryLine.highlight:SetTexture(0.25, 0.5, 1, 0.4)
        summaryLine.highlight:SetAlpha(0)
        
        summaryLine.icon = summaryLine:CreateTexture(nil, 'OVERLAY')
        summaryLine.icon:SetSize(ScootsCraft.summaryLineHeight - 2, ScootsCraft.summaryLineHeight - 2)
        summaryLine.icon:SetPoint('TOPLEFT', 2, -1)
        
        summaryLine:SetScript('OnClick', function()
            HandleModifiedItemClick(summaryLine.leftText:GetText())
            
            if(not IsAltKeyDown() and not IsShiftKeyDown() and not IsControlKeyDown()) then
                ScootsCraft.handleReagentJump(summaryLine.itemId)
            end
        end)
        
        summaryLine:SetScript('OnEnter', function()
            summaryLine.highlight:SetAlpha(1)
            
            GameTooltip:SetOwner(summaryLine, 'ANCHOR_LEFT')
            GameTooltip:SetHyperlink(summaryLine.leftText:GetText())
            GameTooltip:Show()
            
            CursorUpdate(summaryLine)
        end)
        
        summaryLine:SetScript('OnLeave', function()
            summaryLine.highlight:SetAlpha(0)
            GameTooltip_Hide(summaryLine)
        end)
        
        ScootsCraft.frames.summaryLines[summaryLineIndex] = summaryLine
    end
end

ScootsCraft.interface.buildFilterWindow = function()
    ScootsCraft.frames.filterHolder = CreateFrame('Frame', 'ScootsCraft-Filters', ScootsCraft.frames.front)
    ScootsCraft.frames.filterHolder:SetSize(150, 334)
    ScootsCraft.frames.filterHolder:SetPoint('TOPLEFT', ScootsCraft.frames.front, 'TOPLEFT', 22, -80)
    
    -- Search
    ScootsCraft.frames.searchFilter = CreateFrame('EditBox', 'ScootsCraft-Filters-SearchBox', ScootsCraft.frames.filterHolder)
    ScootsCraft.frames.searchFilter:SetSize(140, 19)
    ScootsCraft.frames.searchFilter:SetPoint('TOPLEFT', ScootsCraft.frames.filterHolder, 'TOPLEFT', 5, -5)
    ScootsCraft.frames.searchFilter:SetAutoFocus(false)
    ScootsCraft.frames.searchFilter:SetFontObject('GameFontHighlightSmall')
    ScootsCraft.frames.searchFilter:SetJustifyH('LEFT')
    ScootsCraft.frames.searchFilter:SetTextInsets(5, 5, 0, 0)

    ScootsCraft.frames.searchFilter.label = ScootsCraft.frames.searchFilter:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
    ScootsCraft.frames.searchFilter.label:SetPoint('LEFT', 5, 0)
    ScootsCraft.frames.searchFilter.label:SetJustifyH('LEFT')
    ScootsCraft.frames.searchFilter.label:SetText('Search')
    
    ScootsCraft.frames.searchFilter:SetScript('OnEnterPressed', EditBox_ClearFocus)
    ScootsCraft.frames.searchFilter:SetScript('OnEscapePressed', EditBox_ClearFocus)
    ScootsCraft.frames.searchFilter:SetScript('OnEditFocusGained', function()
        ScootsCraft.searchFilterFocussed = true
        EditBox_HighlightText(ScootsCraft.frames.searchFilter)
    end)
    
    ScootsCraft.frames.searchFilter:SetScript('OnEditFocusLost', function()
        if(ScootsCraft.frames.searchFilter:GetText() == '') then
            ScootsCraft.frames.searchFilter.label:Show()
        end
    end)
    
    ScootsCraft.frames.searchFilter:SetScript('OnTextChanged', function()
        ScootsCraft.setFilter('search', ScootsCraft.frames.searchFilter:GetText())
        
        if(ScootsCraft.frames.searchFilter:GetText() == '') then
            ScootsCraft.frames.searchFilter.label:Show()
        else
            ScootsCraft.frames.searchFilter.label:Hide()
        end
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
    
    ScootsCraft.frames.searchFilterIncludeReagents = ScootsCraft.interface.insertFilterCheckbox({
        ['framename'] = 'ScootsCraft-Filters-SearchBox-IncludeReagents',
        ['parent'] = ScootsCraft.frames.filterHolder,
        ['prior'] = ScootsCraft.frames.searchFilter,
        ['offset'] = 2,
        ['name'] = 'Include reagents',
        ['filterkey'] = 'search-include-reagents',
        ['tooltip'] = 'Search reagent names as well as recipe names.',
    })
    
    -- Have materials
    local divider = ScootsCraft.interface.insertFilterDivider(ScootsCraft.frames.searchFilterIncludeReagents)
    
    ScootsCraft.frames.haveMaterialsFilter = ScootsCraft.interface.insertFilterCheckbox({
        ['framename'] = 'ScootsCraft-Filters-HaveMaterials',
        ['parent'] = ScootsCraft.frames.filterHolder,
        ['prior'] = divider,
        ['offset'] = -2,
        ['name'] = 'Have materials',
        ['filterkey'] = 'have-materials',
        ['tooltip'] = 'Only show recipes that you have the required materials to make.',
    })
    
    -- In bags
    divider = ScootsCraft.interface.insertFilterDivider(ScootsCraft.frames.haveMaterialsFilter)
    
    ScootsCraft.frames.excludeItemsInBagsFilter = ScootsCraft.interface.insertFilterCheckbox({
        ['framename'] = 'ScootsCraft-Filters-ExcludeItemsInBags',
        ['parent'] = ScootsCraft.frames.filterHolder,
        ['prior'] = divider,
        ['offset'] = -2,
        ['name'] = 'Exclude items in bags',
        ['filterkey'] = 'exclude-items-in-bags',
        ['tooltip'] = 'Exclude recipes which create items that are already in your bags.',
    })
    
    -- Attuneable
    divider = ScootsCraft.interface.insertFilterDivider(ScootsCraft.frames.excludeItemsInBagsFilter)
    
    ScootsCraft.frames.attuneableFilter = ScootsCraft.interface.insertFilterRadio({
        ['framenameprefix'] = 'ScootsCraft-Filters-Attuneable-',
        ['parent'] = ScootsCraft.frames.filterHolder,
        ['prior'] = divider,
        ['offset'] = -4,
        ['name'] = 'Show equipment',
        ['filterkey'] = 'attuneable',
        ['choices'] = {
            {
                ['framenamesuffix'] = 'All',
                ['name'] = 'All',
                ['value'] = 'all',
                ['tooltip'] = 'Show all equipment items.',
            },
            {
                ['framenamesuffix'] = 'Account',
                ['name'] = 'Attuneable (account)',
                ['value'] = 'account',
                ['tooltip'] = 'Show equipment items that can be attuned at all.',
            },
            {
                ['framenamesuffix'] = 'Character',
                ['name'] = 'Attuneable (character)',
                ['value'] = 'character',
                ['tooltip'] = 'Show equipment items that can be attuned by the current character.',
            },
        },
    })
    
    -- Attunement level
    divider = ScootsCraft.interface.insertFilterDivider(ScootsCraft.frames.attuneableFilter[#ScootsCraft.frames.attuneableFilter])
    
    ScootsCraft.frames.attunedAtLevelFilter = ScootsCraft.interface.insertFilterRadio({
        ['framenameprefix'] = 'ScootsCraft-Filters-AttunedAt-',
        ['parent'] = ScootsCraft.frames.filterHolder,
        ['prior'] = divider,
        ['offset'] = -4,
        ['name'] = 'Attuned at',
        ['filterkey'] = 'attuned-level',
        ['choices'] = {
            {
                ['framenamesuffix'] = 'NotAttuned',
                ['name'] = 'Unattuned',
                ['value'] = 0,
                ['tooltip'] = 'Only show equipment you have not attuned at all.',
            },
            {
                ['framenamesuffix'] = 'Baseline',
                ['name'] = 'Up to baseline',
                ['value'] = 1,
                ['tooltip'] = 'Only show equipment you have not attuned at all, or only attuned at a baseline level.',
            },
            {
                ['framenamesuffix'] = 'Titanforged',
                ['name'] = 'Up to titanforged',
                ['value'] = 2,
                ['tooltip'] = 'Only show equipment you have not attuned at all, or only attuned up to and including at a titanforged level.',
            },
            {
                ['framenamesuffix'] = 'Warforged',
                ['name'] = 'Up to warforged',
                ['value'] = 3,
                ['tooltip'] = 'Only show equipment you have not attuned at all, or only attuned up to and including at a warforged level.',
            },
            {
                ['framenamesuffix'] = 'Lightforged',
                ['name'] = 'Up to lightforged',
                ['value'] = 4,
                ['tooltip'] = 'Show all equipment items.',
            },
        },
    })
    
    -- Reset
    divider = ScootsCraft.interface.insertFilterDivider(ScootsCraft.frames.attunedAtLevelFilter[#ScootsCraft.frames.attunedAtLevelFilter])
    
    ScootsCraft.frames.resetFilters = CreateFrame('Button', 'ScootsCraft-Filters-Reset', ScootsCraft.frames.filterHolder, 'UIPanelButtonTemplate')
    ScootsCraft.frames.resetFilters:SetSize(100, 20)
    ScootsCraft.frames.resetFilters:SetPoint('TOPLEFT', divider, 'BOTTOMLEFT', 0, -4)
    ScootsCraft.frames.resetFilters:SetText('Reset filters')
    
    ScootsCraft.frames.resetFilters:SetScript('OnClick', function()
        EditBox_ClearFocus(ScootsCraft.frames.searchFilter)
    
        ScootsCraft.filters[ScootsCraft.activeSkill] = {
            ['search'] = '',
            ['search-include-reagents'] = false,
            ['have-materials'] = false,
            ['exclude-items-in-bags'] = false,
            ['attuneable'] = 'all',
            ['attuned-level'] = 4,
        }
        
        ScootsCraft.interface.updateFilterDisplay()
        ScootsCraft.refreshRecipeList()
    end)
    
    --
    
    ScootsCraft.frames.sectionFilter = ScootsCraft.interface.insertFilterDropdown({
        ['framename'] = 'ScootsCraft-Filters-Section',
        ['parent'] = ScootsCraft.frames.front,
        ['prior'] = ScootsCraft.frames.front,
        ['filterkey'] = 'section',
        ['choicesCallback'] = function()
            local choices = {
                {
                    ['id'] = ScootsCraft.defaultFilters['section'],
                    ['name'] = 'All categories',
                },
            }
    
            for _, section in ipairs(ScootsCraft.sectionList) do
                table.insert(choices, {
                    ['id'] = section,
                    ['name'] = section,
                })
            end
            
            return choices
        end
    })
    
    ScootsCraft.frames.sectionFilter:SetPoint('TOPLEFT', ScootsCraft.frames.front, 'TOPLEFT', 55, -38)
    
    --
    
    ScootsCraft.frames.invSlotFilter = ScootsCraft.interface.insertFilterDropdown({
        ['framename'] = 'ScootsCraft-Filters-InvSlot',
        ['parent'] = ScootsCraft.frames.front,
        ['prior'] = ScootsCraft.frames.sectionFilter,
        ['filterkey'] = 'inv-slot',
        ['choicesCallback'] = function()
            local invSlotMap = ScootsCraft.data.getItemInvSlots()
            local choices = {}
            
            for _, invSlot in pairs(ScootsCraft.inventorySlots) do
                table.insert(choices, {
                    ['id'] = invSlotMap[invSlot],
                    ['name'] = _G[invSlot],
                })
            end
            
            table.sort(choices, function(a, b)
                return a.id < b.id
            end)
            
            table.insert(choices, 1, {
                ['id'] = ScootsCraft.defaultFilters['inv-slot'],
                ['name'] = 'All slots'
            })
            
            return choices
        end
    })
    
    --
    
    ScootsCraft.interface.updateFilterDisplay()
end

ScootsCraft.interface.updateFilterDisplay = function()
    ScootsCraft.frames.searchFilter:SetText(ScootsCraft.getFilter('search'))
    
    if(ScootsCraft.getFilter('search') == '') then
        ScootsCraft.frames.searchFilter.label:Show()
    else
        ScootsCraft.frames.searchFilter.label:Hide()
    end
    
    ScootsCraft.frames.searchFilterIncludeReagents:SetChecked(ScootsCraft.getFilter('search-include-reagents'))
    ScootsCraft.frames.haveMaterialsFilter:SetChecked(ScootsCraft.getFilter('have-materials'))
    ScootsCraft.frames.excludeItemsInBagsFilter:SetChecked(ScootsCraft.getFilter('exclude-items-in-bags'))
    
    for _, checkbox in pairs(ScootsCraft.frames.attuneableFilter) do
        checkbox:SetChecked(checkbox.filterValue == ScootsCraft.getFilter('attuneable'))
        
        if(checkbox.filterValue == ScootsCraft.getFilter('attuneable')) then
            checkbox:Disable()
        else
            checkbox:Enable()
        end
    end
    
    for _, checkbox in pairs(ScootsCraft.frames.attunedAtLevelFilter) do
        checkbox:SetChecked(checkbox.filterValue == ScootsCraft.getFilter('attuned-level'))
        
        if(checkbox.filterValue == ScootsCraft.getFilter('attuned-level')) then
            checkbox:Disable()
        else
            checkbox:Enable()
        end
    end
    
    UIDropDownMenu_Initialize(ScootsCraft.frames.sectionFilter, ScootsCraft.frames.sectionFilter.initFunc)
    UIDropDownMenu_Initialize(ScootsCraft.frames.invSlotFilter, ScootsCraft.frames.invSlotFilter.initFunc)
end

ScootsCraft.interface.insertFilterDivider = function(priorElement)
    local divider = ScootsCraft.frames.filterHolder:CreateTexture(nil, 'OVERLAY')
    divider:SetSize(ScootsCraft.frames.filterHolder:GetWidth() - 10, 1)
    divider:SetPoint('TOPLEFT', priorElement, 'BOTTOMLEFT', 0, -2)
    divider:SetTexture(1, 1, 1, 0.1)
    
    return divider
end

ScootsCraft.interface.insertFilterCheckbox = function(data)
    local checkbox = CreateFrame('CheckButton', data.framename, data.parent, 'UICheckButtonTemplate')
    checkbox:SetSize(22, 22)
    checkbox:SetPoint('TOPLEFT', data.prior, 'BOTTOMLEFT', 0, data.offset)
    
    _G[checkbox:GetName() .. 'Text']:SetText(data.name)
    _G[checkbox:GetName() .. 'Text']:ClearAllPoints()
    _G[checkbox:GetName() .. 'Text']:SetPoint('TOPLEFT', checkbox, 'TOPRIGHT', -2, -5)
    
    checkbox:SetHitRectInsets(0, 0 - _G[checkbox:GetName() .. 'Text']:GetWidth(), 0, 0)
    
    checkbox:SetScript('OnClick', function(self)
        ScootsCraft.setFilter(data.filterkey, self:GetChecked() == 1)
    end)
    
    checkbox:SetScript('OnEnter', function()
        GameTooltip:SetOwner(checkbox, 'ANCHOR_TOPLEFT')
        GameTooltip:SetText(data.tooltip, nil, nil, nil, nil, 1)
        GameTooltip:Show()
    end)
    
    checkbox:SetScript('OnLeave', GameTooltip_Hide)
    
    return checkbox
end

ScootsCraft.interface.insertFilterRadio = function(data)
    local header = data.parent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
    header:SetPoint('TOPLEFT', data.prior, 'BOTTOMLEFT', 0, data.offset)
    header:SetJustifyH('LEFT')
    header:SetText(data.name)
    
    local prior = header
    local checkboxes = {}
    local index = 1
    for _, choice in ipairs(data.choices) do
        local offset = 5
        if(index == 1) then
            offset = 0
        end
    
        local checkbox = ScootsCraft.interface.insertFilterCheckbox({
            ['framename'] = data.framenameprefix .. choice.framenamesuffix,
            ['parent'] = data.parent,
            ['prior'] = prior,
            ['offset'] = offset,
            ['name'] = choice.name,
            ['filterkey'] = data.filterkey,
            ['tooltip'] = choice.tooltip,
        })
        
        checkbox.filterValue = choice.value
    
        checkbox:SetScript('OnClick', function(self)
            ScootsCraft.setFilter(data.filterkey, choice.value)
            self:Disable()
            
            for _, otherCheckbox in pairs(checkboxes) do
                if(otherCheckbox:GetName() ~= self:GetName()) then
                    otherCheckbox:SetChecked(false)
                    otherCheckbox:Enable()
                end
            end
        end)
        
        prior = checkbox
        table.insert(checkboxes, checkbox)
        index = index + 1
    end
    
    return checkboxes
end

ScootsCraft.interface.insertFilterDropdown = function(data)
    local dropdown = CreateFrame('Frame', data.framename, data.parent, 'UIDropDownMenuTemplate')
    dropdown:SetPoint('TOPLEFT', data.prior, 'TOPRIGHT', 100, 0)
    
    dropdown.initFunc = function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        
        for _, choice in ipairs(data.choicesCallback()) do
            info.text = choice.name
            info.func = function()
                UIDropDownMenu_SetText(dropdown, choice.name)
                ScootsCraft.setFilter(data.filterkey, choice.id)
            end
            
            if(ScootsCraft.getFilter(data.filterkey) == choice.id) then
                UIDropDownMenu_SetText(dropdown, choice.name)
            end
            
            UIDropDownMenu_AddButton(info, level)
        end
    end
    
    return dropdown
end

ScootsCraft.interface.buildMinimapButton = function()
    if(ScootsCraft.frames.minimapButton ~= nil) then
        return nil
    end
    
    if(ScootsCraft.options.get('minimap-button') ~= true) then
        return nil
    end
    
    ScootsCraft.frames.minimapButton = CreateFrame('Button', 'ScootsCraft-MinimapButton', _G['Minimap'])
    ScootsCraft.frames.minimapButton:SetFrameStrata('MEDIUM')
    ScootsCraft.frames.minimapButton:SetSize(32, 32)
    ScootsCraft.frames.minimapButton:SetMovable(true)
    ScootsCraft.frames.minimapButton:EnableMouse(true)
    ScootsCraft.frames.minimapButton:RegisterForDrag('LeftButton')
    ScootsCraft.frames.minimapButton:RegisterForClicks('LeftButtonUp', 'RightButtonUp')

    ScootsCraft.frames.minimapButton.icon = ScootsCraft.frames.minimapButton:CreateTexture(nil, 'ARTWORK')
    ScootsCraft.frames.minimapButton.icon:SetTexture('Interface\\AddOns\\ScootsCraft\\Textures\\MinimapButton')
    ScootsCraft.frames.minimapButton.icon:SetSize(20, 20)
    ScootsCraft.frames.minimapButton.icon:SetPoint('CENTER', 0, 0)
    
    ScootsCraft.frames.minimapButton.border = ScootsCraft.frames.minimapButton:CreateTexture(nil, 'OVERLAY')
    ScootsCraft.frames.minimapButton.border:SetTexture('Interface\\Minimap\\MiniMap-TrackingBorder')
    ScootsCraft.frames.minimapButton.border:SetSize(54, 54)
    ScootsCraft.frames.minimapButton.border:SetPoint('TOPLEFT', 0, 0)
    
    ScootsCraft.frames.minimapButton:SetHighlightTexture('Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight')
    
    ScootsCraft.minimapButtonAngle = 200
    ScootsCraft.interface.setMinimapButtonPosition()
    
    ScootsCraft.frames.minimapButton:SetScript('OnDragStart', function()
        ScootsCraft.frames.minimapButton:SetScript('OnUpdate', function()
            local cursorPosition = {GetCursorPosition()}
            local scale = UIParent:GetEffectiveScale()
            
            local scaledCursorPosition = {cursorPosition[1] / scale, cursorPosition[2] / scale}
            local minimapPosition = {_G['Minimap']:GetCenter()}
            
            ScootsCraft.minimapButtonAngle = math.deg(math.atan2(scaledCursorPosition[2] - minimapPosition[2], scaledCursorPosition[1] - minimapPosition[1]))
            ScootsCraft.interface.setMinimapButtonPosition()
        end)
    end)
    
    ScootsCraft.frames.minimapButton:SetScript('OnDragStop', function()
        ScootsCraft.frames.minimapButton:SetScript('OnUpdate', nil)
    end)
    
    local fontObjects
    
    ScootsCraft.frames.minimapButton:SetScript('OnEnter', function()
        GameTooltip:SetOwner(ScootsCraft.frames.minimapButton, 'ANCHOR_TOPLEFT')
        
        GameTooltip:AddLine(ScootsCraft.title, nil, nil, nil, true)
        GameTooltip:AddLine(ScootsCraft.version, nil, nil, nil, true)
        GameTooltip:AddLine(' ', nil, nil, nil, true)
        
        GameTooltip:AddDoubleLine(
            'Left-click:',
            'Toggle',
            NORMAL_FONT_COLOR.r,
            NORMAL_FONT_COLOR.g,
            NORMAL_FONT_COLOR.b,
            HIGHLIGHT_FONT_COLOR.r,
            HIGHLIGHT_FONT_COLOR.g,
            HIGHLIGHT_FONT_COLOR.b
        )
        
        GameTooltip:AddDoubleLine(
            'Right-click:',
            'Options',
            NORMAL_FONT_COLOR.r,
            NORMAL_FONT_COLOR.g,
            NORMAL_FONT_COLOR.b,
            HIGHLIGHT_FONT_COLOR.r,
            HIGHLIGHT_FONT_COLOR.g,
            HIGHLIGHT_FONT_COLOR.b
        )
        
        fontObjects = {
            _G['GameTooltipTextLeft1']:GetFontObject(),
            _G['GameTooltipTextLeft2']:GetFontObject(),
            _G['GameTooltipTextLeft3']:GetFontObject()
        }
        
        _G['GameTooltipTextLeft1']:SetFontObject('GameTooltipHeaderText')
        
        _G['GameTooltipTextLeft2']:SetFontObject('GameFontNormalSmall')
        _G['GameTooltipTextLeft2']:SetTextColor(0.6, 0.98, 0.6)
        
        _G['GameTooltipTextLeft3']:SetFontObject('GameFontNormalSmall')
        
        GameTooltip:Show()
    end)
    
    ScootsCraft.frames.minimapButton:SetScript('OnLeave', function()
        _G['GameTooltipTextLeft1']:SetFontObject(fontObjects[1])
        _G['GameTooltipTextLeft2']:SetFontObject(fontObjects[2])
        _G['GameTooltipTextLeft3']:SetFontObject(fontObjects[3])
        
        GameTooltip_Hide(ScootsCraft.frames.minimapButton)
    end)
    
    ScootsCraft.frames.minimapButton:SetScript('OnClick', function(_, button)
        if(button == 'LeftButton') then
            ScootsCraft.interface.toggle()
        elseif(button == 'RightButton') then
            ScootsCraft.options.open()
        end
    end)
end

ScootsCraft.interface.setMinimapButtonPosition = function()
    local radius = 80
    local x = math.cos(math.rad(ScootsCraft.minimapButtonAngle)) * radius
    local y = math.sin(math.rad(ScootsCraft.minimapButtonAngle)) * radius
    ScootsCraft.frames.minimapButton:SetPoint('CENTER', _G['Minimap'], 'CENTER', x, y)
end