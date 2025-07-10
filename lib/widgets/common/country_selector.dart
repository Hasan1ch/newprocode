import 'package:flutter/material.dart';
import 'package:procode/config/countries.dart';
import 'package:procode/config/app_colors.dart';

/// Custom country selector widget with search functionality
/// Provides a searchable dropdown with flag emojis for better UX
/// Used in user profiles and registration for location selection
class CountrySelector extends StatefulWidget {
  final String? selectedCountry;
  final ValueChanged<String?> onCountrySelected;
  final String? label;
  final String? hint;
  final FormFieldValidator<String>? validator;

  const CountrySelector({
    super.key,
    this.selectedCountry,
    required this.onCountrySelected,
    this.label,
    this.hint,
    this.validator,
  });

  @override
  State<CountrySelector> createState() => _CountrySelectorState();
}

class _CountrySelectorState extends State<CountrySelector> {
  late TextEditingController _searchController;
  String? _selectedCountry;
  List<String> _filteredCountries = [];
  bool _isDropdownOpen = false;
  final _focusNode = FocusNode();
  final _layerLink = LayerLink(); // Links overlay to text field
  OverlayEntry? _overlayEntry;
  final GlobalKey _fieldKey = GlobalKey(); // For positioning overlay

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedCountry = widget.selectedCountry;
    _filteredCountries = Countries.names; // Initialize with all countries
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(CountrySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update selection if parent changes it
    if (widget.selectedCountry != oldWidget.selectedCountry) {
      _selectedCountry = widget.selectedCountry;
      _searchController.text = widget.selectedCountry ?? '';
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.removeListener(_onFocusChange);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Handles focus changes to show/hide dropdown
  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _showOverlay();
    } else {
      // Delay removal to allow clicks on dropdown items
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!_focusNode.hasFocus) {
          _removeOverlay();
        }
      });
    }
  }

  /// Filters country list based on search query
  /// Updates overlay to show filtered results
  void _filterCountries(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = Countries.names;
      } else {
        // Case-insensitive search
        _filteredCountries = Countries.names
            .where((country) =>
                country.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
    _updateOverlay();
  }

  /// Handles country selection
  void _selectCountry(String country) {
    setState(() {
      _selectedCountry = country;
      _searchController.text = country;
      _isDropdownOpen = false;
    });
    widget.onCountrySelected(country);
    _removeOverlay();
    _focusNode.unfocus();
  }

  /// Shows the dropdown overlay
  void _showOverlay() {
    _removeOverlay();

    // Get text field position for overlay placement
    final RenderBox? renderBox =
        _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isDropdownOpen = true);
  }

  /// Removes the dropdown overlay
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isDropdownOpen = false);
  }

  /// Updates overlay content without recreating it
  void _updateOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  /// Creates the dropdown overlay with country list
  OverlayEntry _createOverlayEntry() {
    final RenderBox? renderBox =
        _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return OverlayEntry(builder: (_) => const SizedBox.shrink());
    }

    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _removeOverlay, // Close on outside tap
        child: Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height + 5.0, // Position below field
              width: size.width,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surface,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _filteredCountries.length,
                      itemBuilder: (context, index) {
                        final country = _filteredCountries[index];
                        final isSelected = country == _selectedCountry;
                        final countryCode = Countries.getCountryCode(country);

                        // Convert country code to flag emoji
                        // Uses Unicode regional indicator symbols
                        String flagEmoji = '';
                        if (countryCode != null && countryCode.length == 2) {
                          final firstLetter =
                              countryCode.codeUnitAt(0) - 0x41 + 0x1F1E6;
                          final secondLetter =
                              countryCode.codeUnitAt(1) - 0x41 + 0x1F1E6;
                          flagEmoji = String.fromCharCode(firstLetter) +
                              String.fromCharCode(secondLetter);
                        }

                        return InkWell(
                          onTap: () => _selectCountry(country),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            color: isSelected
                                ? Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1)
                                : null,
                            child: Row(
                              children: [
                                // Flag emoji
                                Text(
                                  flagEmoji,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 12),
                                // Country name
                                Expanded(
                                  child: Text(
                                    country,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                // Check mark for selected
                                if (isSelected)
                                  Icon(
                                    Icons.check,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Sync controller text with selection
    if (_searchController.text != (_selectedCountry ?? '')) {
      _searchController.text = _selectedCountry ?? '';
    }

    return Column(
      key: _fieldKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Optional label
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        // Search field with dropdown trigger
        TextFormField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: _filterCountries,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hint ?? 'Select your country',
            prefixIcon: const Icon(Icons.location_on_outlined),
            suffixIcon: Icon(
              _isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
