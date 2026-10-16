/// The three layouts every screen adapts to.
///
/// * phone (< 600 px wide): top bar and a slide-out menu.
/// * tablet (600–1023 px): a slim icon rail on the left.
/// * desktop (1024 px and up): the full sidebar with labels.
enum ScreenSize {
  phone,
  tablet,
  desktop;

  static ScreenSize of(double width) {
    if (width < 600) return ScreenSize.phone;
    if (width < 1024) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }

  bool get isPhone => this == ScreenSize.phone;
  bool get isDesktop => this == ScreenSize.desktop;
}
