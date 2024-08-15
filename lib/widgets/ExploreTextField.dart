import 'package:flutter/material.dart';

import '../constant/constant.dart';

class ExploreTextField extends StatefulWidget {
  final TextEditingController controller;
  final List<String> suggestions;
  final String hinttext;
  final String? svgIconPath;

  ExploreTextField({
    Key? key,
    required this.controller,
    required this.suggestions,
    required this.svgIconPath,
    required this.hinttext,
  }) : super(key: key);

  @override
  _ExploreTextFieldState createState() => _ExploreTextFieldState();
}

class _ExploreTextFieldState extends State<ExploreTextField> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _showSuggestions() {
    if (_overlayEntry != null) {
      _hideSuggestions();
    }
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideSuggestions() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(10.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: widget.suggestions.map((suggestion) {
                  return ListTile(
                    leading: widget.svgIconPath != null
                        ? Image.asset(widget.svgIconPath!, width: 24, height: 24)
                        : null,
                    title: Text(suggestion),
                    onTap: () {
                      widget.controller.text = suggestion;
                      _hideSuggestions();
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(8),
                  hintText: widget.hinttext,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.indigo.shade50, width: 0.7),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.indigo.shade50, width: 1),
                  ),
                  fillColor: Colors.white.withOpacity(0.7),
                  filled: true,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.expand_more),
                    onPressed: _showSuggestions,
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
  void dispose() {
    _hideSuggestions();
    super.dispose();
  }
}
