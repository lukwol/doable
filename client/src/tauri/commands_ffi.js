import { invoke, isTauri } from "@tauri-apps/api/core";
import { Some, None } from "../../gleam_stdlib/gleam/option.mjs";

export async function tauri_is_dev() {
  return isTauri() ? invoke("is_dev") : false;
}

export async function tauri_dev_host() {
  const host = isTauri() ? await invoke("tauri_dev_host") : null;
  return host ? new Some(host) : new None();
}
