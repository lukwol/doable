import { Ok, Error } from "../gleam.mjs";
import { NetworkError } from "../../gleam_fetch/gleam/fetch.mjs";
import { isTauri } from "@tauri-apps/api/core";
import { fetch as tauriFetch } from "@tauri-apps/plugin-http";

export async function raw_send(request) {
  try {
    return new Ok(await (isTauri() ? tauriFetch(request) : fetch(request)));
  } catch (error) {
    return new Error(new NetworkError(error.toString()));
  }
}
