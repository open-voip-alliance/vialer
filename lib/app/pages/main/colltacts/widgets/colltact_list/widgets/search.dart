import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../../resources/theme/brand_theme.dart';
import '../../../../../../util/brand.dart';

class SearchTextField extends StatefulWidget {
  const SearchTextField({
    required this.onChanged,
    super.key,
  });

  final void Function(String) onChanged;

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  final _searchController = TextEditingController();

  bool _canClear = false;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_handleSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  void _handleSearch() {
    setState(() {
      _canClear = _searchController.text.isNotEmpty;
    });

    widget.onChanged(_searchController.text);
  }

  void _handleClear() {
    _searchController.clear();

    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: context.brand.theme.colors.primary,
      controller: _searchController,
      decoration: InputDecoration(
        filled: true,
        fillColor: context.brand.theme.colors.grey3,
        border: const OutlineInputBorder(
          borderSide: BorderSide.none,
          gapPadding: 0,
        ),
        // Must be `Icon` and not `FaIcon` because it's expected as a square.
        prefixIcon: Icon(
          FontAwesomeIcons.magnifyingGlass,
          size: 20,
          color: context.brand.theme.colors.grey4,
        ),
        suffixIcon: _canClear
            ? IconButton(
                onPressed: _handleClear,
                icon: FaIcon(
                  FontAwesomeIcons.xmark,
                  size: 20,
                  color: context.brand.theme.colors.grey4,
                ),
              )
            : null,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
