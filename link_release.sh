#!/usr/bin/env bash
TEMPLATE_FILE="template.json"

echo "Generating new $VERSION release for $NAME"

DLS=("$DL_LINUX" "$DL_MAC" "$DL_WIN")
DIR=("$DIR_LINUX" "$DIR_MAC" "$DIR_WIN")

LEN=${#DLS[@]}

for ((i=0; i<"$LEN"; i++)); do
  curr_dl=${DLS[${i}]}
  if test -f "$curr_dl"; then
    SHA[$i]=$(shasum -a 256 "$curr_dl" | cut -d ' ' -f 1)
    echo "sha[${i}] computed: ${SHA[$i]}"
  fi
done

# shellcheck disable=SC2016
platforms='{"linux": $linux,"macos": $mac,"windows": $win}'

sha_struct=$(jq --null-input --arg linux "${SHA[0]}" --arg macos "${SHA[1]}" --arg win "${SHA[2]}" "$platforms")
dir_struct=$(jq --null-input --arg linux "${DIR[0]}" --arg mac "${DIR[1]}" --arg win "${DIR[2]}" "$platforms")

# JQ dl path can either be .download.Web or .download.GitHub
if [[ $BASE_URL ]];
then
  JQ_DL_PATH="GitHub"
  dl_struct=$(echo "$dl_struct" | jq --arg x "${PROJECT_SLUG:="swift-nav/$NAME"}" '.project_slug=$x')
else
  JQ_DL_PATH="Web"
  dl_struct=$(echo "$dl_struct" | jq --arg x "$BASE_URL" '.base_url=$x')
fi

# Should probably use serialization from Package struct
NEW_RELEASE=$(jq \
  --arg name "$NAME" \
  --arg version "$VERSION" \
  --argjson bd "${dir_struct}" \
  --argjson sha "${sha_struct}" \
  --argjson dl "${dl_struct}" \
  --arg jq_dl_path "${JQ_DL_PATH}" \
  --arg tools "${TOOLS}" \
  --argjson linked "${LINKED:=false}" \
  --compact-output \
  '.name=$name
  | .version=$version
  | .base_dir=$bd
  | .sha256=$sha
  | (.download | .[$jq_dl_path])=$dl
  end

  | .tools=($tools | split(","))
  | .linked=$linked' \
  $TEMPLATE_FILE)

printf "%s\n" "$NEW_RELEASE" >> data/"${NAME,,}"
