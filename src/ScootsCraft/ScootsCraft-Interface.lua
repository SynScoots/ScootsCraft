local core = ScootsCraft.core
local storage = ScootsCraft.storage
local options = ScootsCraft.options
local frames = ScootsCraft.frames
local interface
local utility = ScootsCraft.utility
local lookup = ScootsCraft.lookup

interface = {
    ['toggle'] = function()
        if(frames.master == nil and core.preBuildChecks()) then
            interface.build()
        end
        
        if(frames.master) then
            if(frames.master:IsVisible()) then
                HideUIPanel(frames.master)
            else
                ShowUIPanel(frames.master)
            end
        end
    end,
    ['build'] = function()
        interface.buildMainWindow()
        local skillIndex = interface.buildProfessionSwatch()
        interface.buildFilterWindow()
        interface.buildRecipeList()
        interface.buildDetailsPane()
        interface.buildSummaryPane()
        interface.buildFooterLeft()
        interface.buildFooterRight()
        
        core.setActiveSkill(skillIndex)
        
        frames.events:RegisterEvent('BAG_UPDATE')
    end,
    ['buildMainWindow'] = function()
        frames.master = CreateFrame('Frame', 'ScootsCraft-MasterFrame', UIParent)
        
        UIPanelWindows[frames.master:GetName()] = {
            ['area'] = 'left',
            ['pushable'] = 1,
            ['whileDead'] = true,
            ['width'] = 838
        }
        
        frames.master:SetToplevel(true)
        frames.master:SetMovable(true)
        frames.master:EnableMouse(true)
        frames.master:SetAttribute('UIPanelLayout-enabled', true)
        frames.master:SetAttribute('UIPanelLayout-area', 'left')
        frames.master:SetAttribute('UIPanelLayout-pushable', 1)

        frames.master:SetSize(UIPanelWindows[frames.master:GetName()].width, 438)
        frames.master:SetFrameStrata('MEDIUM')
        
        -- Not a mistake: fixes issue with overlapping frames
        ShowUIPanel(frames.master)
        HideUIPanel(frames.master)
        
        frames.master.icon = frames.master:CreateTexture(nil, 'OVERLAY')
        frames.master.icon:SetPoint('TOPLEFT', 8, -4)
        frames.master.icon:SetSize(60, 60)
        
        --
        
        frames.front = CreateFrame('Frame', 'ScootsCraft-FrontFrame', frames.master)
        frames.front:SetPoint('TOPLEFT', frames.master, 'TOPLEFT', 0, 0)
        frames.front:SetSize(frames.master:GetWidth(), frames.master:GetHeight())
        
        frames.front.background = frames.front:CreateTexture()
        frames.front.background:SetTexture('Interface\\AddOns\\ScootsCraft\\Textures\\Background')
        frames.front.background:SetPoint('TOPLEFT', 0, 0)
        frames.front.background:SetSize(1024, 512)
        
        frames.master:SetScript('OnMouseDown', function()
            EditBox_ClearFocus(frames.searchFilter)
        end)
        
        --
        
        frames.title = CreateFrame('Frame', 'ScootsCraft-Title', frames.front)
        frames.title:SetSize(680, 21)
        frames.title:SetPoint('TOPLEFT', frames.front, 'TOPLEFT', 68, -11)
        frames.title:EnableMouse(true)
        frames.title:RegisterForDrag('LeftButton')
        
        frames.title.addonName = frames.title:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        frames.title.addonName:SetPoint('LEFT', 8, 0)
        frames.title.addonName:SetJustifyH('LEFT')
        frames.title.addonName:SetText(ScootsCraft.title)

        frames.title.version = frames.title:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
        frames.title.version:SetTextColor(0.6, 0.98, 0.6)
        frames.title.version:SetPoint('BOTTOMLEFT', frames.title.addonName, 'BOTTOMRIGHT', 1, 0)
        frames.title.version:SetJustifyH('LEFT')
        frames.title.version:SetText(ScootsCraft.version)

        frames.title.skillName = frames.title:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        frames.title.skillName:SetPoint('BOTTOMLEFT', frames.title.version, 'BOTTOMRIGHT', 1, 0)
        frames.title.skillName:SetJustifyH('LEFT')
        
        frames.title:SetScript('OnDragStart', function()
            if(options.get('drag-window')) then
                frames.master:StartMoving()
            end
        end)
        
        frames.title:SetScript('OnDragStop', function()
            frames.master:StopMovingOrSizing()
        end)
        
        --
        
        frames.optionsButton = CreateFrame('Button', 'ScootsCraft-OptionsButton', frames.front, 'UIPanelButtonTemplate')
        frames.optionsButton:SetSize(64, 19)
        frames.optionsButton:SetPoint('TOPLEFT', frames.front, 'TOPLEFT', 749, -12)
        frames.optionsButton:SetText('Options')
        
        frames.optionsButton:SetScript('OnClick', function()
            options.open()
        end)
        
        --
        
        frames.closeButton = CreateFrame('Button', 'ScootsCraft-CloseButton', frames.front, 'UIPanelCloseButton')
        frames.closeButton:SetPoint('TOPLEFT', frames.front, 'TOPLEFT', 809, -6)
        frames.closeButton:SetScript('OnClick', interface.toggle)
    end,
    ['buildFooterLeft'] = function()
        frames.summariseButton = CreateFrame('Button', 'ScootsCraft-SummariseButton', frames.front, 'UIPanelButtonTemplate')
        frames.summariseButton:SetSize(80, 19)
        frames.summariseButton:SetPoint('TOPLEFT', frames.front, 'TOPLEFT', 16, -410)
        frames.summariseButton:SetText('Summarise')
        
        frames.summariseButton:SetScript('OnClick', function()
            core.generateSummary(core.activeSkill)
        end)
        
        frames.summariseButton:SetScript('OnEnter', function()
            GameTooltip:SetOwner(frames.summariseButton, 'ANCHOR_TOPLEFT')
            GameTooltip:SetText('Summarise profession', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
            GameTooltip:AddLine('Generate a summary of all reagents you need to gather to create one of every item for ' .. core.skills[core.skillIndexMap[core.activeSkill]].displayName .. '.', nil, nil, nil, true)
            GameTooltip:AddLine('Result is influenced by the current value for the filters above.', nil, nil, nil, true)
            GameTooltip:AddLine(' ', nil, nil, nil, true)
            GameTooltip:AddLine('Recipes you have not learned will be excluded from the result.', nil, nil, nil, true)
            
            if(options.get('discount-summaries')) then
                GameTooltip:AddLine('Reagents in your resource bank and inventory will reduce the final counts.', nil, nil, nil, true)
            end
            
            
            GameTooltip:AddLine(' ', nil, nil, nil, true)
            GameTooltip:AddLine('Counts will be inflated in cases where a reagent is also a craft returned by the current filter values.', nil, nil, nil, true)
            GameTooltip:Show()
        end)
        
        frames.summariseButton:SetScript('OnLeave', GameTooltip_Hide)
        
        --
        
        frames.summariseAllButton = CreateFrame('Button', 'ScootsCraft-SummariseButton', frames.front, 'UIPanelButtonTemplate')
        frames.summariseAllButton:SetSize(26, 19)
        frames.summariseAllButton:SetPoint('TOPLEFT', frames.summariseButton, 'TOPRIGHT', 2, 0)
        frames.summariseAllButton:SetText('All')
        
        frames.summariseAllButton:SetScript('OnClick', function()
            core.generateSummary(nil)
        end)
        
        frames.summariseAllButton:SetScript('OnEnter', function()
            GameTooltip:SetOwner(frames.summariseAllButton, 'ANCHOR_TOPLEFT')
            GameTooltip:SetText('Summarise all professions', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
            GameTooltip:AddLine('Generate a summary of all reagents you need to gather to create one of every item for all learned professions.', nil, nil, nil, true)
            GameTooltip:AddLine('Result is influenced by the current value for the filters above.', nil, nil, nil, true)
            GameTooltip:AddLine(' ', nil, nil, nil, true)
            GameTooltip:AddLine('Recipes you have not learned will be excluded from the result.', nil, nil, nil, true)
            
            if(options.get('discount-summaries')) then
                GameTooltip:AddLine('Reagents in your resource bank and inventory will reduce the final counts.', nil, nil, nil, true)
            end
            
            GameTooltip:AddLine(' ', nil, nil, nil, true)
            GameTooltip:AddLine('Counts will be inflated in cases where a reagent is also a craft returned by the current filter values.', nil, nil, nil, true)
            GameTooltip:Show()
        end)
        
        frames.summariseAllButton:SetScript('OnLeave', GameTooltip_Hide)
        
        --
        
        frames.front.recipeCount = frames.front:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
        frames.front.recipeCount:SetPoint('TOPRIGHT', frames.front, 'TOPLEFT', 170, -392)
        frames.front.recipeCount:SetJustifyH('RIGHT')
        
        --

        frames.toggleAllSections = CreateFrame('Button', 'ScootsCraft-ToggleAllSections', frames.front)
        frames.toggleAllSections:SetSize(16, 16)
        frames.toggleAllSections:SetPoint('TOPLEFT', frames.front, 'TOPLEFT', 179, -412)
        frames.toggleAllSections:SetHitRectInsets(-3, -20, 0, 0)
        frames.toggleAllSections:SetHighlightTexture('Interface\\Buttons\\UI-PlusButton-Hilight', 'ADD')
        frames.toggleAllSections:SetNormalTexture('Interface\\Buttons\\UI-MinusButton-Up')
        frames.toggleAllSections:SetPushedTexture('Interface\\Buttons\\UI-MinusButton-Down')

        frames.toggleAllSections:SetScript('OnClick', core.toggleAllSections)
        
        frames.toggleAllSections.label = frames.toggleAllSections:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
        frames.toggleAllSections.label:SetPoint('LEFT', frames.toggleAllSections, 'RIGHT', 3, 0)
        frames.toggleAllSections.label:SetJustifyH('LEFT')
        frames.toggleAllSections.label:SetText('All')
    end,
    ['buildFooterRight'] = function()
        frames.createButton = CreateFrame('Button', 'ScootsCraft-CreateButton', frames.front, 'UIPanelButtonTemplate')
        frames.createButton:SetSize(80, 19)
        frames.createButton:SetPoint('TOPLEFT', frames.front, 'TOPLEFT', 750, -410)
        frames.createButton:SetText('Create')
        frames.createButton:Disable()
        
        frames.createButton:SetScript('OnClick', core.craftItem)
        
        --
        
        frames.increment = CreateFrame('Button', 'ScootsCraft-Quantity-IncrementButton', frames.front)
        frames.increment:SetSize(19, 19)
        frames.increment:SetPoint('TOPRIGHT', frames.createButton, 'TOPLEFT', -1, 0)
        frames.increment:Hide()
        
        frames.increment:SetNormalTexture('Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up')
        frames.increment:SetPushedTexture('Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down')
        frames.increment:SetDisabledTexture('Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled')
        frames.increment:SetHighlightTexture('Interface\\Buttons\\UI-Common-MouseHilight', 'ADD')
        
        frames.increment:SetScript('OnClick', function()
            local check = frames.quantity:GetNumber()
            local maxQty = 200
            
            if(check < maxQty) then
                frames.quantity:SetNumber(check + 1)
            end
        end)
        
        --
        
        frames.quantity = CreateFrame('EditBox', 'ScootsCraft-Quantity', frames.front)
        frames.quantity:SetSize(30, 19)
        frames.quantity:SetPoint('TOPRIGHT', frames.increment, 'TOPLEFT', 0, 0)
        frames.quantity:SetAutoFocus(false)
        frames.quantity:SetMaxLetters(3)
        frames.quantity:SetNumeric(true)
        frames.quantity:SetFontObject('GameFontHighlightSmall')
        frames.quantity:SetText('1')
        frames.quantity:SetJustifyH('CENTER')
        frames.quantity:Hide()
        
        frames.quantity:SetScript('OnEnterPressed', EditBox_ClearFocus)
        frames.quantity:SetScript('OnEscapePressed', EditBox_ClearFocus)
        frames.quantity:SetScript('OnEditFocusGained', EditBox_HighlightText)
        
        frames.quantity:SetScript('OnEditFocusLost', function()
            EditBox_ClearHighlight(frames.quantity)
            
            local check = frames.quantity:GetNumber()
            local maxQty = 200
            
            if(check < 1) then
                frames.quantity:SetNumber(1)
            elseif(check > maxQty) then
                frames.quantity:SetNumber(maxQty)
            end
        end)
        
        frames.quantity.bgLeft = frames.quantity:CreateTexture(nil, 'BACKGROUND')
        frames.quantity.bgLeft:SetTexture('Interface\\Common\\Common-Input-Border')
        frames.quantity.bgLeft:SetSize(8, 19)
        frames.quantity.bgLeft:SetPoint('LEFT', 0, 0)
        frames.quantity.bgLeft:SetTexCoord(0, 0.0625, 0, 0.625)
        
        frames.quantity.bgRight = frames.quantity:CreateTexture(nil, 'BACKGROUND')
        frames.quantity.bgRight:SetTexture('Interface\\Common\\Common-Input-Border')
        frames.quantity.bgRight:SetSize(8, 19)
        frames.quantity.bgRight:SetPoint('RIGHT', 0, 0)
        frames.quantity.bgRight:SetTexCoord(0.9375, 1.0, 0, 0.625)
        
        frames.quantity.bgMiddle = frames.quantity:CreateTexture(nil, 'BACKGROUND')
        frames.quantity.bgMiddle:SetTexture('Interface\\Common\\Common-Input-Border')
        frames.quantity.bgMiddle:SetSize(10, 19)
        frames.quantity.bgMiddle:SetPoint('LEFT', frames.quantity.bgLeft, 'RIGHT', 0, 0)
        frames.quantity.bgMiddle:SetPoint('RIGHT', frames.quantity.bgRight, 'LEFT', 0, 0)
        frames.quantity.bgMiddle:SetTexCoord(0.0625, 0.9375, 0, 0.625)
        
        --
        
        frames.decrement = CreateFrame('Button', 'ScootsCraft-Quantity-DecrementButton', frames.front)
        frames.decrement:SetSize(19, 19)
        frames.decrement:SetPoint('TOPRIGHT', frames.quantity, 'TOPLEFT', 0, 0)
        frames.decrement:Hide()
        
        frames.decrement:SetNormalTexture('Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up')
        frames.decrement:SetPushedTexture('Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down')
        frames.decrement:SetDisabledTexture('Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled')
        frames.decrement:SetHighlightTexture('Interface\\Buttons\\UI-Common-MouseHilight', 'ADD')
        
        frames.decrement:SetScript('OnClick', function()
            local check = frames.quantity:GetNumber()
            
            if(check > 1) then
                frames.quantity:SetNumber(check - 1)
            end
        end)
        
        --
        
        frames.createAllButton = CreateFrame('Button', 'ScootsCraft-CreateButton', frames.front, 'UIPanelButtonTemplate')
        frames.createAllButton:SetSize(80, 19)
        frames.createAllButton:SetPoint('TOPRIGHT', frames.decrement, 'TOPLEFT', -1, 0)
        frames.createAllButton:SetText('Create all')
        frames.createAllButton:Hide()
        
        frames.createAllButton:SetScript('OnClick', function()
            frames.quantity:SetNumber(math.min(200, (select(5, Custom_GetProfessionRecipeInfo(core.visibleSpellId)))))
            core.craftItem()
        end)
        
        --
        
        frames.front.forgeHelper = {}
        
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
            local checkbox = CreateFrame('CheckButton', 'ScootsCraft-ForgeHelper-' .. field.name, frames.front, 'UICheckButtonTemplate')
            checkbox:SetSize(22, 22)
            
            _G[checkbox:GetName() .. 'Text']:SetText(field.name)
            _G[checkbox:GetName() .. 'Text']:ClearAllPoints()
            _G[checkbox:GetName() .. 'Text']:SetPoint('TOPLEFT', checkbox, 'TOPRIGHT', -2, -5)
            
            checkbox:SetHitRectInsets(0, 0 - _G[checkbox:GetName() .. 'Text']:GetWidth(), 0, 0)
            
            if(prev == nil) then
                checkbox:SetPoint('RIGHT', frames.createAllButton, 'LEFT', 0 - (10 + _G[checkbox:GetName() .. 'Text']:GetWidth()), -1)
            else
                checkbox:SetPoint('RIGHT', prev, 'LEFT', 0 - _G[checkbox:GetName() .. 'Text']:GetWidth(), 0)
            end
            
            checkbox:SetScript('OnClick', function()
                if(checkbox:GetChecked() == 1) then
                    for name, check in pairs(frames.front.forgeHelper) do
                        if(name ~= field.name) then
                            check:SetChecked(false)
                        end
                    end
                    
                    core.forgeHelper = field.value
                else
                    core.forgeHelper = nil
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
            
            frames.front.forgeHelper[field.name] = checkbox
            prev = checkbox
        end
        
        frames.front.forgeHelperTitle = frames.front:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
        frames.front.forgeHelperTitle:SetPoint('RIGHT', prev, 'LEFT', 0, 1)
        frames.front.forgeHelperTitle:SetJustifyH('RIGHT')
        frames.front.forgeHelperTitle:SetText('Forge-helper: ')
        frames.front.forgeHelperTitle:Hide()
    end,
    ['buildProfessionSwatch'] = function()
        local skillIdMap = lookup.professionMap

        frames.skillButtons = frames.skillButtons or {}
        local prior = nil
        
        for skillIndex = #skillIdMap, 1, -1 do
            local skill = skillIdMap[skillIndex]
            
            if(core.skills[skillIndex].spellId ~= nil) then
                local button
                
                if(frames.skillButtons[core.skills[skillIndex].name] ~= nil) then
                    button = frames.skillButtons[core.skills[skillIndex].name]
                else
                    button = CreateFrame('Button', 'ScootsCraft-Skillbutton-' .. core.skills[skillIndex].name, frames.front, 'ActionButtonTemplate')
                    button:SetSize(30, 30)
                    
                    _G[button:GetName() .. 'Icon']:SetTexture(core.skills[skillIndex].icon)
                    _G[button:GetName() .. 'NormalTexture']:SetAlpha(0)
                    
                    button.activeGlow = button:CreateTexture(nil, 'OVERLAY')
                    button.activeGlow:SetTexture('Interface\\Buttons\\UI-ActionButton-Border')
                    button.activeGlow:SetBlendMode('ADD')
                    button.activeGlow:SetAlpha(0)
                    button.activeGlow:SetSize(52, 52)
                    button.activeGlow:SetPoint('CENTER', 0, 0)
                    
                    button:HookScript('OnEnter', function()
                        GameTooltip_SetDefaultAnchor(GameTooltip, button)
                        GameTooltip:SetSpellByID(core.skills[skillIndex].spellId)
                        GameTooltip:Show()
                        
                        if(core.activeSkill ~= core.skills[skillIndex].skillId) then
                            button.activeGlow:SetVertexColor(0.3, 0.3, 0.8)
                            button.activeGlow:SetAlpha(1)
                        end
                    end)
                    
                    button:HookScript('OnLeave', function()
                        GameTooltip:Hide()
                    
                        if(core.activeSkill ~= core.skills[skillIndex].skillId) then
                            button.activeGlow:SetAlpha(0)
                        end
                    end)
                    
                    button:SetScript('OnClick', function()
                        core.setActiveSkill(skillIndex)
                    end)
                end
                
                if(prior == nil) then
                    button:SetPoint('TOPRIGHT', frames.front, 'TOPLEFT', 830, -36)
                else
                    button:SetPoint('TOPRIGHT', prior, 'TOPLEFT', -2, 0)
                end
                
                prior = button
                frames.skillButtons[core.skills[skillIndex].name] = button
            end
        end
        
        if(core.activeSkill ~= nil) then
            for skillIndex, _ in pairs(core.skills) do
                if(core.skills[skillIndex].skillId == core.activeSkill) then
                    if(frames.skillButtons[core.skills[skillIndex].name] ~= nil) then
                        return skillIndex
                    end
                    
                    break
                end
            end
        end
        
        for skillIndex, _ in pairs(core.skills) do
            if(frames.skillButtons[core.skills[skillIndex].name] ~= nil) then
                core.activeSkill = core.skills[skillIndex].skillId
                return skillIndex
            end
        end
    end,
    ['buildRecipeList'] = function()
        frames.recipeFrame = CreateFrame('ScrollFrame', 'ScootsCraft-RecipeFrame', frames.front, 'FauxScrollFrameTemplate')
        frames.recipeFrame:SetSize(301, 334)
        frames.recipeFrame:SetPoint('TOPLEFT', frames.front, 'TOPLEFT', 176, -72)
        
        core.recipesVisible = 20
        core.recipeLineHeight = frames.recipeFrame:GetHeight() / core.recipesVisible
        
        frames.recipeFrame:SetScript('OnVerticalScroll', function(self, offset)
            FauxScrollFrame_OnVerticalScroll(self, offset, core.recipeLineHeight, core.renderRecipeList)
        end)
        
        frames.recipes = {}
        for recipeIndex = 1, core.recipesVisible do
            local recipeLine = CreateFrame('Button', 'ScootsCraft-RecipeFrameLine-' .. tostring(recipeIndex), frames.recipeFrame)
            recipeLine:SetSize(frames.recipeFrame:GetWidth(), core.recipeLineHeight)
            recipeLine:SetPoint('TOPLEFT', frames.recipeFrame, 'TOPLEFT', 0, 0 - (core.recipeLineHeight * (recipeIndex - 1)))
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
            recipeLine.icon:SetSize(core.recipeLineHeight, core.recipeLineHeight)
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
            recipeLine.bounty:SetSize(core.recipeLineHeight - 2, core.recipeLineHeight - 2)
            recipeLine.bounty:SetTexture('Interface\\MoneyFrame\\UI-GoldIcon')
            recipeLine.bounty:SetPoint('TOPRIGHT', 0, -1)
            recipeLine.bounty:SetAlpha(0)
            
            recipeLine:SetScript('OnEnter', function()
                if(recipeLine.isSectionHead ~= true) then
                    recipeLine.highlight:SetAlpha(1)
                end
                
                if(recipeLine.isSectionHead ~= true) then
                    if(options.get('recipe-list-tooltip') == 'item') then
                        GameTooltip:SetOwner(recipeLine, 'ANCHOR_RIGHT')
                        
                        local itemId = select(3, Custom_GetProfessionRecipeInfo(recipeLine.recipe.spellId))
                        local itemLink
                        
                        if((itemId or 0) ~= 0) then
                            itemLink = utility.getItemLink(itemId)
                        else
                            itemLink = utility.getCraftingLink(recipeLine.recipe.spellId)
                        end
                        
                        GameTooltip:SetHyperlink(itemLink)
                        
                        GameTooltip:Show()
                    elseif(options.get('recipe-list-tooltip') == 'recipe') then
                        GameTooltip:SetOwner(recipeLine, 'ANCHOR_RIGHT')
                        GameTooltip:SetHyperlink(utility.getCraftingLink(recipeLine.recipe.spellId))
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
                        HandleModifiedItemClick(utility.getCraftingLink(recipeLine.recipe.spellId))
                    else
                        core.selectRecipe(recipeLine.recipe.spellId)
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
                core.toggleSection(recipeLine.section)
            end)
            
            frames.recipes[recipeIndex] = recipeLine
        end
    end,
    ['buildDetailsPane'] = function()
        -- Craft frame
        frames.craftItemScroller = CreateFrame('ScrollFrame', 'ScootsCraft-CraftItemScroller', frames.front, 'UIPanelScrollFrameTemplate')
        frames.craftItemScroller:SetSize(301, 334)
        frames.craftItemScroller:SetPoint('TOPLEFT', frames.front, 'TOPLEFT', 505, -72)
        
        frames.craftItemHolder = CreateFrame('Frame', 'ScootsCraft-CraftItemHolder', frames.craftItemScroller)
        frames.craftItemHolder:SetWidth(frames.craftItemScroller:GetWidth())
        frames.craftItemHolder:SetPoint('TOPLEFT', frames.craftItemScroller, 'TOPLEFT', 0, 0)
        
        frames.craftItemScroller:SetScrollChild(frames.craftItemHolder)
        
        frames.craftItem = CreateFrame('Frame', 'ScootsCraft-CraftItem', frames.craftItemHolder)
        frames.craftItem:SetSize(frames.craftItemHolder:GetWidth() - 6, frames.craftItemHolder:GetHeight() - 10)
        frames.craftItem:SetPoint('TOPLEFT', frames.craftItemHolder, 'TOPLEFT', 3, -5)
        frames.craftItem:Hide()
        
        -- Craft frame contents: Top text
        frames.craftItem.canCraftText = frames.craftItem:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
        frames.craftItem.canCraftText:SetPoint('TOPLEFT', frames.craftItem, 'TOPLEFT', 0, 0)
        frames.craftItem.canCraftText:SetJustifyH('LEFT')
        
        frames.craftItem.spellIdText = frames.craftItem:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
        frames.craftItem.spellIdText:SetPoint('TOPRIGHT', frames.craftItem, 'TOPLEFT', 294, 0)
        frames.craftItem.spellIdText:SetJustifyH('RIGHT')
        
        -- Craft frame contents: Icon
        frames.craftIcon = CreateFrame('Button', 'ScootsCraft-CraftIcon', frames.craftItem)
        frames.craftIcon:SetSize(37, 37)
        frames.craftIcon:SetPoint('TOPLEFT', frames.craftItem.canCraftText, 'BOTTOMLEFT', 0, -4)
        
        frames.craftIcon.text = frames.craftIcon:CreateFontString(nil, 'ARTWORK', 'NumberFontNormal')
        frames.craftIcon.text:SetPoint('BOTTOMRIGHT', -5, 2)
        frames.craftIcon.text:SetJustifyH('RIGHT')
        frames.craftIcon.hasItem = 1
        
        frames.craftIcon:SetScript('OnClick', function()
            local createdItemId = select(3, Custom_GetProfessionRecipeInfo(frames.craftIcon.spellId))
            
            if((createdItemId or 0) ~= 0) then
                HandleModifiedItemClick(utility.getItemLink(createdItemId))
            else
                HandleModifiedItemClick(utility.getCraftingLink(frames.craftIcon.spellId))
            end
        end)
        
        frames.craftIcon:SetScript('OnEnter', function()
            local createdItemId = select(3, Custom_GetProfessionRecipeInfo(frames.craftIcon.spellId))
            
            GameTooltip:SetOwner(frames.craftIcon, 'ANCHOR_RIGHT')
            
            if((createdItemId or 0) ~= 0) then
                GameTooltip:SetHyperlink(utility.getItemLink(createdItemId))
            else
                GameTooltip:SetHyperlink(utility.getCraftingLink(frames.craftIcon.spellId))
            end
        
            GameTooltip:Show()
            CursorUpdate(frames.craftIcon)
        end)
        
        frames.craftIcon:SetScript('OnLeave', GameTooltip_HideResetCursor)
        
        -- Craft frame contents: Name
        frames.craftItem.name = frames.craftItem:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
        frames.craftItem.name:SetWidth(frames.craftItem:GetWidth() - (frames.craftIcon:GetWidth() + 10))
        frames.craftItem.name:SetPoint('TOPLEFT', frames.craftIcon, 'TOPRIGHT', 10, 0)
        frames.craftItem.name:SetJustifyH('LEFT')
        
        -- Craft frame contents: Requirements
        frames.craftItem.requiresLabel = frames.craftItem:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
        frames.craftItem.requiresLabel:SetPoint('TOPLEFT', frames.craftItem.name, 'BOTTOMLEFT', 0, 0)
        frames.craftItem.requiresLabel:SetJustifyH('LEFT')
        
        frames.craftItem.requires = frames.craftItem:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
        frames.craftItem.requires:SetWidth(frames.craftItem:GetWidth() - (frames.craftIcon:GetWidth() + 10 + frames.craftItem.requiresLabel:GetWidth() + 4))
        frames.craftItem.requires:SetPoint('TOPLEFT', frames.craftItem.requiresLabel, 'TOPRIGHT', 4, 0)
        frames.craftItem.requires:SetJustifyH('LEFT')
        
        -- Craft frame contents: Cooldown
        frames.craftItem.cooldown = frames.craftItem:CreateFontString(nil, 'ARTWORK', 'GameFontRedSmall')
        frames.craftItem.cooldown:SetPoint('TOPLEFT', frames.craftItem.requiresLabel, 'BOTTOMLEFT', 0, 0)
        frames.craftItem.cooldown:SetJustifyH('LEFT')
        
        -- Craft frame contents: Description
        frames.craftItem.description = frames.craftItem:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
        frames.craftItem.description:SetWidth(frames.craftItem:GetWidth())
        frames.craftItem.description:SetJustifyH('LEFT')
        
        -- Craft frame contents: Reagents
        frames.craftItem.reagentsLabel = frames.craftItem:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
        frames.craftItem.reagentsLabel:SetPoint('TOPLEFT', frames.craftItem.description, 'BOTTOMLEFT', 0, -10)
        frames.craftItem.reagentsLabel:SetJustifyH('LEFT')
        frames.craftItem.reagentsLabel:SetText('Reagents:')
        
        frames.reagents = {}
        for reagentIndex = 1, 8 do
            frames.reagents[reagentIndex] = CreateFrame('Button', 'ScootsCraft-CraftItem-Reagent-' .. tostring(reagentIndex), frames.craftItem, 'TradeSkillItemTemplate')
            
            if(reagentIndex == 1) then
                frames.reagents[reagentIndex]:SetPoint('TOPLEFT', frames.craftItem.reagentsLabel, 'BOTTOMLEFT', 0, -3)
            elseif(reagentIndex % 2 == 0) then
                frames.reagents[reagentIndex]:SetPoint('TOPLEFT', frames.reagents[reagentIndex - 1], 'TOPRIGHT', 0, 0)
            else
                frames.reagents[reagentIndex]:SetPoint('TOPRIGHT', frames.reagents[reagentIndex - 1], 'BOTTOMLEFT', 0, -2)
            end
            
            frames.reagents[reagentIndex]:SetScript('OnEnter', function()
                GameTooltip:SetOwner(frames.reagents[reagentIndex], 'ANCHOR_TOPLEFT')
                GameTooltip:SetHyperlink(utility.getItemLink(frames.reagents[reagentIndex].itemId))
                GameTooltip:Show()
                CursorUpdate(frames.reagents[reagentIndex])
            end)
            
            frames.reagents[reagentIndex]:SetScript('OnLeave', function()
                GameTooltip:Hide()
                ResetCursor()
            end)
            
            frames.reagents[reagentIndex]:SetScript('OnClick', function()
                HandleModifiedItemClick(utility.getItemLink(frames.reagents[reagentIndex].itemId))
                
                if(frames.reagents[reagentIndex].itemId and not IsControlKeyDown() and not IsAltKeyDown() and not IsShiftKeyDown()) then
                    core.handleReagentJump(frames.reagents[reagentIndex].itemId)
                end
            end)
        end
    end,
    ['buildSummaryPane'] = function()
        frames.summaryFrame = CreateFrame('ScrollFrame', 'ScootsCraft-SummaryFrame', frames.front, 'FauxScrollFrameTemplate')
        frames.summaryFrame:SetSize(301, 334)
        frames.summaryFrame:SetPoint('TOPLEFT', frames.front, 'TOPLEFT', 505, -72)
        frames.summaryFrame:Hide()
        
        frames.summaryFrame.leftHeader = frames.summaryFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
        frames.summaryFrame.leftHeader:SetPoint('TOPLEFT', 20, -3)
        frames.summaryFrame.leftHeader:SetJustifyH('LEFT')
        frames.summaryFrame.leftHeader:SetText('Reagent')
        
        frames.summaryFrame.rightHeader = frames.summaryFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
        frames.summaryFrame.rightHeader:SetPoint('TOPRIGHT', -2, -3)
        frames.summaryFrame.rightHeader:SetJustifyH('RIGHT')
        frames.summaryFrame.rightHeader:SetText('Quantity')
        
        core.summaryLinesVisible = 19
        core.summaryLineHeight = frames.summaryFrame:GetHeight() / (core.summaryLinesVisible + 1)
        
        frames.summaryFrame:SetScript('OnVerticalScroll', function(self, offset)
            FauxScrollFrame_OnVerticalScroll(self, offset, core.summaryLineHeight, core.renderSummary)
        end)
        
        frames.summaryLines = {}
        for summaryLineIndex = 1, core.summaryLinesVisible do
            local summaryLine = CreateFrame('Button', 'ScootsCraft-SummaryFrameLine-' .. tostring(summaryLineIndex), frames.summaryFrame)
            summaryLine:SetSize(frames.summaryFrame:GetWidth(), core.summaryLineHeight)
            summaryLine:SetPoint('TOPLEFT', frames.summaryFrame, 'TOPLEFT', 0, 0 - (core.summaryLineHeight * summaryLineIndex))
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
            summaryLine.icon:SetSize(core.summaryLineHeight - 2, core.summaryLineHeight - 2)
            summaryLine.icon:SetPoint('TOPLEFT', 2, -1)
            
            summaryLine:SetScript('OnClick', function()
                HandleModifiedItemClick(summaryLine.leftText:GetText())
                
                if(not IsAltKeyDown() and not IsShiftKeyDown() and not IsControlKeyDown()) then
                    core.handleReagentJump(summaryLine.itemId)
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
            
            frames.summaryLines[summaryLineIndex] = summaryLine
        end
    end,
    ['buildFilterWindow'] = function()
        frames.filterHolder = CreateFrame('Frame', 'ScootsCraft-Filters', frames.front)
        frames.filterHolder:SetSize(150, 334)
        frames.filterHolder:SetPoint('TOPLEFT', frames.front, 'TOPLEFT', 22, -80)
        
        -- Search
        frames.searchFilter = CreateFrame('EditBox', 'ScootsCraft-Filters-SearchBox', frames.filterHolder)
        frames.searchFilter:SetSize(140, 19)
        frames.searchFilter:SetPoint('TOPLEFT', frames.filterHolder, 'TOPLEFT', 5, -5)
        frames.searchFilter:SetAutoFocus(false)
        frames.searchFilter:SetFontObject('GameFontHighlightSmall')
        frames.searchFilter:SetJustifyH('LEFT')
        frames.searchFilter:SetTextInsets(5, 5, 0, 0)

        frames.searchFilter.label = frames.searchFilter:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
        frames.searchFilter.label:SetPoint('LEFT', 5, 0)
        frames.searchFilter.label:SetJustifyH('LEFT')
        frames.searchFilter.label:SetText('Search')
        
        frames.searchFilter:SetScript('OnEnterPressed', EditBox_ClearFocus)
        frames.searchFilter:SetScript('OnEscapePressed', EditBox_ClearFocus)
        frames.searchFilter:SetScript('OnEditFocusGained', function()
            core.searchFilterFocussed = true
            EditBox_HighlightText(frames.searchFilter)
        end)
        
        frames.searchFilter:SetScript('OnEditFocusLost', function()
            if(frames.searchFilter:GetText() == '') then
                frames.searchFilter.label:Show()
            end
        end)
        
        frames.searchFilter:SetScript('OnTextChanged', function()
            core.setFilter('search', frames.searchFilter:GetText())
            
            if(frames.searchFilter:GetText() == '') then
                frames.searchFilter.label:Show()
            else
                frames.searchFilter.label:Hide()
            end
        end)
        
        frames.searchFilter.bgLeft = frames.searchFilter:CreateTexture(nil, 'BACKGROUND')
        frames.searchFilter.bgLeft:SetTexture('Interface\\Common\\Common-Input-Border')
        frames.searchFilter.bgLeft:SetSize(8, 19)
        frames.searchFilter.bgLeft:SetPoint('LEFT', 0, 0)
        frames.searchFilter.bgLeft:SetTexCoord(0, 0.0625, 0, 0.625)
        
        frames.searchFilter.bgRight = frames.searchFilter:CreateTexture(nil, 'BACKGROUND')
        frames.searchFilter.bgRight:SetTexture('Interface\\Common\\Common-Input-Border')
        frames.searchFilter.bgRight:SetSize(8, 19)
        frames.searchFilter.bgRight:SetPoint('RIGHT', 0, 0)
        frames.searchFilter.bgRight:SetTexCoord(0.9375, 1.0, 0, 0.625)
        
        frames.searchFilter.bgMiddle = frames.searchFilter:CreateTexture(nil, 'BACKGROUND')
        frames.searchFilter.bgMiddle:SetTexture('Interface\\Common\\Common-Input-Border')
        frames.searchFilter.bgMiddle:SetSize(10, 19)
        frames.searchFilter.bgMiddle:SetPoint('LEFT', frames.searchFilter.bgLeft, 'RIGHT', 0, 0)
        frames.searchFilter.bgMiddle:SetPoint('RIGHT', frames.searchFilter.bgRight, 'LEFT', 0, 0)
        frames.searchFilter.bgMiddle:SetTexCoord(0.0625, 0.9375, 0, 0.625)
        
        frames.searchFilterIncludeReagents = interface.insertFilterCheckbox({
            ['framename'] = 'ScootsCraft-Filters-SearchBox-IncludeReagents',
            ['parent'] = frames.filterHolder,
            ['prior'] = frames.searchFilter,
            ['offset'] = 2,
            ['name'] = 'Include reagents',
            ['filterkey'] = 'search-include-reagents',
            ['tooltip'] = 'Search reagent names as well as recipe names.',
        })
        
        -- Have materials
        local divider = interface.insertFilterDivider(frames.searchFilterIncludeReagents)
        
        frames.haveMaterialsFilter = interface.insertFilterCheckbox({
            ['framename'] = 'ScootsCraft-Filters-HaveMaterials',
            ['parent'] = frames.filterHolder,
            ['prior'] = divider,
            ['offset'] = -2,
            ['name'] = 'Have materials',
            ['filterkey'] = 'have-materials',
            ['tooltip'] = 'Only show recipes that you have the required materials to make.',
        })
        
        -- In bags
        divider = interface.insertFilterDivider(frames.haveMaterialsFilter)
        
        frames.excludeItemsInBagsFilter = interface.insertFilterCheckbox({
            ['framename'] = 'ScootsCraft-Filters-ExcludeItemsInBags',
            ['parent'] = frames.filterHolder,
            ['prior'] = divider,
            ['offset'] = -2,
            ['name'] = 'Exclude items in bags',
            ['filterkey'] = 'exclude-items-in-bags',
            ['tooltip'] = 'Exclude recipes which create items that are already in your bags.',
        })
        
        -- Attuneable
        divider = interface.insertFilterDivider(frames.excludeItemsInBagsFilter)
        
        frames.attuneableFilter = interface.insertFilterRadio({
            ['framenameprefix'] = 'ScootsCraft-Filters-Attuneable-',
            ['parent'] = frames.filterHolder,
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
        divider = interface.insertFilterDivider(frames.attuneableFilter[#frames.attuneableFilter])
        
        frames.attunedAtLevelFilter = interface.insertFilterRadio({
            ['framenameprefix'] = 'ScootsCraft-Filters-AttunedAt-',
            ['parent'] = frames.filterHolder,
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
        divider = interface.insertFilterDivider(frames.attunedAtLevelFilter[#frames.attunedAtLevelFilter])
        
        frames.resetFilters = CreateFrame('Button', 'ScootsCraft-Filters-Reset', frames.filterHolder, 'UIPanelButtonTemplate')
        frames.resetFilters:SetSize(100, 20)
        frames.resetFilters:SetPoint('TOPLEFT', divider, 'BOTTOMLEFT', 0, -4)
        frames.resetFilters:SetText('Reset filters')
        
        frames.resetFilters:SetScript('OnClick', function()
            EditBox_ClearFocus(frames.searchFilter)
        
            core.filters[core.activeSkill] = {
                ['search'] = '',
                ['search-include-reagents'] = false,
                ['have-materials'] = false,
                ['exclude-items-in-bags'] = false,
                ['attuneable'] = 'all',
                ['attuned-level'] = 4,
            }
            
            interface.updateFilterDisplay()
            core.refreshRecipeList()
        end)
        
        --
        
        frames.sectionFilter = interface.insertFilterDropdown({
            ['framename'] = 'ScootsCraft-Filters-Section',
            ['parent'] = frames.front,
            ['prior'] = frames.front,
            ['filterkey'] = 'section',
            ['choicesCallback'] = function()
                local choices = {
                    {
                        ['id'] = options.defaultFiltersValues['section'],
                        ['name'] = 'All categories',
                    },
                }
        
                for _, section in ipairs(core.sectionList) do
                    table.insert(choices, {
                        ['id'] = section,
                        ['name'] = section,
                    })
                end
                
                return choices
            end
        })
        
        frames.sectionFilter:SetPoint('TOPLEFT', frames.front, 'TOPLEFT', 55, -38)
        
        --
        
        frames.invSlotFilter = interface.insertFilterDropdown({
            ['framename'] = 'ScootsCraft-Filters-InvSlot',
            ['parent'] = frames.front,
            ['prior'] = frames.sectionFilter,
            ['filterkey'] = 'inv-slot',
            ['choicesCallback'] = function()
                local invSlotMap = lookup.itemInvSlots
                local choices = {}
                
                for _, invSlot in pairs(core.inventorySlots) do
                    table.insert(choices, {
                        ['id'] = invSlotMap[invSlot],
                        ['name'] = _G[invSlot],
                    })
                end
                
                table.sort(choices, function(a, b)
                    return a.id < b.id
                end)
                
                table.insert(choices, 1, {
                    ['id'] = options.defaultFiltersValues['inv-slot'],
                    ['name'] = 'All slots'
                })
                
                return choices
            end
        })
        
        --
        
        interface.updateFilterDisplay()
    end,
    ['updateFilterDisplay'] = function()
        frames.searchFilter:SetText(core.getFilter('search'))
        
        if(core.getFilter('search') == '') then
            frames.searchFilter.label:Show()
        else
            frames.searchFilter.label:Hide()
        end
        
        frames.searchFilterIncludeReagents:SetChecked(core.getFilter('search-include-reagents'))
        frames.haveMaterialsFilter:SetChecked(core.getFilter('have-materials'))
        frames.excludeItemsInBagsFilter:SetChecked(core.getFilter('exclude-items-in-bags'))
        
        for _, checkbox in pairs(frames.attuneableFilter) do
            checkbox:SetChecked(checkbox.filterValue == core.getFilter('attuneable'))
            
            if(checkbox.filterValue == core.getFilter('attuneable')) then
                checkbox:Disable()
            else
                checkbox:Enable()
            end
        end
        
        for _, checkbox in pairs(frames.attunedAtLevelFilter) do
            checkbox:SetChecked(checkbox.filterValue == core.getFilter('attuned-level'))
            
            if(checkbox.filterValue == core.getFilter('attuned-level')) then
                checkbox:Disable()
            else
                checkbox:Enable()
            end
        end
        
        UIDropDownMenu_Initialize(frames.sectionFilter, frames.sectionFilter.initFunc)
        UIDropDownMenu_Initialize(frames.invSlotFilter, frames.invSlotFilter.initFunc)
    end,
    ['insertFilterDivider'] = function(priorElement)
        local divider = frames.filterHolder:CreateTexture(nil, 'OVERLAY')
        divider:SetSize(frames.filterHolder:GetWidth() - 10, 1)
        divider:SetPoint('TOPLEFT', priorElement, 'BOTTOMLEFT', 0, -2)
        divider:SetTexture(1, 1, 1, 0.1)
        
        return divider
    end,
    ['insertFilterCheckbox'] = function(data)
        local checkbox = CreateFrame('CheckButton', data.framename, data.parent, 'UICheckButtonTemplate')
        checkbox:SetSize(22, 22)
        checkbox:SetPoint('TOPLEFT', data.prior, 'BOTTOMLEFT', 0, data.offset)
        
        _G[checkbox:GetName() .. 'Text']:SetText(data.name)
        _G[checkbox:GetName() .. 'Text']:ClearAllPoints()
        _G[checkbox:GetName() .. 'Text']:SetPoint('TOPLEFT', checkbox, 'TOPRIGHT', -2, -5)
        
        checkbox:SetHitRectInsets(0, 0 - _G[checkbox:GetName() .. 'Text']:GetWidth(), 0, 0)
        
        checkbox:SetScript('OnClick', function(self)
            core.setFilter(data.filterkey, self:GetChecked() == 1)
        end)
        
        checkbox:SetScript('OnEnter', function()
            GameTooltip:SetOwner(checkbox, 'ANCHOR_TOPLEFT')
            GameTooltip:SetText(data.tooltip, nil, nil, nil, nil, 1)
            GameTooltip:Show()
        end)
        
        checkbox:SetScript('OnLeave', GameTooltip_Hide)
        
        return checkbox
    end,
    ['insertFilterRadio'] = function(data)
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
        
            local checkbox = interface.insertFilterCheckbox({
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
                core.setFilter(data.filterkey, choice.value)
                self:Disable()
                self:GetPushedTexture():Hide()
                self:GetNormalTexture():Show()
                
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
    end,
    ['insertFilterDropdown'] = function(data)
        local dropdown = CreateFrame('Frame', data.framename, data.parent, 'UIDropDownMenuTemplate')
        dropdown:SetPoint('TOPLEFT', data.prior, 'TOPRIGHT', 100, 0)
        
        dropdown.initFunc = function(self, level)
            local info = UIDropDownMenu_CreateInfo()
            
            for _, choice in ipairs(data.choicesCallback()) do
                info.text = choice.name
                info.func = function()
                    UIDropDownMenu_SetText(dropdown, choice.name)
                    core.setFilter(data.filterkey, choice.id)
                end
                
                if(core.getFilter(data.filterkey) == choice.id) then
                    UIDropDownMenu_SetText(dropdown, choice.name)
                end
                
                UIDropDownMenu_AddButton(info, level)
            end
        end
        
        return dropdown
    end,
    ['buildMinimapButton'] = function()
        if(frames.minimapButton ~= nil) then
            return nil
        end
        
        if(options.get('minimap-button') ~= true) then
            return nil
        end
        
        frames.minimapButton = CreateFrame('Button', 'ScootsCraft-MinimapButton', _G['Minimap'])
        frames.minimapButton:SetFrameStrata('MEDIUM')
        frames.minimapButton:SetSize(32, 32)
        frames.minimapButton:SetMovable(true)
        frames.minimapButton:EnableMouse(true)
        frames.minimapButton:RegisterForDrag('LeftButton')
        frames.minimapButton:RegisterForClicks('LeftButtonUp', 'RightButtonUp')

        frames.minimapButton.icon = frames.minimapButton:CreateTexture(nil, 'ARTWORK')
        frames.minimapButton.icon:SetTexture('Interface\\AddOns\\ScootsCraft\\Textures\\MinimapButton')
        frames.minimapButton.icon:SetSize(20, 20)
        frames.minimapButton.icon:SetPoint('CENTER', 0, 0)
        
        frames.minimapButton.border = frames.minimapButton:CreateTexture(nil, 'OVERLAY')
        frames.minimapButton.border:SetTexture('Interface\\Minimap\\MiniMap-TrackingBorder')
        frames.minimapButton.border:SetSize(54, 54)
        frames.minimapButton.border:SetPoint('TOPLEFT', 0, 0)
        
        frames.minimapButton:SetHighlightTexture('Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight')
        
        core.minimapButtonAngle = 200
        interface.setMinimapButtonPosition()
        
        frames.minimapButton:SetScript('OnDragStart', function()
            frames.minimapButton:SetScript('OnUpdate', function()
                local cursorPosition = {GetCursorPosition()}
                local scale = UIParent:GetEffectiveScale()
                
                local scaledCursorPosition = {cursorPosition[1] / scale, cursorPosition[2] / scale}
                local minimapPosition = {_G['Minimap']:GetCenter()}
                
                core.minimapButtonAngle = math.deg(math.atan2(scaledCursorPosition[2] - minimapPosition[2], scaledCursorPosition[1] - minimapPosition[1]))
                interface.setMinimapButtonPosition()
            end)
        end)
        
        frames.minimapButton:SetScript('OnDragStop', function()
            frames.minimapButton:SetScript('OnUpdate', nil)
        end)
        
        local fontObjects
        
        frames.minimapButton:SetScript('OnEnter', function()
            GameTooltip:SetOwner(frames.minimapButton, 'ANCHOR_TOPLEFT')
            
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
        
        frames.minimapButton:SetScript('OnLeave', function()
            _G['GameTooltipTextLeft1']:SetFontObject(fontObjects[1])
            _G['GameTooltipTextLeft2']:SetFontObject(fontObjects[2])
            _G['GameTooltipTextLeft3']:SetFontObject(fontObjects[3])
            
            GameTooltip_Hide(frames.minimapButton)
        end)
        
        frames.minimapButton:SetScript('OnClick', function(_, button)
            if(button == 'LeftButton') then
                interface.toggle()
            elseif(button == 'RightButton') then
                options.open()
            end
        end)
    end,
    ['setMinimapButtonPosition'] = function()
        local radius = 80
        local x = math.cos(math.rad(core.minimapButtonAngle)) * radius
        local y = math.sin(math.rad(core.minimapButtonAngle)) * radius
        frames.minimapButton:SetPoint('CENTER', _G['Minimap'], 'CENTER', x, y)
    end,
}

for funcName, func in pairs(interface) do
    ScootsCraft.interface[funcName] = func
end

interface = ScootsCraft.interface