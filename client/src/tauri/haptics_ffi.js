import { impactFeedback } from "@tauri-apps/plugin-haptics";

export async function impact_feedback(style) {
  await impactFeedback(style);
}
