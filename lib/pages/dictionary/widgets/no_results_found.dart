import 'package:flutter/material.dart';

class NoResultsFound extends StatelessWidget {
  const NoResultsFound({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text(
      'No results found...',
      style: TextStyle(fontSize: 20.0),
    ));
  }
}
