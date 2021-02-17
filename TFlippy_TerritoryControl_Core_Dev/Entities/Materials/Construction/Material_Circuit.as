void onInit(CBlob@ this)
{	
	this.maxQuantity = 25;
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}