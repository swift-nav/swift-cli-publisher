#!/usr/bin/env bash
TEMPLATE_FILE="template.json"

echo "Generating new $VERSION release for $NAME"

DLS=("$DL_LINUX" "$DL_MAC" "$DL_WIN")
DIR=("$DIR_LINUX" "$DIR_MAC" "$DIR_WIN")

DL_LINUX_ARCH=("$DL_LINUX_X86_64" "$DL_LINUX_AARCH64" "$DL_LINUX_ARM")
DL_MAC_ARCH=("$DL_MAC_X86_64" "$DL_MAC_AARCH64" "$DL_MAC_ARM")
DL_WIN_ARCH=("$DL_WIN_X86_64" "$DL_WIN_AARCH64" "$DL_WIN_ARM")

# shellcheck disable=SC2016
arch_specific='{"x86_64":$x86_64,"aarch64":$aarch,"arm":$arm}'

# Compute all architecture structs and shas
for ((i=0; i<3; i++)); do # iterate over platforms, linux, mac, win
  curr_dl=${DLS[${i}]}
  if test -f "$curr_dl"; then # test whether file exists
    NS_SHA[$i]=$(shasum -a 256 "$curr_dl" | cut -d ' ' -f 1)
    echo "nonspecific sha[${i}] computed: ${NS_SHA[$i]}"
    DLS[$i]='"'$curr_dl'"' # wrap with "" to parse as valid argjson
  else
    case ${i} in
      0) platform=${DL_LINUX_ARCH[*]};;
      1) platform=${DL_MAC_ARCH[*]};;
      2) platform=${DL_WIN_ARCH[*]};;
    esac
    for ((j=0; j<${#platform[@]}; j++)); do
      curr_dl=${platform[${j}]}
      if test -f "$curr_dl"; then
        S_SHA[$i]=$(shasum -a 256 "$curr_dl" | cut -d ' ' -f 1)
        echo "specific sha[${i}][${j}] computed: ${S_SHA[$j]}"
      fi
    done


  fi
done

# shellcheck disable=SC2016

sha_struct=$(jq --null-input --arg linux "${SHA[0]}" --arg mac "${SHA[1]}" --arg win "${SHA[2]}" "$platforms")
dir_struct=$(jq --null-input --arg linux "${DIR[0]}" --arg mac "${DIR[1]}" --arg win "${DIR[2]}" "$platforms")
dl_struct=$(jq --null-input --argjson linux "${DLS[0]}" --argjson mac "${DLS[1]}" --argjson win "${DLS[2]}" "$platforms")

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
  | .tools=($tools | split(","))
  | .linked=$linked' \
  $TEMPLATE_FILE)

printf "%s\n" "$NEW_RELEASE" >> data/"${NAME,,}"
