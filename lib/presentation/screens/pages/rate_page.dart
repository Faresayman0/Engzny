import 'package:flutter/material.dart';
import 'package:gradution_project2/presentation/widgets/constant_widget.dart';
import 'package:gradution_project2/presentation/widgets/rate_widget.dart';

class RatePage extends StatelessWidget {
  const RatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        child: Column(
          children: [
            const SizedBox(
              height: 200,
              child: ConstantWidget(),
            ),
            const SizedBox(
              height: 4,
            ),
            TextField(
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'رقم السيارة',
                hintText: 'ادخل رقم السيارة',
                prefixIcon: const Icon(Icons.directions_car),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            RatingWidget(),
            const SizedBox(
              height: 12,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:   SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  
                  onPressed: () {},
                  child: const Text(
                    'اضف تقييمك',
                    style: TextStyle(fontSize: 18,),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
