extends Control

const APP_VERSION := "1.0.0-alpha"
const COMMUNITY_LINE := "add-config CommunityPatch\\RA3_.SkuDef"
const GAME_RELATIVE := "Data/ra3_1.12.game"
const RUNTIME_DLL := "xinput1_3.dll"
const RUNTIME_INI := "fps_patch.ini"
const RUNTIME_DLL_SHA256 := "781b9ec9cc24b6fd495747dd8434073e8abe60784aeb9fbfc4641b47af1560ff"
const RUNTIME_INI_SHA256 := "6b02e5da7af03490a28a76ef11e754a4a65f0dc0ce651ce1bdca23cb4fa7a360"
const RUNTIME_DLL_URL := "https://raw.githubusercontent.com/ARG303/NewVanillaPatch/main/runtime/xinput1_3.dll"
const RUNTIME_INI_URL := "https://raw.githubusercontent.com/ARG303/NewVanillaPatch/main/runtime/fps_patch.ini"

var game_root := ""
var sku_defs: Array[String] = []
var selected_sku := ""
var runtime_download_step := 0
var runtime_temp_dll := ""
var runtime_temp_ini := ""

var path_edit: LineEdit
var sku_option: OptionButton
var game_value: Label
var runtime_value: Label
var community_value: Label
var battlenet_value: Label
var status_label: Label
var play_60_button: Button
var play_30_button: Button
var runtime_button: Button
var folder_dialog: FileDialog
var http: HTTPRequest

func _ready() -> void:
    _build_ui()
    _load_settings()
    _refresh_all()

func _build_ui() -> void:
    var bg := ColorRect.new()
    bg.color = Color("#090b0f")
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)

    var accent := ColorRect.new()
    accent.color = Color("#b3262e")
    accent.position = Vector2(0, 0)
    accent.size = Vector2(1040, 4)
    add_child(accent)

    var root := VBoxContainer.new()
    root.position = Vector2(46, 34)
    root.size = Vector2(948, 620)
    root.add_theme_constant_override("separation", 16)
    add_child(root)

    var header := HBoxContainer.new()
    header.custom_minimum_size = Vector2(0, 76)
    root.add_child(header)

    var title_box := VBoxContainer.new()
    title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    title_box.add_theme_constant_override("separation", 3)
    header.add_child(title_box)

    var title := Label.new()
    title.text = "NEWVANILLA PATCH"
    title.add_theme_font_size_override("font_size", 31)
    title.add_theme_color_override("font_color", Color("#f0f2f5"))
    title_box.add_child(title)

    var subtitle := Label.new()
    subtitle.text = "RED ALERT 3  •  CLEAN GODOT LAUNCHER  •  BATTLE.NET COMPATIBLE"
    subtitle.add_theme_font_size_override("font_size", 12)
    subtitle.add_theme_color_override("font_color", Color("#808690"))
    title_box.add_child(subtitle)

    var version := Label.new()
    version.text = "v" + APP_VERSION
    version.add_theme_font_size_override("font_size", 13)
    version.add_theme_color_override("font_color", Color("#9da3ad"))
    version.vertical_alignment = VERTICAL_ALIGNMENT_TOP
    header.add_child(version)

    var install_panel := _panel()
    root.add_child(install_panel)
    var install_v := VBoxContainer.new()
    install_v.add_theme_constant_override("separation", 10)
    install_panel.add_child(install_v)

    var install_title := Label.new()
    install_title.text = "GAME INSTALLATION"
    install_title.add_theme_font_size_override("font_size", 12)
    install_title.add_theme_color_override("font_color", Color("#9da3ad"))
    install_v.add_child(install_title)

    var path_row := HBoxContainer.new()
    path_row.add_theme_constant_override("separation", 9)
    install_v.add_child(path_row)

    path_edit = LineEdit.new()
    path_edit.placeholder_text = "Select the Command & Conquer Red Alert 3 folder"
    path_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    path_edit.custom_minimum_size = Vector2(0, 42)
    _style_line_edit(path_edit)
    path_edit.text_submitted.connect(_on_path_submitted)
    path_edit.focus_exited.connect(_on_path_focus_exited)
    path_row.add_child(path_edit)

    var browse := Button.new()
    browse.text = "BROWSE"
    browse.custom_minimum_size = Vector2(126, 42)
    _style_button(browse, false)
    browse.pressed.connect(_on_browse)
    path_row.add_child(browse)

    var sku_row := HBoxContainer.new()
    sku_row.add_theme_constant_override("separation", 9)
    install_v.add_child(sku_row)

    var sku_label := Label.new()
    sku_label.text = "Base config"
    sku_label.custom_minimum_size = Vector2(92, 36)
    sku_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    sku_label.add_theme_color_override("font_color", Color("#858b95"))
    sku_row.add_child(sku_label)

    sku_option = OptionButton.new()
    sku_option.custom_minimum_size = Vector2(0, 36)
    sku_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    sku_option.item_selected.connect(_on_sku_selected)
    sku_row.add_child(sku_option)

    var cards := HBoxContainer.new()
    cards.add_theme_constant_override("separation", 12)
    root.add_child(cards)

    var card_game := _status_card("GAME")
    game_value = card_game.get_node("Content/Value") as Label
    cards.add_child(card_game)

    var card_runtime := _status_card("60 FPS RUNTIME")
    runtime_value = card_runtime.get_node("Content/Value") as Label
    cards.add_child(card_runtime)

    var card_community := _status_card("COMMUNITY PATCH")
    community_value = card_community.get_node("Content/Value") as Label
    cards.add_child(card_community)

    var card_bn := _status_card("RA3BATTLENET")
    battlenet_value = card_bn.get_node("Content/Value") as Label
    cards.add_child(card_bn)

    var runtime_panel := _panel()
    root.add_child(runtime_panel)
    var runtime_row := HBoxContainer.new()
    runtime_row.add_theme_constant_override("separation", 12)
    runtime_panel.add_child(runtime_row)

    var runtime_text := VBoxContainer.new()
    runtime_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    runtime_row.add_child(runtime_text)

    var rt_title := Label.new()
    rt_title.text = "60 FPS RUNTIME"
    rt_title.add_theme_font_size_override("font_size", 14)
    rt_title.add_theme_color_override("font_color", Color("#e6e8eb"))
    runtime_text.add_child(rt_title)

    var rt_desc := Label.new()
    rt_desc.text = "Installed only after an explicit click. The launcher does not embed the DLL and never edits ra3_1.12.game."
    rt_desc.add_theme_font_size_override("font_size", 11)
    rt_desc.add_theme_color_override("font_color", Color("#777e88"))
    runtime_text.add_child(rt_desc)

    runtime_button = Button.new()
    runtime_button.custom_minimum_size = Vector2(208, 44)
    _style_button(runtime_button, false)
    runtime_button.pressed.connect(_on_runtime_action)
    runtime_row.add_child(runtime_button)

    var launch_panel := _panel()
    launch_panel.custom_minimum_size = Vector2(0, 152)
    root.add_child(launch_panel)
    var launch_v := VBoxContainer.new()
    launch_v.add_theme_constant_override("separation", 10)
    launch_panel.add_child(launch_v)

    var launch_title := Label.new()
    launch_title.text = "LAUNCH"
    launch_title.add_theme_font_size_override("font_size", 12)
    launch_title.add_theme_color_override("font_color", Color("#9da3ad"))
    launch_v.add_child(launch_title)

    var launch_row := HBoxContainer.new()
    launch_row.add_theme_constant_override("separation", 12)
    launch_v.add_child(launch_row)

    play_60_button = Button.new()
    play_60_button.text = "PLAY WITH 60 FPS"
    play_60_button.custom_minimum_size = Vector2(0, 62)
    play_60_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _style_button(play_60_button, true)
    play_60_button.pressed.connect(_launch_60)
    launch_row.add_child(play_60_button)

    play_30_button = Button.new()
    play_30_button.text = "PLAY VANILLA  •  30 FPS"
    play_30_button.custom_minimum_size = Vector2(0, 62)
    play_30_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _style_button(play_30_button, false)
    play_30_button.pressed.connect(_launch_30)
    launch_row.add_child(play_30_button)

    status_label = Label.new()
    status_label.text = "Ready. Start RA3BattleNet first if you want to play online through it."
    status_label.add_theme_font_size_override("font_size", 11)
    status_label.add_theme_color_override("font_color", Color("#777e88"))
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    root.add_child(status_label)

    folder_dialog = FileDialog.new()
    folder_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
    folder_dialog.access = FileDialog.ACCESS_FILESYSTEM
    folder_dialog.use_native_dialog = true
    folder_dialog.dir_selected.connect(_on_dir_selected)
    add_child(folder_dialog)

    http = HTTPRequest.new()
    http.timeout = 30.0
    http.request_completed.connect(_on_http_completed)
    add_child(http)

func _panel() -> PanelContainer:
    var p := PanelContainer.new()
    var sb := StyleBoxFlat.new()
    sb.bg_color = Color("#11151b")
    sb.border_color = Color("#242a33")
    sb.set_border_width_all(1)
    sb.corner_radius_top_left = 8
    sb.corner_radius_top_right = 8
    sb.corner_radius_bottom_left = 8
    sb.corner_radius_bottom_right = 8
    sb.content_margin_left = 18
    sb.content_margin_right = 18
    sb.content_margin_top = 14
    sb.content_margin_bottom = 14
    p.add_theme_stylebox_override("panel", sb)
    return p

func _status_card(name_text: String) -> PanelContainer:
    var p := _panel()
    p.name = name_text.replace(" ", "")
    p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    p.custom_minimum_size = Vector2(0, 86)
    var v := VBoxContainer.new()
    v.name = "Content"
    v.add_theme_constant_override("separation", 6)
    p.add_child(v)
    var n := Label.new()
    n.text = name_text
    n.add_theme_font_size_override("font_size", 10)
    n.add_theme_color_override("font_color", Color("#777e88"))
    v.add_child(n)
    var value := Label.new()
    value.name = "Value"
    value.text = "—"
    value.add_theme_font_size_override("font_size", 13)
    value.add_theme_color_override("font_color", Color("#d8dbe0"))
    value.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    v.add_child(value)
    return p

func _style_button(button: Button, primary: bool) -> void:
    button.add_theme_font_size_override("font_size", 13)
    var normal := StyleBoxFlat.new()
    normal.bg_color = Color("#a62129") if primary else Color("#1a1f27")
    normal.border_color = Color("#c5333c") if primary else Color("#313845")
    normal.set_border_width_all(1)
    normal.corner_radius_top_left = 6
    normal.corner_radius_top_right = 6
    normal.corner_radius_bottom_left = 6
    normal.corner_radius_bottom_right = 6
    button.add_theme_stylebox_override("normal", normal)
    var hover := normal.duplicate() as StyleBoxFlat
    hover.bg_color = Color("#bd2832") if primary else Color("#242b35")
    button.add_theme_stylebox_override("hover", hover)
    var pressed := normal.duplicate() as StyleBoxFlat
    pressed.bg_color = Color("#811a21") if primary else Color("#11151a")
    button.add_theme_stylebox_override("pressed", pressed)
    var disabled := normal.duplicate() as StyleBoxFlat
    disabled.bg_color = Color("#15181d")
    disabled.border_color = Color("#242830")
    button.add_theme_stylebox_override("disabled", disabled)
    button.add_theme_color_override("font_color", Color("#f4f4f4"))
    button.add_theme_color_override("font_disabled_color", Color("#5f646c"))

func _style_line_edit(edit: LineEdit) -> void:
    var sb := StyleBoxFlat.new()
    sb.bg_color = Color("#0c0f14")
    sb.border_color = Color("#2a3039")
    sb.set_border_width_all(1)
    sb.corner_radius_top_left = 5
    sb.corner_radius_top_right = 5
    sb.corner_radius_bottom_left = 5
    sb.corner_radius_bottom_right = 5
    sb.content_margin_left = 12
    sb.content_margin_right = 12
    edit.add_theme_stylebox_override("normal", sb)
    edit.add_theme_color_override("font_color", Color("#d7dae0"))
    edit.add_theme_color_override("font_placeholder_color", Color("#555b65"))

func _load_settings() -> void:
    var cfg := ConfigFile.new()
    if cfg.load("user://launcher.cfg") == OK:
        game_root = str(cfg.get_value("launcher", "game_root", ""))
        selected_sku = str(cfg.get_value("launcher", "selected_sku", ""))
    path_edit.text = game_root

func _save_settings() -> void:
    var cfg := ConfigFile.new()
    cfg.set_value("launcher", "game_root", game_root)
    cfg.set_value("launcher", "selected_sku", selected_sku)
    cfg.save("user://launcher.cfg")

func _on_browse() -> void:
    if game_root != "" and DirAccess.dir_exists_absolute(game_root):
        folder_dialog.current_dir = game_root
    folder_dialog.popup_centered_ratio(0.72)

func _on_dir_selected(path: String) -> void:
    _apply_game_root(path)

func _on_path_submitted(text: String) -> void:
    _apply_game_root(text)

func _on_path_focus_exited() -> void:
    if path_edit.text.strip_edges() != game_root:
        _apply_game_root(path_edit.text)

func _apply_game_root(path: String) -> void:
    var candidate := _normalize_path(path)
    if candidate.get_file().to_lower() == "data":
        candidate = candidate.get_base_dir()
    game_root = candidate
    path_edit.text = game_root
    _scan_sku_defs()
    _save_settings()
    _refresh_all()

func _normalize_path(path: String) -> String:
    var p := path.strip_edges().replace("\\", "/")
    while p.ends_with("/"):
        p = p.substr(0, p.length() - 1)
    return p

func _game_path() -> String:
    if game_root == "":
        return ""
    return game_root.path_join(GAME_RELATIVE)

func _data_path() -> String:
    if game_root == "":
        return ""
    return game_root.path_join("Data")

func _scan_sku_defs() -> void:
    sku_defs.clear()
    sku_option.clear()
    if game_root == "" or not DirAccess.dir_exists_absolute(game_root):
        selected_sku = ""
        return
    var files := DirAccess.get_files_at(game_root)
    for file_name in files:
        var lower := file_name.to_lower()
        if lower.begins_with("ra3_") and lower.ends_with(".skudef") and lower.contains("_1.12"):
            sku_defs.append(file_name)
    sku_defs.sort_custom(_sku_sort)
    if sku_defs.is_empty():
        selected_sku = ""
        return
    var chosen := 0
    if selected_sku != "":
        for i in range(sku_defs.size()):
            if sku_defs[i] == selected_sku:
                chosen = i
                break
    else:
        for i in range(sku_defs.size()):
            if sku_defs[i].to_lower().contains("1.12.8"):
                chosen = i
                break
    for sku in sku_defs:
        sku_option.add_item(sku)
    sku_option.select(chosen)
    selected_sku = sku_defs[chosen]

func _sku_sort(a: String, b: String) -> bool:
    var a128 := a.to_lower().contains("1.12.8")
    var b128 := b.to_lower().contains("1.12.8")
    if a128 != b128:
        return a128
    return a.naturalnocasecmp_to(b) < 0

func _on_sku_selected(index: int) -> void:
    if index >= 0 and index < sku_defs.size():
        selected_sku = sku_defs[index]
        _save_settings()
        _refresh_all()

func _sku_path() -> String:
    if game_root == "" or selected_sku == "":
        return ""
    return game_root.path_join(selected_sku)

func _community_patch_file() -> String:
    if game_root == "":
        return ""
    return game_root.path_join("CommunityPatch/RA3_.SkuDef")

func _has_community_line() -> bool:
    var path := _sku_path()
    if path == "" or not FileAccess.file_exists(path):
        return false
    var f := FileAccess.open(path, FileAccess.READ)
    if f == null:
        return false
    var text := f.get_as_text()
    return text.to_lower().contains(COMMUNITY_LINE.to_lower())

func _ensure_community_line() -> bool:
    var path := _sku_path()
    if path == "" or not FileAccess.file_exists(path):
        _set_status("Base SkuDef was not found.", true)
        return false
    if _has_community_line():
        return true
    if not FileAccess.file_exists(_community_patch_file()):
        _set_status("CommunityPatch/RA3_.SkuDef is missing. Install CommunityPatch first.", true)
        return false
    var f := FileAccess.open(path, FileAccess.READ)
    if f == null:
        _set_status("Could not read " + selected_sku, true)
        return false
    var original := f.get_as_text()
    var backup := path + ".newvanilla_backup"
    if not FileAccess.file_exists(backup):
        var bf := FileAccess.open(backup, FileAccess.WRITE)
        if bf == null:
            _set_status("Could not create SkuDef backup. Check folder permissions.", true)
            return false
        bf.store_string(original)
    var out := FileAccess.open(path, FileAccess.WRITE)
    if out == null:
        _set_status("Could not update SkuDef. Check folder permissions.", true)
        return false
    var updated := original
    if not updated.ends_with("\n") and not updated.ends_with("\r"):
        updated += "\r\n"
    updated += COMMUNITY_LINE + "\r\n"
    out.store_string(updated)
    _set_status("CommunityPatch config was added once to " + selected_sku + ".", false)
    _refresh_all()
    return true

func _runtime_dll_path() -> String:
    return _data_path().path_join(RUNTIME_DLL) if _data_path() != "" else ""

func _runtime_ini_path() -> String:
    return _data_path().path_join(RUNTIME_INI) if _data_path() != "" else ""

func _hash_matches(path: String, expected: String) -> bool:
    if path == "" or not FileAccess.file_exists(path):
        return false
    return FileAccess.get_sha256(path).to_lower() == expected.to_lower()

func _runtime_ready() -> bool:
    return _hash_matches(_runtime_dll_path(), RUNTIME_DLL_SHA256) and _hash_matches(_runtime_ini_path(), RUNTIME_INI_SHA256)

func _runtime_present() -> bool:
    return FileAccess.file_exists(_runtime_dll_path())

func _refresh_all() -> void:
    if sku_defs.is_empty() and game_root != "":
        _scan_sku_defs()
    var game_ok := FileAccess.file_exists(_game_path())
    game_value.text = "READY" if game_ok else "NOT FOUND"
    game_value.add_theme_color_override("font_color", Color("#69c687") if game_ok else Color("#d05b63"))

    var runtime_ok := _runtime_ready()
    if runtime_ok:
        runtime_value.text = "60 FPS ENABLED"
        runtime_value.add_theme_color_override("font_color", Color("#69c687"))
        runtime_button.text = "DISABLE 60 FPS RUNTIME"
    elif _runtime_present():
        runtime_value.text = "UNKNOWN / OLD DLL"
        runtime_value.add_theme_color_override("font_color", Color("#e6ad59"))
        runtime_button.text = "INSTALL VERIFIED RUNTIME"
    else:
        runtime_value.text = "DISABLED"
        runtime_value.add_theme_color_override("font_color", Color("#9aa0aa"))
        runtime_button.text = "INSTALL 60 FPS RUNTIME"

    var community_file_ok := FileAccess.file_exists(_community_patch_file())
    var community_line_ok := _has_community_line()
    if community_file_ok and community_line_ok:
        community_value.text = "CONFIGURED"
        community_value.add_theme_color_override("font_color", Color("#69c687"))
    elif community_file_ok:
        community_value.text = "READY TO CONFIGURE"
        community_value.add_theme_color_override("font_color", Color("#e6ad59"))
    else:
        community_value.text = "NOT FOUND"
        community_value.add_theme_color_override("font_color", Color("#9aa0aa"))

    battlenet_value.text = "PASSIVE / SAFE"
    battlenet_value.add_theme_color_override("font_color", Color("#69c687"))

    var sku_ok := selected_sku != "" and FileAccess.file_exists(_sku_path())
    play_60_button.disabled = not (game_ok and sku_ok and runtime_ok)
    play_30_button.disabled = not (game_ok and sku_ok and not _runtime_present())
    runtime_button.disabled = not (game_ok and DirAccess.dir_exists_absolute(_data_path()))

    if game_ok and not sku_ok:
        _set_status("RA3 was found, but no RA3_*_1.12*.SkuDef was found. 1.12.8 configs are supported.", true)
    elif game_ok and runtime_ok:
        _set_status("60 FPS runtime is enabled. Disable it explicitly before using the true 30 FPS button.", false)
    elif game_ok:
        _set_status("Ready for vanilla 30 FPS. RA3BattleNet is passive: start its client before launching RA3.", false)

func _on_runtime_action() -> void:
    if _runtime_ready():
        _disable_runtime()
    else:
        _begin_runtime_download()

func _begin_runtime_download() -> void:
    if game_root == "" or not DirAccess.dir_exists_absolute(_data_path()):
        _set_status("Select a valid RA3 folder first.", true)
        return
    var temp_dir := "user://runtime_download"
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(temp_dir))
    runtime_temp_dll = temp_dir.path_join(RUNTIME_DLL)
    runtime_temp_ini = temp_dir.path_join(RUNTIME_INI)
    runtime_download_step = 1
    http.download_file = runtime_temp_dll
    runtime_button.disabled = true
    _set_status("Downloading verified 60 FPS runtime (1/2)...", false)
    var err := http.request(RUNTIME_DLL_URL)
    if err != OK:
        runtime_download_step = 0
        runtime_button.disabled = false
        _set_status("Could not start runtime download: error " + str(err), true)

func _on_http_completed(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
    if result != HTTPRequest.RESULT_SUCCESS or response_code < 200 or response_code >= 300:
        runtime_download_step = 0
        runtime_button.disabled = false
        _set_status("Runtime download failed. HTTP " + str(response_code) + ", result " + str(result), true)
        return
    if runtime_download_step == 1:
        if not _hash_matches(ProjectSettings.globalize_path(runtime_temp_dll), RUNTIME_DLL_SHA256):
            runtime_download_step = 0
            runtime_button.disabled = false
            _set_status("Downloaded xinput1_3.dll failed SHA-256 verification.", true)
            return
        runtime_download_step = 2
        http.download_file = runtime_temp_ini
        _set_status("Downloading verified 60 FPS runtime (2/2)...", false)
        var err := http.request(RUNTIME_INI_URL)
        if err != OK:
            runtime_download_step = 0
            runtime_button.disabled = false
            _set_status("Could not start fps_patch.ini download: error " + str(err), true)
        return
    if runtime_download_step == 2:
        if not _hash_matches(ProjectSettings.globalize_path(runtime_temp_ini), RUNTIME_INI_SHA256):
            runtime_download_step = 0
            runtime_button.disabled = false
            _set_status("Downloaded fps_patch.ini failed SHA-256 verification.", true)
            return
        runtime_download_step = 0
        _install_downloaded_runtime()

func _install_downloaded_runtime() -> void:
    var src_dll := ProjectSettings.globalize_path(runtime_temp_dll)
    var src_ini := ProjectSettings.globalize_path(runtime_temp_ini)
    var dst_dll := _runtime_dll_path()
    var dst_ini := _runtime_ini_path()
    if FileAccess.file_exists(dst_dll) and not _hash_matches(dst_dll, RUNTIME_DLL_SHA256):
        var unknown_backup := dst_dll + ".pre_newvanilla_backup"
        if not FileAccess.file_exists(unknown_backup):
            var copy_old := DirAccess.copy_absolute(dst_dll, unknown_backup)
            if copy_old != OK:
                runtime_button.disabled = false
                _set_status("An existing xinput1_3.dll could not be backed up. Installation stopped.", true)
                return
    var err_dll := DirAccess.copy_absolute(src_dll, dst_dll)
    var err_ini := DirAccess.copy_absolute(src_ini, dst_ini)
    runtime_button.disabled = false
    if err_dll != OK or err_ini != OK:
        _set_status("Could not write runtime to RA3/Data. Check folder permissions.", true)
        _refresh_all()
        return
    if not _runtime_ready():
        _set_status("Runtime files were copied but verification failed. Launch is blocked.", true)
        _refresh_all()
        return
    _set_status("Verified 60 FPS runtime installed. ra3_1.12.game was not modified.", false)
    _refresh_all()

func _disable_runtime() -> void:
    var dll := _runtime_dll_path()
    var ini := _runtime_ini_path()
    if not _runtime_ready():
        _set_status("Refusing to remove an unknown DLL. Only the verified NewVanilla runtime can be disabled here.", true)
        return
    var disabled_dir := ProjectSettings.globalize_path("user://runtime_disabled")
    DirAccess.make_dir_recursive_absolute(disabled_dir)
    var saved_dll := disabled_dir.path_join(RUNTIME_DLL)
    var saved_ini := disabled_dir.path_join(RUNTIME_INI)
    var c1 := DirAccess.copy_absolute(dll, saved_dll)
    var c2 := DirAccess.copy_absolute(ini, saved_ini)
    if c1 != OK or c2 != OK:
        _set_status("Could not create a local runtime backup. Disable cancelled.", true)
        return
    var e1 := DirAccess.remove_absolute(dll)
    var e2 := DirAccess.remove_absolute(ini)
    if e1 != OK or e2 != OK:
        _set_status("Could not disable runtime. Check RA3/Data folder permissions.", true)
        return
    _set_status("60 FPS runtime disabled explicitly. Vanilla 30 FPS is now available.", false)
    _refresh_all()

func _launch_60() -> void:
    if not _runtime_ready():
        _set_status("60 FPS runtime is not enabled.", true)
        return
    _launch_game(60)

func _launch_30() -> void:
    if _runtime_present():
        _set_status("xinput1_3.dll is present. Disable the 60 FPS runtime first to guarantee true 30 FPS.", true)
        return
    _launch_game(30)

func _launch_game(fps: int) -> void:
    if not FileAccess.file_exists(_game_path()):
        _set_status("ra3_1.12.game was not found.", true)
        return
    if _sku_path() == "" or not FileAccess.file_exists(_sku_path()):
        _set_status("No compatible RA3_*_1.12*.SkuDef is selected.", true)
        return
    if not _ensure_community_line():
        return
    var args := PackedStringArray(["-config", _sku_path()])
    var pid := OS.create_process(_game_path(), args, false)
    if pid <= 0:
        _set_status("Could not start RA3. OS error / process id: " + str(pid), true)
        return
    _set_status("RA3 started in vanilla " + str(fps) + " FPS mode. PID " + str(pid) + ". BattleNet is left completely external/passive.", false)

func _set_status(text: String, is_error: bool) -> void:
    if status_label == null:
        return
    status_label.text = text
    status_label.add_theme_color_override("font_color", Color("#d05b63") if is_error else Color("#777e88"))
