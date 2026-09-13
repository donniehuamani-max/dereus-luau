local Window = {}
Window.__index = Window
local function corner(parent, radius) local c = Instance.new("UICorner"); c.CornerRadius = radius; c.Parent = parent end
local function stroke(parent, color) local s = Instance.new("UIStroke"); s.Color = color; s.Transparency = 0.45; s.Parent = parent end

function Window.new(ui, options)
    options = options or {}; local self = setmetatable({ UI = ui, Tabs = {}, ActiveTab = nil, _destroyed = false }, Window)
    local root = Instance.new("Frame"); root.Name = options.Name or "Window"; root.Size = options.Size or UDim2.fromOffset(560, 390); root.Position = options.Position or UDim2.new(0.5, -280, 0.5, -195); root.AnchorPoint = options.AnchorPoint or Vector2.zero; root.BackgroundColor3 = ui.Theme.Background; root.ClipsDescendants = true; root.Parent = ui.Gui; corner(root, ui.Theme.Radius); stroke(root, ui.Theme.Border); ui:Register(root); self.Root = root
    local title = Instance.new("TextLabel"); title.BackgroundTransparency = 1; title.Size = UDim2.new(1, -32, 0, 30); title.Position = UDim2.fromOffset(16, 10); title.Text = options.Title or "Dereus UI"; title.TextColor3 = ui.Theme.Text; title.TextSize = 20; title.Font = Enum.Font.GothamBold; title.TextXAlignment = Enum.TextXAlignment.Left; title.Parent = root; self.Title = title
    if options.Subtitle then local subtitle = Instance.new("TextLabel"); subtitle.BackgroundTransparency = 1; subtitle.Size = UDim2.new(1, -32, 0, 18); subtitle.Position = UDim2.fromOffset(16, 36); subtitle.Text = options.Subtitle; subtitle.TextColor3 = ui.Theme.Muted; subtitle.TextSize = 12; subtitle.Font = Enum.Font.Gotham; subtitle.TextXAlignment = Enum.TextXAlignment.Left; subtitle.Parent = root; self.Subtitle = subtitle end
    local top = options.Subtitle and 64 or 50; self.TabBar = Instance.new("Frame"); self.TabBar.BackgroundTransparency = 1; self.TabBar.Position = UDim2.fromOffset(16, top); self.TabBar.Size = UDim2.new(1, -32, 0, 36); self.TabBar.Parent = root; local tabLayout = Instance.new("UIListLayout"); tabLayout.FillDirection = Enum.FillDirection.Horizontal; tabLayout.Padding = UDim.new(0, 8); tabLayout.Parent = self.TabBar
    self.Pages = Instance.new("Frame"); self.Pages.BackgroundTransparency = 1; self.Pages.Position = UDim2.fromOffset(16, top + 46); self.Pages.Size = UDim2.new(1, -32, 1, -(top + 62)); self.Pages.Parent = root; return self
end

function Window:AddTab(name, icon)
    assert(not self._destroyed, "Cannot add a tab to a destroyed window"); local page = Instance.new("ScrollingFrame"); page.Name = name; page.BackgroundTransparency = 1; page.Size = UDim2.fromScale(1, 1); page.AutomaticCanvasSize = Enum.AutomaticSize.Y; page.CanvasSize = UDim2.new(); page.ScrollBarThickness = 3; page.ScrollBarImageColor3 = self.UI.Theme.Primary; page.Visible = false; page.Parent = self.Pages
    local padding = Instance.new("UIPadding"); padding.PaddingRight = UDim.new(0, 8); padding.Parent = page; local layout = Instance.new("UIListLayout"); layout.Padding = UDim.new(0, 10); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Parent = page
    local button = Instance.new("TextButton"); button.AutoButtonColor = false; button.Text = (icon and icon .. "  " or "") .. name; button.TextSize = 13; button.Font = Enum.Font.GothamMedium; button.TextColor3 = self.UI.Theme.Muted; button.BackgroundColor3 = self.UI.Theme.Surface; button.Size = UDim2.fromOffset(110, 34); button.Parent = self.TabBar; corner(button, self.UI.Theme.Radius)
    local tab = { Name = name, Page = page, Button = button, Window = self }; table.insert(self.Tabs, tab); self.UI:Connect(button.Activated, function() self:SelectTab(tab) end); if not self.ActiveTab then self:SelectTab(tab) end; return tab
end

function Window:SelectTab(tab)
    if not tab then return end; self.ActiveTab = tab
    for _, item in ipairs(self.Tabs) do local active = item == tab; item.Page.Visible = active; self.UI:Tween(item.Button, { BackgroundColor3 = active and self.UI.Theme.Primary or self.UI.Theme.Surface, TextColor3 = active and self.UI.Theme.PrimaryForeground or self.UI.Theme.Muted }, 0.18) end
end

function Window:SetTitle(title) if self.Title then self.Title.Text = title end end
function Window:Destroy() self._destroyed = true; if self.Root and self.Root.Parent then self.Root:Destroy() end end
return Window
