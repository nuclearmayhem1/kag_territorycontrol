﻿#include "MakeMat.as";

void onInit(CSprite@ this)
{
	// Building
	this.SetZ(-50); //-60 instead of -50 so sprite layers are behind ladders
}

const string[] matNames = { 
	"mat_copper",
	"mat_iron",
	"mat_gold",
	"mat_ironingot",
	"mat_oil"
};

const string[] matNamesResult = { 
	"mat_copperingot",
	"mat_ironingot",
	"mat_goldingot",
	"mat_steelingot",
	"mat_plastic"
};

const int[] matRatio = { 
	10,
	10,
	25,
	4,
	10
};

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 90;
	
	this.Tag("ignore extractor");
	this.Tag("builder always hit");
	
	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		sprite.SetEmitSound("InductionFurnace_Loop.ogg");
		sprite.SetEmitSoundVolume(0.90f);
		sprite.SetEmitSoundSpeed(1.0f);
		sprite.SetEmitSoundPaused(false);
	}
}

void onTick(CBlob@ this)
{

	for (int i = 0; i < 5; i++)
	{
		if (this.hasBlob(matNames[i], matRatio[i]))
		{
			if (isServer())
			{
				CBlob @mat = server_CreateBlob(matNamesResult[i], -1, this.getPosition());
				if (matNamesResult[i] == "mat_plastic")
				{
					mat.server_SetQuantity(20);
				}
				else
				{
					mat.server_SetQuantity(4);
				}
				mat.Tag("justmade");
				this.TakeBlob(matNames[i], matRatio[i]);
				
				if (i == 1) this.TakeBlob("mat_coal", 1);
			}
			
			this.getSprite().PlaySound("ProduceSound.ogg");
			this.getSprite().PlaySound("BombMake.ogg");
		}
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null) return;

	if(blob.hasTag("justmade")){
		blob.Untag("justmade");
		return;
	}
	
	for(int i = 0;i < 5; i += 1)
	if (!blob.isAttached() && blob.hasTag("material") && blob.getName() == matNames[i])
	{
		if (isServer()) this.server_PutInInventory(blob);
		if (isClient()) this.getSprite().PlaySound("bridge_open.ogg");
	}
	
	if (!blob.isAttached() && blob.hasTag("material") && blob.getName() == "mat_coal")
	{
		if (isServer()) this.server_PutInInventory(blob);
		if (isClient()) this.getSprite().PlaySound("bridge_open.ogg");
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	// return (forBlob.getTeamNum() == this.getTeamNum() && forBlob.isOverlapping(this));
	return forBlob !is null && forBlob.isOverlapping(this);
}

void onAddToInventory( CBlob@ this, CBlob@ blob )
{
	if(blob.getName() != "gyromat") return;

	this.getCurrentScript().tickFrequency = 90 / (this.exists("gyromat_acceleration") ? this.get_f32("gyromat_acceleration") : 1);
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
	if(blob.getName() != "gyromat") return;
	
	this.getCurrentScript().tickFrequency = 90 / (this.exists("gyromat_acceleration") ? this.get_f32("gyromat_acceleration") : 1);
}