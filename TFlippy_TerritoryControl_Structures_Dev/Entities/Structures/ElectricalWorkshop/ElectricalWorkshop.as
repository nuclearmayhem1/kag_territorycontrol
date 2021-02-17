// A script by TFlippy

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";

#include "MakeMat.as";
#include "TCTechs.as";

Random traderRandom(Time());

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	//this.Tag("upkeep building");
	//this.set_u8("upkeep cap increase", 0);
	//this.set_u8("upkeep cost", 5);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");

	this.getCurrentScript().tickFrequency = 150;

	// getMap().server_SetTile(this.getPosition(), CMap::tile_wood_back);

	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_Vec2f("shop menu size", Vec2f(4, 4));
	this.set_string("shop description", "Electrician's Workshop");
	this.set_u8("shop icon", 15);

	{
		ShopItem@ s = addShopItem(this, "Copper Wire (2)", "$mat_copperwire$", "mat_copperwire-2", "A copper wire. Kids' favourite toy.");
		AddRequirement(s.requirements, "blob", "mat_copperingot", "Copper Ingot", 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Copper Wire (10)", "$mat_copperwire$", "mat_copperwire-10", "A bundle of copper wires.\nMade slightly more efficiently!");
		AddRequirement(s.requirements, "blob", "mat_copperingot", "Copper Ingot", 4);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Circuit", "$mat_circuit$", "mat_circuit", "A circuit for use in electronics");
		//AddRequirement(s.requirements, "blob", "mat_goldingot", "Gold Ingot", 1);
		//AddRequirement(s.requirements, "blob", "mat_plastic", "Plastic", 25);
		AddRequirement(s.requirements, "blob", "mat_copperwire", "Copper Wire", 10);
		s.spawnNothing = true;
	}
	
}

void onTick(CBlob@ this)
{
	CBlob@[] blobs;
	// if (this.getMap().getBlobsInRadius(this.getPosition(), this.getRadius() * 128.0f, @blobs))
	if (getMap().getBlobsInBox(this.getPosition() + Vec2f(96, 64), this.getPosition() + Vec2f(-96, 0), @blobs))
	{
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ blob = blobs[i];

			// print(blob.getName() + "; " + blob.hasTag("vehicle"));

			if (blob.hasTag("vehicle"))
			{
				if (blob.getHealth() < blob.getInitialHealth()) blob.server_Heal(4);
			}
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{

	this.set_Vec2f("shop offset", Vec2f(2,0));

	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("ConstructShort");

		u16 caller, item;

		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;

		string name = params.read_string();
		CBlob@ callerBlob = getBlobByNetworkID(caller);

		if (callerBlob is null) return;

		if (isServer())
		{
			string[] spl = name.split("-");

			if (spl[0] == "coin")
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;

				callerPlayer.server_setCoins(callerPlayer.getCoins() +  parseInt(spl[1]));
			}
			else if (name.findFirst("mat_") != -1)
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;

				MakeMat(callerBlob, this.getPosition(), spl[0], parseInt(spl[1]));

				// CBlob@ mat = server_CreateBlob(spl[0]);

				// if (mat !is null)
				// {
					// mat.Tag("do not set materials");
					// mat.server_SetQuantity(parseInt(spl[1]));
					// if (!callerBlob.server_PutInInventory(mat))
					// {
						// mat.setPosition(callerBlob.getPosition());
					// }
				// }
			}
			else
			{
				CBlob@ blob = server_CreateBlob(spl[0], callerBlob.getTeamNum(), this.getPosition());

				if (blob is null) return;

				if (callerBlob.getPlayer() !is null ) blob.SetDamageOwnerPlayer(callerBlob.getPlayer());
				
				if (!blob.canBePutInInventory(callerBlob))
				{
					callerBlob.server_Pickup(blob);
				}
				else if (callerBlob.getInventory() !is null && !callerBlob.getInventory().isFull())
				{
					callerBlob.server_PutInInventory(blob);
				}
			}
		}
	}
}
