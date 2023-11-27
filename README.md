# ADTool
## What is the ADTool
The ADTool is a Powershell script with GUI for viewing AD objects and other task. It can be used for viewing user group memberships and well as viewing members of specific AD groups.
## Running the ADTool
As the ADTool is a Powershell script you will need to locate the script file and run it with powershell. You can do this via powershell or explorer.
![add image of running in powershell]()
# The Links Tab
This tab serves as a list of URLs for various web apps. Clicking on the one of the buttons should open the webpage in your default browser
![add image of links tab]()
# The Search Tab
This tab provides a powerful tool for querying Active Directory. Users can search for information related to both users and groups, offering flexibility and detailed results.
## Search Types
The search function is divided into three types. You can use the radio boxes to select one of the types to begin your search.
### Search Users
This option allows you to search for specific users in Active
How to Use:

    -Enter the user's SamAccountName in the "Keyword" text box
    -Click the "Search" button
    -View the results in the text box below, including user details and group memberships
### Search Groups
This option enables you to search for Active Directory groups based on a partial match of their names.
How to Use:

    -Enter a name of the group in the "Keyword" text box. Keyword should be an extact match of the AD group you are looking for
    -Click the "Search" button
    -Explore the results in the text box, which includes group details and member information
### Wildcard
This option searches for AD groups using wildcards, displaying only those with partial matches in their names.
How to Use:

    -Enter a partial name of the group in the "Keyword" text box
    -Click the "Search" button
    -Examine the results in the text box, which shows groups with partial name matches
# The Export Tab
This tab provides a convenient way to export search results to a CSV file. How to Use:

    -Conduct a search using the "Search" tab
    -Click on the "Export" tab
    -Select the location where you want to save the CSV file
# The Computers Tab
This tab allows users to retrieve detailed information about a remote computer in the Active Directory
# The Historical AD Groups Tab
This tab allows users to generate a CSV file that is properly formated for restoring AD groups. How to Use:

    -Enter historical AD group information into the text box
    -Click the "Export" button
    -Choose a location to save the CSV file


