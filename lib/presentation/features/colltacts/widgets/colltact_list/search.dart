import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';

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
    return Container(
      height: 42,
      child: Semantics(
        label: context.msg.main.contacts.search.screenReader.title,
        container: true,
        textField: true,
        excludeSemantics: true,
        child: SearchBar(
          controller: _searchController,
          leading: Icon(
            FontAwesomeIcons.magnifyingGlass,
            size: 20,
            color: context.brand.theme.colors.grey4,
          ),
          trailing: [
            if (_canClear)
              IconButton(
                onPressed: _handleClear,
                icon: FaIcon(
                  FontAwesomeIcons.xmark,
                  size: 20,
                  color: context.brand.theme.colors.grey4,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
