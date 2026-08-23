local core = ScootsCraft.core
local storage = ScootsCraft.storage
local options
local frames = ScootsCraft.frames
local interface = ScootsCraft.interface
local utility = ScootsCraft.utility
local lookup = ScootsCraft.lookup

options = {
    ['createOptionsInterface'] = function()
        frames.options.main = options.insertOptionsPanel({
            ['framename'] = 'ScootsCraft-Options',
            ['name'] = ScootsCraft.title,
            ['noScroll'] = true,
            ['callback'] = function(parent, prior)
                local menuArtwork = options.insertOptionsGroup({
                    ['framename'] = 'ScootsCraft-Options-MenuArtwork',
                    ['parent'] = parent,
                    ['width'] = 190,
                    ['height'] = 363,
                    ['shape'] = 'square',
                })
                
                menuArtwork:SetPoint('TOPLEFT', prior, 'BOTTOMLEFT', 0, -15)
                
                local menuScrollFrame, menuScrollChild = options.insertOptionsScrollFrame({
                    ['framename'] = 'ScootsCraft-Options-Menu',
                    ['parent'] = menuArtwork,
                    ['width'] = menuArtwork:GetWidth(),
                })
                
                menuScrollFrame:SetPoint('TOPLEFT', menuArtwork, 'TOPLEFT', 10, -10)
                menuScrollFrame:SetPoint('BOTTOMRIGHT', menuArtwork, 'BOTTOMRIGHT', -8, 8)
                
                --
                
                local contentArtwork = options.insertOptionsGroup({
                    ['framename'] = 'ScootsCraft-Options-ContentArtwork',
                    ['parent'] = parent,
                    ['width'] = 455,
                    ['height'] = menuArtwork:GetHeight(),
                    ['shape'] = 'square',
                })
                
                contentArtwork:SetPoint('TOPLEFT', menuArtwork, 'TOPRIGHT', -12, 0)
                contentArtwork:SetFrameLevel(menuArtwork:GetFrameLevel() + 1)
                
                local contentHolder = options.insertOptionsScrollFrame({
                    ['framename'] = 'ScootsCraft-Options-ContentHolder',
                    ['parent'] = contentArtwork,
                    ['noChild'] = true,
                })
                
                contentHolder:SetPoint('TOPLEFT', contentArtwork, 'TOPLEFT', 10, -10)
                contentHolder:SetPoint('BOTTOMRIGHT', contentArtwork, 'BOTTOMRIGHT', -8, 8)
                
                contentHolder.setActiveChild = function(childFrame)
                    if(contentHolder.activeChild ~= nil) then
                        contentHolder.activeChild:Hide()
                    end
                    
                    childFrame:Show()
                    contentHolder:SetScrollChild(childFrame)
                    contentHolder.activeChild = childFrame
            
                    if(childFrame:GetHeight() <= contentHolder:GetHeight()) then
                        contentHolder.scrollBar:Hide()
                    else
                        contentHolder.scrollBar:Show()
                    end
                end
                
                --
                
                frames.options.menuArtwork = menuArtwork
                frames.options.menuScrollFrame = menuScrollFrame
                frames.options.menuScrollChild = menuScrollChild
                frames.options.contentArtwork = contentArtwork
                frames.options.contentHolder = contentHolder
                
                --
                
                frames.options.menuLinks = {}
                frames.options.optionPages = {}
                
                frames.options.menuLinks = {}
                frames.options.optionPages = {}
                
                for key, data in pairs(options.optionPageDefinitions) do
                    local menuLink = options.insertMenuLink({
                        ['framename'] = data.framename .. '-MenuLink',
                        ['parent'] = menuScrollChild,
                        ['label'] = data.title or core.definedBars[key],
                        ['width'] = menuScrollChild:GetWidth() - 32,
                        ['callback'] = function(self)
                            for _, link in pairs(frames.options.menuLinks) do
                                link.select(false)
                            end
                            
                            self.select()
                            contentHolder.setActiveChild(frames.options.optionPages[key])
                        end,
                    })
                    
                    menuLink.fade(options.get(key .. '-enabled') == false)
                    frames.options.menuLinks[key] = menuLink
                    
                    --
                    
                    local optionPage = options.insertOptionsPage({
                        ['key'] = key,
                        ['framename'] = data.framename,
                        ['parent'] = contentHolder,
                        ['width'] = contentHolder:GetWidth() - contentHolder.scrollBar:GetWidth(),
                        ['title'] = data.title or core.definedBars[key],
                        ['description'] = data.description,
                        ['callback'] = data.callback,
                        ['special'] = data.special,
                    })
                    
                    frames.options.optionPages[key] = optionPage
                end
                
                frames.options.menuLinks.general.select()
                contentHolder.setActiveChild(frames.options.optionPages.general)
                options.sortMenuLinks()
            end,
        })
    end,
    ['sortMenuLinks'] = function()
        frames.options.menuLinks['general']:SetPoint('TOPLEFT', frames.options.menuScrollChild, 'TOPLEFT', 0, -8)
        local height = frames.options.menuLinks['general']:GetHeight() + 8
        
        local prevLink = frames.options.menuLinks['general']
        
        for _, skill in ipairs(lookup.professionMap) do
            local menuLink = frames.options.menuLinks[skill.skillId]
            menuLink:SetPoint('TOPLEFT', prevLink, 'BOTTOMLEFT', 0, 0)
            
            prevLink = menuLink
            height = height + menuLink:GetHeight()
        end
        
        frames.options.menuScrollChild:SetHeight(height + 8)
    end,
    ['insertOptionsPanel'] = function(data)
        local panel = CreateFrame('Frame', data.framename)
        panel.parent = data.parent
        panel.name = data.name
        InterfaceOptions_AddCategory(panel)
        
        local scrollFrame, scrollChild
        local bottomLevel = panel
        
        panel:HookScript('OnShow', function()
            if(panel.built ~= nil) then
                return
            end
            
            if(data.noScroll ~= true) then
                scrollFrame = options.insertOptionsScrollFrame({
                    ['framename'] = data.framename,
                    ['parent'] = panel,
                    ['width'] = 663,
                    ['height'] = 419,
                })
                
                scrollFrame:SetPoint('TOPLEFT', panel, 'TOPLEFT', 0, -5)
                
                bottomLevel = scrollChild
            end
            
            local height = 0
            
            --
            
            bottomLevel.titleText = bottomLevel:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
            bottomLevel.titleText:SetPoint('TOPLEFT', bottomLevel, 'TOPLEFT', 16, (data.noScroll == true and -20) or -15)
            bottomLevel.titleText:SetText(ScootsCraft.title)
        
            bottomLevel.versionText = bottomLevel:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
            bottomLevel.versionText:SetPoint('BOTTOMLEFT', bottomLevel.titleText, 'BOTTOMRIGHT', 5, 1)
            bottomLevel.versionText:SetText(ScootsCraft.version)
            bottomLevel.versionText:SetTextColor(0.6, 0.98, 0.6)
            
            height = height + bottomLevel.titleText:GetHeight()
            local prior = bottomLevel.titleText
            
            --
            
            if(data.subTitle) then
                bottomLevel.subTitleText = bottomLevel:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
                bottomLevel.subTitleText:SetPoint('TOPLEFT', bottomLevel.titleText, 'BOTTOMLEFT', 0, -2)
                bottomLevel.subTitleText:SetText(data.subTitle)
                
                height = height + bottomLevel.subTitleText:GetHeight() + 2
                prior = bottomLevel.subTitleText
            end
            
            --
            
            local childHeights = data.callback(bottomLevel, prior)
            
            height = height + (childHeights or 0) + 35 + ((data.noScroll == true and 5) or 0)
            
            --
        
            bottomLevel:SetHeight(height)
            
            if(data.noScroll ~= true) then
                if(height <= scrollFrame:GetHeight()) then
                    scrollBar:Hide()
                else
                    scrollBar:Show()
                end
            end
            
            panel.built = true
        end)
        
        return panel, scrollFrame, scrollChild
    end,
    ['insertMenuLink'] = function(data)
        local link = CreateFrame('Button', data.framename .. '-MenuLink', data.parent)
        link:SetSize(data.width or data.parent:GetWidth(), data.height or 20)
        
        link.selected = false
        link.faded = false
        
        link.label = link:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
        link.label:SetPoint('LEFT', link, 'LEFT', 10, 1)
        link.label:SetText(data.label)
        
        link.highlight = link:CreateTexture(nil, 'ARTWORK')
        link.highlight:SetAllPoints()
        link.highlight:SetTexture('Interface\\QuestFrame\\UI-QuestLogTitleHighlight')
        link.highlight:SetBlendMode('ADD')
        link.highlight:Hide()
        
        link.select = function(state)
            local colour
            
            if(state ~= false) then
                link.highlight:SetVertexColor(0.196, 0.388, 0.8, 1)
                link.highlight:Show()
                
                colour = HIGHLIGHT_FONT_COLOR
                link.selected = true
            else
                link.highlight:Hide()
                
                colour = link.faded and {['r'] = 0.7, ['g'] = 0.7, ['b'] = 0.8} or NORMAL_FONT_COLOR
                link.selected = false
            end
            
            link.label:SetTextColor(colour.r, colour.g, colour.b)
        end
        
        link.fade = function(state)
            link.faded = state ~= false
            link.select(link.selected)
        end
        
        if(data.callback) then
            link:SetScript('OnClick', data.callback)
        end
        
        link:SetScript('OnEnter', function(self)
            if(not self.selected) then
                self.highlight:SetVertexColor(1, 1, 1, 0.4)
                self.highlight:Show()
            end
        end)
        
        link:SetScript('OnLeave', function(self)
            if(not self.selected) then
                self.highlight:Hide()
            end
        end)
        
        return link
    end,
    ['insertOptionsPage'] = function(data)
        local page = CreateFrame('Frame', data.framename .. '-OptionsPage', data.parent)
        page:SetWidth(data.width)
        page:Hide()
        
        page:SetScript('OnShow', function(self)
            self.title = self:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
            self.title:SetPoint('TOPLEFT', self, 'TOPLEFT', 10, -10)
            self.title:SetText(data.title)
            
            local height = self.title:GetHeight() + 10
            local prev = self.title
            
            if(data.description) then
                self.description = self:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
                self.description:SetPoint('TOPLEFT', prev, 'BOTTOMLEFT', 0, 0)
                self.description:SetWidth(data.width - 20)
                self.description:SetJustifyH('LEFT')
                self.description:SetWordWrap(true)
                self.description:SetText(data.description)
                
                height = height + self.description:GetHeight()
                prev = self.description
            end
            
            frames.options[data.key] = {}
            local firstField, subHeight, xOffset, yOffset = options.processOptionsFieldList({
                ['key'] = data.key,
                ['framename'] = data.framename,
                ['parent'] = self,
                ['callback'] = data.callback,
            })
            
            firstField:SetPoint('TOPLEFT', prev, 'BOTTOMLEFT', xOffset or 0, 0 - (10 + (yOffset or 0)))
            height = height + subHeight + 10
            
            self:SetHeight(height)
            
            self:SetScript('OnShow', nil)
        end)
        
        return page
    end,
    ['processOptionsFieldList'] = function(pageData)
        local fieldList = pageData.callback({
            ['key'] = pageData.key,
            ['framename'] = pageData.framename,
        })
        
        local field, firstField, prev, prevType
        local height = 0
        local xOffsetPrev = 0
        local yOffsetNext = 0
        local xOffsetNext = 0
        local exportXOffset = 0
        local exportYOffset = 0
        
        options.fieldKeys = options.fieldKeys or {}
        
        for _, fieldData in pairs(fieldList) do
            local xOffset = 0
            local yOffset = 0
            local addLabel = false
            local spacing = 10
            
            if(yOffsetNext > 0) then
                yOffset = yOffsetNext
                yOffsetNext = 0
            end
            
            field, addLabel, xOffset, yOffsetNext = options.processOptionField(pageData, fieldData)
            
            if(fieldData.type == 'range-slider'
            or fieldData.type == 'choice-slider') then
                if(prevType == 'dropdown') then
                    yOffset = 0
                end
            end
            
            height = height + field:GetHeight()
                
            if(addLabel) then
                height = height + field.label:GetHeight()
            end
            
            if(firstField == nil) then
                firstField = field
                exportXOffset = xOffset
                xOffsetNext = xOffset
                
                if(addLabel) then
                    exportYOffset = field.label:GetHeight()
                end
            else
                field:SetPoint('TOPLEFT', prev, 'BOTTOMLEFT', (xOffset - xOffsetPrev) - xOffsetNext, 0 - (spacing + yOffset))
                height = height + spacing + yOffset
                
                if(addLabel) then
                    field:SetPoint('TOPLEFT', prev, 'BOTTOMLEFT', (xOffset - xOffsetPrev) - xOffsetNext, 0 - (spacing + field.label:GetHeight() + yOffset))
                end
                
                xOffsetPrev = xOffset
                xOffsetNext = 0
            end
            
            options.fieldKeys[fieldData.key] = field
            frames.options[pageData.key][fieldData.key] = field
            prev = field
            prevType = fieldData.type
            addLabel = false
        end
        
        height = height + yOffsetNext + 20
        
        return firstField, height, exportXOffset, exportYOffset
    end,
    ['processOptionField'] = function(pageData, fieldData)
        local field
        local addLabel = false
        local xOffset, yOffsetNext = 0, 0
        
        if(fieldData.type == 'checkbox') then
            field = options.processOptionCheckbox(pageData, fieldData)
        elseif(fieldData.type == 'radio') then
            field = options.processOptionRadio(pageData, fieldData)
        elseif(fieldData.type == 'colour') then
            field = options.processOptionColour(pageData, fieldData)
        elseif(fieldData.type == 'text') then
            field = options.processOptionText(pageData, fieldData)
        elseif(fieldData.type == 'reset-text') then
            field = options.processOptionResetText(pageData, fieldData)
        elseif(fieldData.type == 'increment-text') then
            field = options.processOptionIncrementText(pageData, fieldData)
        elseif(fieldData.type == 'button') then
            field = options.processOptionButton(pageData, fieldData)
        elseif(fieldData.type == 'dropdown') then
            field = options.processOptionDropdown(pageData, fieldData)
        elseif(fieldData.type == 'range-slider') then
            field = options.processOptionRangeSlider(pageData, fieldData)
        elseif(fieldData.type == 'choice-slider') then
            field = options.processOptionChoiceSlider(pageData, fieldData)
        elseif(fieldData.type == 'currency-picker') then
            field = options.processOptionCurrencyPicker(pageData, fieldData)
        elseif(fieldData.type == 'item-picker') then
            field = options.processOptionItemPicker(pageData, fieldData)
        elseif(fieldData.type == 'group') then
            field = options.processOptionGroup(pageData, fieldData)
        end
        
        if(fieldData.type == 'reorder-buttons'
        or fieldData.type == 'text'
        or fieldData.type == 'reset-text'
        or fieldData.type == 'increment-text'
        or fieldData.type == 'dropdown'
        or fieldData.type == 'range-slider'
        or fieldData.type == 'choice-slider') then
            addLabel = ((fieldData.label or '') ~= '')
        end
        
        if(fieldData.type == 'range-slider'
        or fieldData.type == 'choice-slider') then
            xOffset = 5
        elseif(fieldData.type == 'increment-text') then
            xOffset = (fieldData.height or 20) + 1
        end
        
        if(fieldData.type == 'range-slider') then
            yOffsetNext = field.textbox:GetHeight() + (select(4, field.lowText:GetPoint()))
        elseif(fieldData.type == 'choice-slider') then
            yOffsetNext = field.currentText:GetHeight() + (select(4, field.lowText:GetPoint()))
        end
        
        return field, addLabel, xOffset, yOffsetNext
    end,
    ----
    ['processOptionCheckbox'] = function(pageData, fieldData)
        return options.insertOptionsCheckbox({
            ['framename'] = fieldData.framename,
            ['parent'] = pageData.parent,
            ['label'] = fieldData.label,
            ['defaultState'] = options.get(fieldData.key),
            ['tooltip'] = fieldData.tooltip,
            ['tooltipExtra'] = fieldData.tooltipExtra,
            ['callback'] = function(self, value)
                options.set(fieldData.key, value)
            
                if(fieldData.callback) then
                    fieldData.callback(pageData.key, fieldData.key, value)
                end
            end,
        })
    end,
    ['processOptionRadio'] = function(pageData, fieldData)
        return options.insertOptionsRadio({
            ['label'] = fieldData.label,
            ['framename'] = fieldData.framename,
            ['parent'] = pageData.parent,
            ['defaultValue'] = options.get(fieldData.key),
            ['choices'] = fieldData.choices,
            ['nullValue'] = fieldData.nullValue,
            ['callback'] = function(self, value)
                options.set(fieldData.key, value)
                
                if(fieldData.callback) then
                    fieldData.callback(pageData.key, fieldData.key, value)
                end
            end,
        })
    end,
    ['processOptionColour'] = function(pageData, fieldData)
        return options.insertOptionsColourPicker({
            ['framename'] = fieldData.framename,
            ['parent'] = pageData.parent,
            ['text'] = fieldData.text,
            ['tooltip'] = fieldData.tooltip,
            ['tooltipExtra'] = fieldData.tooltipExtra,
            ['colour'] = function()
                return options.get(fieldData.key)
            end,
            ['callback'] = function(self, r, g, b, a)
                local value = {['r'] = r, ['g'] = g, ['b'] = b, ['a'] = a}
                options.set(fieldData.key, value)
            
                if(fieldData.callback) then
                    fieldData.callback(pageData.key, fieldData.key, value)
                end
            end,
        })
    end,
    ['processOptionText'] = function(pageData, fieldData)
        return options.insertOptionsTextField({
            ['framename'] = fieldData.framename,
            ['parent'] = pageData.parent,
            ['label'] = fieldData.label,
            ['tooltip'] = fieldData.tooltip,
            ['tooltipExtra'] = fieldData.tooltipExtra,
            ['default'] = options.get(fieldData.key),
            ['numeric'] = fieldData.numeric,
            ['width'] = fieldData.width,
            ['callback'] = function(self, value)
                options.set(fieldData.key, value)
            
                if(fieldData.callback) then
                    fieldData.callback(pageData.key, fieldData.key, value)
                end
            end,
        })
    end,
    ['processOptionResetText'] = function(pageData, fieldData)
        return options.insertOptionsResetTextField({
            ['framename'] = fieldData.framename,
            ['parent'] = pageData.parent,
            ['label'] = fieldData.label,
            ['tooltip'] = fieldData.tooltip,
            ['tooltipExtra'] = fieldData.tooltipExtra,
            ['default'] = options.get(fieldData.key),
            ['resetText'] = fieldData.resetText,
            ['resetValue'] = fieldData.resetValue,
            ['width'] = fieldData.width,
            ['callback'] = function(self, value)
                options.set(fieldData.key, value)
            
                if(fieldData.callback) then
                    fieldData.callback(pageData.key, fieldData.key, value)
                end
            end,
        })
    end,
    ['processOptionIncrementText'] = function(pageData, fieldData)
        return options.insertOptionsIncrementTextField({
            ['framename'] = fieldData.framename,
            ['parent'] = pageData.parent,
            ['label'] = fieldData.label,
            ['width'] = fieldData.width or 100,
            ['height'] = fieldData.height or 20,
            ['justify'] = fieldData.justify or 'CENTER',
            ['increment'] = fieldData.increment,
            ['min'] = fieldData.min,
            ['max'] = fieldData.max,
            ['tooltip'] = fieldData.tooltip,
            ['tooltipExtra'] = fieldData.tooltipExtra,
            ['resetText'] = fieldData.resetText,
            ['resetCallback'] = fieldData.resetCallback,
            ['default'] = options.get(fieldData.key),
            ['callback'] = function(self, value)
                options.set(fieldData.key, value)
            
                if(fieldData.callback) then
                    fieldData.callback(pageData.key, fieldData.key, value)
                end
            end,
        })
    end,
    ['processOptionButton'] = function(pageData, fieldData)
        return options.insertOptionsButton({
            ['framename'] = fieldData.framename,
            ['parent'] = pageData.parent,
            ['width'] = fieldData.width or 100,
            ['height'] = fieldData.height or 20,
            ['text'] = fieldData.text,
            ['tooltip'] = fieldData.tooltip,
            ['callback'] = fieldData.callback,
        })
    end,
    ['processOptionDropdown'] = function(pageData, fieldData)
        return options.insertOptionsDropdown({
            ['framename'] = fieldData.framename,
            ['parent'] = pageData.parent,
            ['width'] = fieldData.width,
            ['choices'] = fieldData.choices,
            ['defaultValue'] = options.get(fieldData.key),
            ['label'] = fieldData.label,
            ['tooltip'] = fieldData.tooltip,
            ['tooltipExtra'] = fieldData.tooltipExtra,
            ['callback'] = function(self, value)
                options.set(fieldData.key, value)
            
                if(fieldData.callback) then
                    fieldData.callback(pageData.key, fieldData.key, value)
                end
            end,
        })
    end,
    ['processOptionRangeSlider'] = function(pageData, fieldData)
        return options.insertOptionsRangeSlider({
            ['framename'] = fieldData.framename,
            ['parent'] = pageData.parent,
            ['width'] = fieldData.width,
            ['height'] = fieldData.height,
            ['defaultValue'] = options.get(fieldData.key),
            ['label'] = fieldData.label,
            ['increment'] = fieldData.increment,
            ['min'] = fieldData.min,
            ['max'] = fieldData.max,
            ['hideMinMax'] = fieldData.hideMinMax,
            ['tooltip'] = fieldData.tooltip,
            ['tooltipExtra'] = fieldData.tooltipExtra,
            ['callbackWhileDragging'] = fieldData.callbackWhileDragging,
            ['callback'] = function(self, value)
                value = tonumber(value)
                
                if(value ~= options.get(fieldData.key)) then
                    options.set(fieldData.key, value)
            
                    if(fieldData.callback) then
                        fieldData.callback(pageData.key, fieldData.key, value)
                    end
                end
            end,
        })
    end,
    ['processOptionChoiceSlider'] = function(pageData, fieldData)
        return options.insertOptionsChoiceSlider({
            ['framename'] = fieldData.framename,
            ['parent'] = pageData.parent,
            ['width'] = fieldData.width,
            ['height'] = fieldData.height,
            ['choices'] = fieldData.choices,
            ['defaultValue'] = options.get(fieldData.key),
            ['label'] = fieldData.label,
            ['tooltip'] = fieldData.tooltip,
            ['tooltipExtra'] = fieldData.tooltipExtra,
            ['callbackWhileDragging'] = fieldData.callbackWhileDragging,
            ['callback'] = function(self, value)
                options.set(fieldData.key, value)
            
                if(fieldData.callback) then
                    fieldData.callback(pageData.key, fieldData.key, value)
                end
            end,
        })
    end,
    ['processOptionCurrencyPicker'] = function(pageData, fieldData)
        return options.insertOptionsCurrencyPicker({
            ['framename'] = fieldData.framename,
            ['parent'] = pageData.parent,
            ['label'] = fieldData.label,
            ['selected'] = options.get(fieldData.key),
            ['callback'] = function(self, value)
                options.set(fieldData.key, value)
            
                if(fieldData.callback) then
                    fieldData.callback(pageData.key, fieldData.key, value)
                end
            end,
        })
    end,
    ['processOptionItemPicker'] = function(pageData, fieldData)
        return options.insertOptionsItemPicker({
            ['framename'] = fieldData.framename,
            ['parent'] = pageData.parent,
            ['label'] = fieldData.label,
            ['selected'] = options.get(fieldData.key),
            ['callback'] = function(self, value)
                options.set(fieldData.key, value)
            
                if(fieldData.callback) then
                    fieldData.callback(pageData.key, fieldData.key, value)
                end
            end,
        })
    end,
    ['processOptionGroup'] = function(pageData, fieldData)
        return options.insertOptionsGroup({
            ['framename'] = fieldData.framename,
            ['parent'] = pageData.parent,
            ['label'] = fieldData.label,
            ['width'] = fieldData.width or 400,
            ['height'] = fieldData.height,
            ['shape'] = fieldData.shape,
            ['callback'] = fieldData.callback
        })
    end,
    ----
    ['insertOptionsGroup'] = function(data)
        local group = CreateFrame('Frame', data.framename, data.parent)
        group:SetWidth(data.width)
        
        if(data.shape ~= 'none') then
            if(data.shape == 'square') then
                group:SetBackdrop({
                    ['bgFile'] = 'Interface\\DialogFrame\\UI-DialogBox-Background-Dark',
                    ['edgeFile'] = 'Interface\\DialogFrame\\UI-DialogBox-Border',
                    ['edgeSize'] = 32,
                    ['insets'] = {
                        ['top'] = 12,
                        ['right'] = 12,
                        ['bottom'] = 9,
                        ['left'] = 11,
                    },
                })
            else
                group:SetBackdrop({
                    ['bgFile'] = 'Interface\\Tooltips\\UI-Tooltip-Background',
                    ['edgeFile'] = 'Interface\\Tooltips\\UI-Tooltip-Border',
                    ['tile'] = true,
                    ['tileSize'] = 16,
                    ['edgeSize'] = 16,
                    ['insets'] = {
                        ['top'] = 5,
                        ['right'] = 5,
                        ['bottom'] = 5,
                        ['left'] = 5,
                    },
                })

                group:SetBackdropColor(0, 0, 0, 0.2)
                group:SetBackdropBorderColor(1, 1, 1, 0.5)
            end
        end
        
        local height = 0
        
        if(data.label) then
            local fromLeft = 10
            local fromTop = 10
            
            if(data.shape == 'none') then
                fromLeft = 0
                fromTop = 0
            end
        
            group.label = group:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
            group.label:SetPoint('TOPLEFT', group, 'TOPLEFT', fromLeft, 0 - fromTop)
            group.label:SetWidth(group:GetWidth() - (fromLeft * 2))
            group.label:SetJustifyH('LEFT')
            group.label:SetWordWrap(true)
            group.label:SetText(data.label)
            
            height = height + group.label:GetHeight() + fromTop
        end
        
        if(data.callback ~= nil) then
            height = height + (data.callback(group, group.label) or 0)
            group:SetHeight(height)
        elseif(data.height ~= nil) then
            group:SetHeight(data.height)
        end
        
        return group
    end,
    ['insertOptionsScrollFrame'] = function(data)
        local scrollFrame = CreateFrame('ScrollFrame', data.framename .. '-ScrollFrame', data.parent, 'UIPanelScrollFrameTemplate')
        local scrollChild

        if(data.width) then
            scrollFrame:SetWidth(data.width)
        end
        
        if(data.height) then
            scrollFrame:SetHeight(data.height)
        end
        
        local scrollBarName = scrollFrame:GetName()
        scrollFrame.scrollBar = _G[scrollBarName .. 'ScrollBar']
        scrollFrame.scrollUpButton = _G[scrollBarName .. 'ScrollBarScrollUpButton']
        scrollFrame.scrollDownButton = _G[scrollBarName .. 'ScrollBarScrollDownButton']

        scrollFrame.scrollUpButton:ClearAllPoints()
        scrollFrame.scrollUpButton:SetPoint('TOPRIGHT', scrollFrame, 'TOPRIGHT', -2, -2)

        scrollFrame.scrollDownButton:ClearAllPoints()
        scrollFrame.scrollDownButton:SetPoint('BOTTOMRIGHT', scrollFrame, 'BOTTOMRIGHT', -2, 2)

        scrollFrame.scrollBar:ClearAllPoints()
        scrollFrame.scrollBar:SetPoint('TOP', scrollFrame.scrollUpButton, 'BOTTOM', 0, -2)
        scrollFrame.scrollBar:SetPoint('BOTTOM', scrollFrame.scrollDownButton, 'TOP', 0, 2)
        
        if(data.noChild ~= true) then
            scrollChild = CreateFrame('Frame', data.framename .. '-ScrollChild', scrollFrame)
            
            if(data.width) then
                scrollChild:SetWidth(data.width)
            end

            scrollFrame:SetScrollChild(scrollChild)
        end
        
        return scrollFrame, scrollChild
    end,
    ['insertOptionsCheckbox'] = function(data)
        local checkbox = CreateFrame('CheckButton', data.framename, data.parent, 'OptionsCheckButtonTemplate')
        checkbox:SetSize(17, 17)
        
        checkbox.label = _G[checkbox:GetName() .. 'Text']
        
        checkbox.label:SetFontObject('GameFontHighlightSmall')
        checkbox.label:SetText(data.label)
        checkbox.label:ClearAllPoints()
        checkbox.label:SetPoint('LEFT', checkbox, 'RIGHT', 3, 1)
        
        checkbox:SetHitRectInsets(0, 0 - (checkbox.label:GetWidth() + 3), 0, 0)
        checkbox:SetChecked(data.defaultState)
        
        for _, texture in pairs({
            checkbox:GetNormalTexture(),
            checkbox:GetPushedTexture(),
            checkbox:GetCheckedTexture(),
            checkbox:GetHighlightTexture(),
            checkbox:GetDisabledTexture(),
            checkbox:GetDisabledCheckedTexture(),
        }) do
            texture:SetTexCoord(0.14, 0.84, 0.17, 0.8)
        end
        
        options.applyFieldTooltip({
            ['field'] = checkbox,
            ['tooltip'] = data.tooltip,
            ['tooltipExtra'] = data.tooltipExtra,
        })
        
        checkbox:SetScript('OnClick', function(self)
            data.callback(self, (self:GetChecked() and true) or false)
        end)
        
        checkbox.applyExternalValue = function(value)
            checkbox:SetChecked(value == true)
        end
        
        return checkbox
    end,
    ['insertOptionsRadio'] = function(data)
        local holder = options.insertOptionsGroup({
            ['framename'] = data.framename,
            ['parent'] = data.parent,
            ['shape'] = 'none',
            ['label'] = data.label,
            ['width'] = 400,
            ['callback'] = function(group, header)
                local prev
                local groupHeight = 0
                group.checkboxes = {}
                
                for index, choice in ipairs(data.choices) do
                    local checkbox = options.insertOptionsCheckbox({
                        ['framename'] = data.framename .. '-Choice-' .. tostring(index),
                        ['parent'] = data.parent,
                        ['label'] = choice.name,
                        ['defaultState'] = choice.value == data.defaultValue,
                        ['tooltip'] = choice.tooltip,
                        ['tooltipExtra'] = choice.tooltipExtra,
                        ['callback'] = function(self, value)
                            if(data.nullValue == nil) then
                                self:Disable()
                                self:GetPushedTexture():Hide()
                                self:GetNormalTexture():Show()
                            end
                        
                            for _, otherCheckbox in pairs(group.checkboxes) do
                                if(otherCheckbox:GetName() ~= self:GetName()) then
                                    otherCheckbox:SetChecked(false)
                                    otherCheckbox:Enable()
                                end
                            end
                            
                            if(data.nullValue == nil or value) then
                                data.callback(group, choice.value)
                            else
                                data.callback(group, data.nullValue)
                            end
                        end,
                    })
                    
                    if(data.nullValue == nil and choice.value == data.defaultValue) then
                        checkbox:Disable()
                    end
                    
                    if(prev == nil) then
                        if(header) then
                            checkbox:SetPoint('TOPLEFT', header, 'BOTTOMLEFT', 0, -1)
                            groupHeight = groupHeight + 1
                        else
                            checkbox:SetPoint('TOPLEFT', group, 'TOPLEFT', 0, 0)
                        end
                    else
                        checkbox:SetPoint('TOPLEFT', prev, 'BOTTOMLEFT', 0, -1)
                        groupHeight = groupHeight + 1
                    end
                    
                    groupHeight = groupHeight + checkbox:GetHeight()
                    
                    prev = checkbox
                    table.insert(group.checkboxes, checkbox)
                end
                
                group.applyExternalValue = function(value)
                    for choiceIndex, choice in pairs(data.choices) do
                        if(choice.value == value) then
                            for checkboxIndex, checkbox in ipairs(group.checkboxes) do
                                if(checkboxIndex == choiceIndex) then
                                    checkbox:SetChecked(true)
                                    checkbox:Disable()
                                else
                                    checkbox:SetChecked(false)
                                    checkbox:Enable()
                                end
                            end
                            
                            break
                        end
                    end
                end
                
                return groupHeight
            end,
        })
        
        return holder
    end,
    ['insertOptionsButton'] = function(data)
        local button = CreateFrame('Button', data.framename, data.parent, 'UIPanelButtonTemplate')
        button:SetSize(data.width or 130, data.height or 19)
        button:SetText(data.text)
        
        button:SetNormalFontObject('GameFontNormalSmall')
        button:SetHighlightFontObject('GameFontHighlightSmall')
        button:SetDisabledFontObject('GameFontNormalSmall')
        
        button:SetScript('OnClick', data.callback)
        
        options.applyFieldTooltip({
            ['field'] = button,
            ['tooltip'] = data.tooltip,
            ['tooltipExtra'] = data.tooltipExtra,
        })
        
        button.applyExternalValue = function() end
        
        return button
    end,
    ['insertOptionsReorderButtons'] = function(data)
        local buttonDown, buttonUp
    
        data.reorderButtonsSetOrder = function(adjust)
            local current = options.get(data.key .. '-order')
            
            if(adjust == 0) then
                if(current == #core.barOrder) then
                    buttonDown:Disable()
                else
                    buttonDown:Enable()
                end
            
                if(current == 1) then
                    buttonUp:Disable()
                else
                    buttonUp:Enable()
                end
                
                return
            end
            
            if(adjust == -1 and current == 1) then
                return
            end
            
            if(adjust == 1 and current == #core.barOrder) then
                return
            end
            
            local found = false
            
            local currentIndex
            for index = 1, #core.barOrder do
                if(core.barOrder[index].key == data.key) then
                    currentIndex = index
                    break
                end
            end
            
            core.barOrder[currentIndex].order = core.barOrder[currentIndex].order + adjust
            options.set(core.barOrder[currentIndex].key .. '-order', core.barOrder[currentIndex].order)
            
            core.barOrder[currentIndex + adjust].order = core.barOrder[currentIndex + adjust].order - adjust
            options.set(core.barOrder[currentIndex + adjust].key .. '-order', core.barOrder[currentIndex + adjust].order)
            
            table.sort(core.barOrder, function(barA, barB)
                return barA.order < barB.order
            end)
            
            data.callback()
            
            options.sortMenuLinks()
            data.reorderButtonsSetOrder(0)
        end
        
        --
        
        buttonDown = CreateFrame('Button', data.framename .. '-OrderUp', data.parent)
        buttonDown:SetSize(data.size or 24, data.size or 24)
        
        buttonDown:SetNormalTexture('Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up')
        buttonDown:SetPushedTexture('Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Down')
        buttonDown:SetDisabledTexture('Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Disabled')
        buttonDown:SetHighlightTexture('Interface\\Buttons\\UI-Common-MouseHilight', 'ADD')
        
        if(data.label) then
            buttonDown.label = buttonDown:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
            buttonDown.label:SetPoint('BOTTOMLEFT', buttonDown, 'TOPLEFT', 0, 0)
            buttonDown.label:SetText(data.label)
        end
        
        buttonDown:SetScript('OnClick', function()
            data.reorderButtonsSetOrder(1)
        end)
    
        --
        
        buttonUp = CreateFrame('Button', data.framename .. '-OrderUp', data.parent)
        buttonUp:SetSize(data.size or 24, data.size or 24)
        buttonUp:SetPoint('LEFT', buttonDown, 'RIGHT', 5, 0)
        
        buttonUp:SetNormalTexture('Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Up')
        buttonUp:SetPushedTexture('Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Down')
        buttonUp:SetDisabledTexture('Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Disabled')
        buttonUp:SetHighlightTexture('Interface\\Buttons\\UI-Common-MouseHilight', 'ADD')
        
        buttonUp:SetScript('OnClick', function()
            data.reorderButtonsSetOrder(-1)
        end)
        
        --
        
        for _, texture in pairs({
            buttonDown:GetNormalTexture(),
            buttonDown:GetPushedTexture(),
            buttonDown:GetDisabledTexture(),
            buttonDown:GetHighlightTexture(),
            buttonUp:GetNormalTexture(),
            buttonUp:GetPushedTexture(),
            buttonUp:GetDisabledTexture(),
            buttonUp:GetHighlightTexture(),
        }) do
            texture:ClearAllPoints()
            texture:SetAllPoints()
            texture:SetTexCoord(0.15, 0.85, 0.15, 0.85)
        end
        
        data.parent:HookScript('OnShow', function()
            data.reorderButtonsSetOrder(0)
        end)
        
        data.reorderButtonsSetOrder(0)
        
        buttonDown.applyExternalValue = function() end
        
        return buttonDown
    end,
    ['insertOptionsTextField'] = function(data)
        local textbox = CreateFrame('EditBox', data.framename, data.parent)
        textbox:SetSize(data.width or 150, data.height or 19)
        textbox:SetAutoFocus(false)
        textbox:SetFontObject('GameFontHighlightSmall')
        textbox:SetJustifyH(data.justify or 'LEFT')
        textbox:SetTextInsets(5, 5, 0, 0)
        textbox:SetText(data.default or '')
        
        if(data.maxChars) then
            textbox:SetMaxLetters(data.maxChars)
        end

        if(data.label) then
            textbox.label = textbox:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
            textbox.label:SetPoint('BOTTOMLEFT', textbox, 'TOPLEFT', 0, 0)
            textbox.label:SetJustifyH(data.justify or 'LEFT')
            textbox.label:SetText(data.label)
        end
        
        textbox:SetScript('OnEnterPressed', EditBox_ClearFocus)
        textbox:SetScript('OnEscapePressed', EditBox_ClearFocus)
        textbox:SetScript('OnEditFocusGained', function()
            EditBox_HighlightText(textbox)
        end)
        
        textbox:HookScript('OnShow', function(self)
            self.preventCallback = true
        end)
        
        textbox.preventCallback = true
        textbox:SetScript('OnTextChanged', function(self)
            if(textbox.preventCallback) then
                textbox.preventCallback = nil
                return
            end
        
            data.callback(self, textbox:GetText())
        end)
        
        options.applyFieldTooltip({
            ['field'] = textbox,
            ['tooltip'] = data.tooltip,
            ['tooltipExtra'] = data.tooltipExtra,
        })
        
        textbox.bgLeft = textbox:CreateTexture(nil, 'BACKGROUND')
        textbox.bgLeft:SetTexture('Interface\\Common\\Common-Input-Border')
        textbox.bgLeft:SetSize(8, 19)
        textbox.bgLeft:SetPoint('LEFT', textbox, 'LEFT', 0, 0)
        textbox.bgLeft:SetTexCoord(0, 0.0625, 0, 0.625)
        
        textbox.bgRight = textbox:CreateTexture(nil, 'BACKGROUND')
        textbox.bgRight:SetTexture('Interface\\Common\\Common-Input-Border')
        textbox.bgRight:SetSize(8, 19)
        textbox.bgRight:SetPoint('RIGHT', textbox, 'RIGHT', 0, 0)
        textbox.bgRight:SetTexCoord(0.9375, 1.0, 0, 0.625)
        
        textbox.bgMiddle = textbox:CreateTexture(nil, 'BACKGROUND')
        textbox.bgMiddle:SetTexture('Interface\\Common\\Common-Input-Border')
        textbox.bgMiddle:SetSize(10, 19)
        textbox.bgMiddle:SetPoint('LEFT', textbox.bgLeft, 'RIGHT', 0, 0)
        textbox.bgMiddle:SetPoint('RIGHT', textbox.bgRight, 'LEFT', 0, 0)
        textbox.bgMiddle:SetTexCoord(0.0625, 0.9375, 0, 0.625)
        
        textbox.applyExternalValue = function(value)
            textbox.preventCallback = true
            textbox:SetText(value)
        end
        
        return textbox
    end,
    ['insertOptionsResetTextField'] = function(data)
        data.height = data.height or 19
    
        local textbox = options.insertOptionsTextField({
            ['framename'] = data.framename,
            ['parent'] = data.parent,
            ['width'] = data.width,
            ['height'] = data.height,
            ['label'] = data.label,
            ['justify'] = data.justify,
            ['tooltip'] = data.tooltip,
            ['tooltipExtra'] = data.tooltipExtra,
            ['default'] = data.default,
            ['callback'] = data.callback
        })
        
        local button = options.insertOptionsButton({
            ['framename'] = data.framename .. '-Button',
            ['parent'] = data.parent,
            ['width'] = data.buttonWidth or 100,
            ['height'] = data.height,
            ['text'] = data.resetText,
            ['callback'] = function()
                textbox:SetText(data.resetValue)
            end,
        })
        
        button:SetPoint('LEFT', textbox, 'RIGHT', 0, 0)
        
        return textbox
    end,
    ['insertOptionsIncrementTextField'] = function(data)
        data.increment = data.increment or 1
        data.height = data.height or 19
        
        local decimals = 0
        local incrementTest = data.increment
        
        while incrementTest < 1 do
            decimals = decimals + 1
            incrementTest = incrementTest * 10
        end
        
        local stringFormat = '%.' .. tostring(decimals) .. 'f'
    
        local textbox = options.insertOptionsTextField({
            ['framename'] = data.framename,
            ['parent'] = data.parent,
            ['label'] = data.label,
            ['width'] = data.width,
            ['height'] = data.height,
            ['justify'] = data.justify or 'CENTER',
            ['tooltip'] = data.tooltip,
            ['tooltipExtra'] = data.tooltipExtra,
            ['default'] = string.format(stringFormat, data.default or data.min or 0),
        })

        if(data.label) then
            textbox.label:SetPoint('BOTTOMLEFT', textbox, 'TOPLEFT', 0 - ((data.height or 19) + 1), 0)
        end
        
        textbox.currentValue = data.default or data.min or 0
        
        if(decimals == 0 and data.min and data.min >= 0) then
            textbox:SetNumeric(true)
        end
        
        --
        
        local incrementDown = CreateFrame('Button', data.framename .. '-IncrementDown', data.parent)
        incrementDown:SetSize(data.height, data.height)
        incrementDown:SetPoint('RIGHT', textbox, 'LEFT', 1, 0)
        
        incrementDown:SetNormalTexture('Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up')
        incrementDown:SetPushedTexture('Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down')
        incrementDown:SetDisabledTexture('Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled')
        incrementDown:SetHighlightTexture('Interface\\Buttons\\UI-Common-MouseHilight', 'ADD')
        
        incrementDown:SetScript('OnClick', function()
            textbox.currentValue = string.format(stringFormat, tonumber(textbox.currentValue) - data.increment)
            textbox:SetText(textbox.currentValue)
        end)
        
        textbox.incrementDown = incrementDown
        
        if(data.tooltip) then
            incrementDown:HookScript('OnEnter', textbox:GetScript('OnEnter'))
            incrementDown:HookScript('OnLeave', textbox:GetScript('OnLeave'))
        end
        
        --
        
        local incrementUp = CreateFrame('Button', data.framename .. '-IncrementUp', data.parent)
        incrementUp:SetSize(data.height, data.height)
        incrementUp:SetPoint('LEFT', textbox, 'RIGHT', -1, 0)
        
        incrementUp:SetNormalTexture('Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up')
        incrementUp:SetPushedTexture('Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down')
        incrementUp:SetDisabledTexture('Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled')
        incrementUp:SetHighlightTexture('Interface\\Buttons\\UI-Common-MouseHilight', 'ADD')
        
        incrementUp:SetScript('OnClick', function()
            textbox.currentValue = string.format(stringFormat, tonumber(textbox.currentValue) + data.increment)
            textbox:SetText(textbox.currentValue)
        end)
        
        textbox.incrementUp = incrementUp
        
        if(data.tooltip) then
            incrementUp:HookScript('OnEnter', textbox:GetScript('OnEnter'))
            incrementUp:HookScript('OnLeave', textbox:GetScript('OnLeave'))
        end
        
        --
        
        textbox.preventCallback = true
        textbox:SetScript('OnTextChanged', function(self)
            if(textbox.preventCallback) then
                textbox.preventCallback = nil
                return
            end
            
            if(self:GetText():match('%.$')) then
                return
            end
            
            textbox.changeEvent(self)
        end)
        
        textbox:SetScript('OnEditFocusLost', function(self)
            textbox.changeEvent(self, true)
        end)
        
        textbox.changeEvent = function(self, forceChange)
            local value, hasChanged = textbox.sanitiseValue(self:GetText())
            local onTextChanged = self:GetScript('OnTextChanged')
        
            if(hasChanged == false) then
                if(not self:HasFocus() or forceChange == true) then
                    self:SetScript('OnTextChanged', nil)
                    self:SetText(textbox.currentValue)
                    self:SetScript('OnTextChanged', onTextChanged)
                end
                
                return
            end
            
            textbox.currentValue = value
            
            if(not self:HasFocus() or forceChange == true) then
                self:SetScript('OnTextChanged', nil)
                self:SetText(value)
                self:SetScript('OnTextChanged', onTextChanged)
            end
            
            if(self.preventCallback == true) then
                self.preventCallback = nil
            else
                data.callback(self, tonumber(value))
            end
        end
        
        textbox.sanitiseValue = function(value)
            if(value == '') then
                return currentValue, false
            end
            
            value = tonumber((tostring(value):gsub('[^0-9.\-]', ''))) or data.default or data.min or 0
            
            if(value == 0) then
                value = 0 -- Convert negative 0
            end
            
            if(data.min) then
                if(value <= data.min) then
                    value = data.min
                    incrementDown:Disable()
                else
                    incrementDown:Enable()
                end
            end
            
            if(data.max) then
                if(value >= data.max) then
                    value = data.max
                    incrementUp:Disable()
                else
                    incrementUp:Enable()
                end
            end
            
            value = string.format(stringFormat, value)
            if(value == currentValue) then
                return value, false
            end
            
            return value, true
        end
        
        --
        
        if(data.resetText and data.resetCallback) then
            local button = options.insertOptionsButton({
                ['framename'] = data.framename .. '-Reset',
                ['parent'] = data.parent,
                ['width'] = 100,
                ['height'] = data.height,
                ['text'] = data.resetText,
                ['callback'] = function()
                    textbox:SetText(string.format(stringFormat, data.resetCallback()))
                end,
            })
            
            button:SetPoint('LEFT', incrementUp, 'RIGHT', 0, 0)
            
            textbox.reset = button
        end
        
        --
        
        textbox.applyExternalValue = function(value)
            textbox.preventCallback = true
            textbox:SetText(textbox.sanitiseValue(value))
        end
        
        textbox:SetText(textbox:GetText() or 0)
        textbox.sanitiseValue(textbox.currentValue)
        
        return textbox
    end,
    ['insertOptionsColourPicker'] = function(data)
        local button
        local colour = data.colour()
        
        button = options.insertOptionsButton({
            ['framename'] = data.framename,
            ['parent'] = data.parent,
            ['width'] = data.width,
            ['height'] = data.height,
            ['text'] = data.text,
            ['tooltip'] = data.tooltip,
            ['tooltipExtra'] = data.tooltipExtra,
            ['callback'] = function()
                button.suppressCallback = true
                
                colour = data.colour()
                
                local currentColourString = string.format('%.2f-%.2f-%.2f-%.2f', colour.r, colour.g, colour.b, colour.a)
            
                ColorPickerFrame.hasOpacity = true
                ColorPickerFrame.opacity = 1 - colour.a

                ColorPickerFrame.previousValues = {
                    ['r'] = colour.r,
                    ['g'] = colour.g,
                    ['b'] = colour.b,
                    ['a'] = colour.a,
                }
                
                ColorPickerFrame.func = function()
                    if(button.suppressCallback) then
                        button.suppressCallback = false
                        return
                    end
                    
                    local r, g, b = ColorPickerFrame:GetColorRGB()
                    local a = 1 - OpacitySliderFrame:GetValue()
                    
                    local testColourString = string.format('%.2f-%.2f-%.2f-%.2f', r, g, b, a)
                    
                    if(currentColourString == testColourString) then
                        return
                    end
                    
                    currentColourString = testColourString
                    
                    button.preview:SetTexture(r, g, b, a)
                    data.callback(button, r, g, b, a)
                end
                
                ColorPickerFrame.opacityFunc = ColorPickerFrame.func
                
                ColorPickerFrame.cancelFunc = function(previousValues)
                    local r = previousValues.r
                    local g = previousValues.g
                    local b = previousValues.b
                    local a = previousValues.a
                    
                    currentColourString = string.format('%.2f-%.2f-%.2f-%.2f', r, g, b, a)
                    
                    button.preview:SetTexture(r, g, b, a)
                    data.callback(button, r, g, b, a)
                    button.suppressCallback = true
                end
            
                ColorPickerFrame:SetColorRGB(colour.r, colour.g, colour.b)
                
                local colourPickerStrata = ColorPickerFrame:GetFrameStrata()
                
                button.runShowHook = true
                button.runHideHook = true
                
                if(button.addedHooks ~= true) then
                    ColorPickerFrame:HookScript('OnShow', function()
                        if(button.runShowHook) then
                            button.suppressCallback = true
                            ColorPickerFrame:SetFrameStrata('TOOLTIP')
                            button.runShowHook = nil
                        end
                    end)
                    
                    ColorPickerFrame:HookScript('OnHide', function()
                        if(button.runHideHook) then
                            button.suppressCallback = true
                            ColorPickerFrame:SetFrameStrata(colourPickerStrata)
                            button.runHideHook = nil
                        end
                    end)
                    
                    button.addedHooks = true
                end
            
                ShowUIPanel(ColorPickerFrame)
            end,
        })
        
        button.previewBorder = button:CreateTexture(nil, 'BORDER')
        button.previewBorder:SetPoint('TOPLEFT', button, 'TOPRIGHT', 3, -3)
        button.previewBorder:SetSize(button:GetHeight() - 6, button:GetHeight() - 6)
        button.previewBorder:SetTexture(1, 1, 1, 1)
        
        button.previewBackground = button:CreateTexture(nil, 'ARTWORK')
        button.previewBackground:SetPoint('TOPLEFT', button.previewBorder, 'TOPLEFT', 1, -1)
        button.previewBackground:SetPoint('BOTTOMRIGHT', button.previewBorder, 'BOTTOMRIGHT', -1, 1)
        button.previewBackground:SetTexture('Interface\\AddOns\\ScootsCraft\\Textures\\ColourPicker-Background', true)
        button.previewBackground:SetHorizTile(true)
        button.previewBackground:SetVertTile(true)
        
        button.preview = button:CreateTexture(nil, 'OVERLAY')
        button.preview:SetPoint('TOPLEFT', button.previewBackground, 'TOPLEFT', 0, 0)
        button.preview:SetPoint('BOTTOMRIGHT', button.previewBackground, 'BOTTOMRIGHT', 0, 0)
        button.preview:SetTexture(colour.r, colour.g, colour.b, colour.a)
        
        button:SetHitRectInsets(0, 0 - (button.previewBackground:GetWidth() + 3), 0, 0)
        
        button.applyExternalValue = function(value)
            button.preview:SetTexture(value.r, value.g, value.b, value.a)
        end
        
        return button
    end,
    ['insertOptionsDropdown'] = function(data)
        local dropdown = CreateFrame('Frame', data.framename, data.parent, 'UIDropDownMenuTemplate')
        
        if(data.label) then
            dropdown.label = dropdown:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
            dropdown.label:SetPoint('BOTTOMLEFT', dropdown, 'TOPLEFT', 0, 0)
            dropdown.label:SetJustifyH(data.justify or 'LEFT')
            dropdown.label:SetText(data.label)
        end
        
        dropdown.text = _G[dropdown:GetName() .. 'Text']
        dropdown.bgLeft = _G[dropdown:GetName() .. 'Left']
        dropdown.bgMiddle = _G[dropdown:GetName() .. 'Middle']
        dropdown.bgRight = _G[dropdown:GetName() .. 'Right']
        dropdown.button = _G[dropdown:GetName() .. 'Button']
        
        dropdown.bgLeft:ClearAllPoints()
        dropdown.bgLeft:SetPoint('TOPLEFT', dropdown, 'TOPLEFT', -18, 18)
        
        dropdown.text:ClearAllPoints()
        dropdown.text:SetPoint('TOPLEFT', dropdown, 'TOPLEFT', 8, -7)
        
        dropdown.button:ClearAllPoints()
        dropdown.button:SetPoint('RIGHT', dropdown.bgMiddle, 'RIGHT', 4, 2)
        dropdown.button:SetSize(18, 18)
        
        for _, texture in pairs({
            dropdown.button:GetNormalTexture(),
            dropdown.button:GetPushedTexture(),
            dropdown.button:GetDisabledTexture(),
            dropdown.button:GetHighlightTexture(),
        }) do
            texture:ClearAllPoints()
            texture:SetAllPoints()
            texture:SetSize(0, 0)
            texture:SetTexCoord(0.12, 0.86, 0.12, 0.86)
        end
        
        local choiceCallback = type(data.choices) == 'function' and data.choices or function() return data.choices end
        
        dropdown.refresh = function(defaultValue)
            local choiceWidth = 0
            local selectedIndex
            
            defaultValue = defaultValue or data.defaultValue
            
            for index, choice in ipairs(choiceCallback()) do
                if(choice.value == defaultValue) then
                    selectedIndex = index
                end
                
                dropdown.text:SetText(choice.name)
                choiceWidth = math.max(choiceWidth, dropdown.text:GetWidth())
            end
            
            dropdown.text:SetText(choiceCallback()[selectedIndex].name)
        
            local midWidth = math.max(data.width or 0, 1 + choiceWidth + dropdown.button:GetWidth())
            dropdown.bgMiddle:SetWidth(midWidth)
            dropdown:SetSize(7 + midWidth + 8, 26)
            
            dropdown.button:SetHitRectInsets(0 - (choiceWidth + 11), -4, -3, -3)
            
            UIDropDownMenu_Initialize(dropdown, function(self, level)
                local info = UIDropDownMenu_CreateInfo()
                
                for index, choice in ipairs(choiceCallback()) do
                    info.text = choice.name
                    info.func = function()
                        dropdown.text:SetText(choice.name)
                        data.callback(self, choice.value)
                    end
                    
                    UIDropDownMenu_AddButton(info, level)
                end
            end)
        end
        
        local old_UIDropDownMenu_InitializeHelper = UIDropDownMenu_InitializeHelper
        UIDropDownMenu_InitializeHelper = function(self)
            old_UIDropDownMenu_InitializeHelper(self)
            
            if(self == dropdown) then
                self:SetHeight(26)
            end
        end
        
        dropdown.refresh()
        
        options.applyFieldTooltip({
            ['field'] = dropdown.button,
            ['tooltip'] = data.tooltip,
            ['tooltipExtra'] = data.tooltipExtra,
        })
        
        dropdown.applyExternalValue = function(value)
            for _, choice in ipairs(data.choices) do
                if(choice.value == value) then
                    dropdown.text:SetText(choice.name)
                    break
                end
            end
        end
        
        return dropdown
    end,
    ['insertOptionsSlider'] = function(data)
        local slider = CreateFrame('Slider', data.framename, data.parent, 'OptionsSliderTemplate')
        slider.isDragging = false
        slider.lastValue = data.defaultValue or 0
        
        slider:SetSize(data.width or 150, data.height or 18)
        slider:SetMinMaxValues(data.min, data.max)
        slider:SetValueStep(data.increment or 1)
        slider:SetValue(data.defaultValue or 0)
        
        slider.label = _G[slider:GetName() .. 'Text']
        slider.lowText = _G[slider:GetName() .. 'Low']
        slider.highText = _G[slider:GetName() .. 'High']
        
        slider.label:SetText(data.label)
        slider.label:SetFontObject('GameFontHighlightSmall')
        slider.label:ClearAllPoints()
        slider.label:SetPoint('BOTTOMLEFT', slider, 'TOPLEFT', -4, 0)
        
        slider.lowText:SetText((data.hideMinMax and '') or tostring(data.min))
        slider.highText:SetText((data.hideMinMax and '') or tostring(data.max))
        
        if(data.hideCurrentValue ~= true) then
            slider.currentText = slider:CreateFontString(slider:GetName() .. 'Current', 'OVERLAY', 'GameFontNormalSmall')
            slider.currentText:SetPoint('TOPLEFT', slider.lowText, 'TOPRIGHT', 0, 0)
            slider.currentText:SetPoint('TOPRIGHT', slider.highText, 'TOPLEFT', 0, 0)
            slider.currentText:SetJustifyH('CENTER')
        end
        
        slider:SetScript('OnValueChanged', function(self, value)
            self.isDragging = true
            
            if(data.hideCurrentValue ~= true) then
                self.currentText:SetText(value)
            end
            
            if(data.callbackWhileDragging == true) then
                local value = self:GetValue()
                
                if(self.lastValue ~= value) then
                    data.callback(self, value)
                    self.lastValue = value
                end
            end
        end)
        
        UIParent:HookScript('OnUpdate', function()
            if(slider.isDragging and not IsMouseButtonDown()) then
                slider.isDragging = false
                
                if(data.callbackWhileDragging ~= true and slider.preventCallback ~= true) then
                    local value = slider:GetValue()
                    
                    if(slider.lastValue ~= value) then
                        data.callback(slider, value)
                        slider.lastValue = value
                    end
                end
            end
        end)
        
        options.applyFieldTooltip({
            ['field'] = slider,
            ['tooltip'] = data.tooltip,
            ['tooltipExtra'] = data.tooltipExtra,
        })
        
        slider.applyExternalValue = function(value)
            local callbackWhileDragging = data.callbackWhileDragging
            
            data.callbackWhileDragging = false
            slider.preventCallback = true
            
            slider:SetValue(value)
            
            data.callbackWhileDragging = callbackWhileDragging
        end
        
        return slider
    end,
    ['insertOptionsRangeSlider'] = function(data)
        local slider, textbox
    
        slider = options.insertOptionsSlider({
            ['framename'] = data.framename .. '-Slider',
            ['parent'] = data.parent,
            ['width'] = data.width,
            ['height'] = data.height,
            ['defaultValue'] = data.defaultValue,
            ['hideCurrentValue'] = true,
            ['label'] = data.label,
            ['increment'] = data.increment,
            ['min'] = data.min,
            ['max'] = data.max,
            ['hideMinMax'] = data.hideMinMax,
            ['callbackWhileDragging'] = data.callbackWhileDragging,
            ['callback'] = function(self, value)
                value = textbox.sanitiseValue(value)
                
                textbox:SetText(value)
                
                data.callback(self, value)
            end,
            ['tooltip'] = data.tooltip,
            ['tooltipExtra'] = data.tooltipExtra,
        })
        
        textbox = options.insertOptionsIncrementTextField({
            ['framename'] = data.framename .. '-IncrementTextbox',
            ['parent'] = data.parent,
            ['width'] = 60,
            ['height'] = data.height,
            ['justify'] = 'CENTER',
            ['default'] = data.defaultValue,
            ['increment'] = data.increment,
            ['min'] = data.min,
            ['max'] = data.max,
            ['callback'] = function(self, value)
                if(slider.isDragging ~= true or data.callbackWhileDragging == true) then
                    if(slider.lastValue ~= value) then
                        slider.lastValue = value
                        data.callback(slider, value)
                        slider:SetValue(value)
                    end
                end
            end,
            ['tooltip'] = data.tooltip,
            ['tooltipExtra'] = data.tooltipExtra,
        })
        
        textbox:SetFrameLevel(slider:GetFrameLevel() + 1)
        textbox.incrementUp:SetFrameLevel(slider:GetFrameLevel() + 1)
        textbox.incrementDown:SetFrameLevel(slider:GetFrameLevel() + 1)
        textbox:SetPoint('TOPLEFT', slider.lowText, 'TOPLEFT', (slider:GetWidth() / 2) - (textbox:GetWidth() / 2), 0)
        
        slider:SetScript('OnValueChanged', function(self, value)
            if(changeFromTextbox) then
                changeFromTextbox = nil
            else
                textbox:SetText(value)
                self.isDragging = true
            end
        end)
        
        slider.textbox = textbox
        
        return slider
    end,
    ['insertOptionsChoiceSlider'] = function(data)
        local defaultValue = 1
        local valueMap = {}
        
        for index, choice in ipairs(data.choices) do
            if(data.choices[index].value == data.defaultValue) then
                defaultValue = index
            end
            
            valueMap[choice.value] = index
        end
    
        local slider = options.insertOptionsSlider({
            ['framename'] = data.framename,
            ['parent'] = data.parent,
            ['width'] = data.width,
            ['height'] = data.height,
            ['defaultValue'] = defaultValue,
            ['label'] = data.label,
            ['increment'] = 1,
            ['min'] = 1,
            ['max'] = #data.choices,
            ['hideMinMax'] = true,
            ['callbackWhileDragging'] = data.callbackWhileDragging,
            ['callback'] = function(self, value)
                data.callback(self, data.choices[value].value)
            end,
            ['tooltip'] = data.tooltip,
            ['tooltipExtra'] = data.tooltipExtra,
        })
        
        slider.currentText:SetText(data.choices[defaultValue].name)
        
        slider:SetScript('OnValueChanged', function(self, value)
            local value = self:GetValue()
            
            if(self.lastValue ~= value) then
                self.currentText:SetText(data.choices[value].name)
                data.callback(self, data.choices[value].value)
                self.lastValue = value
            end
        end)
        
        slider.applyExternalValue = function(value)
            local callbackWhileDragging = data.callbackWhileDragging
            
            data.callbackWhileDragging = false
            slider.preventCallback = true
            
            slider:SetValue(valueMap[value])
            slider.currentText:SetText(data.choices[valueMap[value]].name)
            
            data.callbackWhileDragging = callbackWhileDragging
        end
        
        return slider
    end,
    ['insertOptionsCurrencyPicker'] = function(data)
        data.width = data.width or 400
        
        local picker = options.insertOptionsGroup({
            ['framename'] = data.framename,
            ['parent'] = data.parent,
            ['label'] = data.label,
            ['width'] = data.width,
            ['callback'] = function(group, header)
                local currencyList, currentCurrencyIndex
                local height = 10
                group.lastValue = data.selected
                
                group.currentItem = options.insertOptionsClearableItem({
                    ['framename'] = data.framename .. '-CurrentItem',
                    ['parent'] = group,
                    ['clearText'] = 'Clear currency',
                    ['item'] = nil,
                    ['callback'] = function(self)
                        group.listFrame.selectedItemId = nil
                        group.listFrame.updateView()
                        
                        if(group.lastValue ~= nil) then
                            data.callback(group, nil)
                            group.lastValue = nil
                        end
                    end,
                })
                
                if(not header) then
                    group.currentItem:SetPoint('TOPRIGHT', group, 'TOPRIGHT', -10, -10)
                    height = height + group.currentItem:GetHeight() + 20
                else
                    group.currentItem:SetPoint('TOPRIGHT', group, 'TOPRIGHT', -10, -10 + ((group.currentItem:GetHeight() - header:GetHeight()) / 2))
                end
                
                --
            
                group.listFrame = options.insertOptionsListFrame({
                    ['framename'] = data.framename .. '-FauxScroller',
                    ['parent'] = group,
                    ['height'] = 100,
                    ['childCount'] = 6,
                    ['getItemsCallback'] = function()
                        currencyList = {
                            {
                                ['id'] = '_GOLD',
                                ['name'] = GOLD_AMOUNT:gsub('%s*%%d%s*', ''),
                                ['texture'] = 'Interface\\Icons\\INV_Misc_Coin_01',
                                ['rarity'] = 1,
                            },
                        }

                        for currencyIndex = 1, GetCurrencyListSize() do
                            local name, isHeader, _, isUnused, _, _, currencyType, texture, itemId = GetCurrencyListInfo(currencyIndex)
                            
                            if(not isHeader) then
                                local currency = {
                                    ['id'] = itemId,
                                    ['name'] = name,
                                    ['texture'] = texture,
                                    ['rarity'] = (select(3, GetItemInfoCustom(itemId)))
                                }
                                
                                if(currencyType == 1) then
                                    currency['texture'] = 'Interface\\PVPFrame\\PVP-ArenaPoints-Icon'
                                elseif(currencyType == 2) then
                                    if(UnitFactionGroup('player') == 'Alliance') then
                                        currency['texture'] = 'Interface\\PVPFrame\\PVP-Currency-Alliance'
                                    else
                                        currency['texture'] = 'Interface\\PVPFrame\\PVP-Currency-Horde'
                                    end
                                end
                                
                                table.insert(currencyList, currency)
                            end
                        end
                        
                        table.sort(currencyList, function(itemA, itemB)
                            if(itemA.id == '_GOLD') then
                                return true
                            elseif(itemB.id == '_GOLD') then
                                return false
                            end
                            
                            return itemA.name < itemB.name
                        end)
                        
                        return currencyList
                    end,
                    ['selectItemCallback'] = function(self, currencyIndex)
                        group.currentItem.setItem(currencyList[currencyIndex])
                        
                        if(currencyList[currencyIndex]) then
                            if(group.lastValue ~= currencyList[currencyIndex].id) then
                                data.callback(self, currencyList[currencyIndex].id)
                                group.lastValue = currencyList[currencyIndex].id
                            end
                        else
                            if(group.lastValue ~= nil) then
                                data.callback(self, nil)
                                group.lastValue = nil
                            end
                        end
                    end,
                })
                
                --
                
                if(header) then
                    group.listFrame:SetPoint('TOPLEFT', header, 'BOTTOMLEFT', 0, -11)
                else
                    group.listFrame:SetPoint('TOPLEFT', group, 'TOPLEFT', 10, -11)
                end
                
                group.listFrame:SetScript('OnEvent', function(self, event)
                    self.dataChanged()
                end)
                
                group.listFrame:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
                
                group.listFrame:SetScript('OnShow', function(self)
                    self.updateView()
                end)
                
                group.listFrame.selectedItemId = data.selected
                group.listFrame.dataChanged()
                
                group.listFrame.applySelectedItemId = function()
                    for _, currency in ipairs(currencyList) do
                        if(currency.id == group.listFrame.selectedItemId) then
                            group.currentItem.setItem(currency)
                            break
                        end
                    end
                end
                
                group.listFrame.applySelectedItemId()
                
                height = height + group.listFrame:GetHeight() + 2 + 10
        
                group.applyExternalValue = function(value)
                    group.listFrame.selectedItemId = value
                    group.listFrame.dataChanged()
                    group.listFrame.applySelectedItemId()
                end
                
                return height
            end,
        })
        
        return picker
    end,
    ['insertOptionsItemPicker'] = function(data)
        data.width = data.width or 400
    
        local picker = options.insertOptionsGroup({
            ['framename'] = data.framename,
            ['parent'] = data.parent,
            ['width'] = data.width,
            ['label'] = data.label,
            ['callback'] = function(group, header)
                local currentItemDisplay, catcher, textbox
                local height = 10
                group.lastItem = data.selected
                
                --
                
                data.lookupItem = function(itemId)
                    itemId = tonumber(itemId)
                    
                    if(itemId) then
                        local itemName, _, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfoCustom(itemId)
                    
                        if(itemName) then
                            return {
                                ['id'] = itemId,
                                ['name'] = itemName,
                                ['texture'] = itemTexture,
                                ['rarity'] = itemRarity,
                            }
                        end
                    end
                end
                
                --
                
                local item = data.lookupItem(data.selected)
                
                currentItemDisplay = options.insertOptionsClearableItem({
                    ['framename'] = data.framename .. '-CurrentItem',
                    ['parent'] = group,
                    ['clearText'] = 'Clear item',
                    ['item'] = item,
                    ['callback'] = function(self)
                        item = nil
                        textbox.preventCallback = true
                        textbox:SetText('')
                        
                        if(group.lastItem ~= nil) then
                            data.callback(group, nil)
                            group.lastItem = nil
                        end
                    end,
                })
                
                if(header) then
                    currentItemDisplay:SetPoint('TOPRIGHT', group, 'TOPRIGHT', -10, -10 + ((currentItemDisplay:GetHeight() - header:GetHeight()) / 2))
                else
                    currentItemDisplay:SetPoint('TOPRIGHT', group, 'TOPRIGHT', -10, -10)
                    height = height + currentItemDisplay:GetHeight() + 20
                end
                
                --
        
                group.orText = group:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
                group.orText:SetText('Or')
                
                --
                
                catcher = options.insertOptionsItemCatcher({
                    ['framename'] = data.framename .. '-ItemCatcher',
                    ['parent'] = group,
                    ['width'] = ((data.width - (40 + group.orText:GetWidth())) / 2) - 2,
                    ['text'] = 'Drop item here',
                    ['callback'] = function(self, itemId)
                        item = data.lookupItem(itemId)
                        
                        if(item) then
                            currentItemDisplay.setItem(item)
                            textbox:SetText(tostring(item.id))
                        else
                            currentItemDisplay.setItem(nil)
                            textbox:SetText('')
                        end
                    end,
                })
                
                height = height + catcher:GetHeight()
                
                catcher:SetPoint('TOPLEFT', group, 'TOPLEFT', 11, 0 - ((header and header:GetHeight() + 20) or currentItemDisplay:GetHeight() + 20))
                
                group.orText:SetPoint('LEFT', catcher, 'RIGHT', 11, 0)
                
                --
                
                textbox = options.insertOptionsTextField({
                    ['framename'] = data.framename .. '-Textbox',
                    ['parent'] = group,
                    ['label'] = 'Enter item ID',
                    ['width'] = catcher:GetWidth() + 2,
                    ['justify'] = 'LEFT',
                    ['default'] = (item and item.id and tostring(item.id)) or '',
                    ['callback'] = function(self, itemId)
                        item = data.lookupItem(itemId)
                        
                        if(item) then
                            currentItemDisplay.setItem(item)
                            
                            if(group.lastItem ~= item.id) then
                                data.callback(group, item.id)
                                group.lastItem = item.id
                            end
                        else
                            currentItemDisplay.setItem(nil)
                            
                            if(group.lastItem ~= nil) then
                                data.callback(group, nil)
                                group.lastItem = nil
                            end
                        end
                    end,
                })
                
                textbox:SetPoint('LEFT', group.orText, 'RIGHT', 10, 0 - (textbox.label:GetHeight() / 2))
                textbox:SetNumeric(true)
                textbox:SetScript('OnEditFocusLost', textbox:GetScript('OnTextChanged'))
                
                --
                
                group.currentItem = currentItemDisplay
                group.catcher = catcher
                group.textbox = textbox
                
                group.applyExternalValue = function(value)
                    item = data.lookupItem(value)
                        
                    if(item) then
                        currentItemDisplay.setItem(item)
                        textbox:SetText(tostring(item.id))
                    else
                        currentItemDisplay.setItem(nil)
                        textbox:SetText('')
                    end
                end
                
                return height + 10
            end,
        })
        
        return picker
    end,
    ['insertOptionsListFrame'] = function(data)
        local listFrame = CreateFrame('ScrollFrame', data.framename, data.parent, 'FauxScrollFrameTemplate')
        
        listFrame:SetSize(data.parent:GetWidth() - 43, data.height)
        
        for _, borderName in pairs({'borderTop', 'borderRight', 'borderBottom', 'borderLeft'}) do
            listFrame[borderName] = listFrame:CreateTexture(nil, 'BORDER')
            listFrame[borderName]:SetTexture(0.5, 0.75, 1, 0.2)
        end
        
        listFrame.borderTop:SetPoint('TOPLEFT', listFrame, 'TOPLEFT', 0, 1)
        listFrame.borderTop:SetPoint('TOPRIGHT', listFrame, 'TOPRIGHT', 23, 1)
        listFrame.borderTop:SetHeight(1)
        
        listFrame.borderRight:SetPoint('TOPRIGHT', listFrame.borderTop, 'BOTTOMRIGHT', 0, 0)
        listFrame.borderRight:SetPoint('BOTTOMRIGHT', listFrame.borderBottom, 'TOPRIGHT', 0, 0)
        listFrame.borderRight:SetWidth(1)
        
        listFrame.borderBottom:SetPoint('BOTTOMLEFT', listFrame, 'BOTTOMLEFT', 0, -1)
        listFrame.borderBottom:SetPoint('BOTTOMRIGHT', listFrame, 'BOTTOMRIGHT', 23, -1)
        listFrame.borderBottom:SetHeight(1)
        
        listFrame.borderLeft:SetPoint('TOPLEFT', listFrame.borderTop, 'BOTTOMLEFT', 0, 0)
        listFrame.borderLeft:SetPoint('BOTTOMLEFT', listFrame.borderBottom, 'TOPLEFT', 0, 0)
        listFrame.borderLeft:SetWidth(1)
        
        local childHeight = data.height / data.childCount
        
        listFrame:SetScript('OnVerticalScroll', function(self, offset)
            FauxScrollFrame_OnVerticalScroll(self, offset, childHeight, listFrame.updateView)
        end)
        
        listFrame.childFrames = {}
        for frameIndex = 1, data.childCount do
            local childFrame = CreateFrame('Button', data.framename .. '-Child' .. tostring(frameIndex), listFrame)
            childFrame:SetSize(listFrame:GetWidth(), childHeight)
            childFrame:SetPoint('TOPLEFT', listFrame, 'TOPLEFT', 1, 0 - (childHeight * (frameIndex - 1)))
            childFrame:EnableMouse(true)
            
            childFrame.highlight = childFrame:CreateTexture(nil, 'BACKGROUND')
            childFrame.highlight:SetAllPoints()
            childFrame.highlight:SetTexture(0.25, 0.5, 1, 0.4)
            childFrame.highlight:SetAlpha(0)
            
            childFrame.selected = childFrame:CreateTexture(nil, 'ARTWORK')
            childFrame.selected:SetAllPoints()
            childFrame.selected:SetTexture(1, 1, 1, 0.2)
            childFrame.selected:SetAlpha(0)
            
            childFrame.icon = childFrame:CreateTexture(nil, 'OVERLAY')
            childFrame.icon:SetSize(childHeight - 4, childHeight - 4)
            childFrame.icon:SetPoint('TOPLEFT', 2, -2)
        
            childFrame.text = childFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
            childFrame.text:SetPoint('LEFT', 20, 0)
            childFrame.text:SetJustifyH('LEFT')
            
            childFrame:SetScript('OnEnter', function()
                if((childFrame.itemId or 0) ~= 0) then
                    childFrame.highlight:SetAlpha(1)
                    
                    if(tostring(childFrame.itemId):match('^%d+$')) then
                        GameTooltip:SetOwner(childFrame, 'ANCHOR_CURSOR_RIGHT')
                        GameTooltip:SetHyperlink(select(2, GetItemInfoCustom(childFrame.itemId)))
                        GameTooltip:Show()
                    end
                end
            end)
            
            childFrame:SetScript('OnLeave', function()
                childFrame.highlight:SetAlpha(0)
                GameTooltip_Hide(childFrame)
            end)
            
            childFrame:SetScript('OnClick', function()
                listFrame.selectedItemId = childFrame.itemId
                listFrame.updateView()
                data.selectItemCallback(listFrame, childFrame.itemIndex)
            end)
            
            table.insert(listFrame.childFrames, childFrame)
        end
        
        listFrame.updateView = function()
            local itemList = data.getItemsCallback()
            local offset = FauxScrollFrame_GetOffset(listFrame)
            
            for childIndex = 1, data.childCount do
                local childFrame = listFrame.childFrames[childIndex]
                local itemIndex = childIndex + offset
                local item = itemList[itemIndex] or {}
                
                childFrame.itemId = item.id
                childFrame.itemIndex = itemIndex
                
                if(item.id == nil) then
                    childFrame:SetAlpha(0)
                else
                    childFrame:SetAlpha(1)
                    
                    local colour = lookup.rarityColours[item.rarity]
                    
                    childFrame.icon:SetTexture(item.texture)
                    childFrame.text:SetText(item.name)
                    childFrame.text:SetTextColor(colour[1], colour[2], colour[3])
                    
                    if(item.id == listFrame.selectedItemId) then
                        childFrame.selected:SetAlpha(1)
                    else
                        childFrame.selected:SetAlpha(0)
                    end
                end
            end
        end
        
        listFrame.dataChanged = function()
            FauxScrollFrame_Update(listFrame, #(data.getItemsCallback()), data.childCount, childHeight, nil, nil, nil, nil, nil, nil, true)
            FauxScrollFrame_SetOffset(listFrame, 0)
            listFrame.updateView()
        end
        
        return listFrame
    end,
    ['insertOptionsItemCatcher'] = function(data)
        local catchFrame = CreateFrame('Frame', data.framename, data.parent)
        
        catchFrame:SetWidth(data.width)
        
        catchFrame.background = catchFrame:CreateTexture(nil, 'BACKGROUND')
        catchFrame.background:SetTexture(0, 0.04, 0.3, 0.7)
        catchFrame.background:SetAllPoints()
        
        for _, borderName in pairs({'borderTop', 'borderRight', 'borderBottom', 'borderLeft'}) do
            catchFrame[borderName] = catchFrame:CreateTexture(nil, 'BORDER')
            catchFrame[borderName]:SetTexture(0.5, 0.75, 1, 0.2)
        end
        
        catchFrame.borderTop:SetPoint('TOPLEFT', catchFrame, 'TOPLEFT', 0, 0)
        catchFrame.borderTop:SetPoint('TOPRIGHT', catchFrame, 'TOPRIGHT', 0, 0)
        catchFrame.borderTop:SetHeight(1)
        
        catchFrame.borderRight:SetPoint('TOPRIGHT', catchFrame.borderTop, 'BOTTOMRIGHT', 0, 0)
        catchFrame.borderRight:SetPoint('BOTTOMRIGHT', catchFrame.borderBottom, 'TOPRIGHT', 0, 0)
        catchFrame.borderRight:SetWidth(1)
        
        catchFrame.borderBottom:SetPoint('BOTTOMLEFT', catchFrame, 'BOTTOMLEFT', 0, 0)
        catchFrame.borderBottom:SetPoint('BOTTOMRIGHT', catchFrame, 'BOTTOMRIGHT', 0, 0)
        catchFrame.borderBottom:SetHeight(1)
        
        catchFrame.borderLeft:SetPoint('TOPLEFT', catchFrame.borderTop, 'BOTTOMLEFT', 0, 0)
        catchFrame.borderLeft:SetPoint('BOTTOMLEFT', catchFrame.borderBottom, 'TOPLEFT', 0, 0)
        catchFrame.borderLeft:SetWidth(1)
        
        catchFrame.text = catchFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
        catchFrame.text:SetPoint('TOPLEFT', catchFrame, 'TOPLEFT', 10, -10)
        catchFrame.text:SetText(data.text)
        
        catchFrame:SetHeight(catchFrame.text:GetHeight() + 20)
        
        catchFrame:EnableMouse(true)
        catchFrame:RegisterForDrag('LeftButton')
        
        catchFrame:SetScript('OnReceiveDrag', function(self)
            local dropType, itemId = GetCursorInfo()
            ClearCursor()
            
            if(dropType == 'item') then
                data.callback(self, itemId)
            end
        end)
        
        catchFrame:SetScript('OnMouseUp', catchFrame:GetScript('OnReceiveDrag'))
        
        return catchFrame
    end,
    ['insertOptionsClearableItem'] = function(data)
        local item
        local holder = CreateFrame('Frame', data.framename, data.parent)
        holder:EnableMouse(true)
        
        local clear = CreateFrame('Button', data.framename .. '-Clear', holder)
        clear:SetPoint('RIGHT', holder, 'RIGHT', 0, -1)
        
        clear.normalTexture = clear:CreateTexture(nil, 'ARTWORK')
        clear.normalTexture:SetTexture('Interface\\Buttons\\CancelButton-Up')
        clear.normalTexture:SetAllPoints()
        clear.normalTexture:SetTexCoord(0.25, 0.75, 0.25, 0.75)
        clear:SetNormalTexture(clear.normalTexture)

        clear.pushedTexture = clear:CreateTexture(nil, 'ARTWORK')
        clear.pushedTexture:SetTexture('Interface\\Buttons\\CancelButton-Down')
        clear.pushedTexture:SetAllPoints()
        clear.pushedTexture:SetTexCoord(0.25, 0.75, 0.25, 0.75)
        clear:SetPushedTexture(clear.pushedTexture)

        clear.highlightTexture = clear:CreateTexture(nil, 'HIGHLIGHT')
        clear.highlightTexture:SetTexture('Interface\\Buttons\\CancelButton-Highlight')
        clear.highlightTexture:SetAllPoints()
        clear.highlightTexture:SetBlendMode('ADD')
        clear.highlightTexture:SetTexCoord(0.25, 0.75, 0.25, 0.75)
        clear:SetHighlightTexture(clear.highlightTexture)
        
        holder.clear = clear
        
        --
        
        local name = holder:CreateFontString(nil, 'OVERLAY', data.fontObject or 'GameFontHighlightSmall')
        name:SetJustifyH('RIGHT')
        name:SetText(' ')
        
        holder:SetHeight(name:GetHeight() + (data.extraHeight or 6))
        clear:SetSize(holder:GetHeight(), holder:GetHeight())
        name:SetPoint('RIGHT', holder, 'RIGHT', 0 - (clear:GetWidth() + 5), 0)
    
        local icon = holder:CreateTexture(nil, 'OVERLAY')
        icon:SetSize(name:GetHeight(), name:GetHeight())
        icon:SetPoint('RIGHT', name, 'LEFT', -2, 0)
        
        --
        
        holder:SetScript('OnEnter', function(self)
            if(item ~= nil and item.id ~= nil and tostring(item.id):match('^%d+$')) then
                GameTooltip:SetOwner(self, 'ANCHOR_CURSOR_RIGHT')
                GameTooltip:SetHyperlink(select(2, GetItemInfoCustom(item.id)))
                GameTooltip:Show()
            end
        end)
        
        holder:SetScript('OnLeave', GameTooltip_Hide)
        
        --
        
        holder.setItem = function(itemTable)
            item = itemTable
            
            if(item == nil or item.id == nil) then
                clear:Hide()
                name:Hide()
                icon:Hide()
                
                holder:SetWidth(0)
            else
                local colour = lookup.rarityColours[item.rarity]
                
                icon:SetTexture(item.texture)
                name:SetText(item.name)
                name:SetTextColor(colour[1], colour[2], colour[3])
            
                clear:Show()
                name:Show()
                icon:Show()
                
                holder:SetWidth(clear:GetWidth() + 5 + name:GetWidth() + 2 + icon:GetWidth())
            end
        end
        
        holder.setItem(data.item)
        
        --
        
        clear:SetScript('OnClick', function(self)
            if(item ~= nil and item.id ~= nil) then
                holder.setItem(nil)
                data.callback(holder)
            end
        end)
        
        clear:SetScript('OnEnter', function(self)
            GameTooltip:SetOwner(self, 'ANCHOR_CURSOR_RIGHT')
            GameTooltip:SetText(data.clearText or 'Clear item')
            GameTooltip:Show()
        end)
        
        clear:SetScript('OnLeave', GameTooltip_Hide)
        
        --
        
        return holder
    end,
    ----
    ['applyFieldTooltip'] = function(data)
        if(data.tooltip ~= nil) then
            data.field:SetScript('OnEnter', function()
                GameTooltip:SetOwner(data.field, 'ANCHOR_CURSOR_RIGHT')
                GameTooltip:SetText(data.tooltip, nil, nil, nil, nil, 1)
                
                if(data.tooltipExtra ~= nil) then
                    for _, line in ipairs(data.tooltipExtra) do
                        options.attachTooltipDoubleLine(line[1], line[2])
                    end
                end
                
                GameTooltip:Show()
            end)
            
            data.field:SetScript('OnLeave', GameTooltip_Hide)
        end
    end,
    ['attachTooltipDoubleLine'] = function(leftText, rightText)
        GameTooltip:AddDoubleLine(
            leftText,
            rightText,
            HIGHLIGHT_FONT_COLOR.r,
            HIGHLIGHT_FONT_COLOR.g,
            HIGHLIGHT_FONT_COLOR.b,
            NORMAL_FONT_COLOR.r,
            NORMAL_FONT_COLOR.g,
            NORMAL_FONT_COLOR.b
        )
    end,
}

for funcName, func in pairs(options) do
    ScootsCraft.options[funcName] = func
end

options = ScootsCraft.options