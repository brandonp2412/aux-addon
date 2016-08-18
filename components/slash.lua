SLASH_AUX1 = '/aux'
function SlashCmdList.AUX(command)
	if not command then return end
	local arguments = aux.util.tokenize(command)
    if arguments[1] == 'clear' and arguments[2] == 'history' then
        aux.persistence.load_dataset().history = nil
        aux.log 'History cleared.'
    elseif arguments[1] == 'clear' and arguments[2] == 'post' then
        aux.persistence.load_dataset().post = nil
        aux.log 'Post settings cleared.'
    elseif arguments[1] == 'clear' and arguments[2] == 'datasets' then
        _G.aux_datasets = {}
        aux.log 'Datasets cleared.'
    elseif arguments[1] == 'clear' and arguments[2] == 'merchant' and arguments[3] == 'buy' then
	    _G.aux_merchant_buy = {}
        aux.log 'Merchant buy prices cleared.'
    elseif arguments[1] == 'clear' and arguments[2] == 'merchant' and arguments[3] == 'sell' then
	    _G.aux_merchant_sell = {}
        aux.log 'Merchant sell prices cleared.'
    elseif arguments[1] == 'clear' and arguments[2] == 'item' and arguments[3] == 'cache' then
	    _G.aux_items = {}
	    _G.aux_item_ids = {}
	    _G.aux_auctionable_items = {}
        aux.log 'Item cache cleared.'
    elseif arguments[1] == 'populate' and arguments[2] == 'wdb' then
        aux.cache.populate_wdb()
    elseif arguments[1] == 'tooltip' and arguments[2] == 'value' then
	    _G.aux_tooltip_value = not _G.aux_tooltip_value
        aux.log('Historical value in tooltip '..(_G.aux_tooltip_value and 'enabled' or 'disabled')..'.')
    elseif arguments[1] == 'tooltip' and arguments[2] == 'daily' then
	    _G.aux_tooltip_daily = not _G.aux_tooltip_daily
        aux.log('Market value in tooltip '..(_G.aux_tooltip_daily and 'enabled' or 'disabled')..'.')
    elseif arguments[1] == 'tooltip' and arguments[2] == 'vendor' and arguments[3] == 'buy' then
	    _G.aux_tooltip_vendor_buy = not _G.aux_tooltip_vendor_buy
        aux.log('Vendor buy price in tooltip '..(_G.aux_tooltip_vendor_buy and 'enabled' or 'disabled')..'.')
    elseif arguments[1] == 'tooltip' and arguments[2] == 'vendor' and arguments[3] == 'sell' then
	    _G.aux_tooltip_vendor_sell = not _G.aux_tooltip_vendor_sell
        aux.log('Vendor sell price in tooltip '..(_G.aux_tooltip_vendor_sell and 'enabled' or 'disabled')..'.')
    elseif arguments[1] == 'tooltip' and arguments[2] == 'disenchant' and arguments[3] == 'value' then
	    _G.aux_tooltip_disenchant_value = not _G.aux_tooltip_disenchant_value
        aux.log('Disenchant value in tooltip '..(_G.aux_tooltip_disenchant_value and 'enabled' or 'disabled')..'.')
    elseif arguments[1] == 'tooltip' and arguments[2] == 'disenchant' and arguments[3] == 'distribution' then
	    _G.aux_tooltip_disenchant_distribution = not _G.aux_tooltip_disenchant_distribution
        aux.log('Disenchant distribution in tooltip '..(_G.aux_tooltip_disenchant_distribution and 'enabled' or 'disabled')..'.')
    elseif arguments[1] == 'tooltip' and arguments[2] == 'disenchant' and arguments[3] == 'source' then
	    _G.aux_tooltip_disenchant_source = not _G.aux_tooltip_disenchant_source
        aux.log('Disenchant source in tooltip '..(_G.aux_tooltip_disenchant_source and 'enabled' or 'disabled')..'.')
    elseif arguments[1] == 'ignore' and arguments[2] == 'owner' then
	    _G.aux_ignore_owner = not _G.aux_ignore_owner
        aux.log('Ignoring of owner '..(_G.aux_ignore_owner and 'enabled' or 'disabled')..'.')
    elseif arguments[1] == 'chars' and arguments[2] == 'add' then
		local realm = GetCVar 'realmName'
		_G.aux_characters[realm] = _G.aux_characters[realm] or {}
		for i=3,getn(arguments) do
			local name = string.gsub(strlower(arguments[i]), '^%l', strupper)
			if not _G.aux_characters[realm][name] then
				_G.aux_characters[realm][name] = true
				aux.log('Character "'..name..'" added.')
			end
		end
	elseif arguments[1] == 'chars' and arguments[2] == 'remove' then
		local realm = GetCVar 'realmName'
		if not _G.aux_characters[realm] then
			return
		end
		for i=3,getn(arguments) do
			local name = string.gsub(strlower(arguments[i]), '^%l', strupper)
			if _G.aux_characters[realm][name] then
				_G.aux_characters[realm][name] = nil
				aux.log('Character "'..name..'" removed.')
			end
		end
	elseif arguments[1] == 'chars' then
		local realm = GetCVar 'realmName'
		local chars = {}
		for name, _ in _G.aux_characters[realm] or {} do
			tinsert(chars, name)
		end
		if getn(chars) > 0 then
			aux.log('Your characters: "'..table.concat(chars, ', ')..'".')
		else
			aux.log 'You don\'t have any additional characters. To add your characters type "/aux chars add NAME1 NAME2 NAME3...".'
		end
	else
		aux.log('Unknown command: "'..command..'"')
	end
end