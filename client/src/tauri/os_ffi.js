import { platform } from "@tauri-apps/plugin-os";

export function platform_string() {
  try {
    return platform();
  } catch {
    return "browser";
  }
}
