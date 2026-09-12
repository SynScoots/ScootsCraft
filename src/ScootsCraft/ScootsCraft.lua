ScootsCraft = {
    ['title'] = 'ScootsCraft',
    ['version'] = '2.3.2',
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