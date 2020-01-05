-- Simple Mouseover's Target
--
-- Show's a second tooltip with information on that unit's target

SMouseTarget_Saved = { };

SMouseTarget_PosTable = {
	{ "BOTTOMRIGHT", "BOTTOMLEFT", nil, "lower left (default)" },
	{ "RIGHT", "LEFT", nil, "left" },
	{ "TOPRIGHT", "TOPLEFT", nil, "upper left" },
	{ "BOTTOMLEFT", "TOPLEFT", 10, "top left" },
	{ "BOTTOM", "TOP", 10, "top" },
	{ "BOTTOMRIGHT", "TOPRIGHT", 10, "top right" },
	{ "TOPLEFT", "TOPRIGHT", nil, "upper right" },
	{ "LEFT", "RIGHT", nil, "right" },
	{ "BOTTOMLEFT", "BOTTOMRIGHT", nil, "lower right" },
	{ "TOPRIGHT", "BOTTOMRIGHT", -10, "bottom right" },
	{ "TOP", "BOTTOM", -10, "bottom" },
	{ "TOPLEFT", "BOTTOMLEFT", -10, "bottom left" }
};

function SMouseTarget_OnLoad(self)
	self:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
	self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
	self:RegisterEvent("PLAYER_ENTERING_WORLD");

	SLASH_SIMPLEMOUSETARGET1 = "/simplemouse";
	SLASH_SIMPLEMOUSETARGET2 = "/simplemousetarget";

	SlashCmdList["SIMPLEMOUSETARGET"] = SMouseTarget_Console;
end

function SMouseTarget_OnEvent(self)
	if ( SMouseTarget_Saved["off"] ) then return; end

	SMouseTarget_Pos();
	self:UnregisterEvent("PLAYER_ENTERING_WORLD");
end

function SMouseTarget_Console(msg)
	if ( strlower(strsub( msg, 1, 6 )) == "toggle" ) then
		SMouseTarget_Saved["off"] = not SMouseTarget_Saved["off"];
		local state = "on";
		if ( SMouseTarget_Saved["off"] ) then
			state = "off";
			SMouseTarget:Hide();
		end
		SMouseTarget_Print( "SimpleMouseTarget - turning "..state.." second tooltip" );
	elseif ( strlower(strsub( msg, 1, 2 )) == "on" ) then
		SMouseTarget_Saved["off"] = nil;
		SMouseTarget_OnEvent();
		SMouseTarget_Print( "SimpleMouseTarget - turning on second tooltip" );
	elseif ( strlower(strsub( msg, 1, 3 )) == "off" ) then
		SMouseTarget_Saved["off"] = 1;
		SMouseTarget:Hide();
		SMouseTarget_Print( "SimpleMouseTarget - turning off second tooltip" );
	elseif ( strlower(strsub( msg, 1, 3 )) == "pos" ) then
		local param = tonumber(strsub( msg, 5 ));
		if ( param and param > 0 and param <= 12 ) then
			SMouseTarget_Print( "SimpleMouseoverTarget - moving second tooltip to "..SMouseTarget_PosTable[param][4] );
			SMouseTarget_Pos( param );
		else
			SMouseTarget_PosHelp();
		end
	elseif ( strlower(strsub( msg, 1, 3 )) == "red" ) then
		SMouseTarget_Saved["nowarn"] = not SMouseTarget_Saved["nowarn"];
		local state = "on";
		if ( SMouseTarget_Saved["nowarn"] ) then
			state = "off";
		end
		SMouseTarget_Print( "SimpleMouseTarget - turning "..state.." red warning" );
	elseif ( strlower(strsub( msg, 1, 5 )) == "green" ) then
		SMouseTarget_Saved["noconfirm"] = not SMouseTarget_Saved["noconfirm"];
		local state = "on";
		if ( SMouseTarget_Saved["noconfirm"] ) then
			state = "off";
		end
		SMouseTarget_Print( "SimpleMouseTarget - turning "..state.." green confirmation" );
	else
		SMouseTarget_Help();
	end
end

function SMouseTarget_Help()
	SMouseTarget_Print( "SimpleMouseoverTarget - /simplemousetarget" );
	SMouseTarget_Print( "toggle / on / off - toggle or turn on and off the second tooltip" );
	SMouseTarget_Print( "red - toggle making the second tooltip red if you are the target" );
	SMouseTarget_Print( "green - toggle making the second tooltip green if you are targeting the same the target" );
	SMouseTarget_Print( "pos # - (1-12) set the location of the second tooltip around the main gametooltip" );
end

function SMouseTarget_PosHelp()
	SMouseTarget_Print( "SimpleMouseoverTarget - valid positions" );
	for i=1, 12, 3 do
		SMouseTarget_Print( i..", "..(i+1)..", "..(i+2).." - "..SMouseTarget_PosTable[i][4]..", "..SMouseTarget_PosTable[i+1][4]..", "..SMouseTarget_PosTable[i+2][4].."." );
	end
end

function SMouseTarget_Print( msg )
	DEFAULT_CHAT_FRAME:AddMessage( msg );
end

function SMouseTarget_Pos( pos )
	if ( not pos ) then
		pos = (SMouseTarget_Saved["pos"] or 1);
	end

	SMouseTarget:ClearAllPoints();
	SMouseTarget:SetParent("GameTooltip");
	SMouseTarget:SetPoint( SMouseTarget_PosTable[pos][1], "GameTooltip", SMouseTarget_PosTable[pos][2], 0, (SMouseTarget_PosTable[pos][3] or 0) );
	SMouseTarget_Saved["pos"] = pos;
end

function SMouseTarget_OnUpdate(self)
	local name, unit = GameTooltip:GetUnit()
	if unit and UnitExists(unit.."target") then
		unit = unit.."target"
		getglobal(self:GetName().."TextLeft1"):SetText(UnitName(unit));
		local r, g, b = GameTooltip_UnitColor(unit);
		getglobal(self:GetName().."TextLeft1"):SetTextColor(r, g, b);
		getglobal(self:GetName().."TextLeft1"):Show();
		local string;
		local level = UnitLevel(unit);
		local class = UnitClass(unit);
		local isplayer = UnitIsPlayer(unit);
		local dead = UnitIsDead(unit)
		local ghost = UnitIsGhost(unit);
		local type = UnitCreatureType(unit);
		local plus = UnitClassification(unit);
		if ( level > 0 ) then
			if ( plus and not plus == "rare" ) then
				string = "Lvl "..level.."+ ";
			else
				string = "Lvl "..level.." ";
			end
			if ( not dead and not ghost) then
				if ( isplayer ) then
					if ( class ) then
						string = string..class;
					end
					string = string.." (Player)";
				else
					if ( type ) then
						string = string.."("..type..")";
					else
						string = string.." (NPC)";
					end
				end
			end
		else
			if ( plus == "worldboss" ) then
				string = "BOSS ";
			else
				string = "?? ";
			end
			if ( type ) then
				string = string.."("..type..")";
			else
				string = string.."(?)";
			end
		end

		if ( ghost ) then
			string = string.."(Ghost)";
		elseif ( dead ) then
			string = string.."(Dead)";
		end

		if ( string ) then
			getglobal(self:GetName().."TextLeft2"):SetText(string);
			getglobal(self:GetName().."TextLeft2"):Show();
		else
			getglobal(self:GetName().."TextLeft2"):Hide();
		end

		local width = getglobal(self:GetName().."TextLeft1"):GetWidth();
		local width2 = getglobal(self:GetName().."TextLeft2"):GetWidth();
		if ( width2 > width ) then
			width = width2;
		end
		self:SetWidth(width+20)

		getglobal(self:GetName().."StatusBar"):SetMinMaxValues(0, UnitHealthMax(unit));
		getglobal(self:GetName().."StatusBar"):SetValue(UnitHealth(unit));
		if ( not SMouseTarget_Saved["nowarn"] and UnitIsUnit( unit, "player" ) ) then
			self:SetBackdropColor(0.5, 0.09, 0.09);
		elseif ( not SMouseTarget_Saved["noconfirm"] and UnitIsUnit( unit, "target" ) ) then
			self:SetBackdropColor(0.09, 0.5, 0.09);
		else
			self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
		end
		--self:SetAlpha(GameTooltip:GetAlpha())
		self:SetAlpha(1)
	else
		self:SetAlpha(0)
	end
end