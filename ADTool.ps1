Add-Type -AssemblyName System.Windows.Forms

# Create the main form
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "SecAdmin Tool"
$Form.Size = New-Object System.Drawing.Size(700, 500)

# Create tab control
$TabControl = New-Object System.Windows.Forms.TabControl
$TabControl.Size = New-Object System.Drawing.Size(680, 440)
$TabControl.Location = New-Object System.Drawing.Point(10, 10)

#region "Links"tab
$LinksTab = New-Object System.Windows.Forms.TabPage
$LinksTab.Text = "Links"

# Create table layout panel for links
$LinksTable = New-Object System.Windows.Forms.TableLayoutPanel
$LinksTable.RowCount = [Math]::Ceiling($Links.Count / 2)
$LinksTable.ColumnCount = 2
$LinksTable.AutoSize = $true

# Add links to the table
$Links = @(
    "Sec Admin Docs", "\\shares-cifs.nyumc.org\groups\nyumcit\NYUSECADM\Sec admin Documentation - USE THIS",
    "AD Manager", "https://adm.nyumc.org:8443/",
    "AirWatch", "https://aw.nyumc.org/AirWatch",
    "Intune", "https://intune.microsoft.com",
    "AMS Tools", "https://amstools.nyumc.org/",
    "Citrix Director", "https://ctxcdcpdirxd001.nyumc.org/Director",
    "CyberArk", "https://pvwa.nyumc.org/PasswordVault/v10/logon/radius",
    "Duo Security", "https://admin-a5409281.duosecurity.com",
    "ISM", "https://nyu-amc.ivanticloud.com",
    "Peoplesoft HCM", "https://peoplesofthcm.nyumc.org/psc/hrprod/EMPLOYEE/HRMS/c/NUI_FRAMEWORK.PT_LANDINGPAGE.GBL?NPSLT=Y",
    "Routing Chart", "https://servicecatalog.nyumc.org/DesksideRouting/Pages/RoutingChart.aspx",
    "Sailpoint", "https://identity.nyumc.org",   
    "VPN Termination", "https://vpn-termination.nyumc.org",
    "Webex Admin", "https://nyumc.webex.com/wbxadmin/login.do?&needFilter=false&siteurl=nyumc"    
    
    )

for ($i = 0; $i -lt $Links.Count; $i += 2) {
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $Links[$i]
    $button.FlatStyle = 'Flat'
    $button.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
    $button.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
    $button.Tag = $Links[$i + 1]
    $button.Add_Click({
        $url = $this.Tag.ToString()
        [System.Diagnostics.Process]::Start($url)
    })

    $button.Width = 200  # Set the button width to 200 pixels for longer buttons

    $LinksTable.Controls.Add($button, $i % 2, $i / 2)
}

# Adjust the table layout panel size to fit the longer buttons
$LinksTable.Size = New-Object System.Drawing.Size($LinksTable.ColumnCount * ($button.Width + 10), $LinksTable.RowCount * ($button.Height + 10))

# Add the table to the Links tab
$LinksTab.Controls.Add($LinksTable)

# Add the Links tab to the tab control
$TabControl.TabPages.Add($LinksTab)

# Add the tab control to the form
$Form.Controls.Add($TabControl)
#endregion "Links"tab

#region "Search"tab
$SearchTab = New-Object System.Windows.Forms.TabPage
$SearchTab.Text = "Search"

# Create label for search type
$SearchTypeLabel = New-Object System.Windows.Forms.Label
$SearchTypeLabel.Text = "Search Type:"
$SearchTypeLabel.Location = New-Object System.Drawing.Point(10, 10)
$SearchTypeLabel.AutoSize = $true

# Create radio button for searching users
$SearchUsersRadioButton = New-Object System.Windows.Forms.RadioButton
$SearchUsersRadioButton.Text = "Search Users"
$SearchUsersRadioButton.Location = New-Object System.Drawing.Point(80, 10)
$SearchUsersRadioButton.Checked = $true

# Create radio button for searching groups
$SearchGroupsRadioButton = New-Object System.Windows.Forms.RadioButton
$SearchGroupsRadioButton.Text = "Search Groups"
$SearchGroupsRadioButton.Location = New-Object System.Drawing.Point(180, 10)

# Create radio button for searching groups with wildcards
$SearchWildcardGroupsRadioButton = New-Object System.Windows.Forms.RadioButton
$SearchWildcardGroupsRadioButton.Text = "(Wildcard)"
$SearchWildcardGroupsRadioButton.Location = New-Object System.Drawing.Point(280, 10)

# Create label for search keyword
$SearchKeywordLabel = New-Object System.Windows.Forms.Label
$SearchKeywordLabel.Text = "Keyword:"
$SearchKeywordLabel.Location = New-Object System.Drawing.Point(10, 40)
$SearchKeywordLabel.AutoSize = $true

# Create text box for search keyword input
$SearchKeywordTextBox = New-Object System.Windows.Forms.TextBox
$SearchKeywordTextBox.Location = New-Object System.Drawing.Point(80, 40)
$SearchKeywordTextBox.Size = New-Object System.Drawing.Size(200, 20)

# Create button for executing the search
$SearchButton = New-Object System.Windows.Forms.Button
$SearchButton.Text = "Search"
$SearchButton.Location = New-Object System.Drawing.Point(300, 35)
$SearchButton.Add_Click({
    $keyword = $SearchKeywordTextBox.Text
    $searchType = if ($SearchUsersRadioButton.Checked) { "Users" } elseif ($SearchWildcardGroupsRadioButton.Checked) { "Groups (Wildcard)" } else { "Groups" }
    
    if ([string]::IsNullOrEmpty($keyword)) {
        $SearchResultTextBox.Clear()
        $SearchResultTextBox.AppendText("Please enter a $searchType keyword.")
        return
    }
    
    $SearchResultTextBox.Clear()
    
    if ($SearchUsersRadioButton.Checked) {
        $userFilter = "SamAccountName -eq '$keyword'"
        $users = Get-ADUser -Filter $userFilter -Properties MemberOf
        
        if ([string]::IsNullOrEmpty($users)) {
            $SearchResultTextBox.AppendText("No users found.")
        } else {
            foreach ($user in $users | Sort-Object -Property SamAccountName) {
                $groups = $user.MemberOf | ForEach-Object { Get-ADGroup -Identity $_ }
                
                if ($groups) {
                    $SearchResultTextBox.AppendText("User: $($user.SamAccountName)`r`n")
                    $SearchResultTextBox.AppendText("Group Memberships:`r`n")
                    foreach ($group in $groups | Sort-Object -Property Name) {
                        $SearchResultTextBox.AppendText("$($group.Name)`r`n")
                    }
                    $SearchResultTextBox.AppendText("`r`n")
                } else {
                    $SearchResultTextBox.AppendText("User: $($user.SamAccountName)`r`nNo group memberships found.`r`n`r`n")
                }
            }
        }
    } elseif ($SearchWildcardGroupsRadioButton.Checked) {
        $groups = Get-ADGroup -Filter "Name -like '*$keyword*'"
        
        if ([string]::IsNullOrEmpty($groups)) {
            $SearchResultTextBox.AppendText("No wildcard groups found.")
        } else {
            foreach ($group in $groups | Sort-Object -Property Name) {
            $SearchResultTextBox.AppendText("Group: $($group.Name)`r`n")
            }
        }
    } else {
        $groups = Get-ADGroup -Filter "Name -eq '$keyword'"
        
        if ([string]::IsNullOrEmpty($groups)) {
            $SearchResultTextBox.AppendText("No groups found.")
        } else {
            foreach ($group in $groups | Sort-Object -Property Name) {
                $members = Get-ADGroupMember -Identity $group -Recursive | Where-Object { $_.objectClass -eq 'user' }
                
                if ($members) {
                    $SearchResultTextBox.AppendText("Group: $($group.Name)`r`n")
                    $SearchResultTextBox.AppendText("Members:`r`n")
                    foreach ($member in $members | Sort-Object -Property SamAccountName) {
                        $SearchResultTextBox.AppendText("$($member.SamAccountName)`r`n")
                    }
                    $SearchResultTextBox.AppendText("`r`n")
                } else {
                    $SearchResultTextBox.AppendText("Group: $($group.Name)`r`nNo members found.`r`n`r`n")
                }
            }
        }
    }
})

# Create text box for displaying search results
$SearchResultTextBox = New-Object System.Windows.Forms.TextBox
$SearchResultTextBox.Location = New-Object System.Drawing.Point(10, 70)
$SearchResultTextBox.Size = New-Object System.Drawing.Size(480, 180)
$SearchResultTextBox.Multiline = $true
$SearchResultTextBox.ScrollBars = "Vertical"
$SearchResultTextBox.ReadOnly = $true

# Add controls to the Search tab
$SearchTab.Controls.Add($SearchTypeLabel)
$SearchTab.Controls.Add($SearchUsersRadioButton)
$SearchTab.Controls.Add($SearchGroupsRadioButton)
$SearchTab.Controls.Add($SearchWildcardGroupsRadioButton)
$SearchTab.Controls.Add($SearchKeywordLabel)
$SearchTab.Controls.Add($SearchKeywordTextBox)
$SearchTab.Controls.Add($SearchButton)
$SearchTab.Controls.Add($SearchResultTextBox)
#endregion "Search"tab

#region "Export"tab
$ExportTab = New-Object System.Windows.Forms.TabPage
$ExportTab.Text = "Export"

# Create label for export type
$ExportTypeLabel = New-Object System.Windows.Forms.Label
$ExportTypeLabel.Text = "Export Type:"
$ExportTypeLabel.Location = New-Object System.Drawing.Point(10, 10)
$ExportTypeLabel.AutoSize = $true


# Create button for exporting search results to CSV
$ExportButton = New-Object System.Windows.Forms.Button
$ExportButton.Text = "Export"
$ExportButton.Location = New-Object System.Drawing.Point(300, 35)
$ExportButton.Add_Click({
    $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $saveFileDialog.Filter = "CSV (*.csv)|*.csv"
    $saveFileDialog.Title = "Export Search Results"
    
    if ($saveFileDialog.ShowDialog() -eq "OK") {
        $filePath = $saveFileDialog.FileName
        
        if ([string]::IsNullOrEmpty($SearchResultTextBox.Text)) {
            [System.Windows.Forms.MessageBox]::Show("No results to export.", "Export Search Results", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            return
        }

        # Add header 'name' and the cleaned-up data
        $exportData = @()
        $exportData += "name" # CSV Header
        
        # Extract each line from search result, remove quotes and add them as CSV rows
        $exportData += $SearchResultTextBox.Lines[2..($SearchResultTextBox.Lines.Count - 1)] | ForEach-Object {
            $_.Trim().Replace('"', '') # Clean up any quotes or spaces
        }

        # Output the data as CSV with proper encoding
        $exportData | Out-File -FilePath $filePath -Encoding UTF8

        [System.Windows.Forms.MessageBox]::Show("Search results exported successfully.", "Export Search Results", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
})

# Add controls to the Export tab
$ExportTab.Controls.Add($ExportTypeLabel)
$ExportTab.Controls.Add($ExportButton)

# Add tabs to the tab control
$TabControl.Controls.Add($SearchTab)
$TabControl.Controls.Add($ExportTab)

# Add the tab control to the form
$Form.Controls.Add($TabControl)
#endregion "Export"tab



#region "Computers"tab
$ComputersTab = New-Object System.Windows.Forms.TabPage
$ComputersTab.Text = "Computers"

# Create label for computer search box
$ComputerLabel = New-Object System.Windows.Forms.Label
$ComputerLabel.Text = "Computer Name:"
$ComputerLabel.Location = New-Object System.Drawing.Point(10, 10)
$ComputerLabel.AutoSize = $true

# Create text box for computer search input
$ComputerTextBox = New-Object System.Windows.Forms.TextBox
$ComputerTextBox.Location = New-Object System.Drawing.Point(120, 10)
$ComputerTextBox.Size = New-Object System.Drawing.Size(200, 20)

# Create button for executing the computer search
$ComputerSearchButton = New-Object System.Windows.Forms.Button
$ComputerSearchButton.Text = "Search"
$ComputerSearchButton.Location = New-Object System.Drawing.Point(340, 5)
$ComputerSearchButton.Add_Click({
    $ComputerName = $ComputerTextBox.Text

    # Clear the text box before displaying the result
    $ComputerResultTextBox.Clear()

    if ($ComputerName) {
        try {
            $systemInfo = Get-WmiObject Win32_ComputerSystem -ComputerName $ComputerName
            $biosInfo = Get-WmiObject Win32_BIOS -ComputerName $ComputerName
            $memoryInfo = Get-WmiObject Win32_PhysicalMemory -ComputerName $ComputerName
            $diskDriveInfo = Get-WmiObject Win32_DiskDrive -ComputerName $ComputerName
            $videoControllerInfo = Get-WmiObject Win32_VideoController -ComputerName $ComputerName

            if (!$systemInfo -or !$biosInfo -or !$memoryInfo -or !$diskDriveInfo -or !$videoControllerInfo) {
                $ComputerResultTextBox.AppendText("No computer found with the name: $ComputerName")
                return
            }

            $ComputerResultTextBox.AppendText("System Information for $ComputerName`r`n`r`n")
            $ComputerResultTextBox.AppendText("Manufacturer: " + $systemInfo.Manufacturer + "`r`n")
            $ComputerResultTextBox.AppendText("Model: " + $systemInfo.Model + "`r`n")
            $ComputerResultTextBox.AppendText("BIOS Version: " + $biosInfo.SMBIOSBIOSVersion + "`r`n`r`n")
            $ComputerResultTextBox.AppendText("Memory Information:`r`n")
            $memoryInfo | ForEach-Object {
                $ComputerResultTextBox.AppendText("Capacity: " + ($_ | Select-Object -ExpandProperty Capacity) + " bytes`r`n")
            }
            $ComputerResultTextBox.AppendText("`r`nDisk Drive Information:`r`n")
            $diskDriveInfo | ForEach-Object {
                $ComputerResultTextBox.AppendText("Model: " + $_.Model + "`r`n")
            }
            $ComputerResultTextBox.AppendText("`r`nVideo Controller Information:`r`n")
            $videoControllerInfo | ForEach-Object {
                $ComputerResultTextBox.AppendText("Name: " + $_.Name + "`r`n")
            }
        }
        catch {
            $ComputerResultTextBox.AppendText("Error: $_.Exception.Message")
        }
    } else {
        $ComputerResultTextBox.AppendText("Please enter a computer name.")
    }
})

# Create multi-line text box for displaying the computer search result
$ComputerResultTextBox = New-Object System.Windows.Forms.TextBox
$ComputerResultTextBox.Multiline = $true
$ComputerResultTextBox.Location = New-Object System.Drawing.Point(10, 40)
$ComputerResultTextBox.Size = New-Object System.Drawing.Size(480, 230)
$ComputerResultTextBox.ScrollBars = "Vertical"
$ComputerResultTextBox.ReadOnly = $true

# Add controls to the Computers tab
$ComputersTab.Controls.Add($ComputerLabel)
$ComputersTab.Controls.Add($ComputerTextBox)
$ComputersTab.Controls.Add($ComputerSearchButton)
$ComputersTab.Controls.Add($ComputerResultTextBox)

# Create button for displaying currently running processes
$ShowProcessesButton = New-Object System.Windows.Forms.Button
$ShowProcessesButton.Text = "Show Processes"
$ShowProcessesButton.Width = 100  # Set the width to a suitable value
$ShowProcessesButton.Location = New-Object System.Drawing.Point(500, 50)
$ShowProcessesButton.Add_Click({
    $ComputerName = $ComputerTextBox.Text

    # Clear the text box before displaying the result
    $ComputerResultTextBox.Clear()

    if ($ComputerName) {
        try {
            $processes = Get-WmiObject Win32_Process -ComputerName $ComputerName

            if ($processes) {
                $ComputerResultTextBox.AppendText("Currently Running Processes on $ComputerName`r`n`r`n")
                $processes | ForEach-Object {
                    $ComputerResultTextBox.AppendText("Name: " + $_.Name + "`r`n")
                    $ComputerResultTextBox.AppendText("Process ID: " + $_.ProcessId + "`r`n`r`n")
                }
            } else {
                $ComputerResultTextBox.AppendText("No processes found on $ComputerName")
            }
        }
        catch {
            $ComputerResultTextBox.AppendText("Error: $_.Exception.Message")
        }
    } else {
        $ComputerResultTextBox.AppendText("Please enter a computer name.")
    }
})

# Add the button for displaying currently running processes
$ComputersTab.Controls.Add($ShowProcessesButton)



# Create button for remotely restarting the computer
$RestartComputerButton = New-Object System.Windows.Forms.Button
$RestartComputerButton.Text = "Restart Computer"
$RestartComputerButton.Width = 120  # Set the width to a suitable value
$RestartComputerButton.Location = New-Object System.Drawing.Point(500, 80)
$RestartComputerButton.Add_Click({
    $ComputerToRestart = $ComputerTextBox.Text

    if ($ComputerToRestart) {
        Restart-Computer -ComputerName $ComputerToRestart -Force
    } else {
        [System.Windows.Forms.MessageBox]::Show("Please enter a computer name.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})

# Add the button for remotely restarting the computer
$ComputersTab.Controls.Add($RestartComputerButton)



# Add the Computers tab to the tab control
$TabControl.TabPages.Add($ComputersTab)

# Add the tab control to the form
$Form.Controls.Add($TabControl)
#endregion "Computers"tab

#region "Historical AD Groups"tab

# Create "Historical AD Groups" tab
$HistoricalGroupsTab = New-Object System.Windows.Forms.TabPage
$HistoricalGroupsTab.Text = "Historical AD Groups"

# Create a text box for entering text
$HistoricalGroupsTextBox = New-Object System.Windows.Forms.TextBox
$HistoricalGroupsTextBox.Location = New-Object System.Drawing.Point(10, 70)
$HistoricalGroupsTextBox.Size = New-Object System.Drawing.Size(480, 180)
$HistoricalGroupsTextBox.Multiline = $true
$HistoricalGroupsTextBox.ScrollBars = "Vertical"

# Create an "Export" button
$ExportHistoricalButton = New-Object System.Windows.Forms.Button
$ExportHistoricalButton.Text = "Export"
$ExportHistoricalButton.Location = New-Object System.Drawing.Point(10, 260)
$ExportHistoricalButton.Add_Click({
    # Show a Save File dialog to choose the export location
    $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $saveFileDialog.Filter = "CSV (*.csv)|*.csv"
    $saveFileDialog.Title = "Export Historical Data"

    if ($saveFileDialog.ShowDialog() -eq "OK") {
        $filePath = $saveFileDialog.FileName

        # Split the text into lines and remove "NYUMC\" prefix
        $lines = $HistoricalGroupsTextBox.Text -split '\s*,\s*' | ForEach-Object { $_ -replace '^NYUMC\\', '' }

        # Create an array of objects with a "Name" property
        $data = $lines | ForEach-Object { [PSCustomObject]@{ Name = $_ } }

        # Export the data to a CSV file
        $data | Export-Csv -Path $filePath -NoTypeInformation

        [System.Windows.Forms.MessageBox]::Show("Data exported successfully.", "Export Data", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
})

# Add the text box and export button to the "Historical AD Groups" tab
$HistoricalGroupsTab.Controls.Add($HistoricalGroupsTextBox)
$HistoricalGroupsTab.Controls.Add($ExportHistoricalButton)

# Add the "Historical AD Groups" tab to the tab control
$TabControl.TabPages.Add($HistoricalGroupsTab)
#endregion "Historical AD Groups"tab




# Show the form
$Form.ShowDialog()
