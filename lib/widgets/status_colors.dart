import 'package:flutter/material.dart';

Color getStatusColor(String status) {
  if (status == "Heating") {
    return Colors.orange;
  } else if (status == "Floor Heating") {
    return Colors.purple;
  } else if (status == "Too Cold") {
    return Colors.blue;
  } else if (status == "Too Hot") {
    return Colors.red;
  } else {
    return Colors.green;
  }
}
