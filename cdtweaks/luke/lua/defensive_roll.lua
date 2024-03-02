-- cdtweaks: Defensive Roll feat for rogues --

function GTDEFRLL(op403CGameEffect, CGameEffect, CGameSprite)
	local damageTypeStr = GT_Resource_IDSToSymbol["dmgtype"][CGameEffect.m_dWFlags]
	local damageAmount = CGameEffect.m_effectAmount
	--
	local spriteFlags = CGameSprite.m_baseStats.m_flags
	--
	local spriteHP = CGameSprite.m_baseStats.m_hitPoints
	--
	local spriteState = CGameSprite.m_baseStats.m_generalState
	local state = GT_Resource_SymbolToIDS["state"]
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local spriteSaveVSBreath = CGameSprite.m_derivedStats.m_nSaveVSBreath + CGameSprite.m_bonusStats.m_nSaveVSBreath
	--
	local spriteLevel1 = CGameSprite.m_derivedStats.m_nLevel1 + CGameSprite.m_bonusStats.m_nLevel1
	local spriteLevel2 = CGameSprite.m_derivedStats.m_nLevel2 + CGameSprite.m_bonusStats.m_nLevel2
	--
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][CGameSprite.m_typeAI.m_Class]
	--
	local roll = Infinity_RandomNumber(1, 20) -- 1d20
	-- If the character is struck by a potentially lethal blow, he makes a save vs. breath. If successful, he takes only half damage from the blow.
	if CGameEffect.m_effectId == 0xC and damageTypeStr ~= "STUNNING" and CGameEffect.m_slotNum == -1 and CGameEffect.m_sourceType == 0 and CGameEffect.m_sourceRes:get() == "" -- base weapon damage (all damage types but STUNNING)
		and (spriteClassStr == "THIEF" or spriteClassStr == "FIGHTER_MAGE_THIEF"
			-- incomplete dual-class characters should not benefit from Defensive Roll
			or (spriteClassStr == "FIGHTER_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2))
			or (spriteClassStr == "MAGE_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2))
			or (spriteClassStr == "CLERIC_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2)))
		and EEex_BAnd(spriteState, state["CD_STATE_NOTVALID"]) == 0
		and spriteSaveVSBreath <= roll
		and damageAmount >= spriteHP
		and EEex_Sprite_GetExtendedStat(CGameSprite, stats["CDTWEAKS_DEFENSIVE_ROLL"]) == 0
	then
		CGameEffect.m_effectAmount = math.floor(damageAmount / 2)
		EEex_GameObject_ApplyEffect(CGameSprite,
		{
			["effectID"] = 139, -- Display string
			["durationType"] = 1,
			["effectAmount"] = %feedback_strref%,
			["sourceID"] = op403CGameEffect.m_sourceId, -- Certain opcodes (see f.i. op326) use this field internally... it's probably a good idea to always specify it...
			["sourceTarget"] = op403CGameEffect.m_sourceTarget, -- Certain opcodes (see f.i. op326) use this field internally... it's probably a good idea to always specify it...
		})
		EEex_GameObject_ApplyEffect(CGameSprite,
		{
			["effectID"] = 401, -- Set extended stat
			["duration"] = 7200,
			["special"] = stats["CDTWEAKS_DEFENSIVE_ROLL"],
			["dwFlags"] = 1, -- set
			["effectAmount"] = 1,
			["sourceID"] = op403CGameEffect.m_sourceId, -- Certain opcodes (see f.i. op326) use this field internally... it's probably a good idea to always specify it...
			["sourceTarget"] = op403CGameEffect.m_sourceTarget, -- Certain opcodes (see f.i. op326) use this field internally... it's probably a good idea to always specify it...
		})
	end
end
