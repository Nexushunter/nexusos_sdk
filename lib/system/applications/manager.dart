import 'dart:io';

import 'package:logging/logging.dart';

import '../../utils/utils.dart';
import 'application.dart';

/// [ApplicationManager] manages all applications.
///
/// Manages all of the current running application started within
/// Nexus Desktop Environment.
class ApplicationManager {
  ApplicationManager() {
    _getInstalledApplications();
  }
  final _logger = Logger('ApplicationManager');

  /// The list of [running] applications
  List<Application> _applications = [];
  List<Application> get running => _applications;

  /// This system's list of [installed] applications.
  List<Application> _installed = [];
  List<Application> get installedApps => _installed;

  /// Fetches this system's currently installed applications.
  ///
  /// Fetches this system's installed binaries. These are the standard
  /// binaries installed on the system. Within NexusOs these directories hold
  /// the system wide applications, where as the user installed applications
  /// are contained within their $HOME/Applications/{AppName}.
  _getInstalledApplications() {
    // TODO: Use isolates???
    // Look through bin
    _logger.info('Loading System Applications');
    Directory bin = Directory('/usr/bin');
    Directory sbin = Directory('/usr/sbin');
    _getAppsFromDir(bin);
    _getAppsFromDir(sbin);
  }

  /// Fetches all of the applications installed within the [directory].
  _getAppsFromDir(Directory directory) async {
    if (!directory.existsSync()) {
      return;
    }
    final dirApps = directory.list(followLinks: true);
    dirApps.forEach((dirApp) {
      // A file is the executable file
      if (dirApp is File) {
        // TODO: Add application entry mappings for NexusOS
        String path = dirApp.path;
        String name = path.parseName();

        final app = Application(name: name, path: path);
        _installed.add(app);
      }
    });
  }

  // Start
  start(String appName) async {
    // TODO: Handle Password Request when /usr/sbin apps are run
    // May map to system application directory in NexisOs Project
    final app = _installed.firstWhere(
      (app) => app.name.toLowerCase() == appName.toLowerCase(),
    );
    app.process = Process.run(app.path, []);
    _applications.add(app);
  }

  // Stop
  stop(String appName) async {
    final app = _applications.firstWhere(
      (app) => app.name.toLowerCase() == appName.toLowerCase(),
    );
    var process = await app.process;
    Process.killPid(process.pid);
    _applications.removeWhere((killed) => killed == app);
  }

  /// This watches the user's application directory for updates.
  ///
  /// This watches to ensure any updates to the user's application directory
  /// and adds the newly installed applications to the list of accessible
  /// applications.
  watchUserApps(Directory userDir) {
    // If the path is not in the user's home directory ignore the files.
    if (RegExp(r'^/home/').hasMatch(userDir.path)) {
      // Check if the current directory directory is the user application directory.
      if (_isUserAppDir(userDir.path)) {
        _getAppsFromDir(userDir);
        return;
      } else {
        final userHome = _parseHome(userDir.path);
        _getAppsFromDir(Directory(userHome));
        _getAppsFromDir(userDir);
      }
    }
  }

  _isUserAppDir(String path) =>
      RegExp(r'^\/home\/.*\/Applications\/*').hasMatch(path);

  _parseHome(String path) => RegExp(r'^\/home\/.*\/').stringMatch(path);
}
