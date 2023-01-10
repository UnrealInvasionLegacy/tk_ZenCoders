class MP5GrenadeAmmo extends GrenadeAmmo
	config(TKWeaponsServer);

var config int ClientMaxAmmo;

replication
{
	reliable if (Role == ROLE_Authority)
		ClientMaxAmmo;
}

simulated function PostNetBeginPlay()
{
	MaxAmmo = ClientMaxAmmo;
	Super.PostNetBeginPlay();
}

defaultproperties
{
     ClientMaxAmmo=10
     MaxAmmo=10
     PickupAmmo=4
     PickupClass=Class'tk_ZenCoders.MP5AmmoPickup'
     ItemName="MP5 Grenade Ammo"
} 