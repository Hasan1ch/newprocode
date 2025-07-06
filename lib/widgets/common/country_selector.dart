import 'package:flutter/material.dart';
import 'package:procode/config/countries.dart';
import 'package:procode/config/app_colors.dart';

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
  final _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final GlobalKey _fieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedCountry = widget.selectedCountry;
    _filteredCountries = Countries.names;
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(CountrySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
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

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _showOverlay();
    } else {
      // Delay removal to allow for click events
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!_focusNode.hasFocus) {
          _removeOverlay();
        }
      });
    }
  }

  void _filterCountries(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = Countries.names;
      } else {
        _filteredCountries = Countries.names
            .where((country) =>
                country.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
    _updateOverlay();
  }

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

  void _showOverlay() {
    _removeOverlay();

    final RenderBox? renderBox =
        _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isDropdownOpen = true);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isDropdownOpen = false);
  }

  void _updateOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }

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
        onTap: _removeOverlay,
        child: Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height + 5.0,
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
                                Text(
                                  flagEmoji,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 12),
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

    // Update controller text when selected country changes
    if (_searchController.text != (_selectedCountry ?? '')) {
      _searchController.text = _selectedCountry ?? '';
    }

    return Column(
      key: _fieldKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
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
