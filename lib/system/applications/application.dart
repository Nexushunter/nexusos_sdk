import 'dart:io';

/// An [Application] represent a binary installed within the system.
///
/// An [Application] represents a binary installed within the system, it also
/// represents an instance running
class Application {
  /// This application's [path] to where it is installed in the file system.
  String path;

  /// This application's [name].
  String name;

  /// This application's [iconPath].
  String iconPath;

  Application({
    this.name,
    this.path,
    this.iconPath,
  });

  /// Clones the base application and attaches the requested process.
  clone(Future<ProcessResult> process) {
    return Application(name: name, path: path, iconPath: iconPath)
      ..process = process;
  }

  /// This application's running [process].
  Future<ProcessResult> _process;
  Future<ProcessResult> get process => _process;
  set process(Future<ProcessResult> _process) {
    _process = _process;
  }
}
