local QBCore = exports['qb-core']:GetCoreObject()
if not IsQBCore() then return end

function AddMoney(acc, price, reason)
    print(acc, price, reason)
    if not acc then return print("ERRO NA CONTA! ", acc, price, reason) end
    exports['ps-banking']:AddMoney(acc, price, reason)
end

QB ={
    TriggerCallback = function(name,cb, ...)
     if QBCore ~= nil then
         QBCore.Functions.TriggerCallback(name, cb, ...)
     end
    end,
 
    RegisterCallback = function(name, cb)
     if QBCore ~= nil then 
         QBCore.Functions.CreateCallback(name, cb)
     end
 end
 }