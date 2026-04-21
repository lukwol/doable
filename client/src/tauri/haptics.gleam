import lustre/effect.{type Effect}

pub type ImpactStyle {
  Light
  Medium
  Heavy
  Soft
  Rigid
}

@external(javascript, "./haptics_ffi.js", "impact_feedback")
fn do_impact(style: String) -> Nil

fn impact_style_string(style: ImpactStyle) -> String {
  case style {
    Light -> "light"
    Medium -> "medium"
    Heavy -> "heavy"
    Soft -> "soft"
    Rigid -> "rigid"
  }
}

pub fn impact_feedback(style: ImpactStyle) -> Effect(msg) {
  use _ <- effect.from
  style
  |> impact_style_string
  |> do_impact
}
