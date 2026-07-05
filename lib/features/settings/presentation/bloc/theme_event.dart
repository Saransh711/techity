import 'package:equatable/equatable.dart';

sealed class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

final class LoadTheme extends ThemeEvent {
  const LoadTheme();
}

final class ToggleTheme extends ThemeEvent {
  const ToggleTheme();
}
