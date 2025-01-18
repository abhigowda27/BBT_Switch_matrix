import 'package:flutter/material.dart';

import '../../constants.dart';

class CustomButton extends StatelessWidget {
  CustomButton({
    super.key,
    this.width,
    this.bgmColor,
    required this.text,
    this.icon,
    required this.onPressed,
  });

  final String text;
  double? width = 300;
  Color? bgmColor = appBarColour;
  final GestureTapCallback onPressed;
  IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
      child: InkWell(
        splashColor: bgmColor,
        onTap: onPressed,
        child: Container(
          width: width,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.teal.shade600,
                Colors.purple.shade300,
                // Colors.yellow.shade400
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 1,
                color: bgmColor ?? backGroundColour,
                offset: const Offset(0, 2),
              )
            ],
            borderRadius: BorderRadius.circular(12),
            // border: Border.all(
            //   color: bgmColor ?? backGroundColourDark,
            //   width: 1,
            // ),
          ),
          alignment: const AlignmentDirectional(0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: whiteColour,
                ),
                const SizedBox(width: 8), // Add space between icon and text
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  color: whiteColour,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
