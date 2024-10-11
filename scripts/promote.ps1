$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

write-host "Promoting staging to production"

$versionsFile = resolve-path "$PSScriptRoot/../infra/values.yaml"
$versions = get-content -raw $versionsFile
write-host $versions

# yaml is a superset of json, so helm can handle values.yaml being a json object
$json = convertfrom-json $versions
$json.production_image_tag = $json.staging_image_tag
$json | convertto-json -depth 99 | out-file $versionsFile

git config --global user.email "auto@chester.com"
git config --global user.name "chester"

# need to create 2 commits, first of the updated app version then of the updated infra hash
git add -A
git commit -am "Update production to $($json.staging_image_tag)"

$commitId = git rev-parse HEAD
write-host "Git hash is $commitId"
$json.production_revision = $commitId
$json | convertto-json -depth 99 | out-file $versionsFile

git add -A
git commit -am "Update production revision to $commitId"

git push