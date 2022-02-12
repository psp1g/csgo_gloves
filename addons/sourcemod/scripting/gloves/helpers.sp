/*  CS:GO Gloves SourceMod Plugin
 *
 *  Copyright (C) 2017 Kağan 'kgns' Üstüngel
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */

stock void GetRandomSkin(int client, int team, char[] output, int outputSize, int group = -1)
{
	int max;
	int random;
	if(group != -1)
	{
		char groupStr[10];
		IntToString(group, groupStr, sizeof(groupStr));
		g_smGlovesGroupIndex.GetValue(groupStr, random);
	}
	else
	{
		max = menuGlovesGroup[g_iClientLanguage[client]][team].ItemCount - 1;
		random = GetRandomInt(2, max) - 1;
	}
	
	max = menuGloves[g_iClientLanguage[client]][team][random].ItemCount - 1;
	int random2 = GetRandomInt(1, max);
	menuGloves[g_iClientLanguage[client]][team][random].GetItem(random2, output, outputSize);
}

stock bool IsValidClient(int client)
{
	// GetEntProp(client, Prop_Send, "m_bIsControllingBot") != 1
    if (!(1 <= client <= MaxClients) || !IsClientInGame(client) || IsFakeClient(client) || IsClientSourceTV(client) || IsClientReplay(client))
    {
        return false;
    }
    return true;
}

stock void FirstCharUpper(char[] string)
{
	if (strlen(string) > 0)
	{
		string[0] = CharToUpper(string[0]);
	}
}

stock void FixCustomArms(int client)
{
	char temp[2];
	GetEntPropString(client, Prop_Send, "m_szArmsModel", temp, sizeof(temp));
	if(temp[0])
	{
		SetEntPropString(client, Prop_Send, "m_szArmsModel", "");
	}
}

int SetClientGloves(int client, int glovesId, int glovesSkinId, bool update = true)
{
	int team = GetClientTeam(client);

	g_iGroup[client][team] = glovesId;
	g_iGloves[client][team] = glovesSkinId;

	if (update)
	{
		char teamName[2];
		if (team == CS_TEAM_CT)
		{
			teamName = "ct";
		}
		else
		{
			teamName = "t";
		}

		char updateFields[128];
		Format(updateFields, sizeof(updateFields), "%s_group = %d, %s_glove = %d", teamName, glovesId, teamName, glovesSkinId);

		UpdatePlayerData(client, updateFields);
	}

	RefreshGloves(client, glovesId);
}

int SetClientGlovesFloat(int client, float floatValue, bool update = true)
{
	int team = GetClientTeam(client);

	g_fFloatValue[client][team] = floatValue;

	if (update)
	{
		char teamName[2];
		if (team == CS_TEAM_CT)
		{
			teamName = "ct";
		}
		else
		{
			teamName = "t";
		}

		char updateFields[128];
		Format(updateFields, sizeof(updateFields), "%s_float = %.2f", teamName, floatValue);

		UpdatePlayerData(client, updateFields);
	}

	GivePlayerGloves(client);
}

int SetClientGlovesSeed(int client, int seed, bool update = true)
{
	int team = GetClientTeam(client);

	g_iGloveSeed[client][team] = seed;

	if (update)
	{
		char teamName[2];
		if (team == CS_TEAM_CT)
		{
			teamName = "ct";
		}
		else
		{
			teamName = "t";
		}

		char updateFields[128];
		Format(updateFields, sizeof(updateFields), "%s_float = %.2f", teamName, seed);

		UpdatePlayerData(client, updateFields);
	}

	GivePlayerGloves(client);
}

int RefreshGloves(int client, int index)
{
	int team = GetClientTeam(client);
	int activeWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(activeWeapon != -1)
	{
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", -1);
	}

	if(index == 0)
	{
		int ent = GetEntPropEnt(client, Prop_Send, "m_hMyWearables");
		if(ent != -1)
		{
			AcceptEntityInput(ent, "KillHierarchy");
		}
		SetEntPropString(client, Prop_Send, "m_szArmsModel", g_CustomArms[client][team]);
	}
	else
	{
		GivePlayerGloves(client);
	}

	if(activeWeapon != -1)
	{
		DataPack dpack;
		CreateDataTimer(0.1, ResetGlovesTimer, dpack);
		dpack.WriteCell(client);
		dpack.WriteCell(activeWeapon);
	}

	return 0;
}