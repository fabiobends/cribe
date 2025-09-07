import 'package:cribe/core/constants/spacing.dart';
import 'package:cribe/ui/shared/widgets/styled_text.dart';
import 'package:flutter/material.dart';

class ComponentShowcase extends StatelessWidget {
  final String name;
  final List<Widget> variants;

  const ComponentShowcase({
    super.key,
    required this.name,
    required this.variants,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: StyledText(text: name, variant: TextVariant.title)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.medium),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _buildVariantsWithSpacing(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildVariantsWithSpacing() {
    final spacedVariants = <Widget>[];
    for (int i = 0; i < variants.length; i++) {
      spacedVariants.add(variants[i]);
      if (i < variants.length - 1) {
        spacedVariants.add(const SizedBox(height: Spacing.medium));
      }
    }
    return spacedVariants;
  }
}
