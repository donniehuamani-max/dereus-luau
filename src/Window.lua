local Window = {}
Window.__index = Window

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius
    c.Parent = parent
end

local function stroke(parent, color)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Transparency = 0.45
    s.Parent = parent
end

function Window.new(ui, options)
    options = options or {}
    local self = setmetatable({ UI = ui, Tabs = {}, ActiveTab = nil }, Window)
    local root = Instance.new("Frame")
    root.Name = options.Name or "Window"
    root.Size = options.Size or UDim2.fromOffset(560, 390)
    root.Position = options.Position or UDim2.new(0.5, -280, 0.5, -195)
    root.BackgroundColor3 = ui.Theme.Background
    root.Parent = ui.Gui
    corner(root, ui.Theme.Radius)
    stroke(root, ui.Theme.Border)
    ui:Register(root)
    self.Root = root

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -32, 0, 34)
    title.Position = UDim2.fromOffset(16, 12)
    title.Text = options.Title or "Dereus UI"
    title.TextColor3 = ui.Theme.Text
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = root

    self.TabBar = Instance.new("Frame")
    self.TabBar.BackgroundTransparency = 1
    self.TabBar.Position = UDim2.fromOffset(16, 54)
    self.TabBar.Size = UDim2.new(1, -32, 0, 36)
    self.TabBar.Parent = root
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 8)
    tabLayout.Parent = self.TabBar

    self.Pages = Instance.new("Frame")
    self.Pages.BackgroundTransparency = 1
    self.Pages.Position = UDim2.fromOffset(16, 100)
    self.Pages.Size = UDim2.new(1, -32, 1, -116)
    self.Pages.Parent = root
    return self
end

function Window:AddTab(name, icon)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.BackgroundTransparency = 1
    page.Size = UDim2.fromScale(1, 1)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new()
    page.ScrollBarThickness = 3
    page.Visible = false
    page.Parent = self.Pages
    local padding = Instance.new("UIPadding")
    padding.PaddingRight = UDim.new(0, 8)
    padding.Parent = page
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.Parent = page

    local button = Instance.new("TextButton")
    button.AutoButtonColor = false
    button.Text = (icon and icon .. "  " or "") .. name
    button.TextSize = 13
    button.Font = Enum.Font.GothamMedium
    button.TextColor3 = self.UI.Theme.Muted
    button.BackgroundColor3 = self.UI.Theme.Surface
    button.Size = UDim2.fromOffset(110, 34)
    button.Parent = self.TabBar
    corner(button, self.UI.Theme.Radius)
    local tab = { Name = name, Page = page, Button = button, Window = self }
    table.insert(self.Tabs, tab)
    self.UI:Connect(button.MouseButton1Click, function() self:SelectTab(tab) end)
    if not self.ActiveTab then self:SelectTab(tab) end
    return tab
end

function Window:SelectTab(tab)
    self.ActiveTab = tab
    for _, item in ipairs(self.Tabs) do
        local active = item == tab
        item.Page.Visible = active
        item.Button.BackgroundColor3 = active and self.UI.Theme.Primary or self.UI.Theme.Surface
        item.Button.TextColor3 = active and self.UI.Theme.PrimaryForeground or self.UI.Theme.Muted
    end
end

return Window
