$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

write-host "Update staging version from git tag"

$versionsFile = resolve-path "$PSScriptRoot/../infra/values.yaml"
$versions = get-content -raw $versionsFile
write-host $versions

$appRepo = "argocd-demo-app"
$appUrl = "https://github.com/chestercodes/$appRepo.git"
git clone $appUrl appRepoDir
cd appRepoDir

$tags = git tag --sort=-creatordate
$latestTag = $tags[0]
write-host "Latest tag is $latestTag"

cd ..

# yaml is a superset of json, so helm can handle values.yaml being a json object
$json = convertfrom-json $versions
$json.staging_image_tag = $latestTag
$json | convertto-json -depth 99 | out-file $versionsFile

git config --global user.email "auto@chester.com"
git config --global user.name "chester"

# don't add -A as it might pickup the cloned repo
git add $versionsFile
git commit -m "Update staging image_tag to $latestTag"

git push