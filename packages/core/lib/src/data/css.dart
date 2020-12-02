part of '../core_data.dart';

/// A border of a box.
@immutable
class CssBorder {
  final CssBorderSide _all;
  final CssBorderSide _bottom;
  final CssBorderSide _inlineEnd;
  final CssBorderSide _inlineStart;
  final CssBorderSide _left;
  final CssBorderSide _right;
  final CssBorderSide _top;

  /// Creates a border.
  const CssBorder({
    CssBorderSide all,
    CssBorderSide bottom,
    CssBorderSide inlineEnd,
    CssBorderSide inlineStart,
    CssBorderSide left,
    CssBorderSide right,
    CssBorderSide top,
  })  : _all = all,
        _bottom = bottom,
        _inlineEnd = inlineEnd,
        _inlineStart = inlineStart,
        _left = left,
        _right = right,
        _top = top;

  /// Returns `true` if all sides are unset.
  bool get isNone =>
      (_all == null || _all == CssBorderSide.none) &&
      (_bottom == null || _bottom == CssBorderSide.none) &&
      (_inlineEnd == null || _inlineEnd == CssBorderSide.none) &&
      (_inlineStart == null || _inlineStart == CssBorderSide.none) &&
      (_left == null || _left == CssBorderSide.none) &&
      (_right == null || _right == CssBorderSide.none) &&
      (_top == null || _top == CssBorderSide.none);

  /// Creates a copy of this border but with the given fields replaced with the new values.
  CssBorder copyWith({
    CssBorderSide all,
    CssBorderSide bottom,
    CssBorderSide inlineEnd,
    CssBorderSide inlineStart,
    CssBorderSide left,
    CssBorderSide right,
    CssBorderSide top,
  }) =>
      CssBorder(
        all: CssBorderSide._copyWith(_all, all),
        bottom: CssBorderSide._copyWith(_bottom, bottom),
        inlineEnd: CssBorderSide._copyWith(_inlineEnd, inlineEnd),
        inlineStart: CssBorderSide._copyWith(_inlineStart, inlineStart),
        left: CssBorderSide._copyWith(_left, left),
        right: CssBorderSide._copyWith(_right, right),
        top: CssBorderSide._copyWith(_top, top),
      );

  /// Calculates [Border].
  Border getValue(TextStyleHtml tsh) {
    final bottom = CssBorderSide._copyWith(_all, _bottom)?._getValue(tsh);
    final left = CssBorderSide._copyWith(
            _all,
            _left ??
                (tsh.textDirection == TextDirection.ltr
                    ? _inlineStart
                    : _inlineEnd))
        ?._getValue(tsh);
    final right = CssBorderSide._copyWith(
            _all,
            _right ??
                (tsh.textDirection == TextDirection.ltr
                    ? _inlineEnd
                    : _inlineStart))
        ?._getValue(tsh);
    final top = CssBorderSide._copyWith(_all, _top)?._getValue(tsh);
    if (bottom == null && left == null && right == null && top == null) {
      return null;
    }

    return Border(
      bottom: bottom ?? BorderSide.none,
      left: left ?? BorderSide.none,
      right: right ?? BorderSide.none,
      top: top ?? BorderSide.none,
    );
  }

  @override
  String toString() {
    final bottom = CssBorderSide._copyWith(_all, _bottom);
    final left = CssBorderSide._copyWith(_all, _left ?? _inlineStart);
    final right = CssBorderSide._copyWith(_all, _right ?? _inlineEnd);
    final top = CssBorderSide._copyWith(_all, _top);
    final params = [
      if (bottom != null) 'bottom: $bottom',
      if (left != null) 'left: $left',
      if (right != null) 'right: $right',
      if (top != null) 'top: $top',
    ];
    return 'CssBorder(${params.join(", ")})';
  }
}

/// A side of a border of a box.
@immutable
class CssBorderSide {
  /// The color of this side of the border.
  final Color color;

  /// The style of this side of the border.
  final TextDecorationStyle style;

  /// The width of this side of the border.
  final CssLength width;

  /// Creates the side of a border.
  const CssBorderSide({this.color, this.style, this.width});

  /// A border that is not rendered.
  static const none = CssBorderSide();

  @override
  String toString() {
    final params = [
      if (color != null) 'color: $color',
      if (style != null) 'style: $style',
      if (width != null) 'width: $width',
    ];
    return 'CssBorderSide(${params.join(", ")})';
  }

  BorderSide _getValue(TextStyleHtml tsh) => identical(this, none)
      ? null
      : BorderSide(
          color: color ?? tsh.style.color,
          // TODO: add proper support for other border styles
          style: style != null ? BorderStyle.solid : BorderStyle.none,
          width: width?.getValue(tsh) ?? 0.0,
        );

  static CssBorderSide _copyWith(CssBorderSide base, CssBorderSide value) =>
      base == null || identical(value, none)
          ? value
          : value == null
              ? base
              : CssBorderSide(
                  color: value.color ?? base.color,
                  style: value.style ?? base.style,
                  width: value.width ?? base.width,
                );
}

/// A length measurement.
@immutable
class CssLength {
  /// The measurement number.
  final double number;

  /// The measurement unit.
  final CssLengthUnit unit;

  /// Creates a measurement.
  ///
  /// [number] must not be negative.
  const CssLength(
    this.number, [
    this.unit = CssLengthUnit.px,
  ])  : assert(number >= 0),
        assert(unit != null);

  /// Returns `true` if value is non-zero.
  bool get isNotEmpty => number > 0;

  /// Calculates value in logical pixel.
  double getValue(TextStyleHtml tsh, {double baseValue, double scaleFactor}) {
    double value;
    switch (unit) {
      case CssLengthUnit.auto:
        return null;
      case CssLengthUnit.em:
        baseValue ??= tsh.style.fontSize;
        value = baseValue * number;
        scaleFactor = 1;
        break;
      case CssLengthUnit.percentage:
        if (baseValue == null) return null;
        value = baseValue * number / 100;
        scaleFactor = 1;
        break;
      case CssLengthUnit.pt:
        value = number * 96 / 72;
        break;
      case CssLengthUnit.px:
        value = number;
        break;
    }

    if (value == null) return null;
    if (scaleFactor != null) value *= scaleFactor;

    return value;
  }

  @override
  String toString() =>
      number.toString() + unit.toString().replaceAll('CssLengthUnit.', '');
}

/// A set of length measurements.
@immutable
class CssLengthBox {
  /// The bottom measurement.
  final CssLength bottom;

  final CssLength _inlineEnd;

  final CssLength _inlineStart;

  final CssLength _left;

  final CssLength _right;

  /// The top measurement.
  final CssLength top;

  /// Creates a set.
  const CssLengthBox({
    this.bottom,
    CssLength inlineEnd,
    CssLength inlineStart,
    CssLength left,
    CssLength right,
    this.top,
  })  : _inlineEnd = inlineEnd,
        _inlineStart = inlineStart,
        _left = left,
        _right = right;

  /// Creates a copy with the given measurements replaced with the new values.
  CssLengthBox copyWith({
    CssLength bottom,
    CssLength inlineEnd,
    CssLength inlineStart,
    CssLength left,
    CssLength right,
    CssLength top,
  }) =>
      CssLengthBox(
        bottom: bottom ?? this.bottom,
        inlineEnd: inlineEnd ?? _inlineEnd,
        inlineStart: inlineStart ?? _inlineStart,
        left: left ?? _left,
        right: right ?? _right,
        top: top ?? this.top,
      );

  /// Returns `true` if any of the left, right, inline measurements is set.
  bool get hasLeftOrRight =>
      _inlineEnd?.isNotEmpty == true ||
      _inlineStart?.isNotEmpty == true ||
      _left?.isNotEmpty == true ||
      _right?.isNotEmpty == true;

  /// Calculates the left value taking text direction into account.
  double getValueLeft(TextStyleHtml tsh) => (_left ??
          (tsh.textDirection == TextDirection.ltr ? _inlineStart : _inlineEnd))
      ?.getValue(tsh);

  /// Calculates the right value taking text direction into account.
  double getValueRight(TextStyleHtml tsh) => (_right ??
          (tsh.textDirection == TextDirection.ltr ? _inlineEnd : _inlineStart))
      ?.getValue(tsh);
}

/// Length measurement units.
enum CssLengthUnit {
  /// Special value: auto.
  auto,

  /// Relative unit: em.
  em,

  /// Relative unit: percentage.
  percentage,

  /// Absolute unit: points, 1pt = 1/72th of 1in.
  pt,

  /// Absolute unit: pixels, 1px = 1/96th of 1in.
  px,
}
