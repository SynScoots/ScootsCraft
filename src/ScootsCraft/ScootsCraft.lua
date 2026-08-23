ScootsCraft = {
    ['title'] = 'ScootsCraft',
    ['version'] = '2.1.0',
    ['frames'] = {
        ['events'] = CreateFrame('Frame', 'ScootsCraft-EventsFrame', UIParent),
    },
    ['storage'] = {},
    ['core'] = {
        ['triggeredEvents'] = {},
    },
    ['options'] = {},
    ['interface'] = {},
    ['utility'] = {},
    ['lookup'] = {},
    ['forgeHelperCallbacks'] = {},
}

SLASH_SCOOTSCRAFT1 = '/scootscraft'
SlashCmdList['SCOOTSCRAFT'] = function(...)
    ScootsCraft.interface.toggle()
end