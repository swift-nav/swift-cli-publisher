#!/usr/bin/env bash
TEMPLATE_FILE="template.json"

echo "Generating new $VERSION release for $NAME"

# Should probably use serialization from Package struct
NEW_RELEASE=$(jq \
  --arg name "$NAME" \
  --arg version "$VERSION" \
  \
  --arg base_dir_linux "${BASE_DIR[0]}" \
  --arg base_dir_macos "${BASE_DIR[0]}" \
  --arg base_dir_windows "${BASE_DIR[0]}" \
  \
  --arg base_url "${BASE_URL}" \
  --arg project_slug "${PROJECT_SLUG:="swift-nav/$NAME"}" \
  --arg download_linux "${DOWNLOAD_FILES[0]}" \
  --arg download_macos "${DOWNLOAD_FILES[1]}" \
  --arg download_windows "${DOWNLOAD_FILES[2]}" \
  \
  --arg tools "${TOOLS}" \
  --arg linked "${LINKED:=false}" \
  --compact-output \
  '.name=$name
  | .version=$version

  | .base_dir.linux=$base_dir_linux
  | .base_dir.macos=$base_dir_macos
  | .base_dir.windows=$base_dir_windows

  | if .download.Web.base_url=="" then
  (
    .download.GitHub.project_slug=$project_slug
    | .download.GitHub.linux=$download_linux
    | .download.GitHub.macos=$download_macos
    | .download.GitHub.windows=$download_windows
  )
  else
  (
    .download.Web.base_url=$base_url
    | .download.Web.linux=$download_linux
    | .download.Web.macos=$download_macos
    | .download.Web.windows=$download_windows
  )
  end

  | .tools=[$tools]
  | .linked=$linked' \
  $TEMPLATE_FILE)

printf '%s\n' 0a "$NEW_RELEASE" . x | ex data/"$NAME"
