#include "Survival_Structs.as";

//const u8 secondsforinfluence = 10;


void onInit(CRules@ this)
{
	return;
}


void onTick(CRules@ this)
{
	//if(getGameTime() & (getTicksASecond() * secondsforinfluence) == 0)
	if(getGameTime() & 31 == 0)
	{
		TeamData[]@ team_list;
		this.get("team_list", @team_list);

		if (team_list !is null)
		{
			for (u32 i = 0; i < team_list.length; i++)
			{
				TeamData@ team_data;
				GetTeamData(i, @team_data);
				if (team_data !is null)
				{
					team_data.influence += team_data.controlled_count;
					print(""+i + " " + team_data.influence + " " + team_data.controlled_count);
				}
			}
		}
	}
}