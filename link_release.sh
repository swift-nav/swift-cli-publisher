TEMPLATE_FILE="template.json"

NEW_RELEASE=$(jq \
  --arg name "$NAME" \
  --arg version "$VERSION" \
  --arg base_dir_linux "${BASE_DIR[0]}" \
  --arg base_dir_macos "${BASE_DIR[0]}" \
  --arg base_dir_windows "${BASE_DIR[0]}" \
  --arg project_slug "${PROJECT_SLUG:="swift-nav/$NAME"}" \
  --arg download_linux "${DOWNLOAD_FILES[0]}" \
  --arg download_macos "${DOWNLOAD_FILES[1]}" \
  --arg download_windows "${DOWNLOAD_FILES[2]}" \
  --arg tools "${TOOLS}" \
  --arg linked "${LINKED:=false}" \
  --compact-output \
  '.name=$name
  | .version=$version
  | .base_dir.linux=$base_dir_linux
  | .base_dir.macos=$base_dir_macos
  | .base_dir.windows=$base_dir_windows
  | .download.GitHub.project_slug=$project_slug
  | .download.GitHub.linux=$download_linux
  | .download.GitHub.macos=$download_macos
  | .download.GitHub.windows=$download_windows
  | .tools=[$tools]
  | .linked=$linked' \
  $TEMPLATE_FILE)

printf '%s\n' 0a "$NEW_RELEASE" . x | ex data/"$NAME"
