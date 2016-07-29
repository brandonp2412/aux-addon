Aux.search_tab.FRAMES(function(m, public, private)
    private.frame = CreateFrame('Frame', nil, AuxFrame)
    m.frame:SetAllPoints()
    m.frame:SetScript('OnUpdate', m.on_update)
    m.frame:Hide()

    m.frame.filter = Aux.gui.panel(m.frame)
    m.frame.filter:SetAllPoints(AuxFrameContent)

    m.frame.results = Aux.gui.panel(m.frame)
    m.frame.results:SetAllPoints(AuxFrameContent)

    m.frame.saved = CreateFrame('Frame', nil, m.frame)
    m.frame.saved:SetAllPoints(AuxFrameContent)

    m.frame.saved.favorite = Aux.gui.panel(m.frame.saved)
    m.frame.saved.favorite:SetWidth(378.5)
    m.frame.saved.favorite:SetPoint('TOPLEFT', 0, 0)
    m.frame.saved.favorite:SetPoint('BOTTOMLEFT', 0, 0)

    m.frame.saved.recent = Aux.gui.panel(m.frame.saved)
    m.frame.saved.recent:SetWidth(378.5)
    m.frame.saved.recent:SetPoint('TOPRIGHT', 0, 0)
    m.frame.saved.recent:SetPoint('BOTTOMRIGHT', 0, 0)
    do
        local btn = Aux.gui.button(m.frame, 22)
        btn:SetPoint('TOPLEFT', 0, 0)
        btn:SetWidth(42)
        btn:SetHeight(42)
        btn:SetScript('OnClick', function()
            if this.open then
                m.settings:Hide()
                m.controls:Show()
            else
                m.settings:Show()
                m.controls:Hide()
            end
            this.open = not this.open
        end)

        for _, offset in {14, 10, 6} do
            local fake_icon_part = btn:CreateFontString()
            fake_icon_part:SetFont([[Fonts\FRIZQT__.TTF]], 23)
            fake_icon_part:SetPoint('CENTER', 0, offset)
            fake_icon_part:SetText('_')
        end

        private.settings_button = btn
    end
    do
        local panel = CreateFrame('Frame', nil, m.frame)
        panel:SetBackdrop{bgFile=[[Interface\Buttons\WHITE8X8]]}
        panel:SetBackdropColor(unpack(Aux.gui.config.content_color.backdrop))
        panel:SetPoint('LEFT', m.settings_button, 'RIGHT', 0, 0)
        panel:SetPoint('RIGHT', 0, 0)
        panel:SetHeight(42)
        panel:Hide()
        private.settings = panel
    end
    do
        local panel = CreateFrame('Frame', nil, m.frame)
        panel:SetPoint('LEFT', m.settings_button, 'RIGHT', 0, 0)
        panel:SetPoint('RIGHT', 0, 1)
        panel:SetHeight(40)
        private.controls = panel
    end
    do
        local editbox = Aux.gui.editbox(m.settings)
        editbox:SetPoint('LEFT', 75, 0)
        editbox:SetWidth(50)
        editbox:SetNumeric(true)
        editbox:SetMaxLetters(nil)
        editbox:SetScript('OnTabPressed', function()
            m.last_page_input:SetFocus()
        end)
        editbox:SetScript('OnEnterPressed', function()
            this:ClearFocus()
            m.execute()
        end)
        editbox:SetScript('OnTextChanged', function()
            if m.blizzard_page_index(this:GetText()) and not m.real_time_button:GetChecked() then
                this:SetBackdropColor(unpack(Aux.gui.config.on_color))
            else
                this:SetBackdropColor(unpack(Aux.gui.config.off_color))
            end
        end)
        local label = Aux.gui.label(editbox, 15)
        label:SetPoint('RIGHT', editbox, 'LEFT', -6, 0)
        label:SetText('Pages')
        label:SetTextColor(unpack(Aux.gui.config.text_color.enabled))
        private.first_page_input = editbox
    end
    do
        local editbox = Aux.gui.editbox(m.settings)
        editbox:SetPoint('LEFT', m.first_page_input, 'RIGHT', 10, 0)
        editbox:SetWidth(50)
        editbox:SetNumeric(true)
        editbox:SetMaxLetters(nil)
        editbox:SetScript('OnTabPressed', function()
            m.first_page_input:SetFocus()
        end)
        editbox:SetScript('OnEnterPressed', function()
            this:ClearFocus()
            m.execute()
        end)
        editbox:SetScript('OnTextChanged', function()
            if m.blizzard_page_index(this:GetText()) and not m.real_time_button:GetChecked() then
                this:SetBackdropColor(unpack(Aux.gui.config.on_color))
            else
                this:SetBackdropColor(unpack(Aux.gui.config.off_color))
            end
        end)
        local label = Aux.gui.label(editbox, 16)
        label:SetPoint('RIGHT', editbox, 'LEFT', -3.5, 0)
        label:SetText('-')
        label:SetTextColor(unpack(Aux.gui.config.text_color.enabled))
        private.last_page_input = editbox
    end
    do
        local btn = Aux.gui.checkbutton(m.settings, 16)
        btn:SetPoint('LEFT', 230, 0)
        btn:SetWidth(140)
        btn:SetHeight(25)
        btn:SetText('Real Time Mode')
        btn:SetScript('OnClick', function()
            this:SetChecked(not this:GetChecked())
            this = m.first_page_input
            m.first_page_input:GetScript('OnTextChanged')()
            this = m.last_page_input
            m.last_page_input:GetScript('OnTextChanged')()
        end)
        public.real_time_button = btn
    end
    do
        local btn = Aux.gui.checkbutton(m.settings, 16)
        btn:SetPoint('LEFT', m.real_time_button, 'RIGHT', 15, 0)
        btn:SetWidth(140)
        btn:SetHeight(25)
        btn:SetText('Auto Buyout Mode')
        btn:SetScript('OnClick', function()
            if this:GetChecked() then
                this:SetChecked(false)
            else
                StaticPopup_Show('AUX_SEARCH_AUTO_BUY')
            end
        end)
        private.auto_buy_button = btn
    end
    do
        local btn = Aux.gui.checkbutton(m.settings, 16)
        btn:SetPoint('LEFT', m.auto_buy_button, 'RIGHT', 15, 0)
        btn:SetWidth(140)
        btn:SetHeight(25)
        btn:SetText('Auto Buyout Filter')
        btn:SetScript('OnClick', function()
            if this:GetChecked() then
                this:SetChecked(false)
                aux_auto_buy_filter = nil
                this.prettified = nil
                m.auto_buy_validator = nil
            else
                StaticPopup_Show('AUX_SEARCH_AUTO_BUY_FILTER')
            end
        end)
        btn:SetScript('OnEnter', function()
            if this.prettified then
                GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
                GameTooltip:AddLine(gsub(this.prettified, ';', '\n\n'), 255/255, 254/255, 250/255, true)
                GameTooltip:Show()
            end
        end)
        btn:SetScript('OnLeave', function()
            GameTooltip:Hide()
        end)
        private.auto_buy_filter_button = btn
    end
    do
        local btn = Aux.gui.button(m.controls, 26)
        btn:SetPoint('LEFT', 5, 0)
        btn:SetWidth(30)
        btn:SetHeight(25)
        btn:SetText('<')
        btn:SetScript('OnClick', m.previous_search)
        private.previous_button = btn
    end
    do
        local btn = Aux.gui.button(m.controls, 26)
        btn:SetPoint('LEFT', m.previous_button, 'RIGHT', 4, 0)
        btn:SetWidth(30)
        btn:SetHeight(25)
        btn:SetText('>')
        btn:SetScript('OnClick', m.next_search)
        private.next_button = btn
    end
    do
        local btn = Aux.gui.button(m.controls, 22)
        btn:SetPoint('RIGHT', -5, 0)
        btn:SetWidth(70)
        btn:SetHeight(25)
        btn:SetText('Start')
        btn:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
        btn:SetScript('OnClick', function()
            if arg1 == 'RightButton' then
                m.set_filter(m.current_search().filter_string)
            end
            m.execute()
        end)
        private.start_button = btn
    end
    do
        local btn = Aux.gui.button(m.controls, 22)
        btn:SetPoint('RIGHT', -5, 0)
        btn:SetWidth(70)
        btn:SetHeight(25)
        btn:SetText('Stop')
        btn:SetScript('OnClick', function()
            Aux.scan.abort(m.search_scan_id)
        end)
        btn:Hide()
        private.stop_button = btn
    end
    do
        local btn = Aux.gui.button(m.controls, 22)
        btn:SetPoint('RIGHT', m.start_button, 'LEFT', -4, 0)
        btn:SetWidth(70)
        btn:SetHeight(25)
        btn:SetText(GREEN_FONT_COLOR_CODE..'Resume'..FONT_COLOR_CODE_CLOSE)
        btn:SetScript('OnClick', function()
            m.execute(true)
        end)
        private.resume_button = btn
    end
    do
        local editbox = Aux.gui.editbox(m.controls)
        editbox:SetMaxLetters(nil)
        editbox:EnableMouse(1)
        editbox.complete = Aux.completion.complete_filter
        editbox:SetPoint('RIGHT', m.start_button, 'LEFT', -4, 0)
        editbox:SetHeight(25)
        editbox:SetScript('OnChar', function()
            this:complete()
        end)
        editbox:SetScript('OnTabPressed', function()
            this:HighlightText(0, 0)
        end)
        editbox:SetScript('OnEnterPressed', m.execute)
        editbox:SetScript('OnReceiveDrag', function()
            local item_info = Aux.cursor_item() and Aux.info.item(Aux.cursor_item().item_id)
            if item_info then
                m.set_filter(strlower(item_info.name)..'/exact')
                m.execute(nil, false)
            end
            ClearCursor()
        end)
        private.search_box = editbox
    end
    do
        Aux.gui.horizontal_line(m.frame, -40)
    end
    do
        local btn = Aux.gui.button(m.frame, 18)
        btn:SetPoint('BOTTOMLEFT', AuxFrameContent, 'TOPLEFT', 10, 8)
        btn:SetWidth(243)
        btn:SetHeight(22)
        btn:SetText('Search Results')
        btn:SetScript('OnClick', function() m.update_tab(m.RESULTS) end)
        private.search_results_button = btn
    end
    do
        local btn = Aux.gui.button(m.frame, 18)
        btn:SetPoint('TOPLEFT', m.search_results_button, 'TOPRIGHT', 5, 0)
        btn:SetWidth(243)
        btn:SetHeight(22)
        btn:SetText('Saved Searches')
        btn:SetScript('OnClick', function() m.update_tab(m.SAVED) end)
        private.saved_searches_button = btn
    end
    do
        local btn = Aux.gui.button(m.frame, 18)
        btn:SetPoint('TOPLEFT', m.saved_searches_button, 'TOPRIGHT', 5, 0)
        btn:SetWidth(243)
        btn:SetHeight(22)
        btn:SetText('New Filter')
        btn:SetScript('OnClick', function() m.update_tab(m.FILTER) end)
        private.new_filter_button = btn
    end
    do
        local frame = CreateFrame('Frame', nil, m.frame)
        frame:SetWidth(265)
        frame:SetHeight(25)
        frame:SetPoint('TOPLEFT', AuxFrameContent, 'BOTTOMLEFT', 0, -6)
        private.status_bar_frame = frame
    end
    do
        local btn = Aux.gui.button(m.frame.results, 16)
        btn:SetPoint('TOPLEFT', m.status_bar_frame, 'TOPRIGHT', 5, 0)
        btn:SetWidth(80)
        btn:SetHeight(24)
        btn:SetText('Bid')
        btn:Disable()
        private.bid_button = btn
    end
    do
        local btn = Aux.gui.button(m.frame.results, 16)
        btn:SetPoint('TOPLEFT', m.bid_button, 'TOPRIGHT', 5, 0)
        btn:SetWidth(80)
        btn:SetHeight(24)
        btn:SetText('Buyout')
        btn:Disable()
        private.buyout_button = btn
    end
    do
        local btn = Aux.gui.button(m.frame.results, 16)
        btn:SetPoint('TOPLEFT', m.buyout_button, 'TOPRIGHT', 5, 0)
        btn:SetWidth(80)
        btn:SetHeight(24)
        btn:SetText('Clear')
        btn:SetScript('OnClick', function()
            while tremove(m.current_search().records) do end
            m.results_listing:SetDatabase()
        end)
    end
    do
        local btn = Aux.gui.button(m.frame.saved, 16)
        btn:SetPoint('TOPLEFT', m.status_bar_frame, 'TOPRIGHT', 5, 0)
        btn:SetWidth(80)
        btn:SetHeight(24)
        btn:SetText('Favorite')
        btn:SetScript('OnClick', function()
            local filters = Aux.scan_util.parse_filter_string(m.search_box:GetText())
            if filters then
                tinsert(aux_favorite_searches, 1, {
                    filter_string = m.search_box:GetText(),
                    prettified = Aux.util.join(Aux.util.map(filters, function(filter) return filter.prettified end), ';'),
                })
            end
            m.update_search_listings()
        end)
    end
    do
        local btn1 = Aux.gui.button(m.frame.filter, 16)
        btn1:SetPoint('TOPLEFT', m.status_bar_frame, 'TOPRIGHT', 5, 0)
        btn1:SetWidth(80)
        btn1:SetHeight(24)
        btn1:SetText('Search')
        btn1:SetScript('OnClick', function()
            m.search_box:SetText('')
            m.add_filter()
            m.clear_form()
            m.execute()
        end)

        local btn2 = Aux.gui.button(m.frame.filter, 16)
        btn2:SetPoint('LEFT', btn1, 'RIGHT', 5, 0)
        btn2:SetWidth(80)
        btn2:SetHeight(24)
        btn2:SetText('Add')
        btn2:SetScript('OnClick', function()
            m.add_filter()
            m.clear_form()
        end)

        local btn3 = Aux.gui.button(m.frame.filter, 16)
        btn3:SetPoint('LEFT', btn2, 'RIGHT', 5, 0)
        btn3:SetWidth(80)
        btn3:SetHeight(24)
        btn3:SetText('Replace')
        btn3:SetScript('OnClick', function()
            m.add_filter(nil, true)
            m.clear_form()
        end)
    end
    do
        local editbox = Aux.gui.editbox(m.frame.filter)
        editbox.complete_item = Aux.completion.complete(function() return aux_auctionable_items end)
        editbox:SetPoint('TOPLEFT', 14, -26)
        editbox:SetWidth(260)
        editbox:SetScript('OnChar', function()
            if m.exact_checkbox:GetChecked() then
                this:complete_item()
            end
        end)
        editbox:SetScript('OnTabPressed', function()
            if IsShiftKeyDown() then
                m.max_level_input:SetFocus()
            else
                m.min_level_input:SetFocus()
            end
        end)
        editbox:SetScript('OnEnterPressed', function()
            this:ClearFocus()
            m.execute()
        end)
        local label = Aux.gui.label(editbox, 13)
        label:SetPoint('BOTTOMLEFT', editbox, 'TOPLEFT', -2, 1)
        label:SetText('Name')
        private.name_input = editbox
    end
    do
        local checkbox = CreateFrame('CheckButton', nil, m.frame.filter, 'UICheckButtonTemplate')
        checkbox:SetWidth(22)
        checkbox:SetHeight(22)
        checkbox:SetPoint('TOPLEFT', m.name_input, 'TOPRIGHT', 10, 0)
        local label = Aux.gui.label(checkbox, 13)
        label:SetPoint('BOTTOMLEFT', checkbox, 'TOPLEFT', 1, -3)
        label:SetText('Exact')
        private.exact_checkbox = checkbox
    end
    do
        local editbox = Aux.gui.editbox(m.frame.filter)
        editbox:SetPoint('TOPLEFT', m.name_input, 'BOTTOMLEFT', 0, -28)
        editbox:SetWidth(125)
        editbox:SetNumeric(true)
        editbox:SetMaxLetters(2)
        editbox:SetScript('OnTabPressed', function()
            if IsShiftKeyDown() then
                m.name_input:SetFocus()
            else
                m.max_level_input:SetFocus()
            end
        end)
        editbox:SetScript('OnEnterPressed', function()
            this:ClearFocus()
            m.execute()
        end)
        local label = Aux.gui.label(editbox, 13)
        label:SetPoint('BOTTOMLEFT', editbox, 'TOPLEFT', -2, 1)
        label:SetText('Level Range')
        private.min_level_input = editbox
    end
    do
        local editbox = Aux.gui.editbox(m.frame.filter)
        editbox:SetPoint('TOPLEFT', m.min_level_input, 'TOPRIGHT', 10, 0)
        editbox:SetWidth(125)
        editbox:SetNumeric(true)
        editbox:SetMaxLetters(2)
        editbox:SetScript('OnTabPressed', function()
            if IsShiftKeyDown() then
                m.min_level_input:SetFocus()
            else
                m.name_input:SetFocus()
            end
        end)
        editbox:SetScript('OnEnterPressed', function()
            this:ClearFocus()
            m.execute()
        end)
        local label = Aux.gui.label(editbox, 13)
        label:SetPoint('RIGHT', editbox, 'LEFT', -3.5, 0)
        label:SetText('-')
        private.max_level_input = editbox
    end
    do
        local checkbox = CreateFrame('CheckButton', nil, m.frame.filter, 'UICheckButtonTemplate')
        checkbox:SetWidth(22)
        checkbox:SetHeight(22)
        checkbox:SetPoint('TOPLEFT', m.max_level_input, 'TOPRIGHT', 10, 0)
        local label = Aux.gui.label(checkbox, 13)
        label:SetPoint('BOTTOMLEFT', checkbox, 'TOPLEFT', 1, -3)
        label:SetText('Usable')
        private.usable_checkbox = checkbox
    end
    do
        local dropdown = Aux.gui.dropdown(m.frame.filter)
        dropdown:SetPoint('TOPLEFT', m.min_level_input, 'BOTTOMLEFT', 0, -26)
        dropdown:SetWidth(300)
        dropdown:SetHeight(10)
        local label = Aux.gui.label(dropdown, 13)
        label:SetPoint('BOTTOMLEFT', dropdown, 'TOPLEFT', -2, -4)
        label:SetText('Item Class')
        UIDropDownMenu_Initialize(dropdown, m.initialize_class_dropdown)
        dropdown:SetScript('OnShow', function()
            UIDropDownMenu_Initialize(this, m.initialize_class_dropdown)
        end)
        private.class_dropdown = dropdown
    end
    do
        local dropdown = Aux.gui.dropdown(m.frame.filter)
        dropdown:SetPoint('TOPLEFT', m.class_dropdown, 'BOTTOMLEFT', 0, -22)
        dropdown:SetWidth(300)
        dropdown:SetHeight(10)
        local label = Aux.gui.label(dropdown, 13)
        label:SetPoint('BOTTOMLEFT', dropdown, 'TOPLEFT', -2, -4)
        label:SetText('Item Subclass')
        UIDropDownMenu_Initialize(dropdown, m.initialize_subclass_dropdown)
        dropdown:SetScript('OnShow', function()
            UIDropDownMenu_Initialize(this, m.initialize_subclass_dropdown)
        end)
        private.subclass_dropdown = dropdown
    end
    do
        local dropdown = Aux.gui.dropdown(m.frame.filter)
        dropdown:SetPoint('TOPLEFT', m.subclass_dropdown, 'BOTTOMLEFT', 0, -22)
        dropdown:SetWidth(300)
        dropdown:SetHeight(10)
        local label = Aux.gui.label(dropdown, 13)
        label:SetPoint('BOTTOMLEFT', dropdown, 'TOPLEFT', -2, -4)
        label:SetText('Item Slot')
        UIDropDownMenu_Initialize(dropdown, m.initialize_slot_dropdown)
        dropdown:SetScript('OnShow', function()
            UIDropDownMenu_Initialize(this, m.initialize_slot_dropdown)
        end)
        private.slot_dropdown = dropdown
    end
    do
        local dropdown = Aux.gui.dropdown(m.frame.filter)
        dropdown:SetPoint('TOPLEFT', m.slot_dropdown, 'BOTTOMLEFT', 0, -22)
        dropdown:SetWidth(300)
        dropdown:SetHeight(10)
        local label = Aux.gui.label(dropdown, 13)
        label:SetPoint('BOTTOMLEFT', dropdown, 'TOPLEFT', -2, -4)
        label:SetText('Min Rarity')
        UIDropDownMenu_Initialize(dropdown, m.initialize_quality_dropdown)
        dropdown:SetScript('OnShow', function()
            UIDropDownMenu_Initialize(this, m.initialize_quality_dropdown)
        end)
        private.quality_dropdown = dropdown
    end
    Aux.gui.vertical_line(m.frame.filter, 332)
    local function add_modifier(...)
        local current_filter_string = m.search_box:GetText()
        for i=1,arg.n do
            if current_filter_string ~= '' and strsub(current_filter_string, -1) ~= '/' then
                current_filter_string = current_filter_string..'/'
            end
            current_filter_string = current_filter_string..arg[i]
        end
        m.search_box:SetText(current_filter_string)
    end
    do
        local btn = Aux.gui.button(m.frame.filter, 16)
        btn:SetPoint('TOPRIGHT', -362, -10)
        btn:SetWidth(50)
        btn:SetHeight(19)
        btn:SetText('and')
        btn:SetScript('OnClick', function()
            add_modifier('and')
        end)
        private.and_operator_button = btn
    end
    do
        local btn = Aux.gui.button(m.frame.filter, 16)
        btn:SetPoint('LEFT', m.and_operator_button, 'RIGHT', 10, 0)
        btn:SetWidth(50)
        btn:SetHeight(19)
        btn:SetText('or')
        btn:SetScript('OnClick', function()
            add_modifier('or')
        end)
        private.or_operator_button = btn
    end
    do
        local btn = Aux.gui.button(m.frame.filter, 16)
        btn:SetPoint('LEFT', m.or_operator_button, 'RIGHT', 10, 0)
        btn:SetWidth(50)
        btn:SetHeight(19)
        btn:SetText('not')
        btn:SetScript('OnClick', function()
            add_modifier('not')
        end)
        private.not_operator_button = btn
    end
    private.modifier_buttons = {}
    do
        local btn = Aux.gui.button(m.frame.filter, 16)
        btn:SetPoint('TOPLEFT', m.and_operator_button, 'BOTTOMLEFT', 0, -10)
        m.modifier_buttons['min-unit-bid'] = btn
    end
    do
        local btn = Aux.gui.button(m.frame.filter, 16)
        btn:SetPoint('TOPLEFT', m.modifier_buttons['min-unit-bid'], 'BOTTOMLEFT', 0, -10)
        m.modifier_buttons['min-unit-buy'] = btn
    end
    do
        local btn = Aux.gui.button(m.frame.filter, 16)
        btn:SetPoint('TOPLEFT', m.modifier_buttons['min-unit-buy'], 'BOTTOMLEFT', 0, -10)
        m.modifier_buttons['max-unit-bid'] = btn
    end
    do
        local btn = Aux.gui.button(m.frame.filter, 16)
        btn:SetPoint('TOPLEFT', m.modifier_buttons['max-unit-bid'], 'BOTTOMLEFT', 0, -10)
        m.modifier_buttons['max-unit-buy'] = btn
    end
    do
        local btn = Aux.gui.button(m.frame.filter, 16)
        btn:SetPoint('TOPLEFT', m.modifier_buttons['max-unit-buy'], 'BOTTOMLEFT', 0, -10)
        m.modifier_buttons['bid-profit'] = btn
    end
    do
        local btn = Aux.gui.button(m.frame.filter, 16)
        btn:SetPoint('TOPLEFT', m.modifier_buttons['bid-profit'], 'BOTTOMLEFT', 0, -10)
        m.modifier_buttons['buy-profit'] = btn
    end
    do
        local btn = Aux.gui.button(m.frame.filter, 16)
        btn:SetPoint('TOPLEFT', m.modifier_buttons['buy-profit'], 'BOTTOMLEFT', 0, -10)
        m.modifier_buttons['bid-vend-profit'] = btn
    end
    do
        local btn = Aux.gui.button(m.frame.filter, 16)
        btn:SetPoint('TOPLEFT', m.modifier_buttons['bid-vend-profit'], 'BOTTOMLEFT', 0, -10)
        m.modifier_buttons['buy-vend-profit'] = btn
    end
    do
        local btn = Aux.gui.button(m.frame.filter, 16)
        btn:SetPoint('TOPLEFT', m.modifier_buttons['buy-vend-profit'], 'BOTTOMLEFT', 0, -10)
        m.modifier_buttons['bid-dis-profit'] = btn
    end
    do
        local btn = Aux.gui.button(m.frame.filter, 16)
        btn:SetPoint('TOPLEFT', m.modifier_buttons['bid-dis-profit'], 'BOTTOMLEFT', 0, -10)
        m.modifier_buttons['buy-dis-profit'] = btn
    end
    do
        local btn = Aux.gui.button(m.frame.filter, 16)
        btn:SetPoint('TOPLEFT', m.and_operator_button, 'BOTTOMLEFT', 205, -10)
        m.modifier_buttons['bid-pct'] = btn
    end
    do
        local btn = Aux.gui.button(m.frame.filter, 16)
        btn:SetPoint('TOPLEFT', m.modifier_buttons['bid-pct'], 'BOTTOMLEFT', 0, -10)
        m.modifier_buttons['buy-pct'] = btn
    end
    do
        local btn = Aux.gui.button(m.frame.filter, 16)
        btn:SetPoint('TOPLEFT', m.modifier_buttons['buy-pct'], 'BOTTOMLEFT', 0, -10)
        m.modifier_buttons['item'] = btn
    end
    do
        local btn = Aux.gui.button(m.frame.filter, 16)
        btn:SetPoint('TOPLEFT', m.modifier_buttons['item'], 'BOTTOMLEFT', 0, -10)
        m.modifier_buttons['tooltip'] = btn
    end
    do
        local btn = Aux.gui.button(m.frame.filter, 16)
        btn:SetPoint('TOPLEFT', m.modifier_buttons['tooltip'], 'BOTTOMLEFT', 0, -10)
        m.modifier_buttons['min-lvl'] = btn
    end
    do
        local btn = Aux.gui.button(m.frame.filter, 16)
        btn:SetPoint('TOPLEFT', m.modifier_buttons['min-lvl'], 'BOTTOMLEFT', 0, -10)
        m.modifier_buttons['max-lvl'] = btn
    end
    do
        local btn = Aux.gui.button(m.frame.filter, 16)
        btn:SetPoint('TOPLEFT', m.modifier_buttons['max-lvl'], 'BOTTOMLEFT', 0, -10)
        m.modifier_buttons['rarity'] = btn
    end
    do
        local btn = Aux.gui.button(m.frame.filter, 16)
        btn:SetPoint('TOPLEFT', m.modifier_buttons['rarity'], 'BOTTOMLEFT', 0, -10)
        m.modifier_buttons['left'] = btn
    end
    do
        local btn = Aux.gui.button(m.frame.filter, 16)
        btn:SetPoint('TOPLEFT', m.modifier_buttons['left'], 'BOTTOMLEFT', 0, -10)
        m.modifier_buttons['utilizable'] = btn
    end
    do
        local btn = Aux.gui.button(m.frame.filter, 16)
        btn:SetPoint('TOPLEFT', m.modifier_buttons['utilizable'], 'BOTTOMLEFT', 0, -10)
        m.modifier_buttons['discard'] = btn
    end
    for modifier_name, btn in m.modifier_buttons do
        local modifier_name = modifier_name
        local btn = btn

        local filter = Aux.scan_util.filters[modifier_name]

        btn:SetWidth(100)
        btn:SetHeight(19)
        btn:SetText(modifier_name)
        btn:SetScript('OnClick', function()
            local args = Aux.util.map(btn.inputs, function(input) return input:GetText() end)
            if filter.test(unpack(args)) then
                add_modifier(modifier_name, unpack(args))
                for _, input in btn.inputs do
                    input:SetText('')
                    input:ClearFocus()
                end
            end
        end)
        btn.inputs = {}
        if filter.arity > 0 then
            local editbox = Aux.gui.editbox(m.frame.filter)
            editbox.complete = Aux.completion.complete(function() return ({filter.test()})[2] end)
            editbox:SetPoint('LEFT', btn, 'RIGHT', 10, 0)
            editbox:SetWidth(80)
            --            editbox:SetNumeric(true)
            --            editbox:SetMaxLetters(2)
            editbox:SetScript('OnChar', function()
                this:complete()
            end)
            local on_click = btn:GetScript('OnClick')
            editbox:SetScript('OnEnterPressed', function()
                on_click()
            end)
            tinsert(btn.inputs, editbox)
        end
    end

    private.results_listing = Aux.auction_listing.CreateAuctionResultsTable(m.frame.results, Aux.auction_listing.search_config)
    m.results_listing:SetSort(1,2,3,4,5,6,7,8,9)
    m.results_listing:Reset()
    m.results_listing:SetHandler('OnCellClick', function(cell, button)
        if IsAltKeyDown() and m.results_listing:GetSelection().record == cell.row.data.record then
            if button == 'LeftButton' and m.buyout_button:IsEnabled() then
                m.buyout_button:Click()
            elseif button == 'RightButton' and m.bid_button:IsEnabled() then
                m.bid_button:Click()
            end
        end
    end)
    m.results_listing:SetHandler('OnSelectionChanged', function(rt, datum)
        if not datum then return end
        m.find_auction(datum.record)
    end)

    local handlers = {
        OnClick = function(st, data, _, button)
            if not data then return end
            if button == 'LeftButton' and IsShiftKeyDown() then
                m.search_box:SetText(data.search.filter_string)
            elseif button == 'RightButton' and IsShiftKeyDown() then
                m.add_filter(data.search.filter_string)
            elseif button == 'LeftButton' and IsControlKeyDown() then
                if st == m.favorite_searches_listing and data.index > 1 then
                    local temp = aux_favorite_searches[data.index - 1]
                    aux_favorite_searches[data.index - 1] = data.search
                    aux_favorite_searches[data.index] = temp
                    m.update_search_listings()
                end
            elseif button == 'RightButton' and IsControlKeyDown() then
                if st == m.favorite_searches_listing and data.index < getn(aux_favorite_searches) then
                    local temp = aux_favorite_searches[data.index + 1]
                    aux_favorite_searches[data.index + 1] = data.search
                    aux_favorite_searches[data.index] = temp
                    m.update_search_listings()
                end
            elseif button == 'LeftButton' then
                m.search_box:SetText(data.search.filter_string)
                m.execute()
            elseif button == 'RightButton' then
                if st == m.recent_searches_listing then
                    tinsert(aux_favorite_searches, 1, data.search)
                elseif st == m.favorite_searches_listing then
                    tremove(aux_favorite_searches, data.index)
                end
                m.update_search_listings()
            end
        end,
        OnEnter = function(st, data, self)
            if not data then return end
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
            GameTooltip:AddLine(gsub(data.search.prettified, ';', '\n\n'), 255/255, 254/255, 250/255, true)
            GameTooltip:Show()
        end,
        OnLeave = function()
            GameTooltip:ClearLines()
            GameTooltip:Hide()
        end
    }

    private.recent_searches_listing = Aux.listing.CreateScrollingTable(m.frame.saved.recent)
    m.recent_searches_listing:SetColInfo({{name='Recent Searches', width=1}})
    m.recent_searches_listing:EnableSorting(false)
    m.recent_searches_listing:DisableSelection(true)
    m.recent_searches_listing:SetHandler('OnClick', handlers.OnClick)
    m.recent_searches_listing:SetHandler('OnEnter', handlers.OnEnter)
    m.recent_searches_listing:SetHandler('OnLeave', handlers.OnLeave)

    private.favorite_searches_listing = Aux.listing.CreateScrollingTable(m.frame.saved.favorite)
    m.favorite_searches_listing:SetColInfo({{name='Favorite Searches', width=1}})
    m.favorite_searches_listing:EnableSorting(false)
    m.favorite_searches_listing:DisableSelection(true)
    m.favorite_searches_listing:SetHandler('OnClick', handlers.OnClick)
    m.favorite_searches_listing:SetHandler('OnEnter', handlers.OnEnter)
    m.favorite_searches_listing:SetHandler('OnLeave', handlers.OnLeave)
end)