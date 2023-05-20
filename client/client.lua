--================================================================================================
--==                                VARIABLES - DO NOT EDIT                                     ==
--================================================================================================
ESX = exports['es_extended']:getSharedObject()
inMenu			= true
local ShowBankBlips = true 
local atbank	= false
local bankMenu	= true
local showblips	= true

local BankLocations = { -- to get blips and colors check this: https://wiki.gtanet.work/index.php?title=Blips
	{blip = 108, blipColor = 2, blipScale = 0.9, x = 150.266, y = -1040.203, z = 29.374, blipText = "Bank", BankDistance = 3},
	{blip = 108, blipColor = 2, blipScale = 0.9, x = -1212.980, y = -330.841, z = 37.787, blipText = "Bank", BankDistance = 3},
	{blip = 108, blipColor = 2, blipScale = 0.9, x = -2962.582, y = 482.627, z = 15.703, blipText = "Bank", BankDistance = 3},
	{blip = 108, blipColor = 2, blipScale = 0.9, x = -112.202, y = 6469.295, z = 31.626, blipText = "Bank", BankDistance = 3},
	{blip = 108, blipColor = 2, blipScale = 0.9, x = 314.187, y = -278.621, z = 54.170, blipText = "Bank", BankDistance = 3},
	{blip = 108, blipColor = 2, blipScale = 0.9, x = -351.534, y = -49.529, z = 49.042, blipText = "Bank", BankDistance = 3},
	{blip = 108, blipColor = 3, blipScale = 1.2, x = 252.33, y = 218.11, z = 106.29, blipText = "Bank", BankDistance = 3},
	{blip = 108, blipColor = 2, blipScale = 0.9, x = 1175.064, y = 2706.643, z = 38.094, blipText = "Bank", BankDistance = 3},
}

--================================================================================================
--==                                THREADING - DO NOT EDIT                                     ==
--================================================================================================
local ATMProps = {
	`prop_atm_01`,
	`prop_atm_02`,
	`prop_atm_03`,
	`prop_fleeca_atm`,
	`v_5_b_atm1`,
	`v_5_b_atm2`
}



local BankZones = {
	{ -- Legion Square
		pos = vec3(149.02, -1041.17, 29.37),
		h = 340.0,
		length = 0.8,
		width = 6.0,
		minZ = 28.37,
		maxZ = 31.07
	},

	{ -- Del Perro
		pos = vec3(-1212.92, -331.6, 37.79),
		h = 27.0,
		length = 0.8,
		width = 6.0,
		minZ = 36.79,
		maxZ = 39.49
	},

	{ -- Burton
		pos = vec3(-351.78, -50.36, 49.04),
		h = 341.0,
		length = 0.8,
		width = 6.0,
		minZ = 48.04,
		maxZ = 50.74
	},

	{ -- Hawick
		pos = vec3(313.37, -279.53, 54.17),
		h = 340.0,
		length = 0.8,
		width = 6.0,
		minZ = 53.17,
		maxZ = 55.87
	},

	{ -- Highway
		pos = vec3(-2961.91, 482.27, 15.7),
		h = 87.0,
		length = 0.8,
		width = 6.0,
		minZ = 14.7,
		maxZ = 17.4
	},

	{ -- Sandy Shores
		pos = vec3(1175.7, 2707.51, 38.09),
		h = 0.0,
		length = 0.8,
		width = 6.0,
		minZ = 37.09,
		maxZ = 39.79
	},

	{ -- Paleto Bay
		pos = vec3(-111.54, 6469.59, 31.62),
		h = 315.0,
		length = 0.8,
		width = 4.4,
		minZ = 30.62,
		maxZ = 33.12
	}
}
--===============================================
--==           Base ESX Threading              ==
--===============================================

-- qtarget stuff
exports.qtarget:AddTargetModel(ATMProps, {
	options = {{
		icon = 'fas fa-credit-card',
		label = 'Use ATM',
		event = "bank:openMenu"
	}},
	distance = 1.5
})

exports.qtarget:AddBoxZone('ATM_L', vec3(147.49, -1036.18, 29.34), 0.4, 1.3,
	{
		name = 'ATM_L',
		heading = 340.0,
		minZ = 28.69,
		maxZ = 30.64
	},
	{
		options = {{
			icon = 'fas fa-credit-card',
			label = 'Use ATM',
			event = "bank:openMenu"
		}},
		distance = 1.5
	}
)


for k,v in pairs(BankZones) do
	local name = ('Bank_%s'):format(k)
	exports.qtarget:AddBoxZone(name, v.pos, v.length, v.width,
		{
			name = name,
			heading = v.h,
			minZ = v.minZ,
			maxZ = v.maxZ
		}, {
			options = {{
				icon = 'fas fa-money-bill-wave',
				label = 'Access bank account',
				event = "bank:openMenu"
			}},
			distance = 2.0
		}
	)
end




RegisterNetEvent('bank:openMenu')
AddEventHandler('bank:openMenu', function()
    if lib.progressBar({
		duration = 1000,
		label = 'MEMASUKI ATM',
		useWhileDead = false,
		canCancel = true,
		disable = {
			move = true,
			car = true,
			combat = true,
		},
		anim = {
			scenario = 'PROP_HUMAN_ATM',
		},
	}) 
	then 
		local ped = GetPlayerPed(-1)
		local inMenu = true
		SetNuiFocus(true, true)
		SendNUIMessage({type = 'openGeneral'})
		TriggerServerEvent('bank:balance')
	else
		--ClearPedTasksImmediately(GetPlayerPed(-1))
		lib.notify({
			title = 'BANK',
			description = 'Gagal Memasuukan Kartu',
			type = 'error',
		})

	end
end)

--===============================================
--==           Deposit Event                   ==
--===============================================
RegisterNetEvent('currentbalance1')
AddEventHandler('currentbalance1', function(balance)
	local id = PlayerId()
	local playerName = GetPlayerName(id)
	
	SendNUIMessage({
		type = "balanceHUD",
		balance = balance,
		player = playerName
		})
end)
--===============================================
--==           Deposit Event                   ==
--===============================================
RegisterNUICallback('deposit', function(data)
	TriggerServerEvent('bank:deposit', tonumber(data.amount))
	TriggerServerEvent('bank:balance')
end)

--===============================================
--==          Withdraw Event                   ==
--===============================================
RegisterNUICallback('withdrawl', function(data)
	TriggerServerEvent('bank:withdraw', tonumber(data.amountw))
	TriggerServerEvent('bank:balance')
end)

--===============================================
--==         Balance Event                     ==
--===============================================
RegisterNUICallback('balance', function()
	TriggerServerEvent('bank:balance')
end)

RegisterNetEvent('balance:back')
AddEventHandler('balance:back', function(balance)
	SendNUIMessage({type = 'balanceReturn', bal = balance})
end)


--===============================================
--==         Transfer Event                    ==
--===============================================
RegisterNUICallback('transfer', function(data)
	TriggerServerEvent('bank:transfer', data.to, data.amountt)
	TriggerServerEvent('bank:balance')
end)

--===============================================
--==         Result   Event                    ==
--===============================================
RegisterNetEvent('bank:result')
AddEventHandler('bank:result', function(type, message)
	SendNUIMessage({type = 'result', m = message, t = type})
end)

--===============================================
--==               NUIFocusoff                 ==
--===============================================
RegisterNUICallback('NUIFocusOff', function()
	inMenu = false
	SetNuiFocus(false, false)
	SendNUIMessage({type = 'closeAll'})
	--ClearPedTasksImmediately(GetPlayerPed(-1))
end)

Citizen.CreateThread(function()
	if ShowBankBlips then
		Citizen.Wait(2000)
		for k,v in ipairs(BankLocations)do
			local blip = AddBlipForCoord(v.x, v.y, v.z)
			SetBlipSprite (blip, v.blip)
			SetBlipDisplay(blip, 4)
			SetBlipScale  (blip, v.blipScale)
			SetBlipColour (blip, v.blipColor)
			SetBlipAsShortRange(blip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(v.blipText)
			EndTextCommandSetBlipName(blip)
		end
	end
end)
