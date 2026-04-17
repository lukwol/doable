export function window_location_origin() {
  return window.location.origin;
}

export function history_back() {
  window.history.back();
}

export function reload_page() {
  window.location.reload();
}

export function add_body_class(class_name) {
  document.body.classList.add(class_name);
}
