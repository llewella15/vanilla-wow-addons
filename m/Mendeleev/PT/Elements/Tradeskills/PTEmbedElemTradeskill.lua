
local setname, coremajor = "Tradeskill", "1"
local vmajor, vminor = "Tradeskill 1", tonumber(string.sub("$Revision: 3130 $", 12, -3))

--	Todo:
--	Recepie source (vendor/drop)
--	1.9 (Greater) Sagefish
--	1.9 Nexus Crystals
--	1.9 Recepies



-- Check to see if an update is needed
-- if not then just return out now before we do anything
if not TekLibStub or not PeriodicTableEmbed or not PeriodicTableEmbed:NeedsUpgraded(vmajor, vminor) then return end

local mem = gcinfo()
local t = {

	-- Items harvested by tradeskills
	gatherskill           = {"gatherskillfishing", "gatherskilldisenchant", "gatherskillherbalism", "gatherskillmining", "gatherskillskinning"},
	gatherskillfishing    = "13760 6291 13893 6303 13754 13755 13422 6362 6308 13888 6289 6359 6522 13758 6358 6317 13759 8365 13889 4603 13756 6361",
	gatherskilldisenchant = "20725 11083 16204 11137 11176 10940 11174 10938 11135 11175 16202 11134 16203 10998 11082 10939 11084 14343 11139 10978 11177 14344 11138 11178",
	gatherskillherbalism  = "3358 8839 13466 4625 13467 3821 785 13465 13468 2450 2452 3818 3355 3357 8838 3369 3820 8153 8836 13463 8845 8846 13464 2447 2449 765 2453 3819 3356 8831",
	gatherskillmining     = "7911 12799 1210 2775 774 12361 2776 12364 12365 3864 18562 2770 2771 3858 19774 11370 2835 12363 9262 1705 818 12800 2836 11382 7909 10620 11754 1206 7910 1529 7912 2838 2772",
	gatherskillskinning   = "15412 7392 2318 15414 15415 8165 15416 15417 2319 15419 8167 2934 7286 15422 15423 8169 8368 12810 8154 8170 6470 4234 19767 19768 4235 783 17012 4232 15408 8171 6471 5082 4461 7287 4304 7428",

	-- Tradeskill ingreds by type
	ingredbar      = "12359 11371 3860 2842 6037 3859 3575 2840 2841 3576 12655 3577 12360",
	ingredbolt     = "4305 2997 14048 4339 2996",
	ingredcloth    = "4306 14047 4338 14342 2592 14256 2589",
	ingreddust     = "11083 16204 11137 11176 10940",
	ingreddye      = "2325 2604 6260 6261 4342 10290 4340 2605 2324 4341 9210",
	ingredelement  = "7070 12808 7078 7082 7067 7075 7079 12803 7068 7076 7080 10286 7069 7972 7077 7081",
	ingredessence  = "11174 10938 11135 11175 16202 11134 16203 10998 11082 10939",
	ingredflux     = "2880 3466 18567",
	ingredgem      = "12799 818 12800 11382 1206 774 1705 1210 12361 9262 1529 12363 11754 12364 7910 3864 19774 7909",
	ingredgrinding = "3470 3478 7966 12644 3486",
	ingredhide     = "4236 4231 4233 15407 8172 4461 8368 7428 783 4235 8171 4232 8169",
	ingredleather  = "15419 2318 15423 2934 4234 2319 15417 12810 15422 8170 5082 19768 17012 4304 19767",
	ingrednexus    = "20725",
	ingredoil      = "6371 6370 3829 9061 3824 13423 8956",
	ingredore      = "2775 2776 18562 2770 3858 2771 11370 2772 7911 10620",
	ingredpart     = "4361 10560 4404 10576 10561 15994 10546 10647 7191 4363 4394 10648 18631 4359 9060 4400 4371 4375 10507 16000 4387 4399 16006 10558 4382 4407 4389 10559 10586",
	ingredpearl    = "5498 4611 13926 5500 7971",
	ingredpoison   = "8924 3818 2928 8923 8925 18256 2930 5173 3372 3371",
	ingredpowder   = "10505 4377 4357 15992 4364",
	ingredrod      = "16206 6338 11144 11128 6217",
	ingredsalt     = "15409 4289 8150",
	ingredscale    = "15408 15412 8165 6471 8167 15414 8154 6470 7286 7392 15415 7287 15416",
	ingredshard    = "11084 14343 11139 10978 11177 14344 11138 11178",
	ingredspice    = "2678 2665 17194 3713 2692",
	ingredstone    = "2835 7912 2836 2838 12365",
	ingredthread   = "2321 14341 4291 2320 8343",
	ingredvial     = "3371 18256 8925 3372",

	-- Tradeskill ingred sources (not including harvestables above)
	ingredmonsterdrops = "15420 1475 17011 3730 3667 3731 5465 1080 5466 5784 5467 5785 5468 5469 1081 5470 13926 5471 3164 1288 12662 4589 12037 8146 4337 4655 12804 4402 12809 8151 7072 18512 2251 3172 3712 12184 729 3173 17010 1015 3174 6889 4096 1468 14227 7971 19441 5051 5373 730 7974 5498 12204 12205 12206 4611 12208 8168 769 9260 12203 5503 2672 5504 723 731 2673 2675 19943 17203 3182 5635 8152 18240 12607 5637 12202 3685 12223 19726 2924 2886 2677 15410 5116 10285 12753 2674 3404 5500 6470 12207 814 12811",
	ingredvendorbought = "8923 4289 8924 8925 9210 4291 8150 11291 1179 6261 4340 2320 4341 2596 2604 4342 159 2880 2321 3857 18567 4470 2692 18256 8343 5173 2894 2665 2928 2605 4536 6530 10647 2930 10648 3713 17194 2324 3466 6260 2678 14341 3372 15409 17196 2325 4400 10290 3371",

	--ingreds used by tradeskills
	tradeskill               = {"tradeskillalchemy", "tradeskillblacksmithing", "tradeskillcooking", "tradeskillenchanting", "tradeskillengineering", "tradeskillfirstaid", "tradeskillleatherworking", "tradeskilltailoring"},
	tradeskillalchemy        = "3824 765 3858 8831 8836 3860 8839 3575 10620 6358 8845 8846 3164 1288 13422 13423 3356 3357 3358 7067 12803 6370 4402 6371 7070 12808 18256 4342 8153 9260 9262 7076 7078 10286 785 13463 13464 13465 7082 13467 13468 2447 3369 2449 2450 3371 6522 3372 3355 5635 8925 7972 3818 2453 8838 11176 3819 7069 12359 2452 3820 15410 12363 5637 3821 4625 7080 9149 13466 118 6359 7068",
	tradeskillblacksmithing  = "15417 12753 20520 20725 13510 13512 22203 22202 3823 5966 2840 17011 2841 1206 2842 11371 3859 6037 3860 14047 3575 11382 3576 2592 19726 3577 12662 3864 2880 1210 12799 8146 7067 3486 4338 7069 7070 19774 1529 12810 12811 8153 7075 7076 1705 7966 17010 17012 7080 2459 7081 2318 7971 774 7972 7909 2605 7910 11186 5498 11188 7912 12809 5500 12655 8168 2589 3478 818 8170 3470 3466 2319 12804 3391 12808 12803 17203 7068 5635 12359 4234 2321 5637 4304 12644 11185 2835 4306 12360 12361 2836 3829 12364 12365 11184 7077 12800 7078 2838 3824 4255",
	tradeskillcooking        = "3730 3667 3731 6289 5465 1080 5466 5467 5468 5469 1081 5470 5471 6361 6362 17196 6303 12037 2692 4655 4402 6308 8365 2251 3172 4536 729 3173 3713 1015 3174 6889 1468 5051 12202 769 730 3685 12203 12204 12205 2924 12207 12208 13758 12206 2886 4603 5503 2672 5504 723 731 2673 6522 6317 3404 2674 12223 13889 7974 2675 17194 2678 2665 13754 13755 13756 6291 2677 13759 13760 13888 3821 2894 1179 2452 13893 159 12184 2596",
	tradeskillenchanting     = "7082 20725 11128 7077 14343 16202 14344 16203 16204 7079 12803 11134 16206 11135 10978 13467 6217 7081 8838 11138 12808 11139 11174 11291 7067 4470 12811 8153 7068 5500 11175 11144 11176 11082 11177 11083 11178 11084 10939 12359 7909 1210 9224 2772 5637 6371 7392 11382 6370 7971 6338 13926 6037 7972 10998 3356 7075 3829 8170 10940 10938 11137",
	tradeskillengineering    = "15407 7079 4377 2840 17011 2841 4382 2842 11371 12655 4371 3859 4375 6037 9060 3860 159 14047 3575 4389 4359 2589 3576 2592 19726 4387 3577 17010 10502 4394 10586 10505 17202 10507 12803 7191 2836 1210 3829 4399 12800 4400 4337 7068 4338 4402 7387 10648 12808 4404 8151 4385 12359 18631 8153 4407 10561 7075 10026 7076 1705 7077 10592 7078 7069 16000 10286 7080 1206 10543 14227 7082 10546 7972 7909 1529 7910 16006 3864 774 7912 12804 4357 12799 10558 10559 10560 818 8170 4361 4234 4339 19774 4611 4363 8150 4364 10285 13467 2318 2319 12810 10576 4304 4368 10500 2835 4306 12360 12361 6530 9061 12364 12365 15992 2880 15994 814 2838 7067 10647",
	tradeskillfirstaid       = "4306 2589 14047 1475 1288 2592 4338 19441",
	tradeskillleatherworking = "12753 2934 15422 15423 3824 2459 17011 7428 1206 5082 11754 3383 14044 5784 8951 14047 14048 15419 4236 6470 18240 3390 19726 15414 8171 4338 8343 8170 8169 3356 1529 15408 14341 783 4461 1210 7286 12809 8146 7067 4337 12803 12804 19768 2312 7070 8150 7071 12810 8152 8368 8153 8167 8154 7075 14342 7076 7971 7077 8949 7078 17012 7079 2320 7080 4096 8151 14227 7082 5785 4289 2319 2605 5116 4291 5498 4340 2321 8165 5373 8172 8168 2324 4232 3864 4233 19767 4234 15420 4235 7392 5633 4231 2997 3182 2325 14256 7287 12607 5637 4304 2318 4305 18512 15407 4243 15409 15410 17010 15412 3389 4246 15415 15416 15417 2457 6471 5500 20498 20381 20500",
	tradeskilltailoring      = "11137 8831 11040 3824 17011 9210 3827 13468 16203 2589 3383 6037 14047 14048 2592 19726 3577 8343 12662 3864 6048 4589 12800 7067 4337 12803 4338 7069 6371 7070 12808 1529 12810 7072 4342 8153 14341 14342 7076 14344 7077 17010 17012 10285 10286 11176 10290 7971 2319 2605 7910 4291 5498 6261 5500 929 8170 13926 4234 7068 2321 14227 2324 2604 4340 3182 2325 14256 2320 3829 12811 4304 4339 4305 6260 4306 12360 4341 2318 12809 12364 7079 7080 2996 18240 7078 7082 2997 7071",

	-- tools used in the tradeskill
	toolsenchanting			 = "6218 11130 6339 11145 16207"
}


local lib = {}


-- Return the library's current version
function lib:GetLibraryVersion()
	return vmajor, vminor
end


-- Activate a new instance of this library
function lib:LibActivate(stub, oldLib, oldList)
	self.dataset = t
	t = nil
	PeriodicTableEmbed:GetInstance(coremajor):AddModule(setname, self.dataset, self.memuse)
end

lib.memuse = gcinfo() - mem


--------------------------------
--      Load this bitch!      --
--------------------------------
PeriodicTableEmbed:Register(lib)
