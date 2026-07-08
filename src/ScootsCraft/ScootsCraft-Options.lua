ScootsCraft.options = {}

ScootsCraft.options.load = function()
    local defaultOptions = {
        ['minimap-button'] = true,
        ['drag-window'] = true,
        ['recipe-list-tooltip'] = 'none',
        ['discount-summaries'] = true,
        ['default-filters'] = {
            ['search-include-reagents'] = false,
            ['have-materials'] = false,
            ['exclude-items-in-bags'] = true,
            ['attuneable'] = 'character',
            ['attuned-level'] = 0,
        },
        ['default-filter-skills'] = {
            ScootsCraft.skillMap.Blacksmithing,
            ScootsCraft.skillMap.Engineering,
            ScootsCraft.skillMap.Jewelcrafting,
            ScootsCraft.skillMap.Leatherworking,
            ScootsCraft.skillMap.Tailoring,
        },
    }
    
    ScootsCraft.storage.options = ScootsCraft.storage.options or {}
    
    local options = {}
    
    for name, defaultValue in pairs(defaultOptions) do
        if(name == 'default-filters') then
            if(ScootsCraft.storage.options['default-filters'] == nil) then
                ScootsCraft.storage.options['default-filters'] = {}
            end
        
            options['default-filters'] = {}
            for optionName, optionValue in pairs(defaultValue) do
                if(ScootsCraft.storage.options['default-filters'][optionName] ~= nil) then
                    options['default-filters'][optionName] = ScootsCraft.storage.options['default-filters'][optionName]
                else
                    options['default-filters'][optionName] = defaultOptions['default-filters'][optionName]
                end
            end
        else
            options[name] = defaultValue
            
            if(ScootsCraft.storage.options[name] ~= nil) then
                options[name] = ScootsCraft.storage.options[name]
            else
                options[name] = defaultOptions[name]
            end
        end
    end
    
    ScootsCraft.storage.options = options
    
    for _, skillId in pairs(options['default-filter-skills']) do
        ScootsCraft.filters[skillId] = {}
        
        for key, value in pairs(options['default-filters']) do
            ScootsCraft.filters[skillId][key] = value
        end
    end
end

ScootsCraft.options.get = function(optionName)
    if(ScootsCraft.storage == nil
    or ScootsCraft.storage.options == nil) then
        return nil
    end
    
    return ScootsCraft.storage.options[optionName]
end

ScootsCraft.options.set = function(optionName, optionValue)
    if(ScootsCraft.storage == nil) then
        ScootsCraft.storage = {}
    end
    
    if(ScootsCraft.storage.options == nil) then
        ScootsCraft.storage.options = {}
    end
    
    ScootsCraft.storage.options[optionName] = optionValue
end

ScootsCraft.options.open = function()
    if(ScootsCraft.frames.options ~= nil) then
        InterfaceOptionsFrame_OpenToCategory(ScootsCraft.frames.options)
    end
end

ScootsCraft.options.build = function()
    if(ScootsCraft.frames.options ~= nil) then
        return nil
    end

    ScootsCraft.frames.options = CreateFrame('Frame', 'ScootsCraft-Options', UIParent)
    ScootsCraft.frames.options.name = ScootsCraft.title
    InterfaceOptions_AddCategory(ScootsCraft.frames.options)
    
    ScootsCraft.frames.options:HookScript('OnShow', function()
        if(ScootsCraft.options.built ~= nil) then
            return nil
        end
        
        InterfaceOptionsFrame:SetWidth(math.max(900, InterfaceOptionsFrame:GetWidth()))
        
        ScootsCraft.frames.optionsScrollFrame = CreateFrame('ScrollFrame', 'ScootsCraft-Options-ScrollFrame', ScootsCraft.frames.options, 'UIPanelScrollFrameTemplate')
        ScootsCraft.frames.optionsScrollFrame:SetWidth(663)
    
        ScootsCraft.frames.optionsScrollChild = CreateFrame('Frame', 'ScootsCraft-Options-Fields-ScrollChild', ScootsCraft.frames.optionsScrollFrame)
        ScootsCraft.frames.optionsScrollChild:SetWidth(ScootsCraft.frames.optionsScrollFrame:GetWidth())
        
        local scrollBarName = ScootsCraft.frames.optionsScrollFrame:GetName()
        local scrollBar = _G[scrollBarName .. 'ScrollBar']
        local scrollUpButton = _G[scrollBarName .. 'ScrollBarScrollUpButton']
        local scrollDownButton = _G[scrollBarName .. 'ScrollBarScrollDownButton']

        scrollUpButton:ClearAllPoints()
        scrollUpButton:SetPoint('TOPRIGHT', ScootsCraft.frames.optionsScrollFrame, 'TOPRIGHT', -2, -2)

        scrollDownButton:ClearAllPoints()
        scrollDownButton:SetPoint('BOTTOMRIGHT', ScootsCraft.frames.optionsScrollFrame, 'BOTTOMRIGHT', -2, 2)

        scrollBar:ClearAllPoints()
        scrollBar:SetPoint('TOP', scrollUpButton, 'BOTTOM', 0, -2)
        scrollBar:SetPoint('BOTTOM', scrollDownButton, 'TOP', 0, 2)

        ScootsCraft.frames.optionsScrollFrame:SetScrollChild(ScootsCraft.frames.optionsScrollChild)
        ScootsCraft.frames.optionsScrollFrame:SetPoint('TOPLEFT', ScootsCraft.frames.options, 'TOPLEFT', 0, -5)
        ScootsCraft.frames.optionsScrollFrame:SetHeight(419)
        
        local height = 0
        
        --
        
        ScootsCraft.frames.optionsScrollChild.titleText = ScootsCraft.frames.optionsScrollChild:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
        ScootsCraft.frames.optionsScrollChild.titleText:SetPoint('TOPLEFT', ScootsCraft.frames.optionsScrollChild, 'TOPLEFT', 16, -10)
        ScootsCraft.frames.optionsScrollChild.titleText:SetText(ScootsCraft.title)
    
        ScootsCraft.frames.optionsScrollChild.versionText = ScootsCraft.frames.optionsScrollChild:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        ScootsCraft.frames.optionsScrollChild.versionText:SetPoint('BOTTOMLEFT', ScootsCraft.frames.optionsScrollChild.titleText, 'BOTTOMRIGHT', 5, 1)
        ScootsCraft.frames.optionsScrollChild.versionText:SetText(ScootsCraft.version)
        ScootsCraft.frames.optionsScrollChild.versionText:SetTextColor(0.6, 0.98, 0.6)
        
        height = height + ScootsCraft.frames.optionsScrollChild.titleText:GetHeight()
        
        --
        
        ScootsCraft.frames.minimapToggleOption = ScootsCraft.options.insertOptionsCheckbox({
            ['framename'] = 'ScootsCraft-Options-MinimapToggle',
            ['parent'] = ScootsCraft.frames.optionsScrollChild,
            ['prior'] = ScootsCraft.frames.optionsScrollChild.titleText,
            ['offset'] = -10,
            ['name'] = 'Show minimap button',
            ['defaultState'] = ScootsCraft.options.get('minimap-button'),
            ['tooltip'] = 'Toggle displaying the minimap button.\n\nThe ' .. ScootsCraft.title .. ' window can still be toggled with the command:\n\n/scootscraft',
            ['onClickEvent'] = function(self)
                ScootsCraft.options.set('minimap-button', (self:GetChecked() and true) or false)
                
                if(ScootsCraft.options.get('minimap-button')) then
                    if(ScootsCraft.frames.minimapButton == nil) then
                        ScootsCraft.interface.buildMinimapButton()
                    end
                    
                    ScootsCraft.frames.minimapButton:Show()
                else
                    ScootsCraft.frames.minimapButton:Hide()
                end
            end,
        })
        
        height = height + ScootsCraft.frames.minimapToggleOption:GetHeight() + 10
        
        --
        
        ScootsCraft.frames.draggableOption = ScootsCraft.options.insertOptionsCheckbox({
            ['framename'] = 'ScootsCraft-Options-Draggable',
            ['parent'] = ScootsCraft.frames.optionsScrollChild,
            ['prior'] = ScootsCraft.frames.minimapToggleOption,
            ['offset'] = -5,
            ['name'] = 'Allow dragging the window',
            ['defaultState'] = ScootsCraft.options.get('drag-window'),
            ['tooltip'] = 'With this option enabled, click and drag on the title bar to move the crafting window.',
            ['onClickEvent'] = function(self)
                ScootsCraft.options.set('drag-window', (self:GetChecked() and true) or false)
            end,
        })
        
        height = height + ScootsCraft.frames.draggableOption:GetHeight() + 5
        
        --
        
        ScootsCraft.frames.recipeListTooltipOptionItem = ScootsCraft.options.insertOptionsCheckbox({
            ['framename'] = 'ScootsCraft-Options-RecipeListTooltip-Item',
            ['parent'] = ScootsCraft.frames.optionsScrollChild,
            ['prior'] = ScootsCraft.frames.draggableOption,
            ['offset'] = -5,
            ['name'] = 'Display item tooltip on recipe list',
            ['defaultState'] = ScootsCraft.options.get('recipe-list-tooltip') == 'item',
            ['onClickEvent'] = function(self)
                ScootsCraft.options.set('recipe-list-tooltip', (self:GetChecked() and 'item') or 'none')
                
                if(self:GetChecked()) then
                    ScootsCraft.frames.recipeListTooltipOptionRecipe:SetChecked(false)
                end
            end,
        })
        
        ScootsCraft.frames.recipeListTooltipOptionRecipe = ScootsCraft.options.insertOptionsCheckbox({
            ['framename'] = 'ScootsCraft-Options-RecipeListTooltip-Recipe',
            ['parent'] = ScootsCraft.frames.optionsScrollChild,
            ['prior'] = ScootsCraft.frames.recipeListTooltipOptionItem,
            ['offset'] = 5,
            ['name'] = 'Display crafting tooltip on recipe list',
            ['defaultState'] = ScootsCraft.options.get('recipe-list-tooltip') == 'recipe',
            ['onClickEvent'] = function(self)
                ScootsCraft.options.set('recipe-list-tooltip', (self:GetChecked() and 'recipe') or 'none')
                
                if(self:GetChecked()) then
                    ScootsCraft.frames.recipeListTooltipOptionItem:SetChecked(false)
                end
            end,
        })
        
        height = height + ScootsCraft.frames.recipeListTooltipOptionItem:GetHeight() + ScootsCraft.frames.recipeListTooltipOptionRecipe:GetHeight()
        
        --
        
        ScootsCraft.frames.discountSummaryOption = ScootsCraft.options.insertOptionsCheckbox({
            ['framename'] = 'ScootsCraft-Options-DiscountSummary',
            ['parent'] = ScootsCraft.frames.optionsScrollChild,
            ['prior'] = ScootsCraft.frames.recipeListTooltipOptionRecipe,
            ['offset'] = -5,
            ['name'] = 'Discount summaries by owned reagents',
            ['defaultState'] = ScootsCraft.options.get('discount-summaries'),
            ['tooltip'] = 'With this option enabled, profession summaries have their counts reduced by reagents you already have.',
            ['onClickEvent'] = function(self)
                ScootsCraft.options.set('discount-summaries', (self:GetChecked() and true) or false)
            end,
        })
        
        height = height + ScootsCraft.frames.discountSummaryOption:GetHeight() + 5
        
        --
        
        local leftHeight
        ScootsCraft.frames.optionsDefaultFiltersGroup, leftHeight = ScootsCraft.options.insertOptionsGroup({
            ['framename'] = 'ScootsCraft-Options-DefaultFilters',
            ['parent'] = ScootsCraft.frames.optionsScrollChild,
            ['width'] = 300,
            ['title'] = 'Default filter values'
        })
        
        ScootsCraft.frames.optionsDefaultFiltersGroup:SetPoint('TOPLEFT', ScootsCraft.frames.discountSummaryOption, 'BOTTOMLEFT', 0, -10)
        
        local defaultFilters = ScootsCraft.options.get('default-filters')
        
        --
        
        ScootsCraft.frames.defaultFiltersOptionSearchIncludeReagents = ScootsCraft.options.insertOptionsCheckbox({
            ['framename'] = 'ScootsCraft-Options-DefaultFilters-SearchIncludeReagents',
            ['parent'] = ScootsCraft.frames.optionsDefaultFiltersGroup,
            ['prior'] = ScootsCraft.frames.optionsDefaultFiltersGroup.title,
            ['offset'] = -5,
            ['name'] = '(Search) Include reagents',
            ['defaultState'] = defaultFilters['search-include-reagents'],
            ['onClickEvent'] = function(self)
                defaultFilters['search-include-reagents'] = (self:GetChecked() and true) or false
                ScootsCraft.options.set('default-filters', defaultFilters)
            end,
        })
        
        leftHeight = leftHeight + ScootsCraft.frames.defaultFiltersOptionSearchIncludeReagents:GetHeight() + 5
        
        --
        
        ScootsCraft.frames.defaultFiltersOptionHaveMaterials = ScootsCraft.options.insertOptionsCheckbox({
            ['framename'] = 'ScootsCraft-Options-DefaultFilters-HaveMaterials',
            ['parent'] = ScootsCraft.frames.optionsDefaultFiltersGroup,
            ['prior'] = ScootsCraft.frames.defaultFiltersOptionSearchIncludeReagents,
            ['offset'] = -5,
            ['name'] = 'Have materials',
            ['defaultState'] = defaultFilters['have-materials'],
            ['onClickEvent'] = function(self)
                defaultFilters['have-materials'] = (self:GetChecked() and true) or false
                ScootsCraft.options.set('default-filters', defaultFilters)
            end,
        })
        
        leftHeight = leftHeight + ScootsCraft.frames.defaultFiltersOptionHaveMaterials:GetHeight() + 5
        
        --
        
        ScootsCraft.frames.defaultFiltersOptionExcludeItemsInBags = ScootsCraft.options.insertOptionsCheckbox({
            ['framename'] = 'ScootsCraft-Options-DefaultFilters-ExcludeItemsInBags',
            ['parent'] = ScootsCraft.frames.optionsDefaultFiltersGroup,
            ['prior'] = ScootsCraft.frames.defaultFiltersOptionHaveMaterials,
            ['offset'] = -5,
            ['name'] = 'Exclude items in bags',
            ['defaultState'] = defaultFilters['exclude-items-in-bags'],
            ['onClickEvent'] = function(self)
                defaultFilters['exclude-items-in-bags'] = (self:GetChecked() and true) or false
                ScootsCraft.options.set('default-filters', defaultFilters)
            end,
        })
        
        leftHeight = leftHeight + ScootsCraft.frames.defaultFiltersOptionExcludeItemsInBags:GetHeight() + 5
        
        --
        
        ScootsCraft.frames.optionsScrollChild.defaultFiltersAttuneableHeader, ScootsCraft.frames.optionsDefaultFiltersAttuneable = ScootsCraft.options.insertOptionsRadio({
            ['framenameprefix'] = 'ScootsCraft-Options-DefaultFilters-Attuneable-',
            ['parent'] = ScootsCraft.frames.optionsDefaultFiltersGroup,
            ['prior'] = ScootsCraft.frames.defaultFiltersOptionExcludeItemsInBags,
            ['offset'] = -5,
            ['internalOffset'] = 5,
            ['name'] = 'Show equipment',
            ['onClickEvent'] = function(choice)
                defaultFilters['attuneable'] = choice.value
                ScootsCraft.options.set('default-filters', defaultFilters)
            end,
            ['choices'] = {
                {
                    ['framenamesuffix'] = 'All',
                    ['name'] = 'All',
                    ['value'] = 'all',
                },
                {
                    ['framenamesuffix'] = 'Account',
                    ['name'] = 'Attuneable (account)',
                    ['value'] = 'account',
                },
                {
                    ['framenamesuffix'] = 'Character',
                    ['name'] = 'Attuneable (character)',
                    ['value'] = 'character',
                },
            },
            ['defaultState'] = defaultFilters['attuneable'],
        })
        
        leftHeight = leftHeight + ScootsCraft.frames.optionsScrollChild.defaultFiltersAttuneableHeader:GetHeight() + 5
        
        for checkboxIndex, checkbox in pairs(ScootsCraft.frames.optionsDefaultFiltersAttuneable) do
            leftHeight = leftHeight + checkbox:GetHeight()
            
            if(checkboxIndex > 1) then
                leftHeight = leftHeight - 5
            end
        end
        
        --
        
        ScootsCraft.frames.optionsScrollChild.defaultFiltersAttunedAtHeader, ScootsCraft.frames.optionsDefaultFiltersAttunedAt = ScootsCraft.options.insertOptionsRadio({
            ['framenameprefix'] = 'ScootsCraft-Options-DefaultFilters-AttunedAt-',
            ['parent'] = ScootsCraft.frames.optionsDefaultFiltersGroup,
            ['prior'] = ScootsCraft.frames.optionsDefaultFiltersAttuneable[#ScootsCraft.frames.optionsDefaultFiltersAttuneable],
            ['offset'] = -5,
            ['internalOffset'] = 5,
            ['name'] = 'Attuned at',
            ['onClickEvent'] = function(choice)
                defaultFilters['attuned-level'] = choice.value
                ScootsCraft.options.set('default-filters', defaultFilters)
            end,
            ['choices'] = {
                {
                    ['framenamesuffix'] = 'NotAttuned',
                    ['name'] = 'Unattuned',
                    ['value'] = 0,
                },
                {
                    ['framenamesuffix'] = 'Baseline',
                    ['name'] = 'Up to baseline',
                    ['value'] = 1,
                },
                {
                    ['framenamesuffix'] = 'Titanforged',
                    ['name'] = 'Up to titanforged',
                    ['value'] = 2,
                },
                {
                    ['framenamesuffix'] = 'Warforged',
                    ['name'] = 'Up to warforged',
                    ['value'] = 3,
                },
                {
                    ['framenamesuffix'] = 'Lightforged',
                    ['name'] = 'Up to lightforged',
                    ['value'] = 4,
                },
            },
            ['defaultState'] = defaultFilters['attuned-level'],
        })
        
        leftHeight = leftHeight + ScootsCraft.frames.optionsScrollChild.defaultFiltersAttunedAtHeader:GetHeight() + 5
        
        for checkboxIndex, checkbox in pairs(ScootsCraft.frames.optionsDefaultFiltersAttunedAt) do
            leftHeight = leftHeight + checkbox:GetHeight()
            
            if(checkboxIndex > 1) then
                leftHeight = leftHeight - 5
            end
        end
        
        --
        
        local rightHeight
        ScootsCraft.frames.optionsDefaultFiltersAffectGroup, rightHeight = ScootsCraft.options.insertOptionsGroup({
            ['framename'] = 'ScootsCraft-Options-DefaultFiltersAffect',
            ['parent'] = ScootsCraft.frames.optionsScrollChild,
            ['width'] = 300,
            ['title'] = 'Default filters apply to'
        })
        
        ScootsCraft.frames.optionsDefaultFiltersAffectGroup:SetPoint('TOPLEFT', ScootsCraft.frames.optionsDefaultFiltersGroup, 'TOPRIGHT', 10, 0)
        
        local defaultFilterSkills = ScootsCraft.options.get('default-filter-skills')
        
        --
        
        ScootsCraft.frames.optionsDefaultFilterSkills = {}
        local prior = ScootsCraft.frames.optionsDefaultFiltersAffectGroup.title
        
        for skillIndex, skill in ipairs(ScootsCraft.data.getProfessionMap()) do
            local checked = false
            for _, skillId in pairs(defaultFilterSkills) do
                if(skill.skillId == skillId) then
                    checked = true
                    break
                end
            end
        
            local checkbox = ScootsCraft.options.insertOptionsCheckbox({
                ['framename'] = 'ScootsCraft-Options-DefaultFiltersAffects-' .. skill.name,
                ['parent'] = ScootsCraft.frames.optionsDefaultFiltersAffectGroup,
                ['prior'] = prior,
                ['offset'] = (skillIndex == 1 and -5) or 0,
                ['name'] = skill.name,
                ['defaultState'] = checked,
                ['onClickEvent'] = function(self)
                    defaultFilterSkills = {}
                    
                    for subSkillIndex, subSkill in ipairs(ScootsCraft.data.getProfessionMap()) do
                        if(ScootsCraft.frames.optionsDefaultFilterSkills[subSkillIndex]:GetChecked()) then
                            table.insert(defaultFilterSkills, subSkill.skillId)
                        end
                    end
                    
                    ScootsCraft.options.set('default-filter-skills', defaultFilterSkills)
                end,
            })
            
            ScootsCraft.frames.optionsDefaultFilterSkills[skillIndex] = checkbox
            prior = checkbox
            
            rightHeight = rightHeight + checkbox:GetHeight() + ((skillIndex == 1 and 5) or 0)
        end
        
        --
        
        ScootsCraft.frames.optionsDefaultFiltersGroup:SetHeight(math.max(leftHeight, rightHeight))
        ScootsCraft.frames.optionsDefaultFiltersAffectGroup:SetHeight(math.max(leftHeight, rightHeight))
        
        height = height + math.max(leftHeight, rightHeight)
        
        --
    
        ScootsCraft.frames.optionsScrollChild.defaultDisclaimer = ScootsCraft.frames.optionsScrollChild:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
        ScootsCraft.frames.optionsScrollChild.defaultDisclaimer:SetPoint('TOPLEFT', ScootsCraft.frames.optionsDefaultFiltersGroup, 'BOTTOMLEFT', 0, 0)
        ScootsCraft.frames.optionsScrollChild.defaultDisclaimer:SetText('* Changes to default filter settings will apply after your next reload.' .. '\n ')
        
        height = height + ScootsCraft.frames.optionsScrollChild.defaultDisclaimer:GetHeight()
        
        --
    
        ScootsCraft.frames.optionsScrollChild:SetHeight(height)
        
        if(height <= ScootsCraft.frames.optionsScrollFrame:GetHeight()) then
            scrollBar:Hide()
        else
            scrollBar:Show()
        end
        
        ScootsCraft.options.built = true
    end)
end

ScootsCraft.options.insertOptionsGroup = function(data)
    local groupFrame = CreateFrame('Frame', data.framename, data.parent)
    
    groupFrame:SetWidth(data.width)
    groupFrame:SetBackdrop({
        bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background',
        edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {
            left = 5,
            right = 5,
            top = 5,
            bottom = 5,
        },
    })
    groupFrame:SetBackdropColor(0, 0, 0, 0.2)
    groupFrame:SetBackdropBorderColor(1, 1, 1, 0.5)
    
    groupFrame.title = groupFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    groupFrame.title:SetPoint('TOPLEFT', groupFrame, 'TOPLEFT', 10, -10)
    groupFrame.title:SetText(data.title)
    
    return groupFrame, groupFrame.title:GetHeight() + 20
end

ScootsCraft.options.insertOptionsCheckbox = function(data)
    local checkbox = CreateFrame('CheckButton', data.framename, data.parent, 'UICheckButtonTemplate')
    checkbox:SetSize(28, 28)
    checkbox:SetPoint('TOPLEFT', data.prior, 'BOTTOMLEFT', 0, data.offset)
    
    _G[checkbox:GetName() .. 'Text']:SetFontObject('GameFontNormal')
    _G[checkbox:GetName() .. 'Text']:SetText(data.name)
    _G[checkbox:GetName() .. 'Text']:ClearAllPoints()
    _G[checkbox:GetName() .. 'Text']:SetPoint('LEFT', checkbox, 'RIGHT', 0, 0)
    
    checkbox:SetHitRectInsets(0, 0 - _G[checkbox:GetName() .. 'Text']:GetWidth(), 0, 0)
    checkbox:SetChecked(data.defaultState)
    
    if(data.tooltip ~= nil) then
        checkbox:SetScript('OnEnter', function()
            GameTooltip:SetOwner(checkbox, 'ANCHOR_TOPLEFT')
            GameTooltip:SetText(data.tooltip, nil, nil, nil, nil, 1)
            GameTooltip:Show()
        end)
        
        checkbox:SetScript('OnLeave', GameTooltip_Hide)
    end
    
    checkbox:SetScript('OnClick', data.onClickEvent)
    
    return checkbox
end

ScootsCraft.options.insertOptionsRadio = function(data)
    local header = data.parent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
    header:SetPoint('TOPLEFT', data.prior, 'BOTTOMLEFT', 0, data.offset)
    header:SetJustifyH('LEFT')
    header:SetText(data.name)
    
    local prior = header
    local checkboxes = {}
    local index = 1
    for _, choice in ipairs(data.choices) do
        local offset = data.internalOffset
        if(index == 1) then
            offset = 0
        end
    
        local checkbox = ScootsCraft.options.insertOptionsCheckbox({
            ['framename'] = data.framenameprefix .. choice.framenamesuffix,
            ['parent'] = data.parent,
            ['prior'] = prior,
            ['offset'] = offset,
            ['name'] = choice.name,
            ['defaultState'] = choice.value == data.defaultState,
            ['onClickEvent'] = function(self)
                self:Disable()
            
                for _, otherCheckbox in pairs(checkboxes) do
                    if(otherCheckbox:GetName() ~= self:GetName()) then
                        otherCheckbox:SetChecked(false)
                        otherCheckbox:Enable()
                    end
                end
                
                data.onClickEvent(choice)
            end,
        })
        
        if(choice.value == data.defaultState) then
            checkbox:Disable()
        end
        
        prior = checkbox
        table.insert(checkboxes, checkbox)
        index = index + 1
    end
    
    return header, checkboxes
end