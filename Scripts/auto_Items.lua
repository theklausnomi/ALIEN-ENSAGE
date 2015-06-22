require("libs.Utils")
require("libs.AbilityDamage")

local play = false

function Tick(tick)
    if not PlayingGame() or not SleepCheck() then return end Sleep(250)
    local me = entityList:GetMyHero()
    local bloodstone = me:FindItem("item_bloodstone")
    local bottle, stick = me:FindItem("item_bottle"), me:FindItem("item_magic_stick") or me:FindItem("item_magic_wand")
	local phaseboots = me:FindItem("item_phase_boots")
	local midas = me:FindItem("item_hand_of_midas")
	if not me:IsInvisible() and not me:IsChanneling() and me.alive then
		if bloodstone and bloodstone:CanBeCasted() then
			local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,team=me:GetEnemyTeam(),illusion=false})
			for i,v in ipairs(enemies) do
				local distance = GetDistance2D(v,me)						
				for i,z in ipairs(v.abilities) do
					local dmg = me:DamageTaken(AbilityDamage.GetDamage(z, me.healthRegen), AbilityDamage.GetDmgType(z), v)
					local dmg2 = me:DamageTaken(v.dmgMin + v.dmgBonus, DAMAGE_PHYS, v)
					if distance <= z.castRange+100 and (math.max(math.abs(FindAngleR(v) - math.rad(FindAngleBetween(v, me))) - 0.20, 0)) < 0.15 then
						if (z.abilityPhase and me.health < dmg2 or me.health < dmg) then
							me:CastAbility(bloodstone,me.position)
						end
					end
				end
			end
		elseif midas and midas:CanBeCasted() then
			for _,v in ipairs(entityList:GetEntities(function (v) return v.type == LuaEntity.TYPE_CREEP and v.team ~= me.team and v.alive and v.visible and v.spawned and v.level >= 5 and not v.ancient and v.health > 0 and v.attackRange < 650 and v:GetDistance2D(me) < midas.castRange + 25 end)) do
				me:CastAbility(midas,v)
			end
		elseif bottle and bottle:CanBeCasted() and me:DoesHaveModifier("modifier_fountain_aura_buff") and not me:DoesHaveModifier("modifier_bottle_regeneration") and (me.health < me.maxHealth or me.mana < me.maxMana) then
			me:CastAbility(bottle)
		elseif phaseboots and phaseboots:CanBeCasted() then
			me:CastAbility(phaseboots)
		elseif stick and stick:CanBeCasted() and stick.charges > 0 and me.health/me.maxHealth < 0.3 then
			me:CastAbility(stick)
		end
	end
end

function Load()
	if PlayingGame() then
		play = true
		script:RegisterEvent(EVENT_TICK,Tick)
		script:UnregisterEvent(Load)
	end
end

function Close()
	collectgarbage("collect")
	if play then
		script:UnregisterEvent(Tick)
		script:RegisterEvent(EVENT_TICK,Load)
		play = false
	end
end

script:RegisterEvent(EVENT_CLOSE,Close)
script:RegisterEvent(EVENT_TICK,Load)
