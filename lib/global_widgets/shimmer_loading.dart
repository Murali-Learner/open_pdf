import 'package:flutter/material.dart';
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
          baseColor: Colors.grey[100]!,
          highlightColor: Colors.grey[300]!,
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
