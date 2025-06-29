🟩 Functions
Function Name Return Type Arguments
check_expiry_on_scan trigger -
cleanup_old_qr_configs void -
deactivate_expired_qr_configs void -
increment_scan_count void config_uuid uuid
update_updated_at_column trigger -

🟨 Triggers
Trigger Name Table Function Event Orientation Enabled
check_expiry_after_scan qr_configs check_expiry_on_scan BEFORE UPDATE ROW ✅
update_custom_links_updated_at custom_links update_updated_at_column BEFORE UPDATE ROW ✅
update_qr_configs_updated_at qr_configs update_updated_at_column BEFORE UPDATE ROW ✅
update_qr_presets_updated_at qr_presets update_updated_at_column BEFORE UPDATE ROW ✅
update_users_updated_at users update_updated_at_column BEFORE UPDATE ROW ✅
