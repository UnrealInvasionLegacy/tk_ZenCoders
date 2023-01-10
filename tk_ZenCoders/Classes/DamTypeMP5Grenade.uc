class DamTypeMP5Grenade extends WeaponDamageType
	abstract;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictimHealth)
{
	HitEffects[0] = class'HitSmoke';

	if (VictimHealth <= 0)
		HitEffects[1] = class'HitFlameBig';
	else if (FRand() < 0.8)
		HitEffects[1] = class'HitFlame';
}

defaultproperties
{
     WeaponClass=Class'tk_ZenCoders.MP5Gun'
     DeathString="%o couldn't avoid %k's MP5 grenade."
     FemaleSuicide="%o jumped on her own MP5 grenade."
     MaleSuicide="%o jumped on his own MP5 grenade."
     GibPerterbation=0.400000
}