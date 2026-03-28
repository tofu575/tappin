import 'package:flutter/material.dart';

class RecordButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const RecordButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: FloatingActionButton(
        onPressed: isLoading ? null : onPressed,
        shape: const CircleBorder(),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 48),
                  SizedBox(height: 8),
                  Text('記録', style: TextStyle(fontSize: 20)),
                ],
              ),
      ),
    );
  }
}
