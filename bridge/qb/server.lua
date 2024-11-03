local QBCore = exports['qb-core']:GetCoreObject()
if not IsQBCore() then return end

function AddMoney(acc, price)
    exports['qbx_management']:AddMoney(acc, price)
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