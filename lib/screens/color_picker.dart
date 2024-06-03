part of event_calendar;

class _ColorPicker extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ColorPickerState();
  }
}

class _ColorPickerState extends State<_ColorPicker> {
  @override
  //builds an interface that returns a list to choose appointment colors
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 245, 239, 216),
      content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            
            padding: const EdgeInsets.all(0),
            itemCount: _colorCollection?.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                contentPadding: const EdgeInsets.all(0),
                leading: Icon(
                    index == _selectedColorIndex
                        ? Icons.lens
                        : Icons.trip_origin,
                    color: _colorCollection?[index]),
                title: Text(_colorNames![index]),
                onTap: () {
                  setState(() {
                    _selectedColorIndex = index;
                  });

                  Future.delayed(const Duration(milliseconds: 200), () {
                    // When task is over, close the dialog
                    Navigator.pop(context);
                  });
                },
              );
            },
          )),
    );
  }
}