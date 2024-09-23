import 'package:flutter/material.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: context.theme.brightness == Brightness.dark
              ? Colors.grey[600]!
              : Colors.grey[100]!,
          highlightColor: context.theme.brightness == Brightness.dark
              ? Colors.grey[700]!
              : Colors.grey[300]!,
          child: Card(
            child: ListTile(
              title: Container(
                height: 20.0,
                color: Colors.white,
              ),
              subtitle: Container(
                height: 14.0,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
