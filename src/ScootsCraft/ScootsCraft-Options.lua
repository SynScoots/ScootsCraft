local core = ScootsCraft.core
local storage = ScootsCraft.storage
local options
local frames = ScootsCraft.frames
local interface = ScootsCraft.interface
local utility = ScootsCraft.utility
local lookup = ScootsCraft.lookup

options = {
    ['defaultOptions'] = {
        ['minimap-button'] = true,
        ['drag-window'] = true,
        ['recipe-list-tooltip'] = 'none',
        ['discount-summaries'] = true,
    },
    ['defaultFiltersValues'] = {
        ['search'] = '',
        ['search-include-reagents'] = false,
        ['have-materials'] = false,
        ['exclude-items-in-bags'] = false,
        ['attuneable'] = 'all',
        ['attuned-level'] = 4,
        ['section'] = nil,
        ['inv-slot'] = -1,
    },
    ['load'] = function()
        for _, skill in ipairs(lookup.professionMap) do
            local skillKey = tostring(skill.skillId)
            
            options.defaultOptions[skillKey] = {
                ['default-filters'] = {},
            }
            
            for filterKey, filterValue in pairs(options.defaultFiltersValues) do
                options.defaultOptions[skillKey]['default-filters'][filterKey] = filterValue
            end
            
            if(skill.skillId == core.skillMap.Blacksmithing
            or skill.skillId == core.skillMap.Engineering
            or skill.skillId == core.skillMap.Jewelcrafting
            or skill.skillId == core.skillMap.Leatherworking
            or skill.skillId == core.skillMap.Tailoring) then
                options.defaultOptions[skillKey]['default-filters']['exclude-items-in-bags'] = true
                options.defaultOptions[skillKey]['default-filters']['attuneable'] = 'character'
                options.defaultOptions[skillKey]['default-filters']['attuned-level'] = 0
            end
        end
        
        storage.options = storage.options or {}
        
        options.loadNestedOptions(storage.options, options.defaultOptions)
        
        for _, skill in ipairs(lookup.professionMap) do
            for key, value in pairs(storage.options[tostring(skill.skillId)]['default-filters']) do
                core.filters[skill.skillId][key] = value
            end
        end
    end,
    ['loadNestedOptions'] = function(optionsTable, defaultTable)
        for key, value in pairs(defaultTable) do
            if(type(value) == 'table') then
                if(optionsTable[key] == nil or type(optionsTable[key]) ~= 'table') then
                    optionsTable[key] = {}
                end
                
                options.loadNestedOptions(optionsTable[key], value)
            elseif(optionsTable[key] == nil) then
                optionsTable[key] = value
            end
        end
    end,
    ['get'] = function(key, sourceTable)
        if(storage == nil or storage.options == nil) then
            return nil
        end
        
        if(sourceTable == nil) then
            sourceTable = storage.options
        end
        
        if(sourceTable[key] ~= nil) then
            return sourceTable[key]
        end
        
        local nestedKey = key:match('^([^%.]+)%.')
        
        if(nestedKey and sourceTable[nestedKey] ~= nil and type(sourceTable[nestedKey]) == 'table') then
            return options.get(key:match('^[^%.]+%.(.+)$'), sourceTable[nestedKey])
        end
    end,
    ['set'] = function(key, value, applyToField, sourceTable)
        if(storage == nil or storage.options == nil) then
            return
        end
        
        if(sourceTable == nil) then
            sourceTable = storage.options
        end
        
        local nestedKey = key:match('^([^%.]+)%.')
        
        if(nestedKey) then
            if(sourceTable[nestedKey] == nil or type(sourceTable[nestedKey]) ~= 'table') then
                sourceTable[nestedKey] = {}
            end
            
            options.set(key:match('^[^%.]+%.(.+)$'), value, nil, sourceTable[nestedKey])
        else
            sourceTable[key] = value
        end
        
        if(applyToField == true and options.fieldKeys and options.fieldKeys[key]) then
            options.fieldKeys[key].applyExternalValue(value)
        end
    end,
    ['open'] = function()
        if(frames.options ~= nil) then
            InterfaceOptionsFrame_OpenToCategory(frames.options.main)
        end
    end,
    ['build'] = function()
        if(frames.options ~= nil) then
            return
        end
        
        options.optionPageDefinitions = {
            ['general'] = {
                ['framename'] = 'ScootsCraft-Options-General',
                ['title'] = 'General options',
                ['description'] = nil,
                ['callback'] = options.defineGeneralOptions,
            },
        }
        
        for _, skill in ipairs(lookup.professionMap) do
            options.optionPageDefinitions[skill.skillId] = {
                ['framename'] = 'ScootsCraft-Options-' .. skill.name,
                ['title'] = skill.name,
                ['description'] = string.format('Options only for the %s skill.', skill.name),
                ['callback'] = function(data)
                    return options.defineSkillOptions(data, skill.skillId)
                end,
            }
        end
        
        frames.options = {}
        InterfaceOptionsFrame:SetWidth(math.max(900, InterfaceOptionsFrame:GetWidth()))
        
        options.createOptionsInterface()
    end,
    ['defineGeneralOptions'] = function(data)
        local fieldList = {
            {
                ['key'] = 'minimap-button',
                ['type'] = 'checkbox',
                ['framename'] = 'MinimapToggle',
                ['label'] = 'Show minimap button',
                ['tooltip'] = table.concat({
                    'Toggle displaying the minimap button.',
                    string.format('The %s window can still be toggled with the command:', ScootsCraft.title),
                    '/scootscraft',
                }, '\n\n'),
                ['callback'] = function(pageKey, fieldKey, value)
                    if(value) then
                        if(frames.minimapButton == nil) then
                            interface.buildMinimapButton()
                        end
                        
                        frames.minimapButton:Show()
                    else
                        frames.minimapButton:Hide()
                    end
                end,
            },
            {
                ['key'] = 'drag-window',
                ['type'] = 'checkbox',
                ['framename'] = 'Draggable',
                ['label'] = 'Allow dragging the window',
                ['tooltip'] = 'With this option enabled, click and drag on the title bar to move the crafting window.',
            },
            {
                ['key'] = 'recipe-list-tooltip',
                ['type'] = 'radio',
                ['framename'] = 'RecipeListTooltip',
                ['label'] = 'Recipe list tooltip',
                ['nullValue'] = 'none',
                ['choices'] = {
                    {
                        ['name'] = 'Item',
                        ['value'] = 'item',
                    },
                    {
                        ['name'] = 'Recipe',
                        ['value'] = 'recipe',
                    },
                },
            },
            {
                ['key'] = 'discount-summaries',
                ['type'] = 'checkbox',
                ['framename'] = 'DiscountSummaries',
                ['label'] = 'Discount summaries by owned reagents',
                ['tooltip'] = 'With this option enabled, profession summaries have their counts reduced by reagents you already have.',
            },
        }
        
        for _, field in ipairs(fieldList) do
            field.framename = string.format('%s-%s', data.framename, field.framename)
        end
        
        return fieldList
    end,
    ['defineSkillOptions'] = function(data, skillId)
        local fieldList = {
            {
                ['key'] = 'default-filters',
                ['type'] = 'group',
                ['framename'] = 'DefaultFilters',
                ['label'] = 'Default filters',
                ['callback'] = function(group, header)
                    local firstField, subHeight, xOffset, yOffset = options.processOptionsFieldList({
                        ['key'] = data.key,
                        ['framename'] = data.framename,
                        ['parent'] = group,
                        ['callback'] = function()
                            local groupFieldList = {
                                {
                                    ['key'] = 'search',
                                    ['type'] = 'text',
                                    ['framename'] = 'Search',
                                    ['label'] = 'Search',
                                    ['width'] = 250,
                                },
                                {
                                    ['key'] = 'search-include-reagents',
                                    ['type'] = 'checkbox',
                                    ['framename'] = 'IncludeReagents',
                                    ['label'] = 'Include reagents',
                                },
                                {
                                    ['key'] = 'have-materials',
                                    ['type'] = 'checkbox',
                                    ['framename'] = 'HaveMaterials',
                                    ['label'] = 'Have materials',
                                },
                                {
                                    ['key'] = 'exclude-items-in-bags',
                                    ['type'] = 'checkbox',
                                    ['framename'] = 'ExcludeItemsInBags',
                                    ['label'] = 'Exclude items in bags',
                                },
                                {
                                    ['key'] = 'attuneable',
                                    ['type'] = 'radio',
                                    ['framename'] = 'Attuneable',
                                    ['label'] = 'Show equipment',
                                    ['choices'] = {
                                        {
                                            ['name'] = 'All',
                                            ['value'] = 'all',
                                        },
                                        {
                                            ['name'] = 'Attuneable (account)',
                                            ['value'] = 'account',
                                        },
                                        {
                                            ['name'] = 'Attuneable (character)',
                                            ['value'] = 'character',
                                        },
                                    },
                                },
                                {
                                    ['key'] = 'attuned-level',
                                    ['type'] = 'radio',
                                    ['framename'] = 'AttunedLevel',
                                    ['label'] = 'Attuned at',
                                    ['choices'] = {
                                        {
                                            ['name'] = 'Any',
                                            ['value'] = 4,
                                        },
                                        {
                                            ['name'] = 'Up to warforged',
                                            ['value'] = 3,
                                        },
                                        {
                                            ['name'] = 'Up to titanforged',
                                            ['value'] = 2,
                                        },
                                        {
                                            ['name'] = 'Up to baseline',
                                            ['value'] = 1,
                                        },
                                        {
                                            ['name'] = 'Unattuned only',
                                            ['value'] = 0,
                                        },
                                    },
                                },
                            }
        
                            for _, field in ipairs(groupFieldList) do
                                field.key = string.format('%d.%s.%s', skillId, 'default-filters', field.key)
                                field.framename = string.format('%s-%s', data.framename, field.framename)
                            end
                            
                            return groupFieldList
                        end,
                    })
            
                    firstField:SetPoint('TOPLEFT', header, 'BOTTOMLEFT', xOffset or 0, 0 - (10 + (yOffset or 0)))
                    
                    return subHeight
                end,
            },
        }
        
        for _, field in ipairs(fieldList) do
            field.framename = string.format('%s-%s', data.framename, field.framename)
        end
        
        return fieldList
    end,
}

for funcName, func in pairs(options) do
    ScootsCraft.options[funcName] = func
end

options = ScootsCraft.options