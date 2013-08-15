module("extensions.ddz",package.seeall)

require("ddzuse")

extension = sgs.Package("ddz")

if tonumber(string.sub(sgs.Sanguosha:getVersion(), 1, 8)) < 20130610 then
	error("Sorry, the extension has not been supported by your version.")
end

local suits = {sgs.Card_Spade, sgs.Card_Heart, sgs.Card_Club, sgs.Card_Diamond}
for _,suit in ipairs(suits) do
	for num = 1,13 do
		local NewCard = sgs.Sanguosha:cloneCard("Slash",suit,num)
		if ddzuse then
			NewCard:setObjectName(sgs.Card_Suit2String(NewCard:getSuit()) .. num)
		end
		NewCard:setParent(extension)
	end
end

local joker = sgs.Sanguosha:cloneCard("Slash", sgs.Card_NoSuitBlack, 16)
local JOKER = sgs.Sanguosha:cloneCard("Slash", sgs.Card_NoSuitRed, 20)
if ddzuse then
	joker:setObjectName("JokerBlack")
	JOKER:setObjectName("JokerRed")
end
joker:setParent(extension)
JOKER:setParent(extension)

local point = {1,2,3,4,5,6,7,8,9,10,"J","Q","K"}
for num = 1,13 do
sgs.LoadTranslationTable{
	["spade" .. num] = "黑桃" .. point[num] ,
	[":spade" .. num] = "黑桃" .. point[num] ,
	["heart" .. num] = "红桃" .. point[num] ,
	[":heart" .. num] = "红桃" .. point[num] ,
	["club" .. num] = "梅花" .. point[num] ,
	[":club" .. num] = "梅花" .. point[num] ,
	["diamond" .. num] = "方块" .. point[num] ,
	[":diamond" .. num] = "方块" .. point[num] ,
}
end
sgs.LoadTranslationTable{
	["ddz"] = "太阳神斗地主",
	["JokerBlack"] = "小王",
	[":JokerBlack"] = "小王",
	["JokerRed"] = "大王",
	[":JokerRed"] = "大王",
}
ddz = {}

ddz.CardTypeList = {}

ddz.Pattern = {"Rocket", "Bomb", "Single", "Double", "Triple", "TripleSingle", "TripleDouble", "SingleFlush", "DoubleFlush", 
	"TripleFlush", "AirWing", "QuadrupleTwo"};

ddz.Size = { 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 1, 2, 0}

function ddz.getPos(table, value)
	for i, v in ipairs(table) do
		if v == value then
			return i
		end
	end
	return 0
end

function ddz.CompareWithColor(card1, card2)
	return card1:isBlack() and card2:isRed()
end

function ddz.CompareWithPoint(card1, card2)
	card1 = type(card1) == "number" and sgs.Sanguosha:getCard(card1) or card1
	card2 = type(card1) == "number" and sgs.Sanguosha:getCard(card2) or card2
	local number1, number2 = card1:getNumber(), card2:getNumber()
	if number1 ~= number2 then
		return ddz.getPos(ddz.Size, number1) < ddz.getPos(ddz.Size, number2)
	else
		return number1 == 0 and ddz.CompareWithColor(card1, card2)
	end
end

function ddz.isBomb(card)
	if card:subcardLength() ~= 4 then return false end
	local number =sgs.getCard(card:getEffectiveId()):getNumber()
	for _, cd in sgs.qlist(card:getSubcards()) do
		if sgs.Sanguosha:getCard(cd):getNumber() ~= number then
			return false
		end
	end
	return true
end

function ddz.isSingleFlush(card)
	local length = card:subcardLength()
	if length <5 or length > 12 then return false end
	local subcards = sgs.QList2Table(card:getSubcards())
	subcards:sort(ddz.CompareWithPoint)
	if sgs.Sanguosha:getCard(subcards[-1]):getNumber() == 2 then return false end
	for i = 1, length - 1 do
		if  sgs.Sanguosha:getCard(subcards[i]):getNumber() == 2 or 
			ddz.getPos(ddz.Size, sgs.Sanguosha:getCard(subcards[i]):getNumber()) + 1 ~= ddz.getPos(ddz.Size, sgs.Sanguosha:getCard(subcards[i + 1]):getNumber()) then
			return false
		end
	end
	return true
end

function ddz.isDoubleFlush(card)
	local length = card:subcardLength()
	if length < 6 or length % 2 == 1 then return false end
	local subcards = sgs.QList2Table(card:getSubcards())
	subcards:sort(ddz.CompareWithPoint)
	if sgs.Sanguosha:getCard(subcards[-1]):getNumber() == 2 or
		sgs.Sanguosha:getCard(subcards[-2]):getNumber() == 2 then return false end
	for i = 1, length - 1, 2 do
		if  sgs.Sanguosha:getCard(subcards[i]):getNumber() == 2 or 
			sgs.Sanguosha:getCard(subcards[i]):getNumber() ~= sgs.Sanguosha:getCard(subcards[i + 1]):getNumber() then
			return false
		end
	end
	for i = 2, length - 1, 2 do
		if  sgs.Sanguosha:getCard(subcards[i]):getNumber() == 2 or 
			ddz.getPos(ddz.Size, sgs.Sanguosha:getCard(subcards[i]):getNumber()) + 1 ~= ddz.getPos(ddz.Size, sgs.Sanguosha:getCard(subcards[i + 1]):getNumber()) then
			return false
		end
	end
	return true
end

function ddz.isTripleFlush(card)
	local length = card:subcardLength()
	if length < 6 or length % 3 ~= 0 then return false end
	local subcards = sgs.QList2Table(card:getSubcards())
	subcards:sort(ddz.CompareWithPoint)
	if sgs.Sanguosha:getCard(subcards[-1]):getNumber() == 2 or
		sgs.Sanguosha:getCard(subcards[-2]):getNumber() == 2 or
		sgs.Sanguosha:getCard(subcards[-3]):getNumber() == 2 then return false end
	for i = 1, length - 1, 3 do
		if  sgs.Sanguosha:getCard(subcards[i]):getNumber() == 2 or 
			sgs.Sanguosha:getCard(subcards[i]):getNumber() ~= sgs.Sanguosha:getCard(subcards[i + 1]):getNumber() then
			return false
		end
	end
	for i = 2, length - 1, 3 do
		if  sgs.Sanguosha:getCard(subcards[i]):getNumber() == 2 or 
			sgs.Sanguosha:getCard(subcards[i]):getNumber() ~= sgs.Sanguosha:getCard(subcards[i + 1]):getNumber() then
			return false
		end
	end
	for i = 3, length - 1, 3 do
		if  sgs.Sanguosha:getCard(subcards[i]):getNumber() == 2 or 
			ddz.getPos(ddz.Size, sgs.Sanguosha:getCard(subcards[i]):getNumber()) + 1 ~= ddz.getPos(ddz.Size, sgs.Sanguosha:getCard(subcards[i + 1]):getNumber()) then
			return false
		end
	end
	return true
end

function ddz.fillTripleX(card)
	local string = {}
	local subnum1 = {}
	for _, id in ipairs(subcards) do
		table.insert(subnum1, sgs.Sanguosha:getCard(id):getNumber())
	end
	local subnum2 = table.copyFrom(subnum1)
	subnum2:removeAll(subnum[1])
	local triple, x
	if #subnum2 == 3 then
		triple, x = subnum2[1], subnum1[1]
	else
		triple, x = subnum1[1], subnum2[1]
	end
	for i = 1, 3 do
		table.insert(string, tostring(triple))
	end
	for i = 1, card:subcardLength() - 3 do
		table.insert(string, tostring(x))
	end
	return string
end

function ddz.toString(card)
	local subcards = sgs.QList2Table(card:getSubcards())
	local string = {}
	local length = card:subcardsLength()
	if length <= 3 then
		if length == 1 and card:getNumber() == 0 then
			return card:isRed() and "red" or "black"
		end
		goto lab1
	elseif length == 4 then
		if ddz.isBomb(card) then
			goto lab1
		else
			string:insertTable(ddz.fillTripleX(card))
			goto lab2
		end
	elseif length == 5 then
		if ddz.isSingleFlush(card) then
			subcards:sort(ddz.CompareWithPoint)
			for _, id in ipairs(subcards) do
				table.insert(string, tostring(sgs.Sanguosha:getCard(id):getNumber()))
			end
		else
			string:insertTable(ddz.fillTripleX(card))
		end
		goto lab2
	elseif length == 6 then
		if ddz.isSingleFlush(card) then
			subcards:sort(ddz.CompareWithPoint)
			for _, id in ipairs(subcards) do
				table.insert(string, tostring(sgs.Sanguosha:getCard(id):getNumber()))
			end
		elseif ddz.isDoubleFlush(card) then
			subcards:sort(ddz.CompareWithPoint)
			for _, id in ipairs(subcards) do
				table.insert(string, tostring(sgs.Sanguosha:getCard(id):getNumber()))
			end
		elseif ddz.isTripleFlush(card) then
			subcards:sort(ddz.CompareWithPoint)
			for _, id in ipairs(subcards) do
				table.insert(string, tostring(sgs.Sanguosha:getCard(id):getNumber()))
			end
		end
	end
	::lab1:: for i = 1, length do
		table.insert(string, tostring(sgs.Sanguosha:getCard(subcards[1]):getNumber()))
	end
	::lab2:: return table.concat(string, "|")
end

function ddz.ModeTest(mode)
	local room = sgs.Sanguosha:currentRoom()
	local bans = sgs.Sanguosha:getBanPackages()
	local ban = 0
	for _, b in ipairs(bans) do
		if b == "standard_cards" or b == "standard_ex_cards" or b == "maneuvering" or b == "sp_cards" or b == "nostalgia" then
			ban = ban + 1
		end
	end
	local gamemode = room:getMode()
	if gamemode ~= mode or ban ~= 5 then
		room:doLightbox("$WrongMode", 5000)
		return true
	end
	return false
end

function ddz.StartDraw(splayer, skill)
	local room = sgs.Sanguosha:currentRoom()
	local players = room:getAllPlayers()
	for _,p in sgs.qlist(players) do
		if p:objectName() ~= splayer:objectName() then
			room:changeHero(p, "peasant", false, false, false, false)
		end
		--room:attachSkillToPlayer(p, skill)
	end
	::lab:: if room:getDrawPile():isEmpty() then
		room:swapPile()
	end
	local card = room:getDrawPile():at(math.random(0, room:getDrawPile():length() - 1))
	
	local log = sgs.LogMessage()
	log.type = "$DDZKeyCard" -- The Key Card appeared and it is xxx
	log.card_str = tostring(card)
	room:sendLog(log)
	
	local list = sgs.IntList()
	list:append(card)
	room:fillAG(list)
	local player = splayer
	while room:getDrawPile():length() > 3 do
		room:getThread():delay(100)
		player:drawCards(1)
		player = player:getNext()
	end
	room:clearAG()
	if not room:getCardOwner(card) then
	
		room:doLightbox("$DrawCardsAgain", 5000)
	
		local log = sgs.LogMessage()
		log.type = "$DDZNoOwner" -- Unfortunately, The Key Card xxx is one of the last three cards, we will draw cards again later
		log.card_str = tostring(card)
		room:sendLog(log)
	
		for _, p in sgs.qlist(players) do
			p:throwAllHandCards()
		end
		for _, id in sgs.qlist(room:getDrawPile()) do
			room:throwCard(id, nil)
		end
		goto lab
	end
	
	local log = sgs.LogMessage()
	log.type = "$DDZCardOwner" -- The Owner of cardxx is xxx, the first one to bid will be xx
	log.from = room:getCardOwner(card)
	log.card_str = tostring(card)
	room:sendLog(log)
	
	local tag = sgs.QVariant()
	tag:setValue(room:getCardOwner(card))
	room:doLightbox("$LandlordPrepared", 4000)
	room:setTag("LastWinner", tag)
	
	return false
	
end

function ddz.Bidding(players)
	local room = sgs.Sanguosha:currentRoom()
	room:setTag("DDZBidding", sgs.QVariant(0))
	local biddings = {"OnePoint", "TwoPoint", "ThreePoint", "GiveUp"}
	local cards = room:getNCards(3, false)
	local move = sgs.CardsMoveStruct()
	move.card_ids = cards
	move.to_place = sgs.Player_PlaceTable
	move.open = false
	room:moveCardsAtomic(move, false)
	room:getThread():delay()
	for _, p in sgs.qlist(players) do
		if #biddings == 1 then
			break
		end

		local choice = room:askForChoice(p, "DDZBidding", table.concat(biddings, "+"))
		
		local log = sgs.LogMessage()
		log.type = "#DDZBidding" -- xx has chosen choice
		log.from = p
		log.arg = choice
		room:sendLog(log)
		
		if choice ~= "GiveUp" then
			local j = 0
			local l =  #biddings
			for i = 1, l do
				if biddings[1] ~= choice then
					table.remove(biddings, 1)
				else
					table.remove(biddings, 1)
					break
				end
			end
			local qj = sgs.QVariant()
			if choice == "OnePoint" then
				j = 1
			elseif choice == "TwoPoint" then
				j = 2
			else
				j = 3
			end
			qj:setValue(j)
			room:setTag("DDZBidding", qj)
			local tag = sgs.QVariant()
			tag:setValue(p)
			room:setTag("LastWinner", tag)
		end
	end
	if #biddings == 4 then
		--[[room:setTag("DDZBidding", sgs.QVariant(1))
		local tag = sgs.QVariant()
		tag:setValue(players:first())
		room:setTag("LastWinner", tag)]]
		ddz.StartDraw(players:first(), "DDZVS")
	end
	local lord = room:getTag("LastWinner"):toPlayer()
	for _, p in sgs.qlist(players) do
		local role = "rebel"
		if p:objectName() == lord:objectName() then
			role = "lord"
			
			local log = sgs.LogMessage()
			log.type = "#DDZBiddingResult" -- xx will be the landlord
			log.from = p
			room:sendLog(log)
			
			room:changeHero(p, "landlord", false, false, false, false)
			
			room:doLightbox("$LandlordAppeared", 4000)
			move.open = true
			move.to = p
			move.to_place = sgs.Player_PlaceHand
			room:moveCardsAtomic(move, true)
		end
		room:setPlayerProperty(p, "role", sgs.QVariant(role))
		room:updateStateItem()
		room:resetAI(p)
	end
end

function ddz.Tag2Mark(players) 
	local room = sgs.Sanguosha:currentRoom()
	local ddztype = room:getTag("ddz_type"):toString()
	local suit = room:getTag("ddz_suit"):toString()
	local number = room:getTag("ddz_number"):toInt()
	local length = room:getTag("ddz_length"):toInt()
	local type_code = ddz.Type2Code(ddztype)
	local suit_code = ddz.Suit2Code(suit)
	for _,p in sgs.qlist(players) do
		room:setPlayerMark(p, "ddz_type", type_code)
		room:setPlayerMark(p, "ddz_suit", suit_code)
		room:setPlayerMark(p, "ddz_number", number)
		room:setPlayerMark(p, "ddz_length", length)
	end
	return nil
end

function ddz.Suit2Code(suit)
	local code = 0
	if suit == "spade" then
		code = 4
	elseif suit == "heart" then
		code = 3
	elseif suit == "club" then
		code = 2
	elseif suit == "diamond" then
		code = 1
	end
	return code
end

function ddz.Code2Suit(code) 
	local suit = "no_suit"
	if code == 4 then
		suit = "spade"
	elseif code == 3 then
		suit = "heart"
	elseif code == 2 then
		suit = "club"
	elseif code == 1 then
		suit = "diamond"
	end
	return suit
end

function ddz.Type2Code(ddztype) 
	local code = 0
	for i,tp in ipairs(ddz.CardTypeList) do
		if tp.name == ddztype then
			code = i
		end
	end
	return code
end

function ddz.TagClear()
	
	local room = sgs.Sanguosha:currentRoom()

	room:setTag("ddz_type", sgs.QVariant("FreePlay")) 
		
	room:setTag("ddz_suit", sgs.QVariant("no_suit"))
	
	room:setTag("ddz_number", sgs.QVariant(0))
	
	room:setTag("ddz_length", sgs.QVariant(0))
end

function ddz.NextPlayer(current, players) 
	local room = current:getRoom()
	local nextplayer = current:getNext()
	while nextplayer:objectName() ~= current:objectName() do
		if players:contains(nextplayer) then
			break
		end
		nextplayer = nextplayer:getNext()
	end
	return nextplayer
end

function ddz.OneTurn(players, pattern, prompt) 

	local room = sgs.Sanguosha:currentRoom()

	ddz.TagClear() 
	
	local current = room:getTag("LastWinner"):toPlayer() 
	
	local tag = sgs.QVariant()
	tag:setValue(current)
	room:setTag("CurrentWinner", tag)
	
	ddz.Tag2Mark(players) 
	
	local used = true
	
	while used do
		local used1 = room:askForUseCard(current, pattern, prompt)
		if current:getHandcardNum() == 0 then
			return current
		end
		current = ddz.NextPlayer(current, players)
		local used2 = (current:objectName() == room:getTag("CurrentWinner"):toPlayer():objectName())
		ddz.Tag2Mark(players) 
		used = used1 or not used2
	end
	
	current = room:getTag("CurrentWinner"):toPlayer()
	local LastWinner = sgs.QVariant()
	LastWinner:setValue(current)
	room:setTag("LastWinner", LastWinner) 
	
	room:getThread():delay(1500)
	
	return nil
	
end

function ddz.CreateCardType(DDZtype)
	assert(type(DDZtype) == "table")
	assert(type(DDZtype.name) == "string")
	if DDZtype.ambiguity then assert(type(DDZtype.ambiguity) == "function") end
	assert(type(DDZtype.judging) == "function")
	assert(type(DDZtype.trump) == "number")
	assert(type(DDZtype.number) == "function")
	assert(type(DDZtype.suit) == "function")
	assert(type(DDZtype.compare) == "function")
	table.insert(ddz.CardTypeList, DDZtype)
end

DDZCard = sgs.CreateSkillCard
{
	name = "DDZCard",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		local subcards = self:getSubcards()
		local pb_type = {}
		local suit = ""
		local pb_number = 0
		local cards = sgs.QList2Table(subcards)
		local cardlist = {}
		for _,id in ipairs(cards) do
			local card = sgs.Sanguosha:getCard(id)
			table.insert(cardlist, card)
		end
		local trump = -1
		
		if room:getTag("ddz_type"):toString() == "FreePlay" then
			local n = 0
			local PossibleType = {}
			for _, st in ipairs(ddz.CardTypeList) do
				if st.judging(cardlist) then
					table.insert(PossibleType, st.name)
					n = n + 1
				end
			end
			if n > 1 then
				local pb_typename = room:askForChoice(source, "TypeChosen", table.concat(PossibleType, "+"))
				for _, tp in sgs.qlist(ddz.CardTypeList) do
					if tp.name == pb_typename then
						pb_type = tp
						break
					end
				end
			else
				for _,st in ipairs(ddz.CardTypeList) do
					if st.trump > trump then
					if st.judging(cardlist) then
							trump = st.trump
							pb_type = st
						end
					end
				end
			end
		else
			for _,st in ipairs(ddz.CardTypeList) do
				if st.trump > trump then
					if st.judging(cardlist) then
						trump = st.trump
						pb_type = st
					end
				end
			end
		end
		if pb_type then
			pb_suit = pb_type.suit(cardlist)
			
			if pb_type.ambiguity then
				local values = pb_type.ambiguity(cardlist, room:getTag("ddz_number"):toInt())
				if values then
					pb_number = tonumber(room:askForChoice(source,"NumberChosen", table.concat(values, "+")))
					if pb_number == 1 then 
						pb_number = 14 
					elseif pb_number == 2 then
						pb_number = 15
					end
				else
					pb_number = pb_type.number(cardlist)
				end
			else
				pb_number = pb_type.number(cardlist)
			end
		end
		
		
		
		room:setTag("ddz_type", sgs.QVariant(pb_type.name)) 
		room:setTag("ddz_suit", sgs.QVariant(pb_suit))	
		local pn = sgs.QVariant()
		pn:setValue(pb_number)
		room:setTag("ddz_number", pn)
		room:setTag("ddz_length", sgs.QVariant(#cards))
		local tag = sgs.QVariant()
		tag:setValue(source)
		room:setTag("CurrentWinner", tag)
		
	end
}

DDZVS = sgs.CreateViewAsSkill
{
	name = "DDZVS",
	n = 999,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		local player = sgs.Self
		local pb_type_code = player:getMark("ddz_type")
		local pb_type = ddz.CardTypeList[pb_type_code]
		local pb_suit_code = player:getMark("ddz_suit")
		local pb_suit = ddz.Code2Suit(pb_suit_code)
		local pb_number = player:getMark("ddz_number")
		local pb_length = player:getMark("ddz_length")
		local cardlist = cards
		local can_use = false
		if pb_type.judging(cardlist) then
			if pb_length == #cardlist then
				if pb_type.compare(cardlist, pb_suit, pb_number) then
					can_use = true
				end
			end
		else
			for _,pb in ipairs(ddz.CardTypeList) do
				if pb.trump > pb_type.trump then
					if pb.judging(cardlist) then
						can_use = true
						break
					end
				end
			end
		end
		if can_use then
			local acard = DDZCard:clone()
			for _,id in ipairs(cards) do
				acard:addSubcard(id)
			end
			return acard
		end
		return nil
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@"..self:objectName()
	end
}

FreePlay = ddz.CreateCardType
{
	name = "FreePlay",
	trump = -1,
	judging = function(cards) return false end,
	suit = function(cards) return "no_suit" end,
	number = function(cards) return 0 end,
	compare = function(cards, suit, number) return false end
}

Single = ddz.CreateCardType
{
	name = "Single",
	trump = 0,
	judging = function(cards) return #cards == 1 end,
	suit = function(cards) return cards[1]:getSuitString() end,
	number = function(cards) 		
		local number =  cards[1]:getNumber()
		if number == 1 then
			number = 14
		elseif number == 2 then
			number = 15
		end
		return number
	end,
	compare = function(cards, suit, number)
		local cardnum = cards[1]:getNumber()
		if cardnum == 1 then
			cardnum = 14
		elseif cardnum == 2 then
			cardnum = 15
		end
		return cardnum > number
	end
}

Double = ddz.CreateCardType
{
	name = "Double",
	trump = 0,
	judging = function(cards) 
		return #cards == 2 and cards[1]:getNumber() == cards[2]:getNumber()
	end,
	suit = function(cards)
		if cards[1]:getSuit() == cards[2]:getSuit() then
			return cards[1]:getSuitString()
		else
			return "no_suit"
		end
	end,
	number = function(cards)
		local number =  cards[1]:getNumber()
		if number == 1 then
			number = 14
		elseif number == 2 then
			number = 15
		end
		return number
	end,
	compare = function(cards, suit, number)
		local cardnum = cards[1]:getNumber()
		if cardnum == 1 then
			cardnum = 14
		elseif cardnum == 2 then
			cardnum = 15
		end
		return cardnum > number
	end
}

Triple = ddz.CreateCardType
{
	name = "Triple",
	trump = 0,
	judging = function(cards)
		return #cards == 3 and cards[1]:getNumber() == cards[2]:getNumber() and 
			cards[1]:getNumber() == cards[3]:getNumber()
	end,
	suit = function(cards)
		if cards[1]:getSuit() == cards[2]:getSuit() and cards[1]:getSuit() == cards[3]:getSuit() then
			return cards[1]:getSuitString()
		else
			return "no_suit"
		end
	end,
	number = function(cards)
		local number =  cards[1]:getNumber()
		if number == 1 then
			number = 14
		elseif number == 2 then
			number = 15
		end
		return number
	end,
	compare = function(cards, suit, number)
		local cardnum = cards[1]:getNumber()
		if cardnum == 1 then
			cardnum = 14
		elseif cardnum == 2 then
			cardnum = 15
		end
		return cardnum > number
	end
}

TripleSingle = ddz.CreateCardType
{
	name = "TripleSingle",
	trump = 0,
	judging = function(cards)
		local num1 = -1
		local num2 = -1
		local list1 = {}
		local list2 = {}
		if #cards ~= 4 then return false end
		for _,cd in ipairs(cards) do
			local num = cd:getNumber()
			if num == 1 then
				num = 14
			elseif num == 2 then
				num = 15
			end
			if num1 == -1 or num == num1 then
				num1 = num
				table.insert(list1, cd)
			elseif num2 == -1 or num == num2 then
				num2 = num
				table.insert(list2, cd)
			end
		end
		return #list1 + #list2 == 4 and #list1 * #list2 == 3
	end,
	suit = function(cards)
		return "no_suit"
	end,
	number = function(cards)
		local num1 = -1
		local num2 = -1
		local list1 = {}
		local list2 = {}
		for _,cd in ipairs(cards) do
			local num = cd:getNumber()
			if num == 1 then
				num = 14
			elseif num == 2 then
				num = 15
			end
			if num1 == -1 or num == num1 then
				num1 = num
				table.insert(list1, num)
			elseif num2 == -1 or num == num2 then
				num2 = num
				table.insert(list2, num)
			end
		end
		if #list1 == 3 then
			return list1[1]
		else
			return list2[1]
		end
	end,
	compare = function(cards, suit, number)
		local num1 = -1
		local num2 = -1
		local list1 = {}
		local list2 = {}
		for _,cd in ipairs(cards) do
			local num = cd:getNumber()
			if num == 1 then
				num = 14
			elseif num == 2 then
				num = 15
			end
			if num1 == -1 or num == num1 then
				num1 = num
				table.insert(list1, num)
			elseif num2 == -1 or num == num2 then
				num2 = num
				table.insert(list2, num)
			end
		end
		if #list1 == 3 then
			return list1[1] > number
		else
			return list2[1] > number
		end
	end
}
TripleDouble = ddz.CreateCardType
{
	name = "TripleDouble",
	trump = 0,
	judging = function(cards)
		local num1 = -1
		local num2 = -1
		local list1 = {}
		local list2 = {}
		if #cards ~= 5 then return false end
		for _,cd in ipairs(cards) do
			local num = cd:getNumber()
			if num == 1 then
				num = 14
			elseif num == 2 then
				num = 15
			end
			if num1 == -1 or num == num1 then
				num1 = num
				table.insert(list1, cd)
			elseif num2 == -1 or num == num2 then
				num2 = num
				table.insert(list2, cd)
			end
		end
		return #list1 + #list2 == 5 and #list1 * #list2 == 6
	end,
	suit = function(cards)
		return "no_suit"
	end,
	number = function(cards)
		local num1 = -1
		local num2 = -1
		local list1 = {}
		local list2 = {}
		for _,cd in ipairs(cards) do
			local num = cd:getNumber()
			if num == 1 then
				num = 14
			elseif num == 2 then
				num = 15
			end
			if num1 == -1 or num == num1 then
				num1 = num
				table.insert(list1, num)
			elseif num2 == -1 or num == num2 then
				num2 = num
				table.insert(list2, num)
			end
		end
		if #list1 == 3 then
			return list1[1]
		else
			return list2[1]
		end
	end,
	compare = function(cards, suit, number)
		local num1 = -1
		local num2 = -1
		local list1 = {}
		local list2 = {}
		for _,cd in ipairs(cards) do
			local num = cd:getNumber()
			if num == 1 then
				num = 14
			elseif num == 2 then
				num = 15
			end
			if num1 == -1 or num == num1 then
				num1 = num
				table.insert(list1, num)
			elseif num2 == -1 or num == num2 then
				num2 = num
				table.insert(list2, num)
			end
		end
		if #list1 == 3 then
			return list1[1] > number
		else
			return list2[1] > number
		end
	end
}

QuadrupleTwo = ddz.CreateCardType
{
	name = "QuadrupleTwo",
	trump = 0,
	judging = function(cards)
		local num1 = -1
		local num2 = -1
		local num3 = -1
		local list1 = {}
		local list2 = {}
		local list3 = {}
		if #cards ~= 6 then return false end
		for _,cd in ipairs(cards) do
			local num = cd:getNumber()
			if num == 1 then
				num = 14
			elseif num == 2 then
				num = 15
			end
			if num1 == -1 or num == num1 then
				num1 = num
				table.insert(list1, cd)
			elseif num2 == -1 or num == num2 then
				num2 = num
				table.insert(list2, cd)
			elseif num3 == -1 or num == num3 then
				num3 = num
				table.insert(list3, cd)
			end
		end
		return #list1 == 4 or #list2 == 4 or #list3 == 4
	end,
	suit = function(cards)
		return "no_suit"
	end,
	number = function(cards)
		local num1 = -1
		local num2 = -1
		local num3 = -1
		local list1 = {}
		local list2 = {}
		local list3 = {}
		for _,cd in ipairs(cards) do
			local num = cd:getNumber()
			if num == 1 then
				num = 14
			elseif num == 2 then
				num = 15
			end
			if num1 == -1 or num == num1 then
				num1 = num
				table.insert(list1, num)
			elseif num2 == -1 or num == num2 then
				num2 = num
				table.insert(list2, num)
			elseif num3 == -1 or num == num3 then
				num3 = num
				table.insert(list3, num)
			end
		end
		if #list1 == 4 then
			return list1[1]
		elseif #list2 == 4 then
			return list2[1]
		else
			return list3[1]
		end
	end,
	compare = function(cards, suit, number)
		local num1 = -1
		local num2 = -1
		local num3 = -1
		local list1 = {}
		local list2 = {}
		local list3 = {}
		for _,cd in ipairs(cards) do
			local num = cd:getNumber()
			if num == 1 then
				num = 14
			elseif num == 2 then
				num = 15
			end
			if num1 == -1 or num == num1 then
				num1 = num
				table.insert(list1, num)
			elseif num2 == -1 or num == num2 then
				num2 = num
				table.insert(list2, num)
			elseif num3 == -1 or num == num3 then
				num3 = num
				table.insert(list3, num)
			end
		end
		if #list1 == 4 then
			return list1[1] > number
		elseif #list2 == 4 then
			return list2[1] > number
		else
			return list3[1] > number
		end
	end
}

QuadrupleTwoDouble = ddz.CreateCardType
{
	name = "QuadrupleTwoDouble",
	trump = 0,
	judging = function(cards)
		local num1 = -1
		local num2 = -1
		local num3 = -1
		local list1 = {}
		local list2 = {}
		local list3 = {}
		if #cards ~= 8 then return false end
		for _,cd in ipairs(cards) do
			local num = cd:getNumber()
			if num == 1 then
				num = 14
			elseif num == 2 then
				num = 15
			end
			if num1 == -1 or num == num1 then
				num1 = num
				table.insert(list1, cd)
			elseif num2 == -1 or num == num2 then
				num2 = num
				table.insert(list2, cd)
			elseif num3 == -1 or num == num3 then
				num3 = num
				table.insert(list3, cd)
			end
		end
		local lists = {list1, list2, list3}
		local yes = false
		table.sort(lists, (function(llist, rlist) return #llist > #rlist; end))
		for _, list in ipairs(lists) do
			if #lists == 2 then
				if #list == 4 then
					yes = true
				elseif #list == 2 then
					lists:removeOne(list)
				end
			elseif #lists == 1 then
				if #list == 2 then
					yes = true
				end
			else
				if #list == 4 then
					lists:removeOne(list)
				end
			end
		end
		return yes
	end,
	suit = function(cards)
		return "no_suit"
	end,
	number = function(cards)
		local num1 = -1
		local num2 = -1
		local num3 = -1
		local list1 = {}
		local list2 = {}
		local list3 = {}
		for _,cd in ipairs(cards) do
			local num = cd:getNumber()
			if num == 1 then
				num = 14
			elseif num == 2 then
				num = 15
			end
			if num1 == -1 or num == num1 then
				num1 = num
				table.insert(list1, num)
			elseif num2 == -1 or num == num2 then
				num2 = num
				table.insert(list2, num)
			elseif num3 == -1 or num == num3 then
				num3 = num
				table.insert(list3, num)
			end
		end
		if #list1 == 4 then
			return list1[1]
		elseif #list2 == 4 then
			return list2[1]
		else
			return list3[1]
		end
	end,
	compare = function(cards, suit, number)
		local num1 = -1
		local num2 = -1
		local num3 = -1
		local list1 = {}
		local list2 = {}
		local list3 = {}
		for _,cd in ipairs(cards) do
			local num = cd:getNumber()
			if num == 1 then
				num = 14
			elseif num == 2 then
				num = 15
			end
			if num1 == -1 or num == num1 then
				num1 = num
				table.insert(list1, num)
			elseif num2 == -1 or num == num2 then
				num2 = num
				table.insert(list2, num)
			elseif num3 == -1 or num == num3 then
				num3 = num
				table.insert(list3, num)
			end
		end
		local bigger = false
		if #list1 == 4 then
			bigger = list1[1] > number
		end
		if #list2 == 4 then
			bigger = list2[1] > number
		end
		if #list3 == 4 then
			bigger = list3[1] > number
		end
		return bigger
	end,
	ambiguity = function(cards, number)
		local num1 = -1
		local num2 = -1
		local num3 = -1
		local list1 = {}
		local list2 = {}
		local list3 = {}
		if #cards ~= 8 then return false end
		for _,cd in ipairs(cards) do
			local num = cd:getNumber()
			if num1 == -1 or num == num1 then
				num1 = num
				table.insert(list1, cd)
			elseif num2 == -1 or num == num2 then
				num2 = num
				table.insert(list2, cd)
			elseif num3 == -1 or num == num3 then
				num3 = num
				table.insert(list3, cd)
			end
		end
		local lists = {list1, list2, list3}
		local values = {}
		for _, list in ipairs(lists) do
			if #list ~= 4 then continue end
			if list[1] > number then
				table.insert(values, tostring(list[1]))
			end
		end
		if #values > 1 then return values end
		return nil
	end
}

SingleFlush = ddz.CreateCardType
{
	name = "SingleFlush",
	trump = 0,
	judging = function(cards)
		if #cards < 5 then return false end
		local min_num = 99
		local max_num = -1
		local nums = sgs.IntList()
		for _,cd in ipairs(cards) do
			local number = cd:getNumber()
			if number == 1 then
				number = 14
			elseif number == 2 then
				return false
			end
			if nums:contains(number) then
				return false
			end
			nums:append(number)
			if number < min_num then
				min_num = number
			end
			if number > max_num then
				max_num = number
			end
		end
		return max_num - min_num == #cards - 1
	end,
	suit = function(cards)
		return "no_suit"
	end,
	number = function(cards)
		local max_num = -1
		for _,cd in ipairs(cards) do
			local number = cd:getNumber()
			if number == 1 then
				number = 14
			end
			if number > max_num then
				max_num = number
			end
		end
		return max_num
	end,
	compare = function(cards, suit, number)
		local max_num = -1
		for _,cd in ipairs(cards) do
			local number = cd:getNumber()
			if number == 1 then
				number = 14
			end
			if number > max_num then
				max_num = number
			end
		end
		return max_num > number
	end
}

DoubleFlush = ddz.CreateCardType
{
	name = "DoubleFlush",
	trump = 0,
	judging = function(cards)
		local list1 = sgs.IntList()
		local list2 = sgs.IntList()
		if #cards < 6 then return false end
		for _,cd in ipairs(cards) do
			local number = cd:getNumber()
			if number == 1 then
				number = 14
			elseif number == 2 then
				return false
			end
			if list2:contains(number) then
				return false
			end
			if list1:contains(number) then
				list1:removeOne(number)
				list2:append(number)
			else
				list1:append(number)
			end
		end
		if 2 * list2:length() == #cards then
			local min_num = 99
			local max_num = -1
			for _,num in sgs.qlist(list2) do
				if num < min_num then
					min_num = num
				end
				if num > max_num then
					max_num = num
				end
			end
			return max_num - min_num == list2:length() - 1
		end
		return false
	end,
	suit = function(cards)
		return "no_suit"
	end,
	number = function(cards)
		local min_num = 99
		for _,cd in ipairs(cards) do
			local number = cd:getNumber()
			if number == 1 then
				number = 14
			end
			if number < min_num then
				min_num = number
			end
		end
		return min_num
	end,
	compare = function(cards, suit, number)
		local min_num = 99
		for _,cd in ipairs(cards) do
			local number = cd:getNumber()
			if number == 1 then
				number = 14
			end
			if number < min_num then
				min_num = number
			end
		end
		return min_num > number
	end
}

TripleFlush = ddz.CreateCardType
{
	name = "TripleFlush",
	trump = 0,
	judging = function(cards)
		local list1 = sgs.IntList()
		local list2 = sgs.IntList()
		local list3 = sgs.IntList()
		if #cards < 6 then return false end
		for _,cd in ipairs(cards) do
			local number = cd:getNumber()
			if number == 1 then
				number = 14
			elseif number == 2 then
				return false
			end
			if list3:contains(number) then
				return false
			end
			if list2:contains(number) then
				list2:removeOne(number)
				list3:append(number)
			elseif list1:contains(number) then
				list1:removeOne(number)
				list2:append(number)
			else
				list1:append(number)
			end
		end
		if 3 * list3:length() == #cards then
			local min_num = 99
			local max_num = -1
			for _,num in sgs.qlist(list3) do
				if num < min_num then
					min_num = num
				end
				if num > max_num then
					max_num = num
				end
			end
			return max_num - min_num == list3:length() - 1
		end
		return false
	end,	
	suit = function(cards)
		return "no_suit"
	end,
	number = function(cards)
		local min_num = 99
		for _,cd in ipairs(cards) do
			local number = cd:getNumber()
			if number == 1 then
				number = 14
			end
			if number < min_num then
				min_num = number
			end
		end
		return min_num
	end,
	compare = function(cards, suit, number)
		local min_num = 99
		for _,cd in ipairs(cards) do
			local number = cd:getNumber()
			if number == 1 then
				number = 14
			end
			if number < min_num then
				min_num = number
			end
		end
		return min_num > number
	end
}

AirSingleWing = ddz.CreateCardType
{
	name = "AirSingleWing",
	trump = 0,
	judging = function(cards)
		local list1 = sgs.IntList()
		local list2 = sgs.IntList()
		local list3 = sgs.IntList()
		if #cards < 6 then return false end
		if #cards%4 ~= 0 then return false end
		for _,cd in ipairs(cards) do
			local number = cd:getNumber()
			if number == 1 then
				number = 14
			end
			if list2:contains(number) then
				list2:removeOne(number)
				list3:append(number)
			elseif list1:contains(number) then
				list1:removeOne(number)
				list2:append(number)
			else
				list1:append(number)
			end
		end
		if list3:isEmpty() then return false end
		local length = #cards / 4
		local formed = true
		for _,i in sgs.qlist(list3) do
			for j = 1,(length-1) do
				if not list3:contains(i+j) then
					formed = false
					break
				end
				formed = true
			end
		end
		if list3:contains(2) then
			return false
		end
		return formed
	end,		
	suit = function(cards)
		return "no_suit"
	end,
	number = function(cards)
		local list1 = sgs.IntList()
		local list2 = sgs.IntList()
		local list3 = sgs.IntList()
		for _,cd in ipairs(cards) do
			local number = cd:getNumber()
			if number == 1 then
				number = 14
			end
			if list2:contains(number) then
				list2:removeOne(number)
				list3:append(number)
			elseif list1:contains(number) then
				list1:removeOne(number)
				list2:append(number)
			else
				list1:append(number)
			end
		end
		local length = #cards / 4
		local formed = 0
		for _,i in sgs.qlist(list3) do
			for j = 1,(length-1) do
				if not list3:contains(i-j) then
					formed = 0
					break
				end
				formed = i
			end
		end
		return formed
	end,				
	compare = function(cards, suit, number)
		local list1 = sgs.IntList()
		local list2 = sgs.IntList()
		local list3 = sgs.IntList()
		for _,cd in ipairs(cards) do
			local number = cd:getNumber()
			if number == 1 then
				number = 14
			end
			if list2:contains(number) then
				list2:removeOne(number)
				list3:append(number)
			elseif list1:contains(number) then
				list1:removeOne(number)
				list2:append(number)
			else
				list1:append(number)
			end
		end
		local length = #cards / 4
		local formed = 0
		for _,i in sgs.qlist(list3) do
			for j = 1,(length-1) do
				if not list3:contains(i-j) then
					formed = 0
					break
				end
				formed = i
			end
		end
		return formed > number
	end
}

AirDoubleWing = ddz.CreateCardType
{
	name = "AirDoubleWing",
	trump = 0,
	judging = function(cards)
		local list1 = sgs.IntList()
		local list2 = sgs.IntList()
		local list3 = sgs.IntList()
		local list4 = sgs.IntList()
		if #cards < 6 then return false end
		if #cards%5 ~= 0 then return false end
		for _,cd in ipairs(cards) do
			local number = cd:getNumber()
			if number == 1 then
				number = 14
			elseif number == 2 then
				return false
			end
			if list3:contains(number) then
				list3:removeOne(number)
				list4:append(number)
			end
			if list2:contains(number) then
				list2:removeOne(number)
				list3:append(number)
			elseif list1:contains(number) then
				list1:removeOne(number)
				list2:append(number)
			else
				list1:append(number)
			end
		end
		if 5 * list3:length() == #cards and list3:length() == list2:length() + 2 * list4:length() then
			local min_num = 99
			local max_num = -1
			for _,num in sgs.qlist(list3) do
				if num < min_num then
					min_num = num
				end
				if num > max_num then
					max_num = num
				end
			end
			return max_num - min_num == list3:length() - 1
		end
		return false
	end,		
	suit = function(cards)
		return "no_suit"
	end,
	number = function(cards)
		local list1 = sgs.IntList()
		local list2 = sgs.IntList()
		local list3 = sgs.IntList()
		local list4 = sgs.IntList()
		if #cards < 6 then return false end
		if #cards%5 ~= 0 then return false end
		for _,cd in ipairs(cards) do
			local number = cd:getNumber()
			if number == 1 then
				number = 14
			elseif number == 2 then
				return false
			end
			if list3:contains(number) then
				list3:removeOne(number)
				list4:append(number)
			end
			if list2:contains(number) then
				list2:removeOne(number)
				list3:append(number)
			elseif list1:contains(number) then
				list1:removeOne(number)
				list2:append(number)
			else
				list1:append(number)
			end
		end
		local min_num = 99
		for _,i in sgs.qlist(list3) do
			if i < min_num then
				min_num = i
			end
		end
		return min_num
	end,				
	compare = function(cards, suit, number)
		local list1 = sgs.IntList()
		local list2 = sgs.IntList()
		local list3 = sgs.IntList()
		local list4 = sgs.IntList()
		if #cards < 6 then return false end
		if #cards%5 ~= 0 then return false end
		for _,cd in ipairs(cards) do
			local number = cd:getNumber()
			if number == 1 then
				number = 14
			elseif number == 2 then
				return false
			end
			if list3:contains(number) then
				list3:removeOne(number)
				list4:append(number)
			end
			if list2:contains(number) then
				list2:removeOne(number)
				list3:append(number)
			elseif list1:contains(number) then
				list1:removeOne(number)
				list2:append(number)
			else
				list1:append(number)
			end
		end
		local min_num = 99
		for _,i in sgs.qlist(list3) do
			if i < min_num then
				min_num = i
			end
		end
		return min_num > number
	end
}	

Bomb = ddz.CreateCardType
{
	name = "Bomb",
	trump = 1,
	judging = function(cards)
		if #cards ~= 4 then
			return false
		end
		local num = cards[1]:getNumber()
		for _,cd in ipairs(cards) do
			if cd:getNumber() ~= num then
				return false
			end
		end
		return true
	end,
	suit = function(cards)
		return "no_suit"
	end,
	number = function(cards)
		local number = cards[1]:getNumber()
		if number == 1 then
			number = 14
		elseif number == 2 then
			number = 15
		end
		return number
	end,
	compare = function(cards, suit, number)
		local num = cards[1]:getNumber()
		if num == 1 then
			num = 14
		elseif num == 2 then
			num = 15
		end
		return num > number	
	end
}

Rocket = ddz.CreateCardType
{
	name = "Rocket",
	trump = 2,
	judging = function(cards)
		if #cards ~= 2 then return false end
		local number1 = cards[1]:getNumber()
		local number2 = cards[2]:getNumber()
		return number1 + number2 == 36 and number1 * number2 == 320
	end,
	suit = function(cards)
		return "no_suit"
	end,
	number = function(cards)
		return 0
	end,
	compare = function(cards, suit, number)
		return false
	end
}

peasant = sgs.General(extension, "peasant", "god", 0)
landlord = sgs.General(extension, "landlord", "god", 0, true, true, true)

DDZGame = sgs.CreateTriggerSkill
{
	name = "#DDZGame",
	events = {sgs.GameStart, sgs.CardUsed},
	frequency = sgs.Skill_Compulsory,
	can_trigger = function(self, target)
		return target
	end,
	on_trigger = function(self, event, player, data)
		if event == sgs.GameStart then
		
			local swapcount = sgs.GetConfig("PileSwappingLimitation", 5)
			
			if swapcount < 10 then
				sgs.SetConfig("PileSwappingLimitation", 10)
			end
		
			local room = player:getRoom()
			
			if ddz.ModeTest("03p") then 
				room:gameOver("rebel")
			end
		
			local players = room:getAlivePlayers()
				
			for _,p in sgs.qlist(players) do
				p:gainMark("@points", 15)
			end
				
			while true do
		
				local winner = false
				room:setTag("DDZMult", sgs.QVariant(1))
				
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if p:getGeneralName() == "landlord" then
						room:changeHero(p, "peasant", false, false, false, false)
					end
				end
			
				ddz.StartDraw(player, "DDZVS")
				
				
				local plrs = sgs.SPlayerList()
				local first = room:getTag("LastWinner"):toPlayer()
				plrs:append(first)
				for i = 1, 2 do
					plrs:append(first:getNext())
					first = first:getNext()
				end
		
				ddz.Bidding(plrs)
		
				while not winner do
					winner = ddz.OneTurn(players, "@@DDZVS", "@DDZVS")
				end
				
				local winner_role = winner:getRole()
				local springfulfilled = true
				if winner_role == "lord" then
					local others = room:getOtherPlayers(winner)
					for _,p in sgs.qlist(others) do
						if p:getMark("putimes") ~= 0 then
							springfulfilled = false
							break
						end
					end
				else
					local lord = room:getLord()
					if lord:getMark("putimes") > 1 then
						springfulfilled = false
					end
				end
				if springfulfilled then
					local DDZMult = room:getTag("DDZMult"):toInt()
					DDZMult = DDZMult * 2
					local pm = sgs.QVariant()
					pm:setValue(DDZMult)
					room:setTag("DDZMult", pm)	
				end
					
				local mult_bidding = (room:getTag("DDZMult"):toInt()) * (room:getTag("DDZBidding"):toInt())
				
				if winner_role == "lord" then
					for _,p in sgs.qlist(players) do
						if p:isLord() then
							p:gainMark("@points", mult_bidding * 2)
						else
							p:loseMark("@points", mult_bidding)
						end
					end
				else
					for _,p in sgs.qlist(players) do
						if p:isLord() then
							p:loseMark("@points", mult_bidding*2)
						else
							p:gainMark("@points", mult_bidding)
						end
					end	
				end
				room:setTag("DDZMult", sgs.QVariant(1))
				room:setTag("DDZBidding", sgs.QVariant(0))
				for _,p in sgs.qlist(players) do
					if p:getMark("@points") == 0 then break end
					room:setPlayerMark(p, "putimes", 0)
					p:throwAllHandCards()
				end
			end
			
			local max_point = -1
			local final_winner
			for _,p in sgs.qlist(players) do
				if p:getMark("@points") > max_point then
					max_point = p:getMark("@points")
					final_winner = p
				end
			end
			room:setPlayerProperty(final_winner, "role", sgs.QVariant("lord"))
			for _,p in sgs.qlist(room:getOtherPlayers(final_winner)) do
				room:setPlayerProperty(p, "role", sgs.QVariant("rebel"))
			end
			
			if sgs.GetConfig("PileSwappingLimitation", 5) ~= swapcount then
				sgs.SetConfig("PileSwappingLimitation", swapcount)
			end
			
			room:gameOver("lord")
			
		elseif event == sgs.CardUsed then			
			local room = player:getRoom()
			local use = data:toCardUse()
			if use.card:objectName() ~= "DDZCard" then return false end
			local mark = use.from:getMark("putimes")
			room:addPlayerMark(use.from, "putimes")
			local card_ids = use.card:getSubcards()
			local cards = {}
			for _,id in sgs.qlist(card_ids) do
				local card = sgs.Sanguosha:getCard(id)
				table.insert(cards, card)
			end
			for _,i in ipairs(ddz.CardTypeList) do
				if i.trump > 0 then
					if i.judging(cards) then
						local pockermult = room:getTag("DDZMult"):toInt()
						local n_pockermult = pockermult * 2
						local tag = sgs.QVariant()
						tag:setValue(n_pockermult)
						room:setTag("DDZMult", tag)
					end
				end
			end
		end		
		
	end
}

DDZGameS = sgs.CreateGameStartSkill
{
	name = "#DDZGameS",
	on_gamestart = function(self, player)
		local room = player:getRoom()
		if not room:findPlayerBySkillName("#DDZGame") then
			room:acquireSkill(player, "#DDZGame")
		end
	end
}

peasant:addSkill(DDZGameS)

local skillList=sgs.SkillList()
if not sgs.Sanguosha:getSkill("DDZVS") then
	skillList:append(DDZVS)
end	
if not sgs.Sanguosha:getSkill("#DDZGame") then
	skillList:append(DDZGame)
end	
sgs.Sanguosha:addSkills(skillList)

sgs.LoadTranslationTable{
	["$WrongMode"] = "无法启动斗地主模式",
	["$DrawCardsAgain"] = "重新发牌",
	

	["peasant"] = "农民",
	["landlord"] = "地主",
	
	["$DDZKeyCard"] = "本次的地主牌为 %card",
	["$DDZNoOwner"] = "%card 为底牌之一，重新发牌",
	["$DDZCardOwner"] = "%from 得到了地主牌 %card",
	["@points"] = "积分",
	["$LandlordPrepared"] = "叫分开始",
	["#DDZBidding"] = "%from 选择 %arg",
	["DDZBidding"] = "叫地主",
	["OnePoint"] = "一分",
	["TwoPoint"] = "二分",
	["ThreePoint"] = "三分",
	["GiveUp"] = "不叫",
	["#DDZBiddingResult"] = "%from 成为地主",
	["$LandlordAppeared"] = "地主产生",
	
	["@DDZVS"] = "请出牌",
	["~DDZVS"] = "选择若干张牌→点击确定",
}

sgs.LoadTranslationTable{
	["FreePlay"] = "自由出牌",
	["Single"] = "单牌",
	["Double"] = "对子",
	["Triple"] = "三张",
	["TripleSingle"] = "三带一",
	["TripleDouble"] = "三带二",
	["SingleFlush"] = "顺子",
	["DoubleFlush"] = "双顺",
	["TripleFlush"] = "三顺",
	["AirWing"] = "飞机带翅膀",
	["QuadrupleTwo"] = "四带二",
	
	["Bomb"] = "炸弹",
	["Rocket"] = "火箭",
}