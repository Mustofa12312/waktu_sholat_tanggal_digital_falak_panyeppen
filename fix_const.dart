import 'dart:io';

void main() {
  final file = File('analyze.txt');
  final lines = file.readAsLinesSync();

  for (final line in lines) {
    if (line.contains('Invalid constant value')) {
      final parts = line.split('•');
      if (parts.length >= 3) {
        final fileInfo = parts[2].trim().split(':');
        if (fileInfo.length >= 2) {
          final filePath = fileInfo[0];
          final lineNumber = int.tryParse(fileInfo[1]);

          if (lineNumber != null) {
            final targetFile = File(filePath);
            if (targetFile.existsSync()) {
              final targetLines = targetFile.readAsLinesSync();
              final idx = lineNumber - 1;
              if (idx >= 0 && idx < targetLines.length) {
                targetLines[idx] = targetLines[idx].replaceAll('const ', '');
                targetFile.writeAsStringSync(targetLines.join('\n'));
                print('Fixed $filePath at $lineNumber');
              }
            }
          }
        }
      }
    }
  }
}
