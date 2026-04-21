import gleam/bool
import gleam/dynamic/decode
import gleam/float
import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

pub const threshold = 120.0

const indicator_height = 48.0

pub type PullState {
  Idle
  Pulling(start_y: Float, offset: Float)
  RefreshTriggered
}

pub fn release(pull_state: PullState) -> PullState {
  case pull_state {
    Pulling(offset:, ..) if offset >=. threshold -> RefreshTriggered
    _ -> Idle
  }
}

pub fn on_touch_start(to_msg: fn(Float) -> msg) -> Attribute(msg) {
  event.on("touchstart", touch_start_decoder(to_msg))
}

pub fn on_touch_move(to_msg: fn(Float) -> msg) -> Attribute(msg) {
  event.on("touchmove", touch_y_decoder(to_msg))
}

pub fn on_touch_end(msg: msg) -> Attribute(msg) {
  event.on("touchend", decode.success(msg))
}

pub fn indicator(refreshing: Bool, pull_state: PullState) -> Element(msg) {
  let pull_offset = case pull_state {
    Pulling(offset:, ..) -> offset
    _ -> 0.0
  }
  let progress = float.min(1.0, pull_offset /. threshold)
  let #(indicator_y, indicator_opacity) = case refreshing {
    True -> #(0.0, "1")
    False -> #(
      { progress *. indicator_height } -. indicator_height,
      float.to_string(progress),
    )
  }
  let transition = case pull_offset >. 0.0 {
    True -> "none"
    False -> "transform 0.2s ease-out, opacity 0.2s ease-out"
  }
  let icon = case refreshing {
    True ->
      html.span([attribute.class("loading loading-spinner loading-lg")], [])
    False ->
      html.span(
        [
          attribute.class("text-3xl icon-[heroicons--arrow-down]"),
          attribute.style(
            "transform",
            "rotate(" <> float.to_string(progress *. 180.0) <> "deg)",
          ),
          attribute.style("transition", "transform 0.1s linear"),
        ],
        [],
      )
  }

  html.div(
    [
      attribute.class(
        "flex absolute inset-x-0 top-0 justify-center items-center h-12",
      ),
      attribute.style(
        "transform",
        "translateY(calc("
          <> float.to_string(indicator_y)
          <> "px + env(safe-area-inset-top)))",
      ),
      attribute.style("opacity", indicator_opacity),
      attribute.style("transition", transition),
    ],
    [icon],
  )
}

fn touch_start_decoder(to_msg: fn(Float) -> msg) -> decode.Decoder(msg) {
  use scroll_y <- decode.then(decode.at(["view", "scrollY"], decode.int))
  use <- bool.guard(scroll_y != 0, decode.failure(to_msg(0.0), "not at top"))
  touch_y_decoder(to_msg)
}

fn touch_y_decoder(to_msg: fn(Float) -> msg) -> decode.Decoder(msg) {
  decode.at(["touches", "0", "clientY"], decode.float)
  |> decode.map(to_msg)
}
