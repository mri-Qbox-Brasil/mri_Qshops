DB = {}
function DB.CreateTable()
    MySQL.Sync.execute([[
            CREATE TABLE IF NOT EXISTS `mri_Qshops` (
              `id` int(11) NOT NULL AUTO_INCREMENT,
                `label` text DEFAULT  NULL,
                `jobname` text DEFAULT  NULL,
                `blip_coords` longtext DEFAULT NULL,
                `blip_sprite` longtext DEFAULT NULL,
                `blip_color` longtext DEFAULT NULL,
                `blip_enabled` varchar(255) DEFAULT NULL,
                `bossMenu_coords` longtext DEFAULT NULL,
                `bossMenu_range` longtext DEFAULT NULL,
                `bossMenu_enabled` varchar(255) DEFAULT NULL,
                `locations` longtext DEFAULT NULL,
                `range` longtext DEFAULT NULL,
                `shop_coords` longtext DEFAULT NULL,
                `shop_range` longtext DEFAULT NULL,
                PRIMARY KEY (`id`) USING BTREE,
               UNIQUE KEY `id` (`id`)
            ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
   ]])
end

RegisterNetEvent('mri-qshops:InsertShop', function(data)
  print(json.encode(data))
  
  local sql = "INSERT INTO `mri_qshops` (%s) VALUES (%s)"
  local columns = ""
  local placeholders = ""
  local params = {}

  for k, v in pairs(data) do
      if columns == "" then
          columns = k
          placeholders = "@" .. k
      else
          columns = columns .. ", " .. k
          placeholders = placeholders .. ", @" .. k
      end
      params["@" .. k] = v  -- Associa a chave ao valor correspondente
  end

  MySQL.Async.execute(string.format(sql, columns, placeholders), params)
  print(string.format(sql, columns, placeholders))
end)


