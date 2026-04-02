import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

Item {
  id: root

  property var pluginApi: null

  // Provider metadata
  property string name: "File Search"
  property var launcher: null
  property bool handleSearch: false
  property string supportedLayouts: "list"
  property bool supportsAutoPaste: false

  // Search state
  property var currentResults: []
  property string currentQuery: ""
  property bool searching: false
  property string fdCommandPath: ""
  property bool fdAvailable: false

  // Settings shortcuts
  property bool showHidden: pluginApi?.pluginSettings?.showHidden ?? pluginApi?.manifest?.metadata?.defaultSettings?.showHidden ?? false
  property int maxResults: pluginApi?.pluginSettings?.maxResults ?? pluginApi?.manifest?.metadata?.defaultSettings?.maxResults ?? 0
  property string fileOpener: pluginApi?.pluginSettings?.fileOpener ?? pluginApi?.manifest?.metadata?.defaultSettings?.fileOpener ?? "xdg-open"
  property string searchDirectory: pluginApi?.pluginSettings?.searchDirectory ?? pluginApi?.manifest?.metadata?.defaultSettings?.searchDirectory ?? "~"

  // Debounce timer for search
  Timer {
    id: searchDebouncer
    interval: 300
    repeat: false
    onTriggered: root.executeSearch(root.currentQuery)
  }

  // Process for running fd command
  Process {
    id: fdProcess
    running: false
    
    stdout: StdioCollector {
      id: stdoutCollector
    }

    stderr: StdioCollector {
      id: stderrCollector
    }

    onExited: function(exitCode) {
      root.searching = false;
      
      if (exitCode === 0) {
        root.parseSearchResults(stdoutCollector.text);
      } else {
        Logger.e("FileSearch", "fd command failed with exit code:", exitCode);
        Logger.e("FileSearch", "stderr:", stderrCollector.text);
        
        root.currentResults = [{
          "name": "fd not found",
          "description": "Please install fd to use file search.",
          "icon": "alert-circle",
          "isTablerIcon": true,
          "onActivate": function() {}
        }];
      }
      
      if (launcher) {
        launcher.updateResults();
      }
    }
  }

  function init() {
    Logger.i("FileSearch", "Initializing plugin");
    fdCommandPath = pluginApi?.pluginSettings?.fdCommand ?? "fd";
    fdAvailable = true;
    Logger.i("FileSearch", "Using fd command:", fdCommandPath);
  }

  function handleCommand(searchText) {
    return searchText.startsWith(">file");
  }

  function commands() {
    return [{
      "name": ">file",
      "description": "Search for files",
      "icon": "file-search",
      "isTablerIcon": true,
      "isImage": false,
      "onActivate": function() {
        launcher.setSearchText(">file ");
      }
    }];
  }

  function getResults(searchText) {
    if (!searchText.startsWith(">file")) {
      return [];
    }

    if (!fdAvailable) {
      return [{
        "name": "fd not found",
        "description": "Please install fd to use file search",
        "icon": "alert-circle",
        "isTablerIcon": true,
        "isImage": false,
        "onActivate": function() {}
      }];
    }

    var query = searchText.slice(5).trim();

    if (query === "") {
      return [{
        "name": "Type to search files",
        "description": "Start typing to search for files",
        "icon": "file-search",
        "isTablerIcon": true,
        "isImage": false,
        "onActivate": function() {}
      }];
    }

    if (query !== currentQuery) {
      currentQuery = query;
      searching = true;
      searchDebouncer.restart();
      
      return [{
        "name": "Searching...",
        "description": "Looking for files matching: " + query,
        "icon": "refresh",
        "isTablerIcon": true,
        "isImage": false,
        "onActivate": function() {}
      }];
    }

    if (searching) {
      return [{
        "name": "Searching...",
        "description": "Looking for files matching: " + query,
        "icon": "refresh",
        "isTablerIcon": true,
        "isImage": false,
        "onActivate": function() {}
      }];
    }

    return currentResults;
  }

  function executeSearch(query) {
    if (!fdAvailable || query === "") {
      return;
    }

    Logger.d("FileSearch", "Executing search for:", query);

    if (fdProcess.running) {
      fdProcess.running = false;
    }

    var expandedDir = searchDirectory;
    if (expandedDir.startsWith("~")) {
      expandedDir = Quickshell.env("HOME") + expandedDir.substring(1);
    }

    var args = [];
    
    // Options
    if (showHidden) {
      args.push("--hidden");
    }
    
    args.push("--type", "f");  // Files only
    if (maxResults > 0) {
      args.push("--max-results", maxResults.toString());
    }
    args.push("--base-directory", expandedDir);
    args.push("--absolute-path");
    args.push("--color", "never");
    
    args.push(query);

    Logger.d("FileSearch", "Running command:", fdCommandPath, args.join(" "));

    fdProcess.command = [fdCommandPath].concat(args);
    fdProcess.running = true;
  }

  function parseSearchResults(output) {
    var lines = output.trim().split("\n");
    var results = [];

    if (lines.length === 0 || (lines.length === 1 && lines[0] === "")) {
      results.push({
        "name": "No files found",
        "description": "No files matching '" + currentQuery + "'",
        "icon": "file-off",
        "isTablerIcon": true,
        "isImage": false,
        "onActivate": function() {}
      });
      currentResults = results;
      return;
    }

    for (var i = 0; i < lines.length; i++) {
      var filePath = lines[i].trim();
      if (filePath !== "") {
        results.push(formatFileEntry(filePath));
      }
    }

    currentResults = results;
    Logger.d("FileSearch", "Found", results.length, "results");
  }

  function formatFileEntry(filePath) {
    var parts = filePath.split("/");
    var filename = parts[parts.length - 1];
    var parentPath = parts.slice(0, -1).join("/");
    
    var homeDir = Quickshell.env("HOME");
    if (parentPath.startsWith(homeDir)) {
      parentPath = "~" + parentPath.slice(homeDir.length);
    }

    return {
      "name": filename,
      "description": parentPath,
      "icon": getFileIcon(filename),
      "isTablerIcon": true,
      "isImage": false,
      "singleLine": false,
      "onActivate": function() {
        root.openFile(filePath);
      }
    };
  }

  function getFileIcon(filename) {
    var ext = filename.split(".").pop().toLowerCase();
    
    // Images
    if (["jpg", "jpeg", "png", "gif", "svg", "webp", "bmp", "ico"].indexOf(ext) !== -1) {
      return "photo";
    }
    
    // Documents
    if (["txt", "md", "pdf", "doc", "docx", "odt", "rtf"].indexOf(ext) !== -1) {
      return "file-text";
    }
    
    // Code files
    if (["js", "ts", "py", "java", "cpp", "c", "h", "qml", "rs", "go", "rb", "php", "html", "css", "json", "xml", "yaml", "yml"].indexOf(ext) !== -1) {
      return "code";
    }
    
    // Archives
    if (["zip", "tar", "gz", "bz2", "xz", "7z", "rar"].indexOf(ext) !== -1) {
      return "file-zip";
    }
    
    // Audio
    if (["mp3", "wav", "flac", "ogg", "m4a", "aac", "wma"].indexOf(ext) !== -1) {
      return "music";
    }
    
    // Video
    if (["mp4", "mkv", "avi", "mov", "wmv", "flv", "webm"].indexOf(ext) !== -1) {
      return "video";
    }
    
    // Spreadsheets
    if (["xls", "xlsx", "ods", "csv"].indexOf(ext) !== -1) {
      return "table";
    }
    
    // Presentations
    if (["ppt", "pptx", "odp"].indexOf(ext) !== -1) {
      return "presentation";
    }
    
    // Default
    return "file";
  }

  function openFile(filePath) {
    Logger.i("FileSearch", "Opening file:", filePath);
    Quickshell.execDetached([fileOpener, filePath]);
    launcher.close();
  }
}
