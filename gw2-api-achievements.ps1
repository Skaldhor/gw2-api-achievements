# --- declaring variables ---
$export = "$env:USERPROFILE\Desktop\GW2-Achievements.csv"
$exportAchWithoutCategory = "$env:USERPROFILE\Desktop\GW2-Achievements_without_category.csv"


# --- script ---
# creating csv with header line - delimiter is "~" since comma and semicolon are part of some descriptions and requirements
Add-Content -Path $export -Value "CategoryID~CategoryName~CategoryIcon~AchievementID~AchievementName~AchievementDescription~AchievementTodo~AchievementPoints"


# getting api
$allAchievementCategoryIDs = Invoke-RestMethod -Uri "https://api.guildwars2.com/v2/achievements/Categories"
foreach($achievementCategoryID in $allAchievementCategoryIDs){
    $achievementCategory = Invoke-RestMethod -Uri "https://api.guildwars2.com/v2/achievements/Categories/$achievementCategoryID"

    # merge multiple lines into one, fix formatting and delete format errors for achievement category name
    $achievementCategoryName = $achievementCategory.name
    if($achievementCategoryName -match "<c=@flavor>"){$achievementCategoryName = $achievementCategoryName.Replace("<c=@flavor>","")}
    if($achievementCategoryName -match "<c=@reminder>"){$achievementCategoryName = $achievementCategoryName.Replace("<c=@reminder>","")}
    if($achievementCategoryName -match "</c>"){$achievementCategoryName = $achievementCategoryName.Replace("</c>","")}
    if($achievementCategoryName -match "`n"){$achievementCategoryName = $achievementCategoryName.Replace("`n"," ")}

    $achievementCategoryIcon = $achievementCategory.icon
    foreach($achievementID in ($achievementCategory.achievements)){
        $achievement = Invoke-RestMethod -Uri "https://api.guildwars2.com/v2/achievements/$achievementID"
        $achievementName = $achievement.name

        # merge multiple lines into one, fix formatting and delete format errors for achievement description
        $achievementDescription = $achievement.description
        if($achievementDescription -match "<c=@flavor>"){$achievementDescription = $achievementDescription.Replace("<c=@flavor>","")}
        if($achievementDescription -match "<c=@reminder>"){$achievementDescription = $achievementDescription.Replace("<c=@reminder>","")}
        if($achievementDescription -match "</c>"){$achievementDescription = $achievementDescription.Replace("</c>","")}
        if($achievementDescription -match "`n"){$achievementDescription = $achievementDescription.Replace("`n"," ")}

        # merge multiple lines into one, fix formatting and delete format errors for achievement requirement
        $achievementTodo = $achievement.requirement
        if($achievementTodo -match "<c=@flavor>"){$achievementTodo = $achievementTodo.Replace("<c=@flavor>","")}
        if($achievementTodo -match "<c=@reminder>"){$achievementTodo = $achievementTodo.Replace("<c=@reminder>","")}
        if($achievementTodo -match "</c>"){$achievementTodo = $achievementTodo.Replace("</c>","")}
        if($achievementTodo -match "`n"){$achievementTodo = $achievementTodo.Replace("`n"," ")}

        # count achievement points from different tiers to total score
        $achievementPointList = $achievement.tiers.points
        $achievementPoints = 0
        $achievementPointList | ForEach-Object{$achievementPoints += $_}

        # build line to export for csv - delimiter is "~" since comma and semicolon are part of some descriptions and requirements
        $result = "$achievementCategoryID~$achievementCategoryName~$achievementCategoryIcon~$achievementID~$achievementName~$achievementDescription~$achievementTodo~$achievementPoints"
        Write-Output $result
        for($i=5; $i -gt 0; $i--){
            try{
                Add-Content -Path $export -Value $result -ErrorAction Stop
                break
            }
            catch{
                Start-Sleep 5
            }
        }
        # sleep 200ms before the next query because the API server would temporarily block this pc because of too many requests
        Start-Sleep -Milliseconds 200
    }
}

[System.Collections.Generic.List[string]]$allAchievementIDs = Invoke-RestMethod -Uri "https://api.guildwars2.com/v2/achievements"
[System.Collections.Generic.List[string]]$allAchievementCategoryIDs = Invoke-RestMethod -Uri "https://api.guildwars2.com/v2/achievements/Categories"
[System.Collections.Generic.List[string]]$achievementIDsWithoutCategory = $allAchievementIDs
Add-Content -Path $exportAchWithoutCategory -Value "AchievementID~AchievementName~AchievementDescription~AchievementTodo~AchievementPoints"
foreach($achievementCategoryID in $allAchievementCategoryIDs){
    $achievementCategory = Invoke-RestMethod -Uri "https://api.guildwars2.com/v2/achievements/Categories/$achievementCategoryID"
    $categoryAchievements = $achievementCategory.achievements
    foreach($categoryAchievementID in $categoryAchievements){
        $achievementIDsWithoutCategory.Remove($categoryAchievementID) | Out-Null
    }
}

foreach($achievementID in $achievementIDsWithoutCategory){
    $achievement = Invoke-RestMethod -Uri "https://api.guildwars2.com/v2/achievements/$achievementID"
    $achievementName = $achievement.name

    # merge multiple lines into one, fix formatting and delete format errors for achievement description
    $achievementDescription = $achievement.description
    if($achievementDescription -match "<c=@flavor>"){$achievementDescription = $achievementDescription.Replace("<c=@flavor>","")}
    if($achievementDescription -match "<c=@reminder>"){$achievementDescription = $achievementDescription.Replace("<c=@reminder>","")}
    if($achievementDescription -match "</c>"){$achievementDescription = $achievementDescription.Replace("</c>","")}
    if($achievementDescription -match "`n"){$achievementDescription = $achievementDescription.Replace("`n"," ")}

    # merge multiple lines into one, fix formatting and delete format errors for achievement requirement
    $achievementTodo = $achievement.requirement
    if($achievementTodo -match "<c=@flavor>"){$achievementTodo = $achievementTodo.Replace("<c=@flavor>","")}
    if($achievementTodo -match "<c=@reminder>"){$achievementTodo = $achievementTodo.Replace("<c=@reminder>","")}
    if($achievementTodo -match "</c>"){$achievementTodo = $achievementTodo.Replace("</c>","")}
    if($achievementTodo -match "`n"){$achievementTodo = $achievementTodo.Replace("`n"," ")}

    # count achievement points from different tiers to total score
    $achievementPointList = $achievement.tiers.points
    $achievementPoints = 0
    $achievementPointList | ForEach-Object{$achievementPoints += $_}

    # build line to export for csv - delimiter is "~" since comma and semicolon are part of some descriptions and requirements
    $result = "$achievementID~$achievementName~$achievementDescription~$achievementTodo~$achievementPoints"
    Write-Output $result
    for($i=5; $i -gt 0; $i--){
        try{
            Add-Content -Path $exportAchWithoutCategory -Value $result -ErrorAction Stop
            break
        }
        catch{
            Start-Sleep 5
        }
    }
    # sleep 200ms before the next query because the API server would temporarily block this pc because of too many requests
    Start-Sleep -Milliseconds 200
}