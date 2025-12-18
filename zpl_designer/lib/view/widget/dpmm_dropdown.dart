import 'package:flutter/material.dart';
import 'package:zpl_designer/core/dpmm.dart';

class DpmmDropdown extends StatefulWidget {
  final void Function(Dpmm)? onChanged;
  final Dpmm initialValue;

  const DpmmDropdown({
    super.key,
    this.onChanged,
    this.initialValue = Dpmm.dpmm8,
  });

  @override
  State<DpmmDropdown> createState() => _DpmmDropdownState();
}

class _DpmmDropdownState extends State<DpmmDropdown> {
  late Dpmm _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Dpmm>(
      value: _selected,
      items:
          Dpmm.values
              .map(
                (dpmm) =>
                    DropdownMenuItem(value: dpmm, child: Text(dpmm.toString())),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selected = value;
          });
          widget.onChanged?.call(value);
        }
      },
    );
  }
}
