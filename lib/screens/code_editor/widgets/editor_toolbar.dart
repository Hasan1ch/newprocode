import 'package:flutter/material.dart';

class EditorToolbar extends StatelessWidget {
  final String selectedLanguage;
  final String selectedTheme;
  final double fontSize;
  final bool wrapLines;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<String> onThemeChanged;
  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<bool> onWrapLinesChanged;
  final VoidCallback onFormat;

  const EditorToolbar({
    Key? key,
    required this.selectedLanguage,
    required this.selectedTheme,
    required this.fontSize,
    required this.wrapLines,
    required this.onLanguageChanged,
    required this.onThemeChanged,
    required this.onFontSizeChanged,
    required this.onWrapLinesChanged,
    required this.onFormat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Language Selector
          _buildDropdown(
            icon: Icons.code,
            value: selectedLanguage,
            items: ['Python', 'JavaScript', 'Java', 'HTML', 'CSS'],
            onChanged: onLanguageChanged,
            width: 120,
          ),
          SizedBox(width: 16),

          // Theme Selector
          _buildDropdown(
            icon: Icons.palette,
            value: selectedTheme,
            items: ['Light', 'Dark', 'Monokai', 'Dracula'],
            onChanged: onThemeChanged,
            width: 100,
          ),
          SizedBox(width: 16),

          // Font Size
          _buildFontSizeControl(),
          SizedBox(width: 16),

          // Format Code Button
          IconButton(
            icon: Icon(Icons.format_align_left),
            onPressed: onFormat,
            tooltip: 'Format Code',
            iconSize: 20,
          ),

          // Wrap Lines Toggle
          IconButton(
            icon: Icon(
              wrapLines ? Icons.wrap_text : Icons.horizontal_rule,
            ),
            onPressed: () => onWrapLinesChanged(!wrapLines),
            tooltip: wrapLines ? 'Disable Line Wrap' : 'Enable Line Wrap',
            iconSize: 20,
          ),

          Spacer(),

          // Settings
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              _showSettingsDialog(context);
            },
            tooltip: 'Editor Settings',
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
    required double width,
  }) {
    return Container(
      width: width,
      height: 32,
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: 4),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isDense: true,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                ),
                items: items.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) onChanged(value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFontSizeControl() {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.remove, size: 16),
            onPressed:
                fontSize > 10 ? () => onFontSizeChanged(fontSize - 1) : null,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text(
              '${fontSize.toInt()}',
              style: TextStyle(fontSize: 12),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add, size: 16),
            onPressed:
                fontSize < 24 ? () => onFontSizeChanged(fontSize + 1) : null,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editor Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.keyboard),
                title: Text('Keyboard Shortcuts'),
                subtitle: Text('View and customize shortcuts'),
                onTap: () {
                  Navigator.pop(context);
                  _showKeyboardShortcuts(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.extension),
                title: Text('Editor Extensions'),
                subtitle: Text('Enable/disable features'),
                onTap: () {
                  Navigator.pop(context);
                  // Show extensions dialog
                },
              ),
              ListTile(
                leading: Icon(Icons.color_lens),
                title: Text('Syntax Highlighting'),
                subtitle: Text('Customize colors'),
                onTap: () {
                  Navigator.pop(context);
                  // Show syntax highlighting settings
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showKeyboardShortcuts(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Keyboard Shortcuts'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildShortcut('Run Code', 'Ctrl + Enter'),
                _buildShortcut('Format Code', 'Alt + Shift + F'),
                _buildShortcut('Save', 'Ctrl + S'),
                _buildShortcut('Undo', 'Ctrl + Z'),
                _buildShortcut('Redo', 'Ctrl + Y'),
                _buildShortcut('Find', 'Ctrl + F'),
                _buildShortcut('Replace', 'Ctrl + H'),
                _buildShortcut('Comment Line', 'Ctrl + /'),
                _buildShortcut('Duplicate Line', 'Ctrl + D'),
                _buildShortcut('Delete Line', 'Ctrl + Shift + K'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShortcut(String action, String keys) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              action,
              style: TextStyle(fontSize: 14),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              keys,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
