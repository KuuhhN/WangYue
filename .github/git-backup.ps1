cd $HOME\.openclaw\workspace
git add -A
$d = (Get-Date).ToString('yyyy-MM-ddTHH:mm')
git commit --allow-empty -m "auto: backup $d"
git push 2>&1
echo "Backup done"
