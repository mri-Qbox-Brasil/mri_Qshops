Config = {}
Config.Debug = true

debug = function(data)
    if not Config.Debug then return end
    print(data)
end